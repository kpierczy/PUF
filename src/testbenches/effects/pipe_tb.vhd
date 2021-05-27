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
        -- Width of the parameter inputs to the pipe
        PARAM_WIDTH : Positive := 12;

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

        -- Type of the input wave (available: [sin/sin_rand])
        INPUT_TYPE : String := "sin_rand";

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Natural := 1000;
        -- Amplitude of the input wave in normalized range <0; 1>
        INPUT_AMPLITUDE : Real := 0.5;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive := 100_000;

        -- Mean of the gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_MEAN : Real := 0.0;
        -- Standard deviation gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_STD_DEV : Real := 0.02;

    );
end entity ClippingEffectTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of ClippingEffectTb is
    
    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- ================== Common effects's interface ================== --

    -- Module's enable signal and it's negation
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

    -- Real-converted gain signal
    signal gain_tmp : Real;
    -- Real-converted saturation signal
    signal saturation_tmp : Real;

begin

    -- =================================================================================
    -- Common effects' benchtable
    -- =================================================================================

    -- Instance of the common features regarding guitar effects' testing
    pipeTestbenchInstance: entity work.PipeTestbench(logic)
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
        enable_in => enable_in,
        sample_in => sample_in,
        valid_in  => valid_in
    );

    -- =================================================================================
    -- Module's instance
    -- =================================================================================

    -- Instance of the effects pipe module
    pipe

    -- =================================================================================
    -- Input parameters' generation 
    -- =================================================================================


end architecture logic;
