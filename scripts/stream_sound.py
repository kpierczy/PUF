# ====================================================================================================================================
# @ Author: Krzysztof Pierczyk
# @ Create Time: 2021-05-26 03:29:48
# @ Modified time: 2021-05-26 03:29:49
# @ Description: 
#
#     The script can be used to stream a WAVE sound file though the serial port and stream returning data to the playing device
#     like speakers or headphones. It is used to test the `GuitarMultieffec` FPGA project via the USB <-> UART interface.
#
# @ Note: This script uses `python-sounddevice` library which depends on `libportaudio2` apt package
# @ Note: Script assumes that the sound file is recorded with 16-bit samples and sampling-rate of 48000 Hz.
# ====================================================================================================================================

# Queue is used as a processed data buffer
import enum
import queue
# Serial port
import serial
# System library for stderr
import sys
# Byte-packing samples
import struct
# Threading library for synchronisation obejcts (Event)
import threading
# Just numpy
import numpy as np
# Playing audio streams
import sounddevice as sd
# Loading WAV files
from scipy.io import wavfile
# Measurements of the processing speed
from datetime import date, datetime

# ----------------------------------------------------------- Configuration ----------------------------------------------------------

# =====================================================
# --------- Serial-port-related configuration ---------
# =====================================================

# Name of the serial port
SERIAL_NAME = '/dev/ttyUSB0'

# Communication baud rate
SERIAL_BAUD_RATE = 3_000_000

# Parity used
SERIAL_PARITY = serial.PARITY_NONE

# =====================================================
# ------------ Sound-related configuration ------------
# =====================================================

# Output file (not save when None)
OUTPUT_FILE = "data/sound_processed.wav"

# Path to the input file
SOUND_FILE_PATH = "data/sound.wav"

# Samples type
SAMPLE_TYPE = 'int16'

# Processed channels (either 'mono_l' or 'mono_r')
SAMPLE_CHANNELS = 'mono_l'

# Data endianness
SAMPLE_ENDIANNESS = 'little'

# Sample rate
SAMPLE_RATE = 48000

# Streaming block size (number of frames - i.e. samples - per fetching unit)
BLOCK_SIZE = 2500

# Size of the buffer betwen thread producing data and callback function pushing it to the stream
BUFFER_SIZE = 20

# ----------------------------------------------------------- Global objects ---------------------------------------------------------

# Create buffer to keep processed data from the serial port
q = queue.Queue(maxsize=BUFFER_SIZE)

# Create event used to signal end of sound
event = threading.Event()

# ------------------------------------------------------------- Callbacks ------------------------------------------------------------

# Define callback function passing processed data to the output sound stream
def callback(outdata, frames, time, status):

    # Sanity check - block size should be as configured
    assert frames == BLOCK_SIZE

    # Stop playing if callback does not keep up with demands for played samples
    if status.output_underflow:
        print('[ERROR] Output underflow: increase blocksize?', file=sys.stderr)
        raise sd.CallbackAbort
    
    # If no underflow condition occures no other error really should
    assert not status

    # Try to get data from queue
    try:
        data = q.get_nowait()
    # If queue is empty return empty sample
    except queue.Empty as e:
        outdata[:] = np.zeros(outdata.shape, dtype=outdata.dtype)
        print('[ERROR] Buffer is empty: increase buffersize?', file=sys.stderr)
        return
    
    # Check whether data to play ended
    if len(data) < len(outdata):
        # Copy actual data
        outdata[:len(data)] = data
        # Fille rest of buffer with zeros
        outdata[len(data):] = np.zeros((len(outdata) - len(data), outdata.shape[1]), dtype=outdata.dtype)
        # Stop playing
        raise sd.CallbackStop
    # Otherwise copy data to the output stream
    else:
        outdata[:] = data

# Define function used to convert block of samples via serial interface
def process_block(ser, unprocessed_data, timeout):
    
    start = datetime.now()

    # Prepare output buffer
    data = np.empty(shape=unprocessed_data.shape, dtype = unprocessed_data.dtype)

    # Establish single sample's length
    slength = unprocessed_data.dtype.itemsize

    # Prepare buffer for byt-represented samples
    unprocessed_data_raw = np.empty(shape=unprocessed_data.shape[0] * slength, dtype='uint8')

    # Convert samples to raw bytes
    for i, sample in enumerate(unprocessed_data):

        # Select channel to be processed
        sample_chn = None
        if SAMPLE_CHANNELS == 'mono_l':
            sample_chn = sample[0]
        else:
            sample_chn = sample[1]
        
        # Convert sample to array of bytes
        sample_bytes = bytearray(int(sample_chn).to_bytes(np.dtype(SAMPLE_TYPE).itemsize, SAMPLE_ENDIANNESS, signed=True))

        # Add bytes to the buffor to be processed
        for j in range(slength):
            unprocessed_data_raw[slength * i + j] = sample_bytes[j]

    # Send samples to be processed
    ser.write(bytearray(unprocessed_data_raw))

    # Read processed samples
    processed_data_raw = ser.read(unprocessed_data_raw.shape[0])

    # Combine bytes into samples
    for i in range(data.shape[0]):

        # Convert sample to int
        data[i][0] = int.from_bytes(processed_data_raw[slength * i:slength * i + slength], SAMPLE_ENDIANNESS, signed=True)
        # Write sample to the other channel
        data[i][1] = data[i][0]

    # Push sample to the buffer
    while q.full():
        pass
    if timeout is None:
        q.put_nowait(data)
    else:
        q.put(data, timeout=timeout)

    # Report processing speed if lowe than samplingrate
    speed = len(unprocessed_data) / (datetime.now() - start).total_seconds()
    if speed < SAMPLE_RATE:
        print(f'Processing time under the samplerate: {int(speed / 1000)} KS/S')

    return data


# ---------------------------------------------------------- Data processing ---------------------------------------------------------

# Open sound file
samplerate, unprocessed_data = wavfile.read(SOUND_FILE_PATH)

# Convert data to requested type
unprocessed_data = unprocessed_data.astype(SAMPLE_TYPE)

# Prepare output data array if output file requested
processed_data = None
if OUTPUT_FILE is not None:
    processed_data = np.zeros(unprocessed_data.shape, dtype=SAMPLE_TYPE)

# Check whether file's sampling rate is equal to expected
if samplerate != SAMPLE_RATE:
    print(f'[ERROR] Unexpected samplerate ({samplerate} Hz)', file=sys.stderr)
    exit(1)

# Initialize number of processed samples
processed_samples = 0

# Open serial port
with serial.Serial(SERIAL_NAME, SERIAL_BAUD_RATE, parity=SERIAL_PARITY) as ser:

    try:

        # Fill buffer with initial samples
        print("[INFO] Initial buffering...")
        for _ in range(BUFFER_SIZE):

            # Process block of samples
            data = process_block(ser, unprocessed_data[processed_samples:processed_samples + BLOCK_SIZE], None)

            # Save processed data
            if OUTPUT_FILE is not None:
                processed_data[processed_samples:processed_samples + BLOCK_SIZE] = data

            # Update number of processed samples
            processed_samples = processed_samples + BLOCK_SIZE

        # Create an output stream to play data
        print("Creating stream...")
        stream = sd.OutputStream(
            samplerate=samplerate, blocksize=BLOCK_SIZE, 
            channels=2, dtype=SAMPLE_TYPE,
            callback=callback, finished_callback=event.set)

        # Start regular data processing
        print("Starting stream")
        with stream:

            # Compute timeout for streaming process to play a single buffer
            timeout = BLOCK_SIZE * BUFFER_SIZE / samplerate

            # Process data block by block and put it into stream
            while data is not None:

                # Process block of samples
                data = process_block(ser, unprocessed_data[processed_samples:processed_samples + BLOCK_SIZE], timeout)

                # Save processed data
                if OUTPUT_FILE is not None:
                    processed_data[processed_samples:processed_samples + BLOCK_SIZE] = data

                # Update number of processed samples
                processed_samples = processed_samples + BLOCK_SIZE

            # Wait for end of playing
            event.wait()

    except:
        pass

    # Write processed file
    print(f"\nWritting processed data to the file: {OUTPUT_FILE}")
    wavfile.write(OUTPUT_FILE, SAMPLE_RATE, processed_data[0:processed_samples])
    
