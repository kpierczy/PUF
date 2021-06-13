-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    Effects pipe's testbench 
--    
-- @ Important: Remember to regenrate output of IP sources before running simulation!
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity EffectsPipeTb is
    generic(

        -- ============================================= Common parameters ============================================== --

        -- System clock frequency
        SYS_CLK_HZ : Positive := 100_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- ------------------------ Effect's parameters ------------------------ --

        -- Width of the input sample
        SAMPLE_WIDTH : Positive := 16;
        -- Width of the parameter inputs to the pipe
        PARAM_WIDTH : Positive := 12;
        
        -- --------------------- Input signal's parameters --------------------- --

        
        -- Type of the input wave (available: [sin/sin_rand])
        INPUT_TYPE : String := "sin";

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Natural := 440;
        -- Amplitude of the input wave in normalized range <0; 1>
        INPUT_AMPLITUDE : Real := 0.5;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive := 44_100;

        -- Mean of the gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_MEAN : Real := 0.0;
        -- Standard deviation gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_STD_DEV : Real := 0.02;


        -- ============================================ Effects' parameters ============================================= --

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
end entity EffectsPipeTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of EffectsPipeTb is
    
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
        signal sample_in : Signed(SAMPLE_WIDTH - 1 downto 0);
        -- Gained sample
        signal sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);

        -- ===================== Clipping effect's interface ==================== --

        -- Enable input (active high)
        signal clipping_enable_in : Std_logic := CLIPPING_ENABLE;
        -- Gain input
        signal clipping_gain_in : Unsigned(PARAM_WIDTH - 1 downto 0);
        -- Saturation level (for absolute value of the signal)
        signal clipping_overdrive_in : Unsigned(PARAM_WIDTH - 1 downto 0);


        -- ====================== Tremolo effect's interface ==================== --

        -- Enable input (active high)
        signal tremolo_enable_in : Std_logic := TREMOLO_ENABLE;
        -- Tremolo's depth aprameter (treated as value in <0, 1) range)
        signal tremolo_depth_in : Unsigned(PARAM_WIDTH - 1 downto 0);
        -- Number of system clock's ticks per modulation sample (minus 1)
        signal tremolo_frequency_in : Unsigned(PARAM_WIDTH - 1 downto 0);

        -- ======================= Delay effect's interface ===================== --

        -- Enable input (active high)
        signal delay_enable_in : Std_logic := DELAY_ENABLE;
        -- Depth level (index of the delayed sample being summed with the input)
        signal delay_depth_in : Unsigned(PARAM_WIDTH - 1 downto 0);
        -- Gain level pf the delayed summant (treated as value in <0,0.5) range)
        signal delay_delay_gain_in : Unsigned(PARAM_WIDTH - 1 downto 0);

        -- ====================== Flanger effect's interface ==================== --

        -- Enable input (active high)
        signal flanger_enable_in : Std_logic := FLANGER_ENABLE;
        -- Depth level
        signal flanger_depth_in : Unsigned(PARAM_WIDTH - 1 downto 0);
        -- Strength of the flanger effect
        signal flanger_strength_in : Unsigned(PARAM_WIDTH - 1 downto 0);
        -- Delay's modulation frequency
        signal flanger_frequency_in : Unsigned(PARAM_WIDTH - 1 downto 0);

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
    samplesGeneratorInstance: entity work.SamplesGenerator(logic)
    generic map (
        SYS_CLK_HZ             => SYS_CLK_HZ,
        SYS_RESET_TICKS        => SYS_RESET_TICKS,
        SAMPLE_WIDTH           => SAMPLE_WIDTH,
        INPUT_TYPE             => INPUT_TYPE,
        INPUT_FREQ_HZ          => INPUT_FREQ_HZ,
        INPUT_AMPLITUDE        => INPUT_AMPLITUDE,
        INPUT_SAMPLING_FREQ_HZ => INPUT_SAMPLING_FREQ_HZ,
        INPUT_RAND_MEAN        => INPUT_RAND_MEAN,
        INPUT_RAND_STD_DEV     => INPUT_RAND_STD_DEV
    )
    port map (
        reset_n   => reset_n,
        clk       => clk,
        sample_in => sample_in,
        valid_in  => valid_in
    );

    -- =================================================================================
    -- Module's instance
    -- =================================================================================

    -- Instance of the effects pipe module
    effectsPipeInstance: entity work.EffectsPipe
    generic map (
        SAMPLE_WIDTH => SAMPLE_WIDTH,
        PARAM_WIDTH  => PARAM_WIDTH
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

    -- =================================================================================
    -- Clipping effect's stimulus
    -- =================================================================================

    -- Transform signal into the signed value using saturation
    clipping_gain_in <= real_to_unsigned_sat(clipping_gain_tmp, PARAM_WIDTH);
    -- Generate gain signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => CLIPPING_GAIN_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => CLIPPING_GAIN_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(CLIPPING_GAIN_AMPLITUDE * (2**PARAM_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => clipping_gain_tmp
    );

    -- Transform signal into the signed value using saturation
    clipping_overdrive_in <= real_to_unsigned_sat(clipping_overdrive_tmp, PARAM_WIDTH);
    -- Generate saturation signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => CLIPPING_OVERDRIVE_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => CLIPPING_OVERDRIVE_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(CLIPPING_OVERDRIVE_AMPLITUDE * (2**PARAM_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => clipping_overdrive_tmp
    );

    -- =================================================================================
    -- Tremolo effect's stimulus
    -- =================================================================================

    -- Transform signal into the signed value using saturation
    tremolo_depth_in <= real_to_unsigned_sat(tremolo_depth_tmp, PARAM_WIDTH);
    -- Generate `depth` signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => TREMOLO_DEPTH_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => TREMOLO_DEPTH_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(TREMOLO_DEPTH_AMPLITUDE * (2**PARAM_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => tremolo_depth_tmp
    );

    -- Transform signal into the signed value using saturation
    tremolo_frequency_in <= real_to_unsigned_sat(tremolo_frequency_tmp, PARAM_WIDTH);
    -- Generate `modulation_ticks_per_sample_in` signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => TREMOLO_FREQUENCY_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => TREMOLO_FREQUENCY_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(TREMOLO_FREQUENCY_AMPLITUDE * (2**PARAM_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => tremolo_frequency_tmp
    );

    -- =================================================================================
    -- Delay effect's stimulus
    -- =================================================================================

    -- Transform signal into the signed value using saturation
    delay_delay_gain_in <= real_to_unsigned_sat(delay_delay_gain_tmp, PARAM_WIDTH);
    -- Generate `modulation_ticks_per_sample_in` signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => DELAY_DELAY_GAIN_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => DELAY_DELAY_GAIN_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(DELAY_DELAY_GAIN_AMPLITUDE * (2**PARAM_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => delay_delay_gain_tmp
    );

    -- Transform signal into the signed value using saturation
    delay_depth_in <= real_to_unsigned_sat(delay_depth_tmp, PARAM_WIDTH);
    -- Generate `depth` signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => DELAY_DEPTH_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => DELAY_DEPTH_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(DELAY_DEPTH_AMPLITUDE * (2**PARAM_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => delay_depth_tmp
    );

    -- =================================================================================
    -- Flanger effect's stimulus
    -- =================================================================================

    -- Transform signal into the signed value using saturation
    flanger_strength_in <= real_to_unsigned_sat(flanger_strength_tmp, PARAM_WIDTH);
    -- Generate `strength` signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => FLANGER_STRENGTH_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => FLANGER_STRENGTH_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(FLANGER_STRENGTH_AMPLITUDE * (2**PARAM_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => flanger_strength_tmp
    );

    -- Transform signal into the signed value using saturation
    flanger_depth_in <= real_to_unsigned_sat(flanger_depth_tmp, PARAM_WIDTH);
    -- Generate `depth` signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => FLANGER_DEPTH_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => FLANGER_DEPTH_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(FLANGER_DEPTH_AMPLITUDE * (2**PARAM_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => flanger_depth_tmp
    );

    -- Transform signal into the signed value using saturation
    flanger_frequency_in <= real_to_unsigned_sat(flanger_frequency_tmp, PARAM_WIDTH);
    -- Generate `frequency` signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => FLANGER_FREQUENCY_TOGGLE_FREQ_HZ,
        PHASE_SHIFT  => FLANGER_FREQUENCY_PHASE_SHIFT,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(FLANGER_FREQUENCY_AMPLITUDE * (2**PARAM_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => flanger_frequency_tmp
    );

end architecture logic;
