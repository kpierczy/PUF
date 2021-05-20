-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-17 09:59:45
-- @ Modified time: 2021-05-17 09:59:46
-- @ Description: 
--    
--    Implementation of the interface for the XADC module used to periodically trigger conversion of the sequence read it's result
--    to the array of output vectors. Module assumes that the XADC's sequencer reads auxiliary channels from AUX0 to AUXx 
--    (x in (0, 15)). This assumption is needed to determine index of the sampled channel from the `channel_out` port of the XADC.
--
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.multiplexer.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity AnalogSequenceReader is

    generic(
        -- System clock's frequency [Hz]
        SYS_CLK_HZ : Positive;
        -- Frequency of conversions
        SAMPLING_FREQ_HZ : Positive range 1 to SYS_CLK_HZ / 100;
        -- Number of channels sampled in sequence by the ADC
        CHANNELS_NUM : Positive range 1 to 16
    );
    port(
        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- ================= XADC Interface ================= --

        -- `Data ready` line
        drdy_in : in Std_logic;
        -- Output data lines from the XADC
        do_in : in Std_logic_vector(15 downto 0);
        -- `Sampled channel` output lines from the XADC
        channel_in : in Std_logic_vector(4 downto 0);
        -- `EOC` (End of Conversion) line
        eoc_in : in Std_logic;
        -- `Start conversion` line
        convst_in : out std_logic;
        -- Addres lines of the DRP interface
        daddr_out : out Std_logic_vector(6 downto 0);
        -- `DRP Enable` line
        den_out : out Std_logic;

        -- ================ Sampled channels ================ --

        -- Sampled outputs
        out_channels : out vectorsArray(0 to CHANNELS_NUM)(11 downto 0)
    );

end entity AnalogSequenceReader;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of AnalogSequenceReader is 

    -- ============================= Constants ============================ --

    -- Sample's width (to not use raw '12')
    constant SAMPLE_WIDTH :Positive := 12;

begin

    -- Value at the `channel_out` lines of the XADC indiacated address of the register
    -- containing value of the last sampled channel
    daddr_out <= "00" & channel_in;

    -- End of conversion can be used to send DRP request for reading sampled value 
    den_out <= eoc_in;

    -- ===================== Registers' reading logic ===================== --

    process(clk, reset_n) is

        -- DRP address of the data registers of the first auxiliary channel
        constant DATA_REG_OFFSET : Unsigned(channel_in'left downto channel_in'right) := X"10";
        -- Number of system clock's ticks between conversions
        constant SYS_TICKS_PER_CONVERSION : Positive := SYS_CLK_HZ / SAMPLING_FREQ_HZ;

        -- Stages of the module
        type Stage is (
            WAIT_FOR_NEXT_CONVERSION_ST,
            WAIT_FOR_CONVERSION_END_ST,
            WAIT_FOR_DATA_ST
        );
        -- Actual stage
        variable state : Stage;

        -- Counter used to determine conversion's start
        variable ticks_to_next_conversion : Natural range 0 to SYS_TICKS_PER_CONVERSION - 1;

    begin

        -- Reset state
        if(reset_n = '0') then

            -- Reset DRP address lines
            daddr_out <= (others => '0');
            -- Keep DRP interface disabled
            den_out <= '0';
            -- Reset `Start of conversion` line
            convst_in <= '0';

            -- Kepp 'channels' output low
            out_channels <= (others => (others => '0'));
            -- Reset register counting system ticks to the start  of the next conversion
            ticks_to_next_conversion := SYS_TICKS_PER_CONVERSION - 1;

            -- Set default state
            state := WAIT_FOR_NEXT_CONVERSION_ST;

        elsif(rising_edge(clk)) then

            -- By default, disable `Start conversion` signal
            convst_in <= '0';

            -- State machine
            case state is

                -- Wait for the next conversion
                when WAIT_FOR_NEXT_CONVERSION_ST =>

                    -- If more cycles need to by waited
                    if(ticks_to_next_conversion /= 0) then

                        -- Decrement counter
                        ticks_to_next_conversion := ticks_to_next_conversion - 1;

                    -- If next conversion should eb started
                    else

                        -- Activate `Start conversion` line
                        convst_in <= '1';
                        -- Reset counter
                        ticks_to_next_conversion := SYS_TICKS_PER_CONVERSION - 1;
                        -- Change state
                        state := WAIT_FOR_DATA_ST;

                    end if;

                -- Waiting from sampled data appearance on the DRP interface
                when WAIT_FOR_DATA_ST =>

                    -- =====================================================================
                    -- Note: request for reading last sampled channel's data is triggered
                    --   automaticallly as EOC (End of Conversion) line is connected to the 
                    --   DEN (DRP Enable) line
                    -- =====================================================================

                    -- Decrement counter indicating start of the next conversion
                    ticks_to_next_conversion := ticks_to_next_conversion - 1;

                    -- Check whether data was read
                    if(drdy_in = '1') then

                        -- Copy data to the output
                        out_channels(Unsigned(channel_in) - DATA_REG_OFFSET) <= 
                            do_in(SAMPLE_WIDTH + 3 downto 4);
                        -- Change state
                        state := WAIT_FOR_NEXT_CONVERSION_ST;

                    end if;

            end case;

        end if;

    end process;


end architecture logic;
