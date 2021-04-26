-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-23 22:35:50
-- @ Modified time: 2021-04-23 22:37:26
-- @ Description:
-- 
--     Counter package's testbench 
--
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity counter_tb is
end entity counter_tb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of counter_tb is
     
     -- System clock period
     constant CLK_PERIOD : Time := 20 ns;
     
     -- Min time between random toggles of the clear signal
     constant MIN_CLEAR_TOGGLE_TIME : Time := 10 ns;
     -- Max time between random toggles of the clear signal
     constant MAX_CLEAR_TOGGLE_TIME : Time := 100_000 ns;
     -- MIN time between random toggles of the enable signal
     constant MIN_ENABLE_TOGGLE_TIME : Time := 10 ns;
     -- Max time between random toggles of the enable signal
     constant MAX_ENABLE_TOGGLE_TIME : Time := 100_000 ns;
     
     -- Width of the shift register
     constant REGISTER_WIDTH : Positive := 8;
     
     -- Max value of the cocunter
     constant COUNTER_MAX_VAL : Unsigned(COUNTER_WIDTH - 1 downto 0) := to_unsigned(2**COUNTER_WIDTH - 2, COUNTER_WIDTH);
     
    -- Reset (asynchronous)
    signal reset_n	: Std_logic;
    -- Clock    
    signal clk : Std_logic := '0';
    -- Clear signal (active high)
    signal clear : Std_logic := '0';
    -- Enabling signal (active high)
    signal enable : Std_logic := '0';

    -- Counter value
    signal counter : Unsigned(COUNTER_WIDTH - 1 downto 0);

begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Reset signal
    reset_n <= '0', '1' after CLK_PERIOD;

    -- Clock signal
    clk <= not clk after CLK_PERIOD / 2 when reset_n /= '0' else '0';
    
    -- =================================================================================
    -- Counter test
    -- =================================================================================
    
    -- Counter instance
    couter_inst: entity work.Counter(logic)
    generic map (
        COUNTER_WIDTH => COUNTER_WIDTH
    )
    port map (
        reset_n => reset_n,
        clk     => clk,
        enable  => enable,
        clear   => clear,
        counter => counter
    );
    
    -- Random clear signal
    clear <= not clear after rand_time(MIN_CLEAR_TOGGLE_TIME, MAX_CLEAR_TOGGLE_TIME);

    -- Random enable signal
    enable <= not enable after rand_time(MIN_ENABLE_TOGGLE_TIME, MAX_ENABLE_TOGGLE_TIME);

end architecture logic;
