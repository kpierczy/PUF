-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-20 05:41:45
-- @ Modified time: 2021-05-28 03:25:37
-- @ Description: 
--    
--    Top module of the GuitarMultieffect project.
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.edge.all;
use work.uart.all;
use work.xadc.all;
use work.config.all;
use work.pipe_config.all;
use work.transreceiver_config.all;
use work.xadc_config.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity Top is
    port(
        -- Reset signal
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- ================= Affect pipeline's external interface ================= --

        -- Clipping effect's enable input (active high)
        clipping_enable_in : in Std_logic;

        -- Tremolo effect's enable input (active high)
        tremolo_enable_in : in Std_logic;

        -- Delay effect's enable input (active high)
        delay_enable_in : in Std_logic;

        -- Flanger effect's enable input (active high)
        flanger_enable_in : in Std_logic;

        -- ================== Analog inputs' scanner's interface ================== --

        -- Analog inputs
        anal_in_p, anal_in_n : in Std_logic;
        -- Select signal for external MUX
        mux_sel_out : out Std_logic_vector(3 downto 0);

        -- ================= UART-based transreceiver's interface ================= --

        -- Serial input
        rx : in Std_logic;
        -- Serial output
        tx : out Std_logic 
    );
end entity Top;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of Top is

        -- ====================== Effects' common interface ===================== --

        -- `New input sample` signal (rising-edge-active)
        signal valid_in : Std_logic;
        -- `Output sample ready` signal (rising-edge-active)
        signal valid_out : Std_logic;

        -- Input sample of the pipeline
        signal sample_in : Signed(CONFIG_SAMPLE_WIDTH - 1 downto 0);
        -- Gained sample of the pipeline
        signal sample_out : Signed(CONFIG_SAMPLE_WIDTH - 1 downto 0);

        -- ===================== Clipping effect's interface ==================== --

        -- Gain input
        signal clipping_gain_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);
        -- Saturation level (for absolute value of the signal)
        signal clipping_overdrive_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);

        -- ====================== Tremolo effect's interface ==================== --

        -- Tremolo's depth aprameter (treated as value in <0, 1) range)
        signal tremolo_depth_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);
        -- Number of system clock's ticks per modulation sample (minus 1)
        signal tremolo_frequency_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);

        -- ======================= Delay effect's interface ===================== --

        -- Depth level (index of the delayed sample being summed with the input)
        signal delay_depth_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);
        -- Gain level pf the delayed summant (treated as value in <0,0.5) range)
        signal delay_delay_gain_in : Unsigned(XADC_SAMPLE_WIDTH - 1 downto 0);

        -- ====================== Flanger effect's interface ==================== --

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

        -- ====================== Analog scanner's interface ==================== --

        -- Sampled outputs
        signal analog_channels_out : xadcSamplesArray(0 to CONFIG_XADC_CHANNELS_NUM - 1);

        -- =================== Sample transmitter's interface ==================== --

        -- Transfer initialization signal (active high)
        signal sampler_tx_transfer : Std_logic;
        -- Sample to be transfered (latched on @in clk rising edge when @in transfer high and @out busy's low)
        signal sampler_tx_sample : Std_logic_vector(CONFIG_SAMPLE_WIDTH - 1 downto 0);

        -- =============== Interface of additional edge-detector ================= --

        -- Signal to be observed
        signal edge_detector_in : Std_logic;

        -- Detecion signal
        signal edge_detector_out : std_logic;

begin

    -- =======================================================================================================
    -- ----------------------------------------- Internal components ----------------------------------------- 
    -- =======================================================================================================

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
        sample_in              => sample_in,
        sample_out             => sample_out,
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

    -- Instance of the XADC-based analog sequential scanner
    analogSequenceReaderInstance: entity work.AnalogSequenceReader(logic)
    generic map (
        SYS_CLK_HZ       => CONFIG_SYS_CLK_HZ,
        SAMPLING_FREQ_HZ => CONFIG_XADC_SAMPLING_FREQ_HZ,
        CHANNELS_NUM     => CONFIG_XADC_CHANNELS_NUM
    )
    port map (
        reset_n      => reset_n,
        clk          => clk,
        anal_in_p    => anal_in_p,
        anal_in_n    => anal_in_n,
        mux_sel_out  => mux_sel_out,
        channels_out => analog_channels_out
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

    -- Falling edge on the `busy` output of the samples' reciving module is detected
    edge_detector_in <= sampler_rx_busy;
    -- Output data from the receiver is connected to the input of the pipeline
    sample_in <= Signed(sampler_rx_sample);

    -- Line detecting falling edge on the `busy` output of the RX module is conected to the `valid_in` pipe's input
    valid_in <= edge_detector_out;

    -- Output data from the pipe is connected to the transmitter's input
    sampler_tx_sample <= Std_logic_vector(sample_out);
    -- `transfer` input of the TX module is connected to the `valid_out` output of the pip
    sampler_tx_transfer <= valid_out;

    -- --------------------- Mapping of the effect's parameters to the analog channels -------------------- --

    -- Channel 0: `gain` of the clipping effect
    clipping_gain_in <= Unsigned(analog_channels_out(0));
    -- Channel 1: `saturation` of the clipping effect
    clipping_overdrive_in <= Unsigned(analog_channels_out(1));
    -- Channel 2: `depth` of the tremolo effect
    tremolo_depth_in <= Unsigned(analog_channels_out(2));
    -- Channel 3: `frequency` of the tremolo effect's LFO
    tremolo_frequency_in <= Unsigned(analog_channels_out(3));
    -- Channel 4: `depth` of the delay effect
    delay_depth_in <= Unsigned(analog_channels_out(4));
    -- Channel 5: `delay_gain` of the delay effect
    delay_delay_gain_in <= Unsigned(analog_channels_out(5));
    -- Channel 6: `depth` ofthe flanger effect
    flanger_depth_in <= Unsigned(analog_channels_out(6));
    -- Channel 7: `strength` of the flanger effect
    flanger_strength_in <= Unsigned(analog_channels_out(7));
    -- Channel 8: `frequency` of the flanger effect's LFO
    flanger_frequency_in <= Unsigned(analog_channels_out(8));

end architecture;
