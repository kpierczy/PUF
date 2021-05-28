# Description

The project aims to implement simple 5-module FPGA guitar multieffect based on the Digilent Cora Z10 board with Xilinx Zynq 7010 Core. It is going to contain contains:

- saturation-based **distortion** module
- parametrizable-modulation-frequency **tremolo** module
- parametrizable-frequency of modulation-frequency **tremolo** module (non-implemented yet)
- parametrizable-depth **delay** module
- parametrizable-depth & parametrizable-frequency **chorus** module

At the moment the processing core is interfaced via UART port for simplicity during development stage. In the future it is planned to add basic I2S bus support for connection to the external ADC/DAC modules.

# To do

1. Implement **tremolo** module with sinusoidally changing modulation's frequency

# Version informations

- Vivado Design Suite: 2020.2
- Python: 3.9
