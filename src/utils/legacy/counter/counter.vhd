-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-23 16:36:31
-- @ Modified time: 2021-04-23 16:36:46
-- @ Description:
-- 
--     Implementation of the standard counters
--
-- ===================================================================================================================================

-- ===================================================================================================================================
-- A generic counter with synchronous clear and enable inputs. Clear and enable functions activate on the rising edge of the  @in clk
-- signal.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity Counter is

    generic(
        -- Counter's width
        COUNTER_WIDTH : Positive
    );
    port(

        -- Reset (asynchronous)
        reset_n	: in Std_logic;
        -- Clock    
        clk : in Std_logic;
        -- Clear signal (active high)
        clear : in Std_logic;
        -- Enabling signal (active high)
        enable : in Std_logic;

        -- Counter value
        counter : out Unsigned(COUNTER_WIDTH - 1 downto 0)

    );

end entity Counter;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of Counter is

    -- Counter value (internal)
    signal cnt : Unsigned(COUNTER_WIDTH - 1 downto 0);

begin

    -- =================================================================================
    -- Counter's logic
    -- =================================================================================
    process (clk, reset_n)
    begin
        -- Reset state
        if(reset_n = '0') then
            cnt <= (others => '0');
        -- Process on counted edge
        elsif (rising_edge(clk)) then

            -- Clear active
            if clear = '1' then
                cnt <= (others => '0');
            -- Count up
            else
                if enable = '1' then
                    cnt <= cnt + 1;
                end if;
            end if;
            
        end if;
    
    end process;

    -- Output value assignement
    counter <= cnt;

end architecture logic;
