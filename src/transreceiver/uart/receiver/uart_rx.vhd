-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-26 17:19:40
-- @ Modified time: 2021-04-26 17:19:57
-- @ Description: 
--    
--    Implementation of the UART receiver module
--    
-- @ Note: 'not buffered internally' means 'don't touch when module is busy'
-- ===================================================================================================================================

-- ===================================================================================================================================
-- A generic UART receiver with adjustable baudrate and oversampling rate
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.uart.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity UartRx is

    generic(
        -- Data width
        DATA_WIDTH : Positive range 5 to 8;
        -- Width of the @in baud_rate input
        BAUD_RATE_WIDTH : Positive;
        -- Parity usage
        PARITY_USED : Std_logic;
        -- Parity type
        PARITY_TYPE : Parity;
        -- Number of stopbits
        STOP_BITS : Positive range 1 to 2;
        -- Signal negation (Defaults to standard RS-232, i.e. negated signal and data)
        SIGNAL_NEGATION : Std_logic := '1';
        -- Data negation (Defaults to standard RS-232, i.e. negated signal and data)
        DATA_NEGATION : Std_logic := '1'
    );
    port(
        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;
        -- Ration of the @in clk frequency to the baud frequency (minus 1) (not buffered internally!)
        baud_rate : in Unsigned(BAUD_RATE_WIDTH - 1 downto 0);
        -- Oversampling choice (not buffered internally!)
        ovs : in UartOvs;
        -- Receiver enable signal (active high) (@in rx signal is not sampled, when @in enable's pulled low)
        enable : in Std_logic;
        -- Serial input 
        rx : in Std_logic;
        
        -- 'Module busy' signal (active high)
        busy : out Std_logic;
        -- Eror flags (active high) (if error occured, flag is set for the single @in clk cycle when @out busy goes low)
        err : out UartErrors;
        -- Data to be transfered (latched on @in clk rising edge when @in enable high and @out busy low)
        data : out Std_logic_vector(DATA_WIDTH - 1 downto 0)
    );

end entity UartRx;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------