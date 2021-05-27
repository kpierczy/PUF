-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-27 02:46:08
-- @ Modified time: 2021-05-27 02:46:13
-- @ Description: 
--    
--    Sequential composition of the implemented guitar effects.
--    
-- @ Note : Choice of generic parameters of the effects was left to the default parameters set in their corresponding files.
-- @ Note : At the moment effects' configuration (implicitly) assumes that the sampling frequency is 44100Hz and samples are 
--      16-bit signed values as well as 100MHz system clock.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tremolo.all;
use work.pipe_config.all;
use work.xadc.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity EffectsPipe is
    generic(
        -- Width of samples
        SAMPLE_WIDTH : Positive range 2 to Positive'High := CONFIG_SAMPLE_WIDTH;
        -- Width of the parameter inputs
        PARAM_WIDTH : Positive := XADC_SAMPLE_WIDTH
    );
    port(

        -- ====================== Effects' common interface ===================== --

        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- `New input sample` signal (rising-edge-active)
        valid_in : in Std_logic;
        -- `Output sample ready` signal (rising-edge-active)
        valid_out : out Std_logic;

        -- Input sample
        sample_in : in Signed(SAMPLE_WIDTH - 1 downto 0);
        -- Gained sample
        sample_out : out Signed(SAMPLE_WIDTH - 1 downto 0);

        -- ===================== Clipping effect's interface ==================== --

        -- Enable input (active high)
        clipping_enable_in : in Std_logic;
        -- Gain input
        clipping_gain_in : in Unsigned(PARAM_WIDTH - 1 downto 0);
        -- Saturation level (for absolute value of the signal)
        clipping_saturation_in : in Unsigned(PARAM_WIDTH - 1 downto 0);


        -- ====================== Tremolo effect's interface ==================== --

        -- Enable input (active high)
        tremolo_enable_in : in Std_logic;
        -- Tremolo's depth aprameter (treated as value in <0, 1) range)
        tremolo_depth_in : in Unsigned(PARAM_WIDTH - 1 downto 0);
        -- Frequency-like value tremolo's LFO
        tremolo_frequency_in : in Unsigned(PARAM_WIDTH - 1 downto 0);

        -- ======================= Delay effect's interface ===================== --

        -- Enable input (active high)
        delay_enable_in : in Std_logic;
        -- Depth level (index of the delayed sample being summed with the input)
        delay_depth_in : in Unsigned(PARAM_WIDTH - 1 downto 0);
        -- Attenuation level pf the delayed summant (treated as value in <0,0.5) range)
        delay_attenuation_in : in Unsigned(PARAM_WIDTH - 1 downto 0);

        -- ====================== Flanger effect's interface ==================== --

        -- Enable input (active high)
        flanger_enable_in : in Std_logic;
        -- Depth level
        flanger_depth_in : in Unsigned(PARAM_WIDTH - 1 downto 0);
        -- Strength of the flanger effect
        flanger_strength_in : in Unsigned(PARAM_WIDTH - 1 downto 0);
        -- Frequency-like value flanger's LFO
        flanger_frequency_in : in Unsigned(PARAM_WIDTH - 1 downto 0)

    );
end entity EffectsPipe;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of EffectsPipe is

    -- ===================== Clipping effect's interface ==================== --

    -- Input/output sample
    signal clipping_sample_in, clipping_sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- `New input/output sample` signal
    signal clipping_valid_in, clipping_valid_out : Std_logic;

    -- Gain input
    signal clipping_gain_internal_in : Unsigned(CONFIG_CLIPPING_GAIN_WIDTH - 1 downto 0);
    -- Saturation level (for absolute value of the signal)
    signal clipping_saturation_internal_in : Unsigned(SAMPLE_WIDTH - 2 downto 0);
    
    -- ====================== Tremolo effect's interface ==================== --

    -- Input/output sample
    signal tremolo_sample_in, tremolo_sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- `New input/output sample` signal
    signal tremolo_valid_in, tremolo_valid_out : Std_logic;

    -- Tremolo's depth aprameter (treated as value in <0, 1) range)
    signal tremolo_depth_internal_in : Unsigned(CONFIG_TREMOLO_DEPTH_WIDTH - 1 downto 0);
    -- Number of system clock's ticks per modulation sample (minus 1)
    signal tremolo_ticks_per_modulation_sample_internal_in : Unsigned(CONFIG_TREMOLO_TICKS_PER_SAMPLE_WIDTH - 1 downto 0);
    
    -- ======================= Delay effect's interface ===================== --

    -- Input/output sample
    signal delay_sample_in, delay_sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- `New input/output sample` signal
    signal delay_valid_in, delay_valid_out : Std_logic;

    -- Depth level (index of the delayed sample being summed with the input)
    signal delay_depth_internal_in : Unsigned(CONFIG_DELAY_DEPTH_WIDTH - 1 downto 0);
    -- Attenuation level pf the delayed summant (treated as value in <0,0.5) range)
    signal delay_attenuation_internal_in : Unsigned(CONFIG_DELAY_ATTENUATION_WIDTH - 1 downto 0);
    
    -- ====================== Flanger effect's interface ==================== --

    -- Input/output sample
    signal flanger_sample_in, flanger_sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- `New input/output sample` signal
    signal flanger_valid_in, flanger_valid_out : Std_logic;

    -- Depth level
    signal flanger_depth_internal_in : Unsigned(CONFIG_FLANGER_DEPTH_WIDTH - 1 downto 0);
    -- Strength of the flanger effect
    signal flanger_strength_internal_in : Unsigned(CONFIG_FLANGER_STRENGTH_WIDTH - 1 downto 0);
    -- Delay's modulation frequency
    signal flanger_ticks_per_delay_sample_internal_in : Unsigned(CONFIG_FLANGER_TICKS_PER_DELAY_SAMPLE_WIDTH - 1 downto 0);

    -- ========================= Auxiliary functions ======================== --

    -- Function returns @in right vector truncated or extended to @in len bits in sucha a way
    -- that elements are added/removed to/from the right end of the @in right.
    function resize_from_right(len : Positive; right : Unsigned) return Unsigned is
        variable ret : unsigned(len - 1 downto 0) := (others => '0');
    begin
        -- If right vector should be extended
        if(len > right'length) then
            for i in 0 to right'length - 1 loop
                ret(ret'left - i) := right(right'left - i);
            end loop;
        -- If right vector should be truncated
        elsif(len < right'length) then
            for i in 0 to len - 1 loop
                ret(ret'left - i) := right(right'left - i);
            end loop;
        -- If vectors are of the same size
        else
            ret := right;
        end if;

        return ret;

    end function;

    -- Function calculating completion of the unsigned number
    function complete(vec : Unsigned) return Unsigned is
        variable ret : Unsigned(vec'range);
    begin
        for i in vec'range loop
            ret(i) := not(vec(i));
        end loop;
        return ret;
    end function;

begin

    -- =======================================================================================================
    -- ----------------------------------------- Internal components ----------------------------------------- 
    -- =======================================================================================================

    -- Clipping effect module
    clippingEffectInstance : entity work.ClippingEffect
    generic map (
        SAMPLE_WIDTH => SAMPLE_WIDTH,
        GAIN_WIDTH   => CONFIG_CLIPPING_GAIN_WIDTH,
        TWO_POW_DIV  => CONFIG_CLIPPING_TWO_POW_DIV
    )
    port map (
        reset_n       => reset_n,
        clk           => clk,
        enable_in     => clipping_enable_in,
        valid_in      => clipping_valid_in,
        valid_out     => clipping_valid_out,
        sample_in     => clipping_sample_in,
        sample_out    => clipping_sample_out,
        gain_in       => clipping_gain_internal_in,
        saturation_in => clipping_saturation_internal_in
    );

    -- Tremolo effect module
    tremoloEffectInstance : entity work.TremoloEffect
    generic map (
        SAMPLE_WIDTH           => SAMPLE_WIDTH,
        GENERATOR_TYPE         => CONFIG_TREMOLO_GENERATOR_TYPE,
        DEPTH_WIDTH            => CONFIG_TREMOLO_DEPTH_WIDTH,
        LFO_SAMPLE_WIDTH       => CONFIG_TREMOLO_LFO_SAMPLE_WIDTH,
        TICKS_PER_SAMPLE_WIDTH => CONFIG_TREMOLO_TICKS_PER_SAMPLE_WIDTH
    )
    port map (
        reset_n                        => reset_n,
        clk                            => clk,
        enable_in                      => tremolo_enable_in,
        valid_in                       => tremolo_valid_in,
        valid_out                      => tremolo_valid_out,
        sample_in                      => tremolo_sample_in,
        sample_out                     => tremolo_sample_out,
        depth_in                       => tremolo_depth_internal_in,
        ticks_per_modulation_sample_in => tremolo_ticks_per_modulation_sample_internal_in
    );

    -- Delay effect module
    delayEffectInstance : entity work.DelayEffect
    generic map (
        SAMPLE_WIDTH      => SAMPLE_WIDTH,
        ATTENUATION_WIDTH => CONFIG_DELAY_ATTENUATION_WIDTH,
        DEPTH_WIDTH       => CONFIG_DELAY_DEPTH_WIDTH,
        BRAM_SAMPLES_NUM  => CONFIG_DELAY_BRAM_SAMPLES_NUM,
        BRAM_ADDR_WIDTH   => CONFIG_DELAY_BRAM_ADDR_WIDTH,
        BRAM_LATENCY      => CONFIG_DELAY_BRAM_LATENCY
    )
    port map (
        reset_n        => reset_n,
        clk            => clk,
        enable_in      => delay_enable_in,
        valid_in       => delay_valid_in,
        valid_out      => delay_valid_out,
        sample_in      => delay_sample_in,
        sample_out     => delay_sample_out,
        depth_in       => delay_depth_internal_in,
        attenuation_in => delay_attenuation_internal_in
    );

    -- Flanger effect module
    flangerEffectInstance : entity work.FlangerEffect
    generic map (
        SAMPLE_WIDTH                 => SAMPLE_WIDTH,
        STRENGTH_WIDTH               => CONFIG_FLANGER_STRENGTH_WIDTH,
        DEPTH_WIDTH                  => CONFIG_FLANGER_DEPTH_WIDTH,
        TICKS_PER_DELAY_SAMPLE_WIDTH => CONFIG_FLANGER_TICKS_PER_DELAY_SAMPLE_WIDTH,
        DELAY_BRAM_SAMPLES_NUM       => CONFIG_FLANGER_DELAY_BRAM_SAMPLES_NUM,
        DELAY_BRAM_ADDR_WIDTH        => CONFIG_FLANGER_DELAY_BRAM_ADDR_WIDTH,
        DELAY_BRAM_LATENCY           => CONFIG_FLANGER_DELAY_BRAM_LATENCY,
        LFO_BRAM_SAMPLES_NUM         => CONFIG_FLANGER_LFO_BRAM_SAMPLES_NUM,
        LFO_BRAM_ADDR_WIDTH          => CONFIG_FLANGER_LFO_BRAM_ADDR_WIDTH,
        LFO_BRAM_DATA_WIDTH          => CONFIG_FLANGER_LFO_BRAM_DATA_WIDTH,
        LFO_BRAM_LATENCY             => CONFIG_FLANGER_LFO_BRAM_LATENCY
    )
    port map (
        reset_n                   => reset_n,
        clk                       => clk,
        enable_in                 => flanger_enable_in,
        valid_in                  => flanger_valid_in,
        valid_out                 => flanger_valid_out,
        sample_in                 => flanger_sample_in,
        sample_out                => flanger_sample_out,
        depth_in                  => flanger_depth_internal_in,
        strength_in               => flanger_strength_internal_in,
        ticks_per_delay_sample_in => flanger_ticks_per_delay_sample_internal_in
    );

    -- =======================================================================================================
    -- ------------------------------------ Modules' chaining components -------------------------------------
    -- =======================================================================================================

    -- 1. Clipping
    clipping_sample_in <= sample_in;
    clipping_valid_in <= valid_in;

    -- 2. Tremolo
    tremolo_sample_in <= clipping_sample_out;
    tremolo_valid_in <= clipping_valid_out;

    -- 3. Delay
    delay_sample_in <= tremolo_sample_out;
    delay_valid_in <= tremolo_valid_out;

    -- 4. Delay
    flanger_sample_in <= delay_sample_out;
    flanger_valid_in <= delay_valid_out;

    -- 5 Output
    sample_out <= flanger_sample_out;
    valid_out <= flanger_valid_out;

    -- =======================================================================================================
    -- ----------------------------------------- Parameters' scaling -----------------------------------------
    -- =======================================================================================================

    -- ---------------------------------------------------------------------------------------
    -- @note : Parameter inputs to the effects' pipe have to be of a specified length as they
    --    will be driven from the common source (i.e. XADC measurements of potentiometers).
    --    On the other hand, these parameters have various meaning and so can have various
    --    length. Underlaying section scales parameters so that the input ranges (assummed
    --    that they are used in full scale) can be mapped to proper effect's parameters' 
    --    ranges.
    -- ---------------------------------------------------------------------------------------

    -- ==================================== Clipping effect's interface =================================== --

    -- ---------------------------------------------------------------------------------------
    -- Range of the gain effect is regulated by the clipping module's default parameters so
    -- MSBs of the external input can be just mapped to the MSBs of the module.
    -- ---------------------------------------------------------------------------------------

    -- External input wider than interna;
    clipping_gain_internal_in <= resize_from_right(
        CONFIG_CLIPPING_GAIN_WIDTH, clipping_gain_in
    );
    
    -- ---------------------------------------------------------------------------------------
    -- Saturation level was inverted by completion (to 1) of the input signal so that `more
    -- saturation` means `more clipping`. 
    --
    -- Moreover external input is mapped to the internal one in such way that maximum
    -- saturation cuts top 1/4 of the samples' range (i.e. 1/2 of the `saturation_in` range
    -- as it's width is one bit less as the samples' width). It is accomplished by setting
    -- MSB of the saturation level to '0' and mapping MSBs of the external signal to the
    -- Rest of the parameter's bits.
    -- ---------------------------------------------------------------------------------------   

    clipping_saturation_internal_in <= complete(b"0" & resize_from_right(
        CONFIG_SAMPLE_WIDTH - 2, clipping_saturation_in
    ));
    
    -- ============================= Tremolo effect's interface =========================== --

    -- ---------------------------------------------------------------------------------------
    -- Depth level's granularity is controlled by it's overall width. From view of the 
    -- external input it is enough to drive MSBs of the input
    -- ---------------------------------------------------------------------------------------
    
    tremolo_depth_internal_in <= resize_from_right(
        CONFIG_TREMOLO_DEPTH_WIDTH, tremolo_depth_in
    );

    -- ---------------------------------------------------------------------------------------
    -- At the moment width of the `ticks_per_modulation_sample_in` is set to 17-bit. It can
    -- provide internal LFO's (Low Frequency Oscilator) frequency form range ~ <0.74, 97k> Hz.
    -- The higher value of the input the LOWER frequency (as the period is longer). To revert 
    -- this trend the completion (to 1) of the external input will be passed to the module's
    -- input.
    --
    --  97kHz it too high frequency to be recorded with the 48kHz samplingrate and so it 
    --  should never be set. To reduce the maximum frequency the 2^N value should always be
    --  added to the actual preset. If so, the maximum frequency is divided by 2^N. N was 
    --  choosen as 10. It truncates maximum frequencie's level to ~ 95 Hz. This value is next
    --  added to the external input's value with saturation.
    --
    -- @ Note: LFO's frequency is described as f_LFO[t] = f_SYS / A_LFO / (ticks[t] + 1),
    --     where
    --
    --     - f_LFO[t] - frequency of the LFO in [Hz]
    --     - f_SYS - system clock's frequency in [Hz]
    --     - A_LFO - amplitude of the LFO generator
    --     - ticks[t] - value on the `ticks_per_delay_sample_in` input
    --
    --  From this equation it can be seen that adding 2^N to the mentioned input reduces 
    --  maximum frequency by 2^N factor.
    -- ---------------------------------------------------------------------------------------

    tremoloLFOSumInstance : entity work.sumUnsignedSat
    port map (
        a_in       => to_unsigned(2**10, CONFIG_TREMOLO_TICKS_PER_SAMPLE_WIDTH),
        b_in       => resize_from_right(CONFIG_TREMOLO_TICKS_PER_SAMPLE_WIDTH, complete(tremolo_frequency_in)),
        result_out => tremolo_ticks_per_modulation_sample_internal_in,
        err_out    => open
    );
    
    -- ============================== Delay effect's interface ============================ --

    -- ---------------------------------------------------------------------------------------
    -- Attenuation input can always be used in the full range. The only fact to bear in mind
    -- is that MSBs of the external input should always correspond to MSBs of the module's
    -- input to cover full range (even if with not full granularity)
    -- ---------------------------------------------------------------------------------------

    delay_attenuation_internal_in <= resize_from_right(
        CONFIG_DELAY_ATTENUATION_WIDTH, delay_attenuation_in
    );

    -- ---------------------------------------------------------------------------------------
    -- Depth input can always be used in the full range. The only fact to bear in mind is that
    -- MSBs of the external input should always correspond to MSBs of the module's input
    -- to cover full range (even if with not full granularity)
    -- ---------------------------------------------------------------------------------------

    delay_depth_internal_in <= resize_from_right(
        CONFIG_DELAY_DEPTH_WIDTH, delay_depth_in
    );
    
    -- ============================= Flanger effect's interface =========================== --

    -- ---------------------------------------------------------------------------------------
    -- Strength level of the delayed summand is treated as value in range <0, 1). The only
    -- importnt fact to fully utilize the offerred range (even though not always the full
    -- granularity) is to map MSBs of the external input to the MSBs of the module's input
    -- ---------------------------------------------------------------------------------------
    
    flanger_strength_internal_in <= resize_from_right(
        CONFIG_FLANGER_STRENGTH_WIDTH, flanger_strength_in
    );

    -- ---------------------------------------------------------------------------------------
    -- The `depth_in` input of the flanger effect is always treated as the value in <0, 1)
    -- range that scales the amplitude of the internal LFO generator. Similarly to the
    -- `strength_in` it is important to map MSBs of the external input to the MSBs of the
    -- effect's input.
    -- ---------------------------------------------------------------------------------------

    flanger_depth_internal_in <= resize_from_right(
        CONFIG_FLANGER_DEPTH_WIDTH, flanger_depth_in
    );

    -- ---------------------------------------------------------------------------------------
    -- At the moment width of the `ticks_per_modulation_sample_in` is set to 20-bit. It can
    -- provide internal LFO's (Low Frequency Oscilator) frequency form range ~ <0.1, 97k> Hz.
    -- The higher value of the input the LOWER frequency (as the period is longer). To revert 
    -- this trend the completion (to 1) of the external input will be passed to the module's
    -- input.
    --
    --  97kHz it too high frequency for the flanger effects. According to articles given in
    --  the project's documentation, the flanger's LFO's frequency should not exceed 4Hz.
    --  To reduce the maximum frequency, the N least significant bits of the mentioned
    --  input should always be set to '1'. If so, the maximum frequency is divided by
    --  2^N. N was choosen as 15. It truncates maximum frequencie's level to ~ 3 Hz. Rest of
    --  the `non-fixed` bits of the module's input was mapped to the MSBs of the external 
    --  input.
    --
    -- @ Note: LFO's frequency is described as f_LFO[t] = f_SYS / A_LFO / (ticks[t] + 1),
    --     where
    --
    --     - f_LFO[t] - frequency of the LFO in [Hz]
    --     - f_SYS - system clock's frequency in [Hz] (assummed 100MHz)
    --     - A_LFO - amplitude of the LFO generator
    --     - ticks[t] - value on the `ticks_per_delay_sample_in` input
    --
    --  From this equation it can be seen that adding 2^N to the mentioned input reduces 
    --  maximum frequency by 2^N factor.
    -- ---------------------------------------------------------------------------------------

    flangerLFOSumInstance : entity work.sumUnsignedSat
    port map (
        a_in       => to_unsigned(2**15, CONFIG_FLANGER_TICKS_PER_DELAY_SAMPLE_WIDTH),
        b_in       => resize_from_right(CONFIG_FLANGER_TICKS_PER_DELAY_SAMPLE_WIDTH,complete(flanger_frequency_in)),
        result_out => flanger_ticks_per_delay_sample_internal_in,
        err_out    => open
    );

end architecture logic;
