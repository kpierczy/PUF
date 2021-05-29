-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    Delay effect's testbench 
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity DelayEffectTb is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Positive := 100_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- ======================== Effect's parameters ========================= --

        -- Width of the input sample
        SAMPLE_WIDTH : Positive := 16;

        -- Width of the @in delay_gain_in port
        DELAY_GAIN_WIDTH : Positive := 8;
        -- Width of the @in depth port
        DEPTH_WIDTH : Positive := 8;

        -- =========================== BRAM parameters ========================== --

        -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
        BRAM_SAMPLES_NUM : Positive := 400;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive := 16;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive := 2;
        
        -- ===================== Input signal's parameters ====================== --

        -- Type of the input wave (available: [sin/sin_rand])
        INPUT_TYPE : String := "sin";

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Positive := 440;
        -- Amplitude of the input wave in normalized range <0;1>
        INPUT_AMPLITUDE : Real := 0.5;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive := 44_100;

        -- Mean of the gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_MEAN : Real := 0.0;
        -- Standard deviation gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_STD_DEV : Real := 0.01;

        -- ==================== Enable signal's parameters ====================== --

        -- Frequency of pulling down the `enable_in` input port (disabled when 0)
        CYCLIC_DISABLE_FREQ_HZ : Natural := 20;
        -- Number of system clock's cycles that the `enable_in` port is held low
        CYCLIC_DISABLE_CLK : Positive := 5_000_000;

        -- ================ Effect parameters' stimulus signals ================= --

        -- Amplitudes of `depth_in` input's values in normalized range <0; 1> ('1.0' is (BRAM_SAMPLES_NUM - 1))
        DEPTH_AMPLITUDE : Real := 1.0;
        -- Frequency of the changes of `depth_in` input
        DEPTH_TOGGLE_FREQ_HZ : Natural := 0;

        -- Amplitudes of `delay_gain_in` input's values in normalized range <0; 1>
        DELAY_GAIN_AMPLITUDE : Real := 0.3;
        -- Frequency of the changes of `delay_gain_in` input
        DELAY_GAIN_TOGGLE_FREQ_HZ : Natural := 0

    );
end entity DelayEffectTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of DelayEffectTb is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    
    
    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- ================== Common effects's interface ================== --

    -- Module's enable signal and it's negation
    signal enable_in : Std_logic := '1';
    -- Input and output samples
    signal sample_in, sample_out :  Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');
    -- Signal for new sample on input
    signal valid_in : Std_logic := '0';
    -- Signal for new sample on output
    signal valid_out : Std_logic;
    
    -- ================= Specific effects's interface ================= --

    -- Depth level (index of the delayed sample being summed with the input)
    signal depth_in : unsigned(DEPTH_WIDTH - 1 downto 0);
    -- Gain level pf the delayed summant (treated as value in <0,0.5) range)
    signal delay_gain_in : unsigned(DELAY_GAIN_WIDTH - 1 downto 0);

    -- ====================== Auxiliary signals ====================== --

    -- Real-converted depth input value
    signal depth_tmp : Real;
    -- Real-converted gain input value
    signal delay_gain_tmp : Real;

begin

    -- =================================================================================
    -- Common effects' benchtable
    -- =================================================================================

    -- Instance of the common features regarding guitar effects' testing
    effectTestbenchInstance: entity work.EffectTestbench(logic)
    generic map (
        SYS_CLK_HZ             => SYS_CLK_HZ,
        SYS_RESET_TICKS        => SYS_RESET_TICKS,
        SAMPLE_WIDTH           => SAMPLE_WIDTH,
        INPUT_TYPE             => INPUT_TYPE,
        INPUT_FREQ_HZ          => INPUT_FREQ_HZ,
        INPUT_AMPLITUDE        => INPUT_AMPLITUDE,
        INPUT_SAMPLING_FREQ_HZ => INPUT_SAMPLING_FREQ_HZ,
        INPUT_RAND_MEAN        => INPUT_RAND_MEAN,
        INPUT_RAND_STD_DEV     => INPUT_RAND_STD_DEV,
        CYCLIC_DISABLE_FREQ_HZ => CYCLIC_DISABLE_FREQ_HZ,
        CYCLIC_DISABLE_CLK     => CYCLIC_DISABLE_CLK
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
    
    -- Instance of the tremolo effect's module
    delayEffectInstance : entity work.DelayEffect
    generic map (
        SAMPLE_WIDTH      => SAMPLE_WIDTH,
        DELAY_GAIN_WIDTH  => DELAY_GAIN_WIDTH,
        DEPTH_WIDTH       => DEPTH_WIDTH,
        BRAM_SAMPLES_NUM  => BRAM_SAMPLES_NUM,
        BRAM_ADDR_WIDTH   => BRAM_ADDR_WIDTH,
        BRAM_LATENCY      => BRAM_LATENCY
    )
    port map (
        reset_n        => reset_n,
        clk            => clk,
        enable_in      => enable_in,
        valid_in       => valid_in,
        valid_out      => valid_out,
        sample_in      => sample_in,
        sample_out     => sample_out,
        depth_in       => depth_in,
        delay_gain_in  => delay_gain_in
    );

    -- =================================================================================
    -- Input parameters' generation 
    -- =================================================================================

    -- Transform signal into the signed value using saturation
    depth_in <= real_to_unsigned_sat(depth_tmp, DEPTH_WIDTH);
    -- Generate `depth_in` signal    
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => DEPTH_TOGGLE_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(DEPTH_AMPLITUDE * (BRAM_SAMPLES_NUM - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => depth_tmp
    );

    -- Transform signal into the signed value using saturation
    delay_gain_in <= real_to_unsigned_sat(delay_gain_tmp, DELAY_GAIN_WIDTH);
    -- Generate `delay_gain_in` signal    
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => DELAY_GAIN_TOGGLE_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(DELAY_GAIN_AMPLITUDE * (2**DELAY_GAIN_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => delay_gain_tmp
    );    


end architecture logic;
