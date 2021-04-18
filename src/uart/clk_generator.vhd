-- ===================================================================================================================================
-- @ Author: Your name
-- @ Create Time: 2021-04-17 22:05:46
-- @ Modified by: Your name
-- @ Modified time: 2021-04-17 22:05:48
-- @ Description:
-- 
--     Implementation of the UART baud generator
--
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity baud_generator is

	PORT(
        -- System clock    
        clk : in std_logic;
        -- Ascynchronous reset
        reset_n	: in std_logic;
        -- Oversampling pulse generation enable
        os_en : in std_logic;
        -- Baud pulse generation enable
        baud_en : in std_logic;

        -- Ratio of system clock frequency and desired baud rate (minus 1)
        rate : out std_logic_vector(15 downto 0) 
        -- Oversampling pulse output
        os : out std_logic;                    
        -- Baud pulse output
        baud : out std_logic                     
    );

end baud_generator;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of baud_generator is

    -- Internal signal enabling oversampling counter
    signal os_counter_enable : std_logic;
    -- Internal signal enabling baud counter
    signal baud_counter_enable : std_logic;
    -- Register holding limit of the oversampling counter
    signal os_counter_limit : std_logic_vector(15 downto 0);
    -- Register holding limit of the baud counter
    signal baud_counter_limit : std_logic_vector(11 downto 0);

begin

    -- =================================================================================
    -- @brief: Latches @in rate input to the internal registers when the first `enable`
    --    input is pulled high. Enables coresponding counter. On reset holds both
    --    counters disabled.
    -- =================================================================================
	process(reset_n, clk)

        begin
        
        -- Disable counters on reset
        if(reset_n = '0') then

            os_counter_enable <= '0';   -- Disable oversampling counter
            baud_counter_enable <= '0'; -- Disable baud counter
        
        elsif(clk'event and clk = '1') then

            
            -- If the generator was activated (by activating one of pulse generators)
            if((os_en or baud_en) and (not(os_counter_enable) and not(baud_counter_enable)))

                -- Latch @in rate value in internal registers
                os_counter_limit <= rate sra 4;
                baud_counter_limit <= rate;
                
            end if;

            --create baud enable pulse
            IF(count_baud < clk_freq/baud_rate-1) THEN --baud period not reached
                count_baud := count_baud + 1;          --increment baud period counter
                baud_pulse <= '0';                     --deassert baud rate pulse
            ELSE                                       --baud period reached
                count_baud := 0;                       --reset baud period counter
                baud_pulse <= '1';                     --assert baud rate pulse
                count_os := 0;                         --reset oversampling period counter to avoid cumulative error
            END IF;
            --create oversampling enable pulse
            IF(count_os < clk_freq/baud_rate/os_rate-1) THEN --oversampling period not reached
                count_os := count_os + 1;                    --increment oversampling period counter
                os_pulse <= '0';                             --deassert oversampling rate pulse		
            ELSE                                             --oversampling period reached
                count_os := 0;                               --reset oversampling period counter
                os_pulse <= '1';                             --assert oversampling pulse
            END IF;

        end if;
    end process;

end architecture logic;