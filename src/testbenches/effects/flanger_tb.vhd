-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    Flanger effect's testbench 
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity FlangerEffectTb is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Positive := 200_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- ======================== Effect's parameters ========================= --

        -- Width of the input sample
        SAMPLE_WIDTH : Positive := 16;

        -- Width of the @in attenuation_in port
        STRENGTH_WIDTH : Positive := 12;
        -- Width of the @in depth port
        DEPTH_WIDTH : Positive := 8;
        -- Width of the `ticks_per_delay_sample_in` input
        TICKS_PER_DELAY_SAMPLE_WIDTH : Positive := 30;

        -- Number of bits that the @in depth value is shifed right to calculate effective depth coefficient
        DEPTH_TWO_POW_DIV : Positive := 13;

        -- =========================== BRAM parameters ========================== --

        -- Number of usable cells in delay line's BRAM
        DELAY_BRAM_SAMPLES_NUM : Positive := 2_560;
        -- Width of the delay line's address port
        DELAY_BRAM_ADDR_WIDTH : Positive := 16;
        -- Latency of the delay line's BRAM read operation (1 for lack of output registers in the BRAM block)
        DELAY_BRAM_LATENCY : Positive := 2;

        -- Number of usable cells in delay line's BRAM
        GENERATOR_BRAM_SAMPLES_NUM : Positive := 5513;
        -- Width of the delay line's address port
        GENERATOR_BRAM_ADDR_WIDTH : Positive := 13;
        -- Width of the data hold in the generator's BRAM
        GENERATOR_BRAM_DATA_WIDTH : Positive := 16;
        -- Latency of the delay line's BRAM read operation (1 for lack of output registers in the BRAM block)
        GENERATOR_BRAM_LATENCY : Positive := 2; 
        
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
        CYCLIC_DISABLE_FREQ_HZ : Natural := 0;
        -- Number of system clock's cycles that the `enable_in` port is held low
        CYCLIC_DISABLE_CLK : Positive := 1;

        -- ================ Effect parameters' stimulus signals ================= --

        -- Amplitudes of `depth_in` input's values in normalized range <0; 1> ('1.0' is (BRAM_SAMPLES_NUM - 1))
        DEPTH_AMPLITUDE : Real := 0.5;
        -- Frequency of the changes of `depth_in` input
        DEPTH_TOGGLE_FREQ_HZ : Natural := 0;

        -- Amplitudes of `strength_in` input's values in normalized range <0; 1>
        STRENGTH_AMPLITUDE : Real := 0.5;
        -- Frequency of the changes of `strength_in` input
        STRENGTH_TOGGLE_FREQ_HZ : Natural := 0;

        -- Amplitudes of `ticks_per_delay_sample_in` input's values in normalized range <0; 1>
        TICKS_PER_DELAY_SAMPLE_AMPLITUDE : Real := 0.0;
        -- Frequency of the changes of `ticks_per_delay_sample_in` input
        TICKS_PER_DELAY_TOGGLE_FREQ_HZ : Natural := 0;

        -- Additional argument used to automatically calculate TICKS_PER_DELAY_SAMPLE_AMPLITUDE
        -- for the given delay value's modulation frequency (TICKS_PER_DELAY_SAMPLE_AMPLITUDE used when < 0)
        DELAY_MODULATION_FREQ_HZ_AMPLITUDE : Real := 0.5
    );
end entity FlangerEffectTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of FlangerEffectTb is

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
    -- Strength level pf the effect
    signal strength_in : unsigned(STRENGTH_WIDTH - 1 downto 0);
    -- Module's saturation
    signal ticks_per_delay_sample_in : Unsigned(TICKS_PER_DELAY_SAMPLE_WIDTH - 1 downto 0);    

    -- ====================== Auxiliary signals ====================== --

    -- Real-converted depth input value
    signal depth_tmp : Real;
    -- Real-converted strength input value
    signal strength_tmp : Real;
    -- Real-converted `ticks_per_delay_sample_in` input signal
    signal ticks_per_delay_sample_tmp : Real;


    -- ===================== Auxiliary functions ===================== --

    -- Amplitudes of `modulation_ticks_per_sample_in` input's values in normalized range <0; 1>
    constant ACTUAL_DELAY_MODULATION_FREQ_HZ_AMPLITUDE : Real := 
        Real(SYS_CLK_HZ) / DELAY_MODULATION_FREQ_HZ_AMPLITUDE / (GENERATOR_BRAM_SAMPLES_NUM * 4  - 4);

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
    
    -- Instance of the flanger module
    flangerEffectInstance : entity work.FlangerEffect
    generic map (
        SAMPLE_WIDTH                 => SAMPLE_WIDTH,
        STRENGTH_WIDTH               => STRENGTH_WIDTH,
        DEPTH_WIDTH                  => DEPTH_WIDTH,
        TICKS_PER_DELAY_SAMPLE_WIDTH => TICKS_PER_DELAY_SAMPLE_WIDTH,
        DEPTH_TWO_POW_DIV            => DEPTH_TWO_POW_DIV,
        DELAY_BRAM_SAMPLES_NUM       => DELAY_BRAM_SAMPLES_NUM,
        DELAY_BRAM_ADDR_WIDTH        => DELAY_BRAM_ADDR_WIDTH,
        DELAY_BRAM_LATENCY           => DELAY_BRAM_LATENCY,
        GENERATOR_BRAM_SAMPLES_NUM   => GENERATOR_BRAM_SAMPLES_NUM,
        GENERATOR_BRAM_ADDR_WIDTH    => GENERATOR_BRAM_ADDR_WIDTH,
        GENERATOR_BRAM_DATA_WIDTH    => GENERATOR_BRAM_DATA_WIDTH,
        GENERATOR_BRAM_LATENCY       => GENERATOR_BRAM_LATENCY
    )
    port map (
        reset_n                   => reset_n,
        clk                       => clk,
        enable_in                 => enable_in,
        valid_in                  => valid_in,
        valid_out                 => valid_out,
        sample_in                 => sample_in,
        sample_out                => sample_out,
        depth_in                  => depth_in,
        strength_in               => strength_in,
        ticks_per_delay_sample_in => ticks_per_delay_sample_in
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
        MAX_VAL      => Real(Integer(DEPTH_AMPLITUDE * (2**DEPTH_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => depth_tmp
    );

    -- Transform signal into the signed value using saturation
    strength_in <= real_to_unsigned_sat(strength_tmp, STRENGTH_WIDTH);
    -- Generate `attenuation_in` signal    
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => STRENGTH_TOGGLE_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(STRENGTH_AMPLITUDE * (2**STRENGTH_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => strength_tmp
    );    

    -- Transform signal into the signed value using saturation
    ticks_per_delay_sample_in <= real_to_unsigned_sat(ticks_per_delay_sample_tmp, TICKS_PER_DELAY_SAMPLE_WIDTH);
    -- Generate `ticks_per_delay_sample_in` signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => TICKS_PER_DELAY_TOGGLE_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => ACTUAL_DELAY_MODULATION_FREQ_HZ_AMPLITUDE,
        reset_n      => reset_n,
        clk          => clk,
        wave         => ticks_per_delay_sample_tmp
    );    

end architecture logic;
