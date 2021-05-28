-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    Tremolo effect's testbench 
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.generator_pkg.all;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity TremoloEffectTb is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Positive := 200_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- ======================== Effect's parameters ========================= --

        -- Width of the input sample
        SAMPLE_WIDTH : Positive := 16;

        -- ====================== Effect generator's type ======================= --

        -- Generator type
        GENERATOR_TYPE : GeneratorType := TRIANGLE;

        -- ====================== Modulation's parameters ======================= --

        -- Width of the modulation wave's depth input
        DEPTH_WIDTH : Positive := 16;
        -- Width of the modulating sample
        LFO_SAMPLE_WIDTH : Positive := 8;
        -- Width of the `ticks_per_sample` input
        TICKS_PER_SAMPLE_WIDTH : Positive := 16;

        -- ==================== QuadrupletGenerator-specific ==================== --

        -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
        BRAM_SAMPLES_NUM : Positive := 129;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive := 8;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive := 2;
        
        -- ===================== Input signal's parameters ====================== --

        -- Type of the input wave (available: [sin/sin_rand])
        INPUT_TYPE : String := "sin";

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Positive := 1000;
        -- Amplitude of the input wave in normalized range <0; 1>
        INPUT_AMPLITUDE : Real := 0.5;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive := 100_000;

        -- Mean of the gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_MEAN : Real := 0.0;
        -- Standard deviation gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_STD_DEV : Real := 0.01;
        
        -- ==================== Enable signal's parameters ====================== --

        -- Frequency of pulling down the `enable_in` input port (disabled when 0)
        CYCLIC_DISABLE_FREQ_HZ : Natural := 60;
        -- Number of system clock's cycles that the `enable_in` port is held low
        CYCLIC_DISABLE_CLK : Positive := 200_000;

        -- ================ Effect parameters' stimulus signals ================= --

        -- -------------------------------------------------------------------------
        -- @Note: Stimulus signals for effect's parameters are generated as random 
        --    steps with given frequency and amplitude.
        -- -------------------------------------------------------------------------

        -- Additional argument used to automatically calculate MODULATION_TICKS_PER_SAMPLE_AMPLITUDE
        -- for the given modulation frequency (MODULATION_TICKS_PER_SAMPLE_AMPLITUDE used when < 0)
        MODULATION_FREQ_HZ_AMPLITUDE : Integer := 70;

        -- Amplitudes of `depth_in` input's values in normalized range <0; 1>
        MODULATION_DEPTH_AMPLITUDE : Real := 1.0;
        -- Frequency of the changes of `depth_in` input
        MODULATION_TOGGLE_DEPTH_FREQ_HZ : Natural := 0;

        -- Amplitudes of `modulation_ticks_per_sample_in` input's values in normalized range <0; 1>
        MODULATION_TICKS_PER_SAMPLE_AMPLITUDE : Real := 0.0;
        -- Frequency of the changes of `modulation_ticks_per_sample_in` input
        MODULATION_TOGGLE_TICKS_PER_SAMPLE_FREQ_HZ : Natural := 0

    );
end entity TremoloEffectTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of TremoloEffectTb is

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

    -- Tremolo's depth aprameter (treated as value in <0, 1) range)
    signal depth_in : Unsigned(DEPTH_WIDTH - 1 downto 0);  
    -- Modulation's frequency-controlling input
    signal ticks_per_modulation_sample_in : Unsigned(TICKS_PER_SAMPLE_WIDTH - 1 downto 0);

    -- ====================== Auxiliary signals ====================== --

    -- Real-converted input signal
    signal sample_tmp : Real;
    -- Real-converted input signal
    signal depth_tmp : Real;
    -- Real-converted input signal
    signal ticks_per_modulation_sample_tmp : Real;

    -- ===================== Auxiliary functions ===================== --

    -- Chooses actual value of the MODULATION_TICKS_PER_SAMPLE_AMPLITUDE
    impure function calculate_ticks_per_sample_amplitude return Real is
    begin
        -- If modulation signal is NOT given with the particulat frequency
        if(MODULATION_FREQ_HZ_AMPLITUDE < 0) then
            return Real(Integer(MODULATION_TICKS_PER_SAMPLE_AMPLITUDE * (2**TICKS_PER_SAMPLE_WIDTH - 1)));
        -- Else
        else
            -- If triangle generator used
            if(GENERATOR_TYPE = TRIANGLE) then
                return Real(Integer(
                    SYS_CLK_HZ / MODULATION_FREQ_HZ_AMPLITUDE / 2**(LFO_SAMPLE_WIDTH + 1)));
            -- If quadruplet generator used
            else
                return Real(Integer(
                    SYS_CLK_HZ / MODULATION_FREQ_HZ_AMPLITUDE / (BRAM_SAMPLES_NUM * 4  - 4)));
            end if;
        end if;
    end function;

    -- Amplitudes of `modulation_ticks_per_sample_in` input's values in normalized range <0; 1>
    constant ACTUAL_MODULATION_TICKS_PER_SAMPLE_AMPLITUDE : Real := calculate_ticks_per_sample_amplitude;

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
    tremoloEffectInstance: entity work.TremoloEffect
    generic map (
        GENERATOR_TYPE         => GENERATOR_TYPE,
        SAMPLE_WIDTH           => SAMPLE_WIDTH,
        LFO_SAMPLE_WIDTH       => LFO_SAMPLE_WIDTH,
        DEPTH_WIDTH            => DEPTH_WIDTH,
        TICKS_PER_SAMPLE_WIDTH => TICKS_PER_SAMPLE_WIDTH,
        BRAM_SAMPLES_NUM       => BRAM_SAMPLES_NUM,
        BRAM_ADDR_WIDTH        => BRAM_ADDR_WIDTH,
        BRAM_LATENCY           => BRAM_LATENCY
    )
    port map (
        reset_n                        => reset_n,
        clk                            => clk,
        enable_in                      => enable_in,
        valid_in                       => valid_in,
        valid_out                      => valid_out,
        sample_in                      => sample_in,
        sample_out                     => sample_out,
        depth_in                       => depth_in,
        ticks_per_modulation_sample_in => ticks_per_modulation_sample_in
    );

    -- =================================================================================
    -- Input parameters' generation 
    -- =================================================================================

    -- Transform signal into the signed value using saturation
    depth_in <= real_to_unsigned_sat(depth_tmp, DEPTH_WIDTH);
    -- Generate `depth` signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => MODULATION_TOGGLE_DEPTH_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(MODULATION_DEPTH_AMPLITUDE * (2**DEPTH_WIDTH - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => depth_tmp
    );

    -- Transform signal into the signed value using saturation
    ticks_per_modulation_sample_in <= real_to_unsigned_sat(ticks_per_modulation_sample_tmp, TICKS_PER_SAMPLE_WIDTH);
    -- Generate `modulation_ticks_per_sample_in` signal
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => MODULATION_TOGGLE_TICKS_PER_SAMPLE_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => ACTUAL_MODULATION_TICKS_PER_SAMPLE_AMPLITUDE,
        reset_n      => reset_n,
        clk          => clk,
        wave         => ticks_per_modulation_sample_tmp
    );

end architecture logic;
