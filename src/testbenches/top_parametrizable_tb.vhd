-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    Testbench for the top module of with effects' parameter controlled by set of constants (not by XADC simulation)
-- 
-- @ Note: Configuration of project's modules should be set in dedicated `*config.vhd` files.
-- @ Note: Analog stimulus signals for XADC should be defined in the `data/xadc-analog-input.txt` file
-- @ Note: Intergation simulation of the whole project is not convinient, as XADC is configured in the `external mux` mode. It 
--     results in need of generation of a strange analog-stimulus file where a single channel is used to set value of all 9 parameters
--     of the effect's chain.
-- @ Important: Remember to regenrate output of IP sources before running simulation!
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;
use work.uart.all;
use work.edge.all;
use work.xadc.all;
use work.config.all;
use work.pipe_config.all;
use work.transreceiver_config.all;
use work.xadc_config.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity TopParamTb is
    generic(

        -- ============================================= System parameters ============================================== --

        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;
        
        -- --------------------- Input signal's parameters --------------------- --

        
        -- Type of the input wave (available: [sin/sin_rand])
        INPUT_TYPE : String := "sin";

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Natural := 440;
        -- Amplitude of the input wave in normalized range <0; 1>
        INPUT_AMPLITUDE : Real := 0.6;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive := 44_100;

        -- Mean of the gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_MEAN : Real := 0.0;
        -- Standard deviation gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_STD_DEV : Real := 0.02;

        -- ============================================== Effects' setup ================================================ --

        -- -------------------------------------------------------------------------
        -- @Note: Stimulus signals for effect's parameters are generated as random 
        --    steps with given frequency and amplitude.
        -- -------------------------------------------------------------------------

        -- ---------- Clipping effect's parameters' stimulus signals ------------ --

        -- Clippign effect's state
        CLIPPING_ENABLE : Std_logic := '1';

        -- Amplitudes of gain values in normalized range <0; 1>
        CLIPPING_GAIN_AMPLITUDE : Real := 0.75;
        -- Frequency of the changes of `gain_in` input
        CLIPPING_GAIN_TOGGLE_FREQ_HZ : Natural := 0;
        -- Phase shift of the parameter in normalized <0,1> range
        CLIPPING_GAIN_PHASE_SHIFT : Real := 0.0;

        -- Amplitudes of clips in normalized range <0; 1>
        CLIPPING_OVERDRIVE_AMPLITUDE : Real := 1.0;
        -- Frequency of the changes of `saturation_in` input
        CLIPPING_OVERDRIVE_TOGGLE_FREQ_HZ : Natural := 0;
        -- Phase shift of the parameter in normalized <0,1> range
        CLIPPING_OVERDRIVE_PHASE_SHIFT : Real := 0.0;

        -- ----------- Tremolo effect's parameters' stimulus signals ------------ --

        -- Tremolo effect's state
        TREMOLO_ENABLE : Std_logic := '1';

        -- Amplitudes of `depth_in` input's values in normalized range <0; 1>
        TREMOLO_DEPTH_AMPLITUDE : Real := 1.0;
        -- Frequency of the changes of `depth_in` input
        TREMOLO_DEPTH_TOGGLE_FREQ_HZ : Natural := 0;
        -- Phase shift of the parameter in normalized <0,1> range
        TREMOLO_DEPTH_PHASE_SHIFT : Real := 0.0;

        -- Amplitudes of the frequency-like parameter of the tremolo's LFO
        TREMOLO_FREQUENCY_AMPLITUDE : Real := 1.0;
        -- Toggle frequency of the frequency-like parameter of the tremolo's LFO
        TREMOLO_FREQUENCY_TOGGLE_FREQ_HZ : Natural := 0;
        -- Phase shift of the parameter in normalized <0,1> range
        TREMOLO_FREQUENCY_PHASE_SHIFT : Real := 0.0;

        -- ------------ Delay effect's parameters' stimulus signals ------------- --

        -- Delay effect's state
        DELAY_ENABLE : Std_logic := '1';

        -- Amplitudes of `depth_in` input's values in normalized range <0; 1> ('1.0' is (BRAM_SAMPLES_NUM - 1))
        DELAY_DEPTH_AMPLITUDE : Real := 0.01;
        -- Frequency of the changes of `depth_in` input
        DELAY_DEPTH_TOGGLE_FREQ_HZ : Natural := 0;
        -- Phase shift of the parameter in normalized <0,1> range
        DELAY_DEPTH_PHASE_SHIFT : Real := 0.0;

        -- Amplitudes of `delay_gain_in` input's values in normalized range <0; 1>
        DELAY_DELAY_GAIN_AMPLITUDE : Real := 1.0;
        -- Frequency of the changes of `delay_gain_in` input
        DELAY_DELAY_GAIN_TOGGLE_FREQ_HZ : Natural := 0;
        -- Phase shift of the parameter in normalized <0,1> range
        DELAY_DELAY_GAIN_PHASE_SHIFT : Real := 0.0;

        -- ----------- Flanger effect's parameters' stimulus signals ------------ --

        -- Delay effect's state
        FLANGER_ENABLE : Std_logic := '1';

        -- Amplitudes of `depth_in` input's values in normalized range <0; 1> ('1.0' is (BRAM_SAMPLES_NUM - 1))
        FLANGER_DEPTH_AMPLITUDE : Real := 1.0;
        -- Frequency of the changes of `depth_in` input
        FLANGER_DEPTH_TOGGLE_FREQ_HZ : Natural := 0;
        -- Phase shift of the parameter in normalized <0,1> range
        FLANGER_DEPTH_PHASE_SHIFT : Real := 0.0;

        -- Amplitudes of `strength_in` input's values in normalized range <0; 1>
        FLANGER_STRENGTH_AMPLITUDE : Real := 0.5;
        -- Frequency of the changes of `strength_in` input
        FLANGER_STRENGTH_TOGGLE_FREQ_HZ : Natural := 0;
        -- Phase shift of the parameter in normalized <0,1> range
        FLANGER_STRENGTH_PHASE_SHIFT : Real := 0.0;

        -- Amplitudes of the frequency-like parameter of the flanger's LFO
        FLANGER_FREQUENCY_AMPLITUDE : Real := 1.0;
        -- Toggle frequency of the frequency-like parameter of the flanger's LFO
        FLANGER_FREQUENCY_TOGGLE_FREQ_HZ : Natural := 0;
        -- Phase shift of the parameter in normalized <0,1> range
        FLANGER_FREQUENCY_PHASE_SHIFT : Real := 0.0

    );
end entity TopParamTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of TopParamTb is

        -- ====================== Effects' common interface ===================== --

        -- Reset signal (asynchronous)
        signal reset_n : Std_logic;
        -- System clock
        signal clk : Std_logic;

        -- `New input sample` signal (rising-edge-active)
        signal valid_in : Std_logic;
        -- `Output sample ready` signal (rising-edge-active)
        signal valid_out : Std_logic;

        -- Input sample
        signal sample_in : Signed(CONFIG_SAMPLE_WIDTH - 1 downto 0);
        -- Gained sample
        signal sample_out : Signed(CONFIG_SAMPLE_WIDTH - 1 downto 0);

        -- Input sample to the pipe
        signal sample_pipe_in : Signed(CONFIG_SAMPLE_WIDTH - 1 downto 0);
        -- Output sample from the pipe
        signal sample_pipe_out : Signed(CONFIG_SAMPLE_WIDTH - 1 downto 0);        

        -- ===================== Clipping effect's interface ==================== --

        -- Enable input (active high)
        signal clipping_enable_in : Std_logic := CLIPPING_ENABLE;
        -- Gain input
        signal clipping_gain_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);
        -- Saturation level (for absolute value of the signal)
        signal clipping_overdrive_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);


        -- ====================== Tremolo effect's interface ==================== --

        -- Enable input (active high)
        signal tremolo_enable_in : Std_logic := TREMOLO_ENABLE;
        -- Tremolo's depth aprameter (treated as value in <0, 1) range)
        signal tremolo_depth_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);
        -- Number of system clock's ticks per modulation sample (minus 1)
        signal tremolo_frequency_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);

        -- ======================= Delay effect's interface ===================== --

        -- Enable input (active high)
        signal delay_enable_in : Std_logic := DELAY_ENABLE;
        -- Depth level (index of the delayed sample being summed with the input)
        signal delay_depth_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);
        -- Gain level pf the delayed summant (treated as value in <0,0.5) range)
        signal delay_delay_gain_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);

        -- ====================== Flanger effect's interface ==================== --

        -- Enable input (active high)
        signal flanger_enable_in : Std_logic := FLANGER_ENABLE;
        -- Depth level
        signal flanger_depth_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);
        -- Strength of the flanger effect
        signal flanger_strength_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);
        -- Delay's modulation frequency
        signal flanger_frequency_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);

        -- ===================== Sample receiver's interface ==================== --

        -- 'Module busy' signal (active high)
        signal sampler_rx_busy : Std_logic;
        -- Sample received (pushed on @in busy falling edge when no error occured during sample's reception)
        signal sampler_rx_sample : Std_logic_vector(CONFIG_SAMPLE_WIDTH - 1 downto 0);

        -- =================== Sample transmitter's interface ==================== --

        -- Transfer initialization signal (active high)
        signal sampler_tx_transfer : Std_logic;
        -- Sample to be transfered (latched on @in clk rising edge when @in transfer high and @out busy's low)
        signal sampler_tx_sample : Std_logic_vector(CONFIG_SAMPLE_WIDTH - 1 downto 0);

        -- ============================= Serial lines =========================== --

        -- Serial input line
        signal rx : Std_logic := '0';
        -- Serial output line
        signal tx : Std_logic  := '0';
        -- Error output from the samples' receiver
        signal err : UartErrors;

        -- =============== Interface of additional edge-detector ================= --

        -- Signal to be observed
        signal edge_detector_in : Std_logic;

        -- Detecion signal
        signal edge_detector_out : std_logic;

        -- =========================== Auxiliary signals ======================== --

        -- Real version of the effect's parameters used to generate signals with math_real library
        signal clipping_enable_tmp : Real;
        signal clipping_gain_tmp : Real;
        signal clipping_overdrive_tmp : Real;
        signal tremolo_enable_tmp : Real;
        signal tremolo_depth_tmp : Real;
        signal tremolo_frequency_tmp : Real;
        signal delay_enable_tmp : Real;
        signal delay_depth_tmp : Real;
        signal delay_delay_gain_tmp : Real;
        signal flanger_enable_tmp : Real;
        signal flanger_depth_tmp : Real;
        signal flanger_strength_tmp : Real;
        signal flanger_frequency_tmp : Real;

begin

    -- =================================================================================
    -- Common effects' benchtable
    -- =================================================================================
    
    -- Instance of the common features regarding guitar effects' testing
    pipeTestbenchInstance: entity work.SignalGenerator(logic)
    generic map (
        SYS_CLK_HZ             => CONFIG_SYS_CLK_HZ,
        SYS_RESET_TICKS        => SYS_RESET_TICKS,
        SAMPLE_WIDTH           => CONFIG_SAMPLE_WIDTH,
        INPUT_TYPE             => INPUT_TYPE,
        INPUT_FREQ_HZ          => INPUT_FREQ_HZ,
        INPUT_AMPLITUDE        => INPUT_AMPLITUDE,
        INPUT_RAND_MEAN        => INPUT_RAND_MEAN,
        INPUT_RAND_STD_DEV     => INPUT_RAND_STD_DEV
    )
    port map (
        reset_n   => reset_n,
        clk       => clk,
        sample_in => sample_in
    );

    -- =================================================================================
    -- Module's instance
    -- =================================================================================

    -- Instance of the samples' receiver
    sampleRxInstane : entity work.SampleRx(logic)
    generic map (
        SYS_CLK_HZ      => CONFIG_SYS_CLK_HZ,
        SAMPLE_BYTES    => CONFIG_SAMPLE_WIDTH / CONFIG_TRANSRECEIVER_BYTE_SIZE,
        BAUD_RATE       => CONFIG_TRANSRECEIVER_BAUD_RATE,
        PARITY_USED     => CONFIG_TRANSRECEIVER_PARITY_USED,
        PARITY_TYPE     => CONFIG_TRANSRECEIVER_PARITY_TYPE,
        STOP_BITS       => CONFIG_TRANSRECEIVER_STOP_BITS,
        SIGNAL_NEGATION => CONFIG_TRANSRECEIVER_SIGNAL_NEGATION,
        DATA_NEGATION   => CONFIG_TRANSRECEIVER_DATA_NEGATION
    )
    port map (
        reset_n => reset_n,
        clk     => clk,
        rx      => rx,
        busy    => sampler_rx_busy,
        sample  => sampler_rx_sample,
        err     => open
    );

    -- Edge detector sensing reception of the new sample
    edgeDetectorSyncInstance : entity work.EdgeDetectorSync(logic)
      generic map (
        OUTPUT_ACTIVE => '1',
        EDGE_DETECTED => FALLING
      )
      port map (
        reset_n   => reset_n,
        clk       => clk,
        sig       => edge_detector_in,
        detection => edge_detector_out
      );

    -- Instance of the effects' pipe
    effectsPipeInstance : entity work.EffectsPipe(logic)
    generic map (
        SAMPLE_WIDTH => CONFIG_SAMPLE_WIDTH,
        PARAM_WIDTH  => XADC_SAMPLE_WIDTH
    )
    port map (
        reset_n                => reset_n,
        clk                    => clk,
        valid_in               => valid_in,
        valid_out              => valid_out,
        sample_in              => sample_pipe_in,
        sample_out             => sample_pipe_out,
        clipping_enable_in     => clipping_enable_in,
        clipping_gain_in       => clipping_gain_in,
        clipping_overdrive_in  => clipping_overdrive_in,
        tremolo_enable_in      => tremolo_enable_in,
        tremolo_depth_in       => tremolo_depth_in,
        tremolo_frequency_in   => tremolo_frequency_in,
        delay_enable_in        => delay_enable_in,
        delay_depth_in         => delay_depth_in,
        delay_delay_gain_in    => delay_delay_gain_in,
        flanger_enable_in      => flanger_enable_in,
        flanger_depth_in       => flanger_depth_in,
        flanger_strength_in    => flanger_strength_in,
        flanger_frequency_in   => flanger_frequency_in
    );

    -- Instance fo the samples' transmitter
    sampleTxInstance: entity work.SampleTx(logic)
    generic map (
        SYS_CLK_HZ      => CONFIG_SYS_CLK_HZ,
        SAMPLE_BYTES    => CONFIG_SAMPLE_WIDTH / CONFIG_TRANSRECEIVER_BYTE_SIZE,
        BAUD_RATE       => CONFIG_TRANSRECEIVER_BAUD_RATE,
        PARITY_USED     => CONFIG_TRANSRECEIVER_PARITY_USED,
        PARITY_TYPE     => CONFIG_TRANSRECEIVER_PARITY_TYPE,
        STOP_BITS       => CONFIG_TRANSRECEIVER_STOP_BITS,
        SIGNAL_NEGATION => CONFIG_TRANSRECEIVER_SIGNAL_NEGATION,
        DATA_NEGATION   => CONFIG_TRANSRECEIVER_DATA_NEGATION
    )
    port map (
        reset_n  => reset_n,
        clk      => clk,
        transfer => sampler_tx_transfer,
        sample   => sampler_tx_sample,
        busy     => open,
        tx       => tx
    );

    -- =======================================================================================================
    -- -------------------------------------- Inter-modules connections --------------------------------------
    -- =======================================================================================================

    -- Line detecting falling edge on the `busy` output of the RX module is conected to the `valid_in` pipe's input
    valid_in <= edge_detector_out;

    -- Falling edge on the `busy` output of the samples' reciving module is detected
    edge_detector_in <= sampler_rx_busy;
    -- Output data from the receiver is connected to the input of the pipeline
    sample_pipe_in <= Signed(sampler_rx_sample);

    -- Output data from the pipe is connected to the transmitter's input
    sampler_tx_sample <= Std_logic_vector(sample_pipe_out);
    -- `transfer` input of the TX module is connected to the `valid_out` output of the pip
    sampler_tx_transfer <= valid_out;

    -- =================================================================================
    -- Samples' transmission
    -- =================================================================================

    -- Process transmitting input samples with constant (sampling) frequency
    process is

        -- Sample to be transmitted
        variable sample_to_transmit : Std_logic_vector(CONFIG_SAMPLE_WIDTH - 1 downto 0);
        -- Buffer for byte to be transmitted
        variable byte_to_transmit : std_logic_vector(CONFIG_TRANSRECEIVER_BYTE_SIZE - 1 downto 0);
        -- Bytes transmitted
        variable num_bytes_transmitted : Natural range 0 to CONFIG_SAMPLE_WIDTH / CONFIG_TRANSRECEIVER_BYTE_SIZE;
        -- Time stamp of the next sample to be transmitted
        variable next_sample_time : time;

    begin

        -- Zero data buffers
        sample_to_transmit := (others=>'0');
        byte_to_transmit := (others => '0');
        num_bytes_transmitted := CONFIG_SAMPLE_WIDTH / CONFIG_TRANSRECEIVER_BYTE_SIZE;

        -- Wait for end of reset state
        wait until reset_n = '1';

        -- Set time of the next sample
        next_sample_time := now;

        -- Start transmitting loop
        loop

            -- Check whether all bytes was transmitted
            if(num_bytes_transmitted = CONFIG_SAMPLE_WIDTH / CONFIG_TRANSRECEIVER_BYTE_SIZE) then

                -- Reset counter of received byte
                num_bytes_transmitted := 0;

                -- Assert that sampling frequency is not greater than transmission's time
                assert(next_sample_time >= now)
                    report
                        "[TopTestbench] Time of sample's transmission is higher than sampling perio!"
                severity error;

                -- Wait a few cycle before sending nex samples
                wait for next_sample_time - now;

                -- Sample current value of the input signal
                sample_to_transmit := Std_logic_vector(sample_in);
                -- Set time of the next sample
                next_sample_time := now + 1 sec / INPUT_SAMPLING_FREQ_HZ;

            else

                -- Select byte to be transmitted
                byte_to_transmit := sample_to_transmit(
                    (num_bytes_transmitted + 1) * CONFIG_TRANSRECEIVER_BYTE_SIZE - 1 downto 
                    num_bytes_transmitted * CONFIG_TRANSRECEIVER_BYTE_SIZE
                );

                -- Transmit serial byte
                uart_tx_tb(
                    CONFIG_TRANSRECEIVER_BAUD_RATE,
                    CONFIG_TRANSRECEIVER_PARITY_USED,
                    CONFIG_TRANSRECEIVER_PARITY_TYPE,
                    CONFIG_TRANSRECEIVER_STOP_BITS,
                    CONFIG_TRANSRECEIVER_SIGNAL_NEGATION,
                    CONFIG_TRANSRECEIVER_DATA_NEGATION,
                    byte_to_transmit,
                    rx
                );

                -- Increment number of transmitted bytes
                num_bytes_transmitted := num_bytes_transmitted + 1;

            end if;

        end loop;

    end process;

    -- =================================================================================
    -- Samples' reception
    -- =================================================================================

    -- Error checking
    process is

        -- Buffer for received sample
        variable sample_received : Std_logic_vector(CONFIG_SAMPLE_WIDTH - 1 downto 0) := (others => '0');
        -- Number of received bytes
        variable num_bytes_received : Natural range 0 to CONFIG_SAMPLE_WIDTH / CONFIG_TRANSRECEIVER_BYTE_SIZE := 0;
        -- Buffer for received byte
        variable byte_received : std_logic_vector(CONFIG_TRANSRECEIVER_BYTE_SIZE - 1 downto 0) := (others => '0');

    begin

        -- Reset received word
        sample_received := (others => '0');
        byte_received := (others => '0');
        -- Reset number of received bytes
        num_bytes_received := 0;
        -- Reset reception errors
        err <= (
            start_err  => '0',
            stop_err   => '0',
            parity_err => '0'
        );

        loop

            -- Check whether all bytes was received
            if(num_bytes_received < CONFIG_SAMPLE_WIDTH / CONFIG_TRANSRECEIVER_BYTE_SIZE) then

                -- Receive serial byte
                uart_rx_tb(
                    CONFIG_TRANSRECEIVER_BAUD_RATE,
                    CONFIG_TRANSRECEIVER_PARITY_USED,
                    CONFIG_TRANSRECEIVER_PARITY_TYPE,
                    CONFIG_TRANSRECEIVER_STOP_BITS,
                    CONFIG_TRANSRECEIVER_SIGNAL_NEGATION,
                    CONFIG_TRANSRECEIVER_DATA_NEGATION,
                    tx,
                    err,
                    byte_received
                );

                -- Put received byte into sample buffer
                sample_received(
                    (num_bytes_received + 1) * CONFIG_TRANSRECEIVER_BYTE_SIZE - 1 downto 
                    num_bytes_received * CONFIG_TRANSRECEIVER_BYTE_SIZE
                ) := byte_received;

                -- Increment number of received bytes
                num_bytes_received := num_bytes_received + 1;

            -- If all bytes was received
            else 

                -- Reset counter of received byte
                num_bytes_received := 0;
                -- Copy received sample from the bufer
                sample_out <= Signed(sample_received);
                -- Wait for the next rising edge of the system clk after reception
                wait until rising_edge(clk);

            end if;

        end loop;
    
    end process;

    -- =================================================================================
    -- Clipping effect's stimulus
    -- =================================================================================

    -- Transform signal into the signed value using saturation
    clipping_gain_in <= real_to_unsigned_sat(clipping_gain_tmp, XADC_SAMPLE_WIDTH);
    -- Generate gain signal
    generate_random_stairs(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => CLIPPING_GAIN_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => CLIPPING_GAIN_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(CLIPPING_GAIN_AMPLITUDE * (2**XADC_SAMPLE_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => clipping_gain_tmp
    );

    -- Transform signal into the signed value using saturation
    clipping_overdrive_in <= real_to_unsigned_sat(clipping_overdrive_tmp, XADC_SAMPLE_WIDTH);
    -- Generate saturation signal
    generate_random_stairs(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => CLIPPING_OVERDRIVE_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => CLIPPING_OVERDRIVE_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(CLIPPING_OVERDRIVE_AMPLITUDE * (2**XADC_SAMPLE_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => clipping_overdrive_tmp
    );

    -- =================================================================================
    -- Tremolo effect's stimulus
    -- =================================================================================

    -- Transform signal into the signed value using saturation
    tremolo_depth_in <= real_to_unsigned_sat(tremolo_depth_tmp, XADC_SAMPLE_WIDTH);
    -- Generate `depth` signal
    generate_random_stairs(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => TREMOLO_DEPTH_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => TREMOLO_DEPTH_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(TREMOLO_DEPTH_AMPLITUDE * (2**XADC_SAMPLE_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => tremolo_depth_tmp
    );

    -- Transform signal into the signed value using saturation
    tremolo_frequency_in <= real_to_unsigned_sat(tremolo_frequency_tmp, XADC_SAMPLE_WIDTH);
    -- Generate `modulation_ticks_per_sample_in` signal
    generate_random_stairs(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => TREMOLO_FREQUENCY_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => TREMOLO_FREQUENCY_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(TREMOLO_FREQUENCY_AMPLITUDE * (2**XADC_SAMPLE_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => tremolo_frequency_tmp
    );

    -- =================================================================================
    -- Delay effect's stimulus
    -- =================================================================================

    -- Transform signal into the signed value using saturation
    delay_delay_gain_in <= real_to_unsigned_sat(delay_delay_gain_tmp, XADC_SAMPLE_WIDTH);
    -- Generate `modulation_ticks_per_sample_in` signal
    generate_random_stairs(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => DELAY_DELAY_GAIN_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => DELAY_DELAY_GAIN_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(DELAY_DELAY_GAIN_AMPLITUDE * (2**XADC_SAMPLE_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => delay_delay_gain_tmp
    );

    -- Transform signal into the signed value using saturation
    delay_depth_in <= real_to_unsigned_sat(delay_depth_tmp, XADC_SAMPLE_WIDTH);
    -- Generate `depth` signal
    generate_random_stairs(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => DELAY_DEPTH_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => DELAY_DEPTH_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(DELAY_DEPTH_AMPLITUDE * (2**XADC_SAMPLE_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => delay_depth_tmp
    );

    -- =================================================================================
    -- Flanger effect's stimulus
    -- =================================================================================

    -- Transform signal into the signed value using saturation
    flanger_strength_in <= real_to_unsigned_sat(flanger_strength_tmp, XADC_SAMPLE_WIDTH);
    -- Generate `strength` signal
    generate_random_stairs(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => FLANGER_STRENGTH_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => FLANGER_STRENGTH_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(FLANGER_STRENGTH_AMPLITUDE * (2**XADC_SAMPLE_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => flanger_strength_tmp
    );

    -- Transform signal into the signed value using saturation
    flanger_depth_in <= real_to_unsigned_sat(flanger_depth_tmp, XADC_SAMPLE_WIDTH);
    -- Generate `depth` signal
    generate_random_stairs(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => FLANGER_DEPTH_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => FLANGER_DEPTH_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(FLANGER_DEPTH_AMPLITUDE * (2**XADC_SAMPLE_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => flanger_depth_tmp
    );

    -- Transform signal into the signed value using saturation
    flanger_frequency_in <= real_to_unsigned_sat(flanger_frequency_tmp, XADC_SAMPLE_WIDTH);
    -- Generate `frequency` signal
    generate_random_stairs(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => FLANGER_FREQUENCY_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => FLANGER_FREQUENCY_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(FLANGER_FREQUENCY_AMPLITUDE * (2**XADC_SAMPLE_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => flanger_frequency_tmp
    );
    
end architecture logic;
