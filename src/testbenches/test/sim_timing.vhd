-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-20 13:52:10
-- @ Modified time: 2021-05-20 13:52:13
-- @ Description: 
--    
--    Sketch used to check whether signals set by the one process on the system clock's edge are seen as such (i.e. set) on the sam
--    clock's edge in other processes
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.sim.all;

entity SimTimingTest is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Positive := 200_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10
    );
end entity SimTimingTest;

architecture logic of SimTimingTest is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;  

    -- Clock signal
    signal clk : Std_logic := '0';
    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- Some signals
    signal A : Std_logic := '0';
    signal B : Std_logic := '0';
    signal C : Std_logic := '0';
    -- Some signals
    signal A_async : Std_logic := '0';
    signal B_async : Std_logic := '0';
    signal C_async : Std_logic := '0';

begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Clock signal
    clock_tb(CLK_PERIOD, clk);

    -- Reset signal
    reset_tb(SYS_RESET_TICKS * CLK_PERIOD, reset_n);

    -- =================================================================================
    -- Test processes (signal set on clk rising edge)
    -- =================================================================================

    -- Test B and set A appropriately
    process (reset_n, clk) is
    begin
    
        if(reset_n = '0') then
            A <= '0';
        elsif(rising_edge(clk)) then
            if(B = '1') then
                A <= '1';
            else
                A <= '0';
            end if;
        end if;

    end process;

    -- Toggle B at constant rate
    process (reset_n, clk) is
        constant PERIOD : Positive := 5;
        variable ticks : natural := 0;
    begin
    
        if(reset_n = '0') then
            ticks := 0;
            B <= '0';
        elsif(rising_edge(clk)) then
            
            B <= '0';
            ticks := ticks + 1;
            if(ticks = PERIOD - 1) then
                ticks := 0;
                B <= '1';
            end if;

        end if;

    end process;

    -- Test B and set C appropriately
    process (reset_n, clk) is
    begin
    
        if(reset_n = '0') then
            C <= '0';
        elsif(rising_edge(clk)) then
            if(B = '1') then
                C <= '1';
            else
                C <= '0';
            end if;
        end if;

    end process;

    -- =================================================================================
    -- Test processes (signal set with `wait`)
    -- =================================================================================

    -- Test B and set A appropriately
    process is
    begin
    
        -- Reset condition
        A_async <= '0';
        -- Wait for first rising edge after reset
        wait until reset_n = '1';
        wait until rising_edge(clk);
        -- Set signals every rising edge
        loop
            if(B_async = '1') then
                A_async <= '1';
            else
                A_async <= '0';
            end if;
            wait for CLK_PERIOD;
        end loop;

    end process;

    -- Toggle B at constant rate
    process is
        constant PERIOD : Positive := 5;
        variable ticks : natural := 0;
    begin
    
        -- Reset condition
        B_async <= '0';
        -- Wait for first rising edge after reset
        wait until reset_n = '1';
        wait until rising_edge(clk);
            -- Set signals every rising edge
        loop
            B_async <= '0';
            ticks := ticks + 1;
            if(ticks = PERIOD - 1) then
                ticks := 0;
                B_async <= '1';
            end if;

            wait for CLK_PERIOD;
        end loop;

    end process;

    -- Test B and set C appropriately
    process is
    begin
    
    
        -- Reset condition
        C_async <= '0';
        -- Wait for first rising edge after reset
        wait until reset_n = '1';
        wait until rising_edge(clk);
        -- Set signals every rising edge
        loop
            if(B_async = '1') then
                C_async <= '1';
            else
                C_async <= '0';
            end if;
            wait for CLK_PERIOD;
        end loop;

    end process;

end architecture logic;
