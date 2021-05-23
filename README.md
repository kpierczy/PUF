# Description

The project implements simple 4-module FPGA guitar multieffect based on the Digilent Cora Z10 board with Xilinx Zynq7010 Core. It contains:
- saturation-based **distortion** module
- variable-frequency **tremolo** module
- variable-depth **delay** module
- variable-depth & variable-frequency **chorus** module
At the moment the processing core is interfaced via UART port for simplicity during development stage. In the future it is planned to add basic I2S bus support for connection to the external ADC/DAC modules.

# Version informations

- Vivado Design Suite: 2020.2
- Python: 3.9
