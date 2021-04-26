-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-25 21:09:17
-- @ Modified time: 2021-04-25 21:09:20
-- @ Description: 
--    
--     Implementation of the standard pulse-generating timers
--    
-- ===================================================================================================================================

-- ===================================================================================================================================
-- A generic pulse-generating timer with synchronous enable input and limit value. Internal counter gets cleared when the @in enable
-- input is hold low on the rising edge of the @in clk signal. On the next rising edge after the counter's value is equal @in limit
-- value, the counter is reset to 0 and @out overflow output is pulled active state up to the next rising edge (assuming @in enable
-- is set high when counter resets).
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity Timer is

    generic(
        -- Active state of the @out overflow output
        OUTPUT_ACTIVE : Std_logic := '1';
        -- Counter's width
        COUNTER_WIDTH : Positive := 8
    );
    port(

        -- Reset (asynchronous)
        reset_n	: in Std_logic;
        -- Clock    
        clk : in Std_logic;
        -- Enabling signal (active high)
        enable : in Std_logic;
        -- Limit value
        limit : in Unsigned (COUNTER_WIDTH - 1 downto 0);

        -- Timer value
        counter : out Unsigned (COUNTER_WIDTH - 1 downto 0);
        -- Overflow pulse output
        overflow : out Std_logic

    );

end entity Timer;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of Timer is

    -- Value of the internal counter
    signal counter_value : Unsigned (COUNTER_WIDTH - 1 downto 0);
    -- Signal clearing internal counter
    signal counter_clear : Std_logic;
    -- State of the comparison between counter'a value and limit
    signal limit_reached : Std_logic;
    -- Internal indication of overflow state
    signal overflow_active : Std_logic;
    -- Intenrla signal indicating whether @out overflow output is enabled
    signal out_active : Std_logic;

begin

    
    -- =================================================================================
    -- Counter control
    -- =================================================================================
    
    -- Counter instance
    counter_inst: entity work.Counter(logic)
    generic map (
        COUNTER_WIDTH => COUNTER_WIDTH
    )
    port map (
        reset_n	=> reset_n,
        clk     => clk,
        enable  => enable,
        clear  	=> counter_clear,
        counter => counter_value
    );

    -- Comparison between counter's value and the limti value
    limit_reached <= '1' when (counter_value = limit) else '0';

    -- Internal counter's clear on limit and when timer is disabled (on the next active edge)
    counter_clear <= ((not enable) or limit_reached);

    -- Output counter value
    counter <= counter_value;

    -- =================================================================================
    -- Output control
    -- =================================================================================

    -- Detect overflow condition
    process(reset_n, clk) is
    begin
        -- Reset state
        if(reset_n = '0') then
            overflow_active <= '0';
        -- Detect output's desired state
        elsif(rising_edge(clk)) then
            overflow_active <= limit_reached;
        end if;
    end process;

    -- Control output state
    process(reset_n, clk) is
    begin
        if(reset_n = '0') then
            out_active <= '0';
        elsif(rising_edge(clk)) then
            if(enable = '1') then
                out_active <= '1';
            else
                out_active <= '0';
            end if;
        end if;
    end process;

    -- Set overflow pulse
    overflow <= OUTPUT_ACTIVE when ((overflow_active and out_active) = '1') else (not OUTPUT_ACTIVE);

end architecture logic;
