# ====================================================================================================================================
# @ Author: Krzysztof Pierczyk
# @ Create Time: 2021-05-23 17:44:54
# @ Modified time: 2021-05-23 17:44:55
# @ Description: 
#
#     Simple generator of the analog stimulus file for Vivado XADC simulations.
#
# @ Note: Time stamps are assummed to be in [ns] and signal's value in [V].
# ====================================================================================================================================

import os
import math
import numpy as np
from pathlib import Path

# Path to the root folder of the project
OUTPUT_FILE = 'data/xadc-analog-input.txt'

# Width of the single columnt
COLUMN_WIDTH = 11

# Signal's frequency [Hz]
SIGNAL_FREQUENCY_HZ = 100

# Precision of the sample's value
SAMPLE_PRECISION = 6

# PWM signal generator
def pwm(time, freq, width, shift, amplitude):
    """
    Generator of the PWM signal

    Arguments
    ---------
    freq : float
        frequency of the pwm in [Hz]
    width : float
        width of the 'high' signal in normalized range <0,1>
    shift : float
        phase shift in normalized range <0,1>
    amplitude : float
        wave's amplitude
    time : float
        time of the requested wave's value in [s]
    
    Returns
    -------
    value of the pwm wave at given @in time
    
    """

    # Calculate wave's period
    period = 1 / freq

    # Calculate offset of the @in time from start of PWM's period
    time_offset = (time - shift * period) % period

    # Return 1.0 or 0.0 depending on the phase
    if(time_offset <= width * period):
        return 1.0 * amplitude
    else:
        return 0.0

# Simulation's length [ms]
SIM_LENGTH = 60

# Signal's sampling frequency
SIM_FREQ = 200_000

# List of functions associated with subsequent signals
signals = {
    "TEMP"     : None,
    "VCCINT"   : None,
    "VCCBRAM"  : None,
    "VCCPINT"  : None,
    "VCCPAUX"  : None,
    "VCCDDRO"  : None,
    "VCCAUX"   : None,
    "VP"       : None,
    "VN"       : None,
    "VAUXP[0]" : lambda time: pwm(time, freq = 50, width = 1.0, shift = 0.0, amplitude = 1.0),
    "VAUXN[0]" : None,
    "VAUXP[1]" : None,
    "VAUXN[1]" : None,
    "VAUXP[2]" : None,
    "VAUXN[2]" : None,
    "VAUXP[3]" : None,
    "VAUXN[3]" : None,
    "VAUXP[4]" : None,
    "VAUXN[4]" : None,
    "VAUXP[5]" : None,
    "VAUXN[5]" : None,
    "VAUXP[6]" : None,
    "VAUXN[6]" : None,
    "VAUXP[7]" : None,
    "VAUXN[7]" : None,
    "VAUXP[8]" : None,
    "VAUXN[8]" : None,
    "VAUXP[9]" : None,
    "VAUXN[9]" : None,
    "VAUXP[10]" : None,
    "VAUXN[10]" : None,
    "VAUXP[11]" : None,
    "VAUXN[11]" : None,
    "VAUXP[12]" : None,
    "VAUXN[12]" : None,
    "VAUXP[13]" : None,
    "VAUXN[13]" : None,
    "VAUXP[14]" : None,
    "VAUXN[14]" : None,
    "VAUXP[15]" : None,
    "VAUXN[15]" : None
}

# ---------------------------------------------------------- Script's body -----------------------------------------------------------

# Create output folder (otionally)
folder_name = os.path.dirname(OUTPUT_FILE)
if len(folder_name) != 0:
    Path(folder_name).mkdir(parents=True, exist_ok=True)

# Open output file
file = open(OUTPUT_FILE, 'w')

# Print file's header
file.write('TIME'.ljust(COLUMN_WIDTH))
for key, item in signals.items():
    file.write(key.rjust(COLUMN_WIDTH))
# End line with '\\'
file.write('\n')

# Prepare list of timestamps to produce [ns]
time_stamps = np.linspace(0, SIM_LENGTH * 1_000_000, num = int(SIM_LENGTH / 1000 * SIM_FREQ) + 1)

# Print subsequent timestamps
for stamp in time_stamps:
    # Print stamp
    file.write(str(int(stamp)).ljust(COLUMN_WIDTH))
    # Print subsequent signals' values
    for key, elem in signals.items():
        if(elem is not None):
            file.write(f'{elem(stamp / 1_000_000_000):.0{SAMPLE_PRECISION}f}'.rjust(COLUMN_WIDTH))
        else:
            file.write(f'{0:.0{SAMPLE_PRECISION}f}'.rjust(COLUMN_WIDTH))
    # End line with '\\'
    file.write('\n')
