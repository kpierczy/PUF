# Description

The project implements simple 4-module FPGA guitar multieffect based on the Digilent Cora Z10 board with Xilinx Zynq7010 Core. It contains:
- saturation-based **distortion** module (implemented)
- parametrizable-modulation-frequency **tremolo** module (implemented)
- parametrizable-frequency of modulation-frequency **tremolo** module
- parametrizable-depth **delay** module
- parametrizable-depth & parametrizable-frequency **chorus** module
At the moment the processing core is interfaced via UART port for simplicity during development stage. In the future it is planned to add basic I2S bus support for connection to the external ADC/DAC modules.

# To do

1. Extend **tremolo** module with *depth* parameter
2. Implement **tremolo** module with sinusoidal changing modulation's frequency
3. Implement **delay** module
3. Implement **chorus** module

# Version informations

- Vivado Design Suite: 2020.2
- Python: 3.9
