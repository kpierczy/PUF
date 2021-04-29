-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-26 00:56:13
-- @ Modified time: 2021-04-26 00:56:23
-- @ Description: 
--    
--    Timer's package testbench
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity pulse_generator_tb is
end entity pulse_generator_tb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of pulse_generator_tb is
     
    -- Type of signal generation
    type Generation is (SCHEDULED, RANDOM);

    -- System clock period
    constant CLK_PERIOD : Time := 20 ns;
    
     -- MIN time between random toggles of the enable signal
     constant MIN_ENABLE_TOGGLE_TIME : Time := 10 ns;
     -- Max time between random toggles of the enable signal
     constant MAX_ENABLE_TOGGLE_TIME : Time := 10_000 ns;
     -- MIN time between random toggles of the timer's limit value
     constant MIN_LIMIT_RANDOMIZE_TIME : Time := 10 ns;
     -- Max time between random toggles of the timer's limit value
     constant MAX_LIMIT_RANDOMIZE_TIME : Time := 10_000 ns;
     
     -- Width of the cocunter
     constant COUNTER_WIDTH : Positive := 3;
     -- State of the timer's output when active
     constant OUTPUT_ACTIVE : Std_logic := '1';
     
    -- Reset (asynchronous)
    signal reset_n	: Std_logic;
    -- Clock    
    signal clk : Std_logic := '0';
    -- Enabling signal (active high)
    signal enable : Std_logic := '0';
    -- Timer counter's limtit value
    signal limit : Unsigned(COUNTER_WIDTH - 1 downto 0) := (others => '0');

    -- Timer's pulse
    signal overflow : Std_logic := '0';

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
    couter_inst: entity work.PulseGenerator(logic)
    generic map (
        OUTPUT_ACTIVE => OUTPUT_ACTIVE,
        COUNTER_WIDTH => COUNTER_WIDTH
    )
    port map (
        reset_n  => reset_n,
        clk      => clk,
        enable   => enable,
        limit    => limit,
        overflow => overflow
    );
    
    -- Enable signal's path
    process is
        -- State of the egnerating machine
        variable gen : Generation := SCHEDULED;
    begin
        -- Planned generation
        if(gen = SCHEDULED) then

            -- Perform planned path
            enable <= '1';
            wait for CLK_PERIOD * 15.5;
            enable <= '0';
            wait for CLK_PERIOD;
            enable <= '1';
            wait for (2**COUNTER_WIDTH - 1) * CLK_PERIOD;
            enable <= '0';
            wait for CLK_PERIOD;
            enable <= '1';
            wait for CLK_PERIOD;

            -- Switch to random generation
            gen := RANDOM;

        -- Random generation
        else
            enable <= not enable;
            wait for rand_time(MIN_ENABLE_TOGGLE_TIME, MAX_ENABLE_TOGGLE_TIME);
        end if;
    end process;

    -- Limit value's path
    process is
        -- State of the egnerating machine
        variable gen : Generation := SCHEDULED;
    begin
        -- Planned generation
        if(gen = SCHEDULED) then

            -- Perform planned path
            limit <= to_unsigned(0, COUNTER_WIDTH);
            wait for CLK_PERIOD * 15.5;
            limit <= to_unsigned(0, COUNTER_WIDTH);
            wait for CLK_PERIOD;
            limit <= to_unsigned(2**COUNTER_WIDTH - 1, COUNTER_WIDTH);
            wait for (2**COUNTER_WIDTH - 1) * CLK_PERIOD;

            -- -- Switch to random generation
            gen := RANDOM;

        -- Random generation
        else
            limit <= Unsigned(rand_logic_vector(COUNTER_WIDTH));
            wait for rand_time(MIN_LIMIT_RANDOMIZE_TIME, MAX_LIMIT_RANDOMIZE_TIME);
        end if;
    end process;

end architecture logic;
