-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-23 22:35:50
-- @ Modified time: 2021-04-23 22:37:26
-- @ Description:
-- 
--     Uart package's testbench 
--
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.uart.all;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity uart_tb is
    generic(
        -- Data width
        DATA_WIDTH : Positive := 8;

        -- Min time between random toggles of the input data
        MIN_DATA_TOGGLE_TIME : Time := 10 ns;
        -- Max time between random toggles of the input data
        MAX_DATA_TOGGLE_TIME : Time := 1000 ns;

        -- Min time between random toggles of the parity
        MIN_PARITY_TOGGLE_TIME : Time := 10 ns;
        -- Max time between random toggles of the parity
        MAX_PARITY_TOGGLE_TIME : Time := 1000 ns
    );
end entity uart_tb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of uart_tb is

    -- Actual parity
    signal parity_type : Parity := EVEN;
    -- Counter value
    signal data : Std_logic_vector(DATA_WIDTH - 1 downto 0);
    -- Parity bit
    signal parity_bit : Std_logic;

begin
    
    -- =================================================================================
    -- Parity generation test
    -- =================================================================================
    
    -- Parity generation
    parity_bit <= parity_gen(data, parity_type);

    -- Data generation
    process is
    begin
        data <= rand_logic_vector(DATA_WIDTH);
        wait for rand_time(MIN_DATA_TOGGLE_TIME, MAX_DATA_TOGGLE_TIME);
    end process;

    -- Parity type generation
    process is
    begin
        parity_type <= EVEN when (rand_logic_vector(1) = "1") else ODD;
        wait for rand_time(MIN_PARITY_TOGGLE_TIME, MAX_PARITY_TOGGLE_TIME);
    end process;

end architecture logic;
