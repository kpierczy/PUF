-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-28 03:13:37
-- @ Modified time: 2021-05-28 03:13:38
-- @ Description: 
--    
--    Configruation of the samples' receiver/transmitter modules.
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.uart.all;

package transreceiver_config is

    -- Width (in bits) of the single byte
    constant CONFIG_TRANSRECEIVER_BYTE_SIZE : Positive := 8;

    -- Tranmission's baudrate
    constant CONFIG_TRANSRECEIVER_BAUD_RATE : Positive := 20_000_000;

    -- Usage of the parity bit
    constant CONFIG_TRANSRECEIVER_PARITY_USED : Std_logic := '1';

    -- Transmission's parity
    constant CONFIG_TRANSRECEIVER_PARITY_TYPE : ParityType := EVEN;

    -- Number of stopbits
    constant CONFIG_TRANSRECEIVER_STOP_BITS : Positive := 1;

    -- Signal negation on the serial line
    constant CONFIG_TRANSRECEIVER_SIGNAL_NEGATION : Std_logic := '1';

    -- Data negation on the serial line
    constant CONFIG_TRANSRECEIVER_DATA_NEGATION : Std_logic := '1';

end package transreceiver_config;
