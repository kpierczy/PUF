-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-21 00:18:59
-- @ Modified time: 2021-05-21 00:19:10
-- @ Description: 
--    
--    Triangle generator's testbench
--    
-- ===================================================================================================================================

library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity TriangleGeneratorTb is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Positive := 100_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- Width of the single sample
        SAMPLE_WIDTH : Positive := 8;

        -- Frequency of the wave signal (rounded to the natural fraction of the SYS_CLK_HZ)
        WAVE_FREQ_HZ : Positive := 2000
    );
end entity TriangleGeneratorTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of TriangleGeneratorTb is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;
    -- Number of system clock's ticks per generated sample
    constant SYS_TICKS_PER_SAMPLE : Positive := SYS_CLK_HZ / (WAVE_FREQ_HZ * 2**SAMPLE_WIDTH * 2);

    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- ====================== Module's interface ====================== --

    -- Next clk's cycle after `sample_clk`'s rising edge a new sample is read from memory
    signal en_in : Std_logic;
    -- Data lines
    signal sample_out_raw : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    signal sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);

    -- ===================== Verification signals ===================== --

    -- Desired value of sample
    signal sample_expected : Signed(SAMPLE_WIDTH - 1 downto 0);

begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Clock signal
    clock_tb(CLK_PERIOD, clk);

    -- Reset signal
    reset_tb(SYS_RESET_TICKS * CLK_PERIOD, reset_n);

    -- =================================================================================
    -- Module's instance
    -- =================================================================================

    -- Instance of the triangle generator's module
    triangleGeneratorInstance : entity work.TriangleGenerator(logic)
    generic map (
        SAMPLE_WIDTH => SAMPLE_WIDTH
    )
    port map (
        reset_n       => reset_n,
        clk           => clk,
        en_in         => en_in,
        sample_out    => sample_out_raw
    );

    -- Convert bitvector to number
    sample_out <= signed(sample_out_raw);

    -- =================================================================================
    -- Procedure's validation
    -- =================================================================================

    -- Samples generating process
    process is
        variable ticks_since_last_sample : natural;
    begin

        -- Keep module inactive
        en_in <= '0';
        -- Reset ticks' counter
        ticks_since_last_sample := SYS_TICKS_PER_SAMPLE - 1;

        -- Wait for end of reset
        wait until reset_n = '1';

        -- Validate module's output in loop
        loop

            -- Wait for next rising edge
            wait until rising_edge(clk);
            -- Check whether next sample is ot be generated
            if(ticks_since_last_sample = SYS_TICKS_PER_SAMPLE - 1) then
                en_in <= '1';
                ticks_since_last_sample := 0;
            else
                en_in <= '0';
                ticks_since_last_sample := ticks_since_last_sample + 1;
            end if;
            
        end loop;

    end process;

    -- Validate Module
    process is
        -- Actual direction of the counter
        type Dir is (UP, DOWN);
        variable direction : Dir;
        -- Counter value
        variable counter : Signed(SAMPLE_WIDTH - 1 downto 0);
    begin

        -- Reset validation signals 
        sample_expected <= (others => '0');
        -- Reset counter
        counter := (others => '0');
        -- Initialize direction
        direction := UP;

        -- Wait for end of reset
        wait until reset_n = '1';

        -- Validate module's output in loop
        loop

            -- Wait for change of the generator's output
            wait until sample_out'event;
            -- Wait for the next falling clk's edge after
            wait until falling_edge(clk);

            -- Test counter's direction
            if(direction = UP) then
                
                -- Increment counter
                counter := counter + 1;
                -- Change direction if required
                if(counter = 2**(SAMPLE_WIDTH - 1) - 1) then
                    direction := DOWN;
                end if;

            else

                -- Decrement counter
                counter := counter - 1;
                -- Change direction if required
                if(counter = - 2**(SAMPLE_WIDTH - 1)) then
                    direction := UP;
                end if;

            end if;

            -- Compare expected output with actual
            if(sample_out /= counter) then
                sample_expected <= (others => 'X');
            else
                sample_expected <= counter;
            end if;

        end loop;
        
    end process;

end architecture logic;
