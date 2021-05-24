-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-20 15:40:44
-- @ Modified time: 2021-05-20 15:40:45
-- @ Description: 
--    
--    `TriangleGenerator` is a signed counter module with a transparent output that can be used to generate triangle wave.
--    Counter goes from 0 to MAX_VALUE, then to MIN_VALUE and back to 0. It complies interface common for other generaors
--    in the project. In comparison to them it has (obviously) 0 latency.
--
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.generator.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity TriangleGenerator is
    generic(
        -- Output mode
        MODE : SIGNESS := SIGNED_OUT;
        -- Width of the single sample
        SAMPLE_WIDTH : Positive
    );
    port(
        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Signal starting generation of the next sample (active high)
        en_in : in Std_logic;
        -- Data lines
        sample_out : out Std_logic_vector(SAMPLE_WIDTH - 1 downto 0)
    );
end entity TriangleGenerator;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of TriangleGenerator is

    -- Internal counter signal (connected to the @out sample_out)
    signal counter : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);

begin

    -- =================================================================================
    -- Module's logic
    -- =================================================================================

    -- Connect output buffer of address port
    sample_out <= counter;

    -- State machine
    process(reset_n, clk) is
        -- Actual direction of the counter
        type Dir is (UP, DOWN);
        variable direction : Dir;
    begin

        -- Reset condition
        if(reset_n = '0') then

            -- Keep outputs low
            counter <= (others => '0');
            -- Initialize direction
            direction := UP;

        -- Normal operation
        elsif(rising_edge(clk)) then

            if(en_in = '1') then
            
                -- Test counter's direction
                if(direction = UP) then
                    
                    -- Depending on signess
                    if(MODE = SIGNED_OUT) then

                        -- Increment counter
                        counter <= Std_logic_vector(Signed(counter) + 1);

                        -- Change direction if required
                        if(Signed(counter) = 2**(SAMPLE_WIDTH - 1) - 2) then
                            direction := DOWN;
                        end if;
                        
                    else

                        -- Increment counter
                        counter <= Std_logic_vector(Unsigned(counter) + 1);

                        -- Change direction if required
                        if(Unsigned(counter) = 2**SAMPLE_WIDTH - 2) then
                            direction := DOWN;
                        end if;

                    end if;


                else

                    -- Depending on signess
                    if(MODE = SIGNED_OUT) then

                        -- Decrement counter
                        counter <= Std_logic_vector(Signed(counter) - 1);
                        
                        -- Change direction if required
                        if(Signed(counter) = - 2**(SAMPLE_WIDTH - 1) + 1) then
                            direction := UP;
                        end if;

                    else

                        -- Decrement counter
                        counter <= Std_logic_vector(Unsigned(counter) - 1);
                        
                        -- Change direction if required
                        if(Unsigned(counter) = 1) then
                            direction := UP;
                        end if;

                    end if;

                end if;

            end if;

        end if;

    end process;

end architecture;
