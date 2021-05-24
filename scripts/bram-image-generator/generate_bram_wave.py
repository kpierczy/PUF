# ====================================================================================================================================
# @ Author: Krzysztof Pierczyk
# @ Create Time: 2021-05-21 00:34:48
# @ Modified time: 2021-05-21 00:34:49
# @ Description: 
#
#     Script used to generate ASCII file appropriate for initializing BRAM module with samples of the predefined function.
#     Output of this script can be used along with `xilinx-coe-generator` (source below) to create .coe file directly 
#     used to initialize BRAM.
#
# @ See: https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_3/ug901-vivado-synthesis.pdf#page=146
# @ See: https://github.com/kooltzh/xilinx-coe-generator
# @ Note: Scripts egnerates samples' representation with radix equal to 16 (hexadecimal system)
# ====================================================================================================================================

import math
import numpy as np
import os
from pathlib import Path

# ---------------------------------------------------------- Configuration -----------------------------------------------------------

# Path to the output file
FILE_PATH = "data/tremolo-effect-bram/tremolo_effect_bram.txt"

# If true, an additional MIF file representation is generated
MIF_FILE = True
# Number of bits in MIF representation
MIF_BITS = 16

# If true, an additional file with human-readable representation of samples will be produced
HUMAN_READABLE_FILE = True

# Address offset of samples in BRAM
ADDRESS_OFFSET = 0

# Type of wave (at now only 'sin', 'saw')
WAVE_TYPE = 'sin'

# Coefficient that the sample is multiplied before being converted to the file representation
GAIN = 2**15 - 1

# Shift of the generated wave (before gain)
SHIFT = 1

# Number of samples to be generated
SAMPLES_NUM = 129

# Function's argument's range to be taken into account (both sides inclusively)
ARG_RANGE = (0, math.pi / 2)

# ----------------------------------------------------------- Definitions ------------------------------------------------------------

def saw(arg):
    # Compute function's region
    region = np.math.floor(arg) % 4
    # Compute arg's offset from the region start
    offset = arg - np.math.floor(arg)
    # Return value depending on region
    if region == 0:
        return offset
    elif region == 1:
        return 1 - offset
    elif region == 2:
        return - offset
    elif region == 3:
        return -1 + offset
    
def get_sample(fun : str, arg : float):

    # Select function
    if fun == 'sin':
        return math.sin(arg)
    # elif fun == 'saw':
    #     return saw(arg)

# -------------------------------------------------------------- Logic ---------------------------------------------------------------

# Create output folder (otionally)
folder_name = os.path.dirname(FILE_PATH)
if len(folder_name) != 0:
    Path(folder_name).mkdir(parents=True, exist_ok=True)

# Open output file
file = open(FILE_PATH, 'w')
# Optionally, open MIF file
mif_file = None
if MIF_FILE:
    file_name_no_ext = FILE_PATH.split('.')[0]
    mif_file = open(file_name_no_ext  + '.mif', 'w')
# Optionally, open auxiliary file
aux_file = None
if HUMAN_READABLE_FILE:
    file_name_no_ext = FILE_PATH.split('.')[0]
    aux_file = open(file_name_no_ext  + '_hr.txt', 'w')

# Generate list of desired sample's arguments
args = np.linspace(ARG_RANGE[0], ARG_RANGE[1], SAMPLES_NUM)

# Write address offset
file.write(f'0x{ADDRESS_OFFSET:X} = ')

# Generate subsequent lines (samples) into the file
for i in range(0, SAMPLES_NUM):

    # Get sample
    sample = int((get_sample(WAVE_TYPE, args[i]) + SHIFT) * GAIN)

    # Print sample's representation to the file
    file.write(f'{sample:X}')

    # Optionally, write MIF representation to the auxiliriaty file
    if MIF_FILE:
        mif_file.write(f'{sample:0{MIF_BITS}b}')

    # Optionally, write human-readable representation to the auxiliriaty file
    if HUMAN_READABLE_FILE:
        aux_file.write(f'{sample}')

    # On all but last sample write new line character
    if i != SAMPLES_NUM - 1:
        file.write('\n')
        if MIF_FILE:
            mif_file.write('\n')
        if HUMAN_READABLE_FILE:
            aux_file.write('\n')

# Close output file
file.close()
# Optionally, close auxiliary file
if MIF_FILE:
    mif_file.close()
# Optionally, close auxiliary file
if HUMAN_READABLE_FILE:
    aux_file.close()
