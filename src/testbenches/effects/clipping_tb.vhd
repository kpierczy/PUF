-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    Clipping effect's testbench 
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity ClippingEffectTb is
    generic(

        -- System clock frequency
        SYS_CLK_HZ : Positive := 200_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- ======================== Effect's parameters ========================= --

        -- Width of the input sample
        SAMPLE_WIDTH : Positive := 16;

        -- ========================= Gain's parameters ========================== --

        -- Width of the gain input (gain's width must be smaller than sample's width)
        GAIN_WIDTH : Positive := 12;
        -- Index of the 2's power that the multiplication's result is divided by before saturation
        TWO_POW_DIV : Natural := 11;
        
        -- ===================== Input signal's parameters ====================== --

        -- -------------------------------------------------------------------------
        -- @Note: Stimulus signals for effect's parameters are generated as random 
        --    steps with given frequency and amplitude.
        -- -------------------------------------------------------------------------

        -- Type of the input wave (available: [sin])
        INPUT_TYPE : String := "sin";

        -- Frequency of the input signal 
        INPUT_FREQU_HZ : Natural := 2000;
        -- Amplitude of the input wave in normalized range <0; 1>
        INPUT_AMPLITUDE : Real := 0.5;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive := 44100;

        -- ================ Effect parameters' stimulus signals ================= --

        -- -------------------------------------------------------------------------
        -- @Note: Stimulus signals for effect's parameters are generated as random 
        --    steps with given frequency and amplitude.
        -- -------------------------------------------------------------------------

        -- Amplitudes of gain values in normalized range <0; 1>
        GAIN_AMPLITUDE : Real := 0.75;
        -- Frequency of the changes of `gain_in` input
        GAIN_TOGGLE_FREQ_HZ : Natural := 120;

        -- Amplitudes of clips in normalized range <0; 1>
        SATURATION_AMPLITUDE : Real := 0.75;
        -- Frequency of the changes of `saturation_in` input
        SATURATION_TOGGLE_FREQ_HZ : Natural := 100

    );
end entity ClippingEffectTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of ClippingEffectTb is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    
    
    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- ================== Common effects's interface ================== --

    -- Module's enable signal
    signal enable_in : Std_logic := '1';
    -- Input and output samples
    signal sample_in, sample_out : Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');

    -- Signal for new sample on input (rising-edge-active)
    signal valid_in : Std_logic := '0';
    -- Signal for new sample on output (rising-edge-active)
    signal valid_out : Std_logic;

    -- ================= Specific effects's interface ================= --

    -- Module's gain
    signal gain_in : Unsigned(GAIN_WIDTH - 1 downto 0);
    -- Module's saturation
    signal saturation_in : Unsigned(SAMPLE_WIDTH - 2 downto 0);

    -- ====================== Auxiliary signals ====================== --

    -- Real-converted input signal
    signal sample_in_tmp : Real;
    -- Real-converted gain signal
    signal gain_in_tmp : Real;
    -- Real-converted saturation signal
    signal saturation_in_tmp : Real;

begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Clock signal
    clock_tb(CLK_PERIOD, clk);

    -- Reset signal
    reset_tb(SYS_RESET_TICKS * CLK_PERIOD, reset_n);

    -- =================================================================================
    -- Module's instance
    -- =================================================================================

    -- Instance of the clipping effect's module
    clippingEffectInstance : entity work.ClippingEffect(logic)
    generic map(
        SAMPLE_WIDTH => SAMPLE_WIDTH,
        GAIN_WIDTH   => GAIN_WIDTH,
        TWO_POW_DIV  => TWO_POW_DIV
    )
    port map(
        reset_n       => reset_n,
        clk           => clk,
        enable_in     => enable_in,
        valid_in      => valid_in,
        valid_out     => valid_out,
        sample_in     => sample_in,
        gain_in       => gain_in,
        saturation_in => saturation_in,
        sample_out    => sample_out
    );

    -- =================================================================================
    -- Input signals' generation 
    -- =================================================================================

    -- Generate input signal : sin
    inputSin : if INPUT_TYPE = "sin" generate
        sample_in <= to_signed(integer(sample_in_tmp), SAMPLE_WIDTH);
        generate_sin(
            SYS_CLK_HZ   => SYS_CLK_HZ,
            FREQUENCY_HZ => INPUT_FREQU_HZ,
            PHASE_SHIFT  => 0.0,
            AMPLITUDE    => Real(INPUT_AMPLITUDE) * (2**(SAMPLE_WIDTH - 1) - 1),
            OFFSET       => 0.0,
            reset_n      => reset_n,
            clk          => clk,
            wave         => sample_in_tmp
        );
    end generate;

    -- Generate gain signal
    gain_in <= to_unsigned(Natural(gain_in_tmp), GAIN_WIDTH);
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => GAIN_TOGGLE_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(GAIN_AMPLITUDE * (2**GAIN_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => gain_in_tmp
    );

    -- Generate saturation signal
    saturation_in <= to_unsigned(Natural(saturation_in_tmp), SAMPLE_WIDTH - 1);
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => SATURATION_TOGGLE_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(SATURATION_AMPLITUDE * (2**(SAMPLE_WIDTH - 1) - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => saturation_in_tmp
    );

    -- =================================================================================
    -- Input signal's sampling process
    -- =================================================================================

    -- Enable `enable_in` signal on end of reset
    enable_on_end_of_reset(
        SYS_CLK_HZ       => SYS_CLK_HZ,
        ENABLE_DELAY_CLK => 0,
        clk              => clk,
        reset_n          => reset_n,
        sig              => enable_in
    );

    -- Generate sampling pulse 
    generate_clk(
        SYS_CLK_HZ       => SYS_CLK_HZ,
        FREQUENCY_HZ     => INPUT_SAMPLING_FREQ_HZ,
        reset_n          => reset_n,
        clk              => clk,
        wave             => valid_in
    );

end architecture logic;
