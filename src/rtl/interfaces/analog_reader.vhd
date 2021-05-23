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
use work.xadc.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity AnalogSequenceReader is

    generic(
        -- System clock's frequency [Hz]
        SYS_CLK_HZ : Positive;
        -- Frequency of conversions
        SAMPLING_FREQ_HZ : Positive;
        -- Number of channels sampled in sequence by the ADC
        CHANNELS_NUM : Positive range 1 to 16
    );
    port(
        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Analog inputs
        anal_in_p, anal_in_n : in Std_logic;
        -- Select signal for external MUX
        mux_sel_out : out Std_logic_vector(3 downto 0);
        -- Sampled outputs
        channels_out : out xadcSamplesArray(0 to CHANNELS_NUM - 1)
    );

end entity AnalogSequenceReader;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of AnalogSequenceReader is 

    -- =========================== XADC Wrapper =========================== --

    -- Address lines mapped to the registers containing conversion results from auxiliary channels
    signal daddr_in : Std_logic_vector(3 downto 0);
    -- `DPR Enable` line
    signal den_in : Std_logic;
    -- `DRP Data Ready` line
    signal drdy_out : Std_logic;
    -- `DRP Output Data` lines mapped to the bits representing samples' values
    signal do_out : std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    -- `Start conversion` line
    signal convst_in : Std_logic;
    -- External MUX select lines (mapped to range <0x0; 0xF>)
    signal muxaddr_out : Std_logic_vector(3 downto 0);
    -- `End of conversion` line
    signal eoc_out : Std_logic;
    -- `XADC Busy` line
    signal busy_out : Std_logic;

begin

    -- Assert sampling frequency is low enough
    assert (SAMPLING_FREQ_HZ <= SYS_CLK_HZ / 100)
        report 
            "[AnalogReader] Sampling frequency too high!"
    severity error;


    -- ========================================================================================== --
    -- -------------------------------------- XADC Instance ------------------------------------- --
    -- ========================================================================================== --

    -- Instance of the XADC wrapper
    analogSequenceReaderXadcInterfaceInstance: entity work.AnalogSequenceReaderXadcInterface(logic)
      port map (
        clk              => clk,
        reset_n          => reset_n,
        xadc_daddr_in    => daddr_in,
        xadc_den_in      => den_in,
        xadc_drdy_out    => drdy_out,
        xadc_do_out      => do_out,
        xadc_convst_in   => convst_in,
        xadc_anal_in_p   => anal_in_p,
        xadc_anal_in_n   => anal_in_n,
        xadc_muxaddr_out => muxaddr_out,
        xadc_eoc_out     => eoc_out,
        xadc_busy_out    => busy_out
      );

    -- ========================================================================================== --
    -- -------------------------------- Registers' reading logic -------------------------------- --
    -- ========================================================================================== --

    -- Connect external MUX select lines
    mux_sel_out <= muxaddr_out;

    -- Cyclic triggering ADC conversion
    process(clk, reset_n) is

        -- Number of system clock's ticks between conversions
        constant SYS_TICKS_PER_CONVERSION : Positive := SYS_CLK_HZ / SAMPLING_FREQ_HZ;

        -- Counter used to determine conversion's start
        variable ticks_to_next_conversion : Natural range 0 to SYS_TICKS_PER_CONVERSION - 1;

    begin

        -- Reset state
        if(reset_n = '0') then

            -- Keep DRP inputs to the XADC low
            daddr_in <= (others => '0');
            -- Reset `Start of conversion` line
            convst_in <= '0';
            -- Reset register counting system ticks to the start  of the next conversion
            ticks_to_next_conversion := SYS_TICKS_PER_CONVERSION - 1;

        elsif(rising_edge(clk)) then

            -- By default, disable `Start conversion` signal
            convst_in <= '0';

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
                -- Assign address of the next converted channel to the DRP address lines
                daddr_in <= muxaddr_out;

            end if;

        end if;

    end process;

    -- Reading data from the ADC at the end of each conversion
    process(clk, reset_n) is

        -- Stages of the module
        type Stage is (
            WAIT_FOR_CONVERSION_END_ST,
            WAIT_FOR_CONVERTED_SAMPLE_ST
        );
        -- Actual stage
        variable state : Stage;

    begin

        -- Reset state
        if(reset_n = '0') then

            -- Keep DRP inputs to the XADC low
            den_in <= '0';
            -- Kepp 'channels' output low
            channels_out <= (others => (others => '0'));

            -- Set default state
            state := WAIT_FOR_CONVERSION_END_ST;

        elsif(rising_edge(clk)) then

            -- By default, disable `DRP Enable` signal
            den_in <= '0';

            -- State machine
            case state is

                -- Wait for end of conversion
                when WAIT_FOR_CONVERSION_END_ST =>

                    -- Check `EoC` line
                    if(eoc_out = '1') then

                        -- Enable DRP read
                        den_in <= '1';
                        -- Change state
                        state := WAIT_FOR_CONVERTED_SAMPLE_ST;

                    end if;

                -- Waiting from sampled data appearance on the DRP interface
                when WAIT_FOR_CONVERTED_SAMPLE_ST =>

                    -- Check whether data was read
                    if(drdy_out = '1') then

                        -- Copy data to the output
                        channels_out(to_integer(Unsigned(daddr_in))) <= do_out;
                        -- Change state
                        state := WAIT_FOR_CONVERSION_END_ST;

                    end if;

            end case;

        end if;

    end process;

end architecture logic;
