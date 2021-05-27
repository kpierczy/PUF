-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-27 02:46:08
-- @ Modified time: 2021-05-27 02:46:13
-- @ Description: 
--    
--    Sequential composition of the implemented guitar effects.
--    
-- @ Note : Choice of generic parameters of the effects was left to the default parameters set in their corresponding files.
-- @ Note : At the moment effects' configuration (implicitly) assumes that the sampling frequency is 48000Hz and samples are 
--      16-bit signed values.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity EffectsPipe is
    generic(
        -- Width of samples
        SAMPLE_WIDTH : Positive range 2 to Positive'High;
        -- Width of the parameter inputs
        PARAM_WIDTH : Positive
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
        sample_in : in Signed;
        -- Gained sample
        sample_out : out Signed;

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
        -- Number of system clock's ticks per modulation sample (minus 1)
        tremolo_ticks_per_modulation_sample_in : in Unsigned(PARAM_WIDTH - 1 downto 0);

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
        -- Delay's modulation frequency
        flanger_ticks_per_delay_sample_in : in Unsigned(PARAM_WIDTH - 1 downto 0)

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
    signal clipping_gain_internal_in : Unsigned;
    -- Saturation level (for absolute value of the signal)
    signal clipping_saturation_internal_in : Unsigned;
    
    -- ====================== Tremolo effect's interface ==================== --

    -- Input/output sample
    signal tremolo_sample_in, tremolo_sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- `New input/output sample` signal
    signal tremolo_valid_in, tremolo_valid_out : Std_logic;

    -- Tremolo's depth aprameter (treated as value in <0, 1) range)
    signal tremolo_depth_internal_in : Unsigned;
    -- Number of system clock's ticks per modulation sample (minus 1)
    signal tremolo_ticks_per_modulation_sample_internal_in : Unsigned;
    
    -- ======================= Delay effect's interface ===================== --

    -- Input/output sample
    signal delay_sample_in, delay_sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- `New input/output sample` signal
    signal delay_valid_in, delay_valid_out : Std_logic;

    -- Depth level (index of the delayed sample being summed with the input)
    signal delay_depth_internal_in : Unsigned;
    -- Attenuation level pf the delayed summant (treated as value in <0,0.5) range)
    signal delay_attenuation_internal_in : Unsigned;
    
    -- ====================== Flanger effect's interface ==================== --

    -- Input/output sample
    signal flanger_sample_in, flanger_sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- `New input/output sample` signal
    signal flanger_valid_in, flanger_valid_out : Std_logic;

    -- Depth level
    signal flanger_depth_internal_in : Unsigned;
    -- Strength of the flanger effect
    signal flanger_strength_internal_in : Unsigned;
    -- Delay's modulation frequency
    signal flanger_ticks_per_delay_sample_internal_in : Unsigned;

begin

    -- =======================================================================================================
    -- ----------------------------------------- Internal components ----------------------------------------- 
    -- =======================================================================================================

    -- Clipping effect module
    clippingEffectInstance : entity work.ClippingEffect
    generic map (
        SAMPLE_WIDTH => SAMPLE_WIDTH
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
        SAMPLE_WIDTH => SAMPLE_WIDTH
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
        SAMPLE_WIDTH      => SAMPLE_WIDTH
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
        SAMPLE_WIDTH => SAMPLE_WIDTH
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
    --    that it is used in full scale) can be mapped to proper effect's parameters' ranges.
    -- ---------------------------------------------------------------------------------------

    -- ==================================== Clipping effect's interface =================================== --

    -- ---------------------------------------------------------------------------------------
    -- Range of the gain effect is regulated by the clipping module's default parameters so
    -- MSB of the external inptu can be just mapped to the MSB of the module.
    -- ---------------------------------------------------------------------------------------

    -- External input wider than interna;
    clippingGainExternalWiderCase : if clipping_gain_in'length >= clipping_gain_internal_in'length generate
        clipping_gain_internal_in <= 
            clipping_gain_in(clipping_gain_in'left downto clipping_gain_in'left - clipping_gain_internal_in'left)
    end generate

    -- External input more narrow than interna;
    clippingGainExternalMoreNarrowrCase : if clipping_gain_in'length < clipping_gain_internal_in'length generate
        clipping_gain_internal_in <= 
            (clipping_gain_internal_in'left downto clipping_gain_internal_in'left - clipping_gain_in'left => clipping_gain_in,
        others => '0')
    end generate
    
    -- ---------------------------------------------------------------------------------------
    -- Saturation level was inverted so that `more saturation` means `more clipping`. 
    -- Moreover external input is mapped to the internal one in such way that maximum
    -- saturation cuts top 1/4 of the samples' range
    -- ---------------------------------------------------------------------------------------   

    clipping_saturation_internal_in;
    
    -- ============================= Tremolo effect's interface =========================== --

    tremolo_depth_internal_in;
    tremolo_ticks_per_modulation_sample_internal_in;
    
    -- ============================== Delay effect's interface ============================ --

    delay_depth_internal_in;
    delay_attenuation_internal_in;
    
    -- ============================= Flanger effect's interface =========================== --

    flanger_depth_internal_in;
    flanger_strength_internal_in;
    flanger_ticks_per_delay_sample_internal_in;

end architecture logic;
