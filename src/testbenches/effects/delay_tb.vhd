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
        SYS_CLK_HZ : Positive := 200_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- ======================== Effect's parameters ========================= --

        -- Width of the input sample
        SAMPLE_WIDTH : Positive := 16;

        -- Width of the @in attenuation_in port
        ATTENUATION_WIDTH : Positive := 8;
        -- Width of the @in depth port
        DEPTH_WIDTH : Positive := 8;

        -- =========================== BRAM parameters ========================== --

        -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
        BRAM_SAMPLES_NUM : Positive := 100;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive := 16;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive := 2;
        
        -- ===================== Input signal's parameters ====================== --

        -- Type of the input wave (available: [sin/sin_rand])
        INPUT_TYPE : String := "sin_rand";

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Positive := 1000;
        -- Amplitude of the input wave in normalized range <0; 1>
        INPUT_AMPLITUDE : Real := 0.5;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive := 100_000;

        -- Limits of the uniform random summant of the input signal
        INPUT_MIN_RAND : Real := 0;
        INPUT_MAX_RAND : Real := 0;

        -- ==================== Enable signal's parameters ====================== --

        -- Frequency of pulling down the `enable_in` input port (disabled when 0)
        CYCLIC_DISABLE_FREQ_HZ : Natural := 50;
        -- Number of system clock's cycles that the `enable_in` port is held low
        CYCLIC_DISABLE_CLK : Positive := 1;

        -- ================ Effect parameters' stimulus signals ================= --

        -- Amplitudes of `depth_in` input's values in normalized range <0; 1> ('1.0' is (BRAM_SAMPLES_NUM - 1))
        DEPTH_AMPLITUDE : Real := 0.25;
        -- Frequency of the changes of `depth_in` input
        DEPTH_TOGGLE_FREQ_HZ : Natural := 0;

        -- Amplitudes of `attenuation_in` input's values in normalized range <0; 1>
        ATTENUATION_AMPLITUDE : Real := 1.0;
        -- Frequency of the changes of `attenuation_in` input
        ATTENUATION_TOGGLE_FREQ_HZ : Natural := 0

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
    signal enable_in, disable_in : Std_logic := '1';
    -- Input and output samples
    signal sample_in, sample_out :  Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');
    -- Signal for new sample on input (rising-edge-active)
    signal valid_in : Std_logic := '0';
    -- Signal for new sample on output (rising-edge-active)
    signal valid_out : Std_logic;
    
    -- ================= Specific effects's interface ================= --

    -- Depth level (index of the delayed sample being summed with the input)
    signal depth_in : unsigned(DEPTH_WIDTH - 1 downto 0);
    -- Attenuation level pf the delayed summant (treated as value in <0,0.5) range)
    signal attenuation_in : unsigned(ATTENUATION_WIDTH - 1 downto 0);

    -- ====================== Auxiliary signals ====================== --

    -- Real-converted input signal
    signal sample_tmp : Real;
    -- Real-converted depth input value
    signal depth_tmp : Real;
    -- Real-converted attenuation input value
    signal attenuation_tmp : Real;

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
    
    -- Control `enable_in` signal with it's negation
    enable_in <= not(disable_in);
    
    -- Instance of the tremolo effect's module
    delayEffectInstance : entity work.DelayEffect
    generic map (
        SAMPLE_WIDTH      => SAMPLE_WIDTH,
        ATTENUATION_WIDTH => ATTENUATION_WIDTH,
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
        attenuation_in => attenuation_in
    );

    -- =================================================================================
    -- Input signals' generation 
    -- =================================================================================
    
    -- Generate input signal : sin
    inputSin : if INPUT_TYPE = "sin" generate
        sample_in <= to_signed(integer(sample_tmp), SAMPLE_WIDTH);
        generate_sin(
            SYS_CLK_HZ   => SYS_CLK_HZ,
            FREQUENCY_HZ => INPUT_FREQ_HZ,
            PHASE_SHIFT  => 0.0,
            AMPLITUDE    => Real(INPUT_AMPLITUDE * (2**(SAMPLE_WIDTH - 1) - 1)),
            OFFSET       => 0.0,
            reset_n      => reset_n,
            clk          => clk,
            wave         => sample_tmp
        );
    end generate;

    -- Generate input signal : sin with uniform noise
    inputSin : if INPUT_TYPE = "sin_rand" generate
        sample_in <= to_signed(integer(sample_tmp), SAMPLE_WIDTH);
        generate_random_sin(
            SYS_CLK_HZ   => SYS_CLK_HZ,
            FREQUENCY_HZ => INPUT_FREQ_HZ,
            PHASE_SHIFT  => 0.0,
            AMPLITUDE    => Real(INPUT_AMPLITUDE * (2**(SAMPLE_WIDTH - 1) - 1)),
            OFFSET       => 0.0,
            LOW_RAND     => INPUT_MIN_RAND,
            HIGH_RAND    => INPUT_MAX_RAND,
            reset_n      => reset_n,
            clk          => clk,
            wave         => sample_tmp
        );
    end generate;

    -- Generate `depth_in` signal
    depth_in <= to_unsigned(Natural(depth_tmp), DEPTH_WIDTH);
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => DEPTH_TOGGLE_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(DEPTH_AMPLITUDE * (BRAM_SAMPLES_NUM - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => depth_tmp
    );

    -- Generate `attenuation_in` signal
    attenuation_in <= to_unsigned(Natural(attenuation_tmp), ATTENUATION_WIDTH);
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => ATTENUATION_TOGGLE_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(ATTENUATION_AMPLITUDE * (2**ATTENUATION_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => attenuation_tmp
    );    

    -- =================================================================================
    -- Input signal's sampling process
    -- =================================================================================

    -- Generate cyclic reset signal
    generate_clk(
        SYS_CLK_HZ       => SYS_CLK_HZ,
        FREQUENCY_HZ     => CYCLIC_DISABLE_FREQ_HZ,
        HIGH_CLK         => CYCLIC_DISABLE_CLK,
        reset_n          => reset_n,
        clk              => clk,
        wave             => disable_in
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
