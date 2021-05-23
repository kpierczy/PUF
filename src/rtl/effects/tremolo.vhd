 -- ===================================================================================================================================
 -- @ Author: Krzysztof Pierczyk
 -- @ Create Time: 2021-05-22 11:00:23
 -- @ Modified time: 2021-05-22 16:15:54
 -- @ Description: 
 --    
 --    Tremolo effect module with dynamically parametrized modulation's frequency implementing interface for external modulation
 --    wave's generator. It is assumed that generator's samples span over all range of values from -MAX to MAX. result of the 
 --    modulation is always divided so that effective modulation's amplitude ranges from 0 to 1.
 --
 -- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.edge.all;
use work.dsp.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity TremoloEffect is

    generic(
        -- Width of the input sample
        SAMPLE_WIDTH : Positive range 2 to 32;
        -- Width of the modulating sample
        MODULATION_SAMPLE_WIDTH : Positive range 2 to 32;
        -- Width of the `modulation_freq` parameter input
        MODULATION_FREQ_WIDTH : Positive;
        -- Number of bits of the `modulation_freq` input be shifted right to calculate modulation wave's frequency
        MODULATION_FREQ_TWO_POW_DIV : Natural;
        -- Number of samples in a single period of the modulation wave
        MODULATION_SAMPLES_NUM : Positive;
        -- Latency of the modulation wave's generator (0 if sample is ready next cycle after `modulation_next_sample_out` = '1')
        MODULATION_GENERATOR_LATENCY : natural
    );
    port(

        -- ==================== Effects' common interface =================== --

        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Enable signal (when module's disabled, samples are not modified)
        enable_in : in Std_logic;
        -- `New input sample` signal (rising-edge-active)
        valid_in : in Std_logic;
        -- `Output sample ready` signal (rising-edge-active)
        valid_out : out Std_logic;

        -- Input sample
        sample_in : in Signed(SAMPLE_WIDTH - 1 downto 0);
        -- Gained sample
        sample_out : out Signed(SAMPLE_WIDTH - 1 downto 0);

        -- =================== Effect's-specific interface ================== --

        -- Period of the modulating wave's sample in system clock's ticks (minus (MODULATION_GENERATOR_LATENCY + 1))
        modulation_sample_period_in : in Unsigned(MODULATION_FREQ_WIDTH - 1 downto 0);

        -- Generator's sample output
        modulation_sample_in : in Unsigned(MODULATION_SAMPLE_WIDTH - 1 downto 0);
        -- Generator's `busy` signal (active hight)
        modulation_busy_in : in Std_logic;
        -- Generator's input initializing generation of the next sample (active high)
        modulation_next_sample_out : out Std_logic

    );

end entity TremoloEffect;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of TremoloEffect is

     -- Signal activated hight for one cycle when rising edge detected on @p in valid_in
    signal new_sample : Std_logic;

    -- Input sample buffer
    signal sample_buf : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- Modulation sample buffer
    signal modulation_sample_buf : Signed(MODULATION_SAMPLE_WIDTH - 1 downto 0);
    -- Modulation frequency buffer
    signal modulation_freq_buf : Signed(MODULATION_FREQ_WIDTH - 1 downto 0);
    
    -- Internal result of modulation
    signal result : Signed(SAMPLE_WIDTH - 1 downto 0);

begin

    -- Assert that the maximum frequency of the modulating wave is in allowable range
    assert (2**ADDR_WIDTH - SAMPLE_ADDR_OFFSET >= SAMPLES_NUM)
        report 
            "[QuadrupleGenerator] Adress port too narrow to address all samples!"
    severity error;

    -- =================================================================================
    -- Internal components
    -- =================================================================================

    -- `valid_in` edge detector
    edgeDetectotInstance : entity work.EdgeDetectorSync(logic)
    generic map(
        OUTPUT_ACTIVE => '1',
        EDGE_DETECTED => RISING
    )
    port map(
        reset_n   => reset_n,
        clk       => clk,
        sig       => valid_in,
        detection => new_sample
    );

    -- =================================================================================
    -- Module's logic
    -- =================================================================================

    -- Asynchronous multiplication of input sample and modulating sample
    result <= resize(sample_buf * modulation_sample_buf / 2**MODULATION_SAMPLE_WIDTH, SAMPLE_WIDTH);

    -- Output state machine
    process(reset_n, clk) is

        -- Stages of the module
        type Stage is (IDLE_ST, OUTPUT_ST);
        -- Actual stage
        variable state : Stage;

        -- Counter of input samples since last wave sample's update
        variable samples_since_last_wave_sample : unsigned(MODULATION_FREQ_WIDTH - 1 downto 0);

    begin

        -- Reset condition
        if(reset_n = '0') then

            -- Keep outputs low
            valid_out <= '0';
            sample_out <= (others => '0');
            modulation_next_sample_out <= '0';
            busy <= 0;
            -- Reset internal buffers
            sample_buf <= (others => '0');
            modulation_sample_buf <= (others => '0');
            samples_per_modulation_sample_buf <= (others => '0');
            result <= (others => '0');
            -- Reset internal counter
            samples_since_last_wave_sample := 0;
            -- Reset state
            state := IDLE_ST;

        -- Normal operation
        elsif(rising_edge(clk)) then
            
            -- Deactivate `sample ready` output by defau
            valid_out <= '0';
            -- Deactivate generator by default
            modulation_next_sample_out <= '1';

            -- When module's enabled
            if(enable_in = '1') then

                -- State machine
                case state is 

                    -- Waiting for new sample
                    when IDLE_ST =>

                        -- Check if new sample arrived
                        if(new_sample = '1') then

                            -- Latch input sample
                            sample_buf <= sample_in;
                            -- Latch modulation frequency
                            samples_per_modulation_sample_buf <= samples_per_modulation_sample;
                            -- Mark module as busy
                            busy <= '1';
                            -- Change state
                            state := COMPUTE_ST;

                        end if;

                    -- Output computed sample
                    when COMPUTE_ST =>

                        -- Push processed sample to the output
                        sample_out <= result;
                        -- Signal new sample on the output
                        valid_out <= '1';
                        -- Check whether modulation is in fact enabled
                        if(samples_per_modulation_sample_buf /= to_unsigned(0, MODULATION_FREQ_WIDTH)) then
                            -- Mark module as idle
                            busy <= '0';
                            -- Reset counter of samples
                            samples_since_last_wave_sample := 0;
                            -- Change state
                            state := COMPUTE_ST;
                        else
                            -- Check whether number of samples since the last wave's sample's update exceeed limit
                            if(samples_since_last_wave_sample = samples_per_modulation_sample_buf) then
                                -- Reset counter of samples
                                samples_since_last_wave_sample := 0;
                                -- Start fetching new sample from the generator
                                modulation_next_sample_out <= '1';
                                -- Switch to the fetching state
                                state := WAIT_FOR_GENERATOR_START_ST;
                            -- If not, back to IDLE
                            else
                                -- Mark module as idle
                                busy <= '0';
                                -- Increment counter of samples
                                samples_since_last_wave_sample := samples_since_last_wave_sample + 1;
                                -- Change state
                                state := IDLE_ST;
                            end if;

                        end if;

                    -- Wait for the generator's start
                    when WAIT_FOR_GENERATOR_START_ST =>

                        if(modulation_busy_in = '1') then
                                state := FETCH_MODULATIO_SAMPLE_ST;
                        end if;

                    -- Waiting for the next modulation sample
                    when FETCH_MODULATIO_SAMPLE_ST =>

                        -- Wait for generator's stop
                        if(modulation_busy_in = '0') then
                                -- Mark module as idle
                                busy <= '0';
                                -- Fetch new modulating wave's sample from the generator 
                                modulation_sample_buf <= modulation_sample_in;
                                -- Change state
                                state := IDLE_ST;
                        end if;

                end case;

            -- When module's disabled
            else 

                -- Check if new sample arrived or module's was turned off during processing
                if(new_sample = '1' or state /= IDLE_ST) then

                    -- Output unprocessed input sample
                    if(state /= IDLE_ST) then
                        sample_out <= sample_buf;
                    else
                        sample_out <= sample_in;
                    end if;

                    -- Reset counter of samples
                    samples_since_last_wave_sample := 0;
                    -- Signal new sample on the output
                    valid_out <= '1';
                    -- Reset state
                    state := IDLE_ST;
                    
                end if;

            end if;

        end if;

    end process;

end architecture logic;