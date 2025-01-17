# ====================================================================================================================================
# @ Author: Krzysztof Pierczyk
# @ Create Time: 2021-05-23 17:44:54
# @ Modified time: 2021-05-23 17:44:55
# @ Description: 
#
#     Script improts IP Core source files (.xci) from the structure generated by Vivado to the configured folder
#
# ====================================================================================================================================

import os
from pathlib import Path
from shutil import copyfile
import fileinput

# Path to the root folder of the project
PROJECT_HOME = '/home/cris/Desktop/PUF'

# Output directory for source files (relative to PROJECT_HOME)
OUT_DIR = 'src/ip'

# ----------------------------------------------------------- Definitions ------------------------------------------------------------

# Create output dir's path object
outDirPath = Path(PROJECT_HOME).joinpath(OUT_DIR)

# Create output dir if needed
outDirPath.mkdir(parents=True, exist_ok=True)

# Establish directory of IP sources
ipSourceDirPath = Path(PROJECT_HOME).glob('workdir/*.srcs').__next__()

# Search for all source files
ip_sources = ipSourceDirPath.rglob('*.xci')

# Copy files to the output directory
for path in ip_sources:

    ipOutDirPath = outDirPath.joinpath(path.name.split('.')[0])

    # Create folder for the IP
    Path(ipOutDirPath).mkdir(exist_ok=True)

    ipOutFilePathStr = os.path.join(str(ipOutDirPath), path.name)

    # Copy file to the outpt directory
    copyfile(str(path), ipOutFilePathStr)

    # Open copied file
    with fileinput.FileInput(ipOutFilePathStr, inplace=True) as file:
        # Iterate over file's lines
        for line in file:
            # Replace path to the directory for outputs of IP's generation 
            print(line.replace(
                '"RUNTIME_PARAM.OUTPUTDIR">../../../../',
                '"RUNTIME_PARAM.OUTPUTDIR">../../../workdir/'                       
            ), end='')
