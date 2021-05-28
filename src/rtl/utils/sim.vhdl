-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create time: 2021-04-25 23:26:44
-- @ Modified time: 2021-04-25 23:27:04
-- @ Description: 
--    
--    Package contianing simulation utilities
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- ===================================================================================================================================
-- ------------------------------------------------------------- Package -------------------------------------------------------------
-- ===================================================================================================================================

package sim is

    -- ===================================================================
    -- Auxiliary functions
    -- ===================================================================

    -- Absolute value of a real number
    function absolute(num : Real) return Real;
    
    -- Converts Real value to the Signed bit vector of the given length saturating value when needed
    function real_to_signed_sat(num : Real; len : Positive) return Signed;

    -- Converts Real value to the Unsigned bit vector of the given length saturating value when needed
    function real_to_unsigned_sat(num : Real; len : Positive) return Unsigned;

    -- ===================================================================
    -- General use utilities
    -- ===================================================================

    -- Clocking procedure
    procedure clock_tb(period : time; signal clk : out std_logic);
    
    -- Resetting procedure
    procedure reset_tb(reset_time : time; signal reset_n : out std_logic);

    -- Signal resetting procedure
    procedure enable_on_end_of_reset(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Number of system clock's cycles of enable delay efter reset off
        constant ENABLE_DELAY_CLK : Natural := 0;
        -- Clock signal
        signal clk : in std_logic;        
        -- Reset signal
        signal reset_n : in std_logic;
        -- Controlled siganl
        signal sig : out std_logic
    );

    -- ===================================================================
    -- Random generators
    -- ===================================================================

    -- Random function's seed
    shared variable seed1, seed2 : Integer := 999;

    -- Sets internal seeds for RN Generator
    procedure set_uniform_seeds(one, two : Integer);

    -- Generates random Real number in range
    impure function rand_real(min_val, max_val : Real) return Real;
    
    -- Generates random Time value in range
    impure function rand_time(min_val, max_val : Time; unit : Time := ns) return Time;

    -- Generates random Integer value in range
    impure function rand_int(min_val, max_val : Integer) return Integer;

    -- Generates  random logic vector with the given length
    impure function rand_logic_vector(len : Integer) return Std_logic_vector; 

    -- ===================================================================
    -- Wave generators
    -- ===================================================================

    -- Generates sine wave updating samples at rising edge of the clock
    procedure generate_sin(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Wave's phase shift (in normalized range (0;1>)
        constant PHASE_SHIFT : Real;
        -- Wave's amplitude
        constant AMPLITUDE : Real;
        -- Wave's offset
        constant OFFSET : Real;
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal wave : out Real
    );

    -- Generates sine wave summed with the gaussian noise of given parameters
    procedure generate_random_sin(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Wave's phase shift (in normalized range (0;1>)
        constant PHASE_SHIFT : Real;
        -- Wave's amplitude
        constant AMPLITUDE : Real;
        -- Wave's offset
        constant OFFSET : Real;
        -- Mean value of the gaussian distribution
        constant RNG_MEAN : Real := 0.0;
        -- Standard deviation of the gaussian distribution
        constant RNG_STD_DEV : Real := 1.0;
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal wave : out Real
    );

    -- Clocking procedure with reset
    procedure generate_clk(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Number of system clock's cycles that @in sig should be pulled high
        constant HIGH_CLK : Natural := 1;        
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal wave : out std_logic
    );

    -- PWM signal's generator
    procedure generate_pwm(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Wave's phase shift in normalized <0,1> range
        constant PHASE_SHIFT : Real;
        -- Pulse's width ('1' level) in normalized <0,1> range
        constant PWM_WIDTH : Real;
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal pwm : out std_logic
    );    

    -- Generates random `stairs` with values in given range updating samples at rising edge of the clock
    procedure generate_random_stairs(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Wave's phase shift (in normalized range (0;1>)
        constant PHASE_SHIFT : Real := 0.0;
        -- Wave's min val
        constant MIN_VAL : Real;
        -- Wave's max val (wave's value when FREQUENCY_HZ is 0)
        constant MAX_VAL : Real;
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal wave : out Real
    );

end package sim;

-- ===================================================================================================================================
-- ---------------------------------------------------------- Package Body -----------------------------------------------------------
-- ===================================================================================================================================

package body sim is

    -- ===================================================================
    -- Auxiliary functions
    -- ===================================================================

    -- Absolute value of a real number
    function absolute(num : Real) return Real is
    begin
        if(num >= 0.0) then
            return num;
        else
            return -num;
        end if;
    end function;

    -- Converts Real value to the Signed bit vector of the given length saturating value when needed
    function real_to_signed_sat(num : Real; len : Positive) return Signed is
    begin
        -- Check whether value is in range
        if(Integer(absolute(num)) <= 2**(len - 1) - 1) then
            return to_signed(integer(num), len);
        -- If over th range, saturate on max value
        elsif(num > 0.0) then
            return to_signed(integer(2**(len - 1) - 1), len);
        -- If under the range, saturate on min value
        else
            return to_signed(integer(-2**(len - 1)), len);
        end if;
    end function;

    -- Converts Real value to the Unsigned bit vector of the given length saturating value when needed
    function real_to_unsigned_sat(num : Real; len : Positive) return Unsigned is
    begin
        -- Check whether value is in range
        if((Integer(num) <= 2**len - 1) and (Integer(num) >= 0)) then
            return to_unsigned(integer(num), len);
        -- If over th range, saturate on max value
        elsif(num > 0.0) then
            return to_unsigned(2**len - 1, len);
        -- If under the range, saturate on min value
        else
            return to_unsigned(0, len);
        end if;
    end function;    

    -- ===================================================================
    -- General use utilities
    -- ===================================================================

    -- Clocking procedure
    procedure clock_tb(period : time; signal clk : out std_logic) is
    begin
        loop
            clk <= '1';
            wait for period / 2;
            clk <= '0';
            wait for period / 2;
        end loop;
    end procedure;

    -- Resetting procedure
    procedure reset_tb(reset_time : time; signal reset_n : out std_logic) is
    begin
        reset_n <= '0';
        wait for reset_time;
        reset_n <= '1';
    end procedure;

    -- Signal resetting procedure
    procedure enable_on_end_of_reset(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Number of system clock's cycles of enable delay efter reset off
        constant ENABLE_DELAY_CLK : Natural := 0;
        -- Clock signal
        signal clk : in std_logic;
        -- Reset signal
        signal reset_n : in std_logic;
        -- Controlled siganl
        signal sig : out std_logic
    ) is
    begin

        -- Disable signal
        sig <= '0';
        -- Wait for end of reset
        wait until reset_n = '1';
        for i in 0 to ENABLE_DELAY_CLK loop
            wait until rising_edge(clk);
        end loop;
        -- Enable signal
        sig <= '1';
        -- End procedure
        wait;

    end procedure;

    -- ===================================================================
    -- Uniform random generators
    -- ===================================================================

    -- Sets internal seeds for RN Generator
    procedure set_uniform_seeds(one, two : Integer) is
    begin
        seed1 := one;
        seed2 := two;
    end procedure;

    -- Generates random Real number in range
    impure function rand_real(min_val, max_val : Real) return Real is
        -- Return value from 'uniform' call
        variable r : Real;
    begin
        uniform(seed1, seed2, r);
        return r * (max_val - min_val) + min_val;
    end function;

    -- Generates random Time value in range
    impure function rand_time(min_val, max_val : Time; unit : Time := ns) return Time is
        -- Helper variables
          variable r, r_scaled, min_real, max_real : Real;
    begin
         uniform(seed1, seed2, r);
          min_real := Real(min_val / unit);
          max_real := Real(max_val / unit);
          r_scaled := r * (max_real - min_real) + min_real;
          return Real(r_scaled) * unit;
    end function;

    -- Generates random Integer value in range
    impure function rand_int(min_val, max_val : Integer) return Integer is
        variable r : Real;
    begin
        uniform(seed1, seed2, r);
        return Integer(round(r * Real(max_val - min_val + 1) + Real(min_val) - 0.5));
    end function;

    -- Generates  random logic vector with the given length
    impure function rand_logic_vector(len : Integer) return Std_logic_vector is
        -- Helper variables
        variable r : Real;
        variable slv : Std_logic_vector(len - 1 downto 0);
    begin
        for i in slv'range loop
            uniform(seed1, seed2, r);
            slv(i) := '1' when r > 0.5 else '0';
        end loop;
        return slv;
    end function;

    -- ===================================================================
    -- Gaussian random generators
    -- ===================================================================

    impure function rand_real_gaussian(mean, std_dev : Real) return Real is
        variable R, O : Real;
        variable ret : real;
    begin
        -- Draw two random values from the uniform distribution and transform them
        R := -2.0 * log(rand_real(0.0, 1.0));
        O := 2.0 * math_pi * rand_real(0.0, 1.0);
        -- Compute gaussian random number following Box-Muller rule
        ret := R * cos(O);
        -- ret := R * sin(O);
        -- Returned scaled version of the number
        return ret * std_dev + mean;
    end function;

    -- ===================================================================
    -- Wave generators
    -- ===================================================================

    -- Generates sine wave updating samples at falling edge of the clock
    procedure generate_sin(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Wave's phase shift (in normalized range (0;2pi>)
        constant PHASE_SHIFT : Real;
        -- Wave's amplitude
        constant AMPLITUDE : Real;
        -- Wave's offset
        constant OFFSET : Real;        
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal wave : out Real
    ) is 
        -- Peiord of the system clock
        constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ; 
        -- Counter used to generate sinus wave
        variable ticks : Natural;
    begin
        -- -- Reset condition
        ticks := 0;
        wave <= 0.0;
        -- --Wait for the first rising edge after reset
        wait until reset_n = '1';
        wait until rising_edge(clk);
        -- -- Update wave on rising edges
        loop
            ticks := ticks + 1;
            wave <= AMPLITUDE * sin(2.0 * MATH_PI * Real(ticks) * Real(FREQUENCY_HZ) / Real(SYS_CLK_HZ) + PHASE_SHIFT) + OFFSET;
            wait for CLK_PERIOD;
        end loop;

    end procedure;

    -- Generates sine wave summed with the gaussian noise of given parameters
    procedure generate_random_sin(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Wave's phase shift (in normalized range (0;1>)
        constant PHASE_SHIFT : Real;
        -- Wave's amplitude
        constant AMPLITUDE : Real;
        -- Wave's offset
        constant OFFSET : Real;
        -- Mean value of the gaussian distribution
        constant RNG_MEAN : Real := 0.0;
        -- Standard deviation of the gaussian distribution
        constant RNG_STD_DEV : Real := 1.0;
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal wave : out Real
    ) is
        -- Peiord of the system clock
        constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ; 
        -- Counter used to generate sinus wave
        variable ticks : Natural;
    begin
        -- -- Reset condition
        ticks := 0;
        wave <= 0.0;
        -- --Wait for the first rising edge after reset
        wait until reset_n = '1';
        wait until rising_edge(clk);
        -- -- Update wave on rising edges
        loop
            ticks := ticks + 1;
            wave <= AMPLITUDE * sin(2.0 * MATH_PI * Real(ticks) * Real(FREQUENCY_HZ) / Real(SYS_CLK_HZ) + PHASE_SHIFT) +
                    OFFSET + 
                    rand_real_gaussian(RNG_MEAN, RNG_STD_DEV);
            wait for CLK_PERIOD;
        end loop;

    end procedure;

    -- Binary clock signal
    procedure generate_clk(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Number of system clock's cycles that @in sig should be pulled high
        constant HIGH_CLK : Natural := 1;        
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal wave : out std_logic
    ) is
    begin

        -- Reset condition
        wave <= '0';

        -- If freequency is zero
        if(FREQUENCY_HZ = 0) then

            wait;

        -- If non-zero frequency given
        else

            -- Wait for end of reset
            wait until reset_n = '1';

            -- Update `wave` in predefined sequence
            loop

                -- Wait for rising edge
                wait until rising_edge(clk);

                -- Inform about new sample
                wave <= '1';
                -- Waif given number of cycles to pull signal low
                for i in 0 to Natural(HIGH_CLK) - 1 loop
                    wait until rising_edge(clk);
                end loop;
                wave <= '0';

                -- Wait a gap time before triggering the next cycle
                wait for 1 sec / FREQUENCY_HZ - 1 sec / SYS_CLK_HZ;

            end loop;

        end if;

    end procedure;

    -- PWM signal's generator
    procedure generate_pwm(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Wave's phase shift in normalized <0,1> range
        constant PHASE_SHIFT : Real;
        -- Pulse's width ('1' level) in normalized <0,1> range
        constant PWM_WIDTH : Real;
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal pwm : out std_logic
    ) is
        constant SYS_CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;
    begin

        -- Reset condition
        pwm <= '0';

        -- Wait for end of reset
        wait until reset_n = '1';

        -- If freequency is zero
        if(FREQUENCY_HZ = 0) then

            -- If pulse's width is positive, set signal to '1'
            if(PWM_WIDTH > 0.0) then
                pwm <= '1';
            end if;

            wait;

        -- If non-zero frequency given
        else

            -- Wait for phase shift
            wait for 1 sec / FREQUENCY_HZ * PHASE_SHIFT;

            -- Update `wave` in predefined sequence
            loop

                -- Wait for rising edge
                wait until rising_edge(clk);

                -- Set signal high
                pwm <= '1';

                -- Wait for the high-time
                if(1 sec / FREQUENCY_HZ * PWM_WIDTH > SYS_CLK_PERIOD) then
                    wait for 1 sec / FREQUENCY_HZ * PWM_WIDTH - SYS_CLK_PERIOD;
                end if;
                -- Wait for next rising edge
                wait until rising_edge(clk);

                -- Set signal low
                pwm <= '0';

                -- Wait for the high-time
                if(1 sec / FREQUENCY_HZ * (1.0 - PWM_WIDTH) > SYS_CLK_PERIOD) then
                    wait for 1 sec / FREQUENCY_HZ * (1.0 - PWM_WIDTH) - SYS_CLK_PERIOD;
                end if;

            end loop;

        end if;

    end procedure;

    -- Generates random `stairs` with values in given range
    procedure generate_random_stairs(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Wave's phase shift in normalized <0,1>
        constant PHASE_SHIFT : Real := 0.0;
        -- Wave's min val
        constant MIN_VAL : Real;
        -- Wave's max val (wave's value when FREQUENCY_HZ is 0)
        constant MAX_VAL : Real;
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal wave : out Real
    ) is
    begin

        -- Reset condition
        wave <= 0.0;

        -- Wait for end of reset
        wait until reset_n = '1';

        -- When 0 frequency, just push amplitude value
        if(FREQUENCY_HZ /= 0) then

            -- Set initial value
            wave <= rand_real(MIN_VAL, MAX_VAL);

            -- Wait for phase shift
            wait for 1 sec / FREQUENCY_HZ * PHASE_SHIFT;

            -- Change value and wait infinitely
            loop
                wait until falling_edge(clk);
                wave <= rand_real(MIN_VAL, MAX_VAL);
                wait for 1 sec / FREQUENCY_HZ;
            end loop;
        else
            wave <= MAX_VAL;
            wait;
        end if;

    end procedure;

end package body sim;

-- ===================================================================================================================================
-- ------------------------------------------------ Signal generator for testbenches -------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- General entity for effect's testing
entity SignalGenerator is
    generic(

        -- ========================= General parameters ========================= --

        -- Frequency of the system clock
        SYS_CLK_HZ : Positive;
        -- Count of system clock's ticks that the reset signal is active at the beggining
        SYS_RESET_TICKS : Positive;
        -- Width of the samples
        SAMPLE_WIDTH : Positive := 16;

        -- ===================== Input signal's parameters ====================== --

        -- Type of the input wave (available: [sin/sin_rand])
        INPUT_TYPE : String;

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Positive;
        -- Amplitude of the input wave in normalized range <0;1>
        INPUT_AMPLITUDE : Real;

        -- Mean of the gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_MEAN : Real;
        -- Standard deviation gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_STD_DEV : Real

    );
    port(

        -- ========================== System signals ============================ --

        -- Reset signal
        reset_n : out Std_logic := '0';
        -- System clock
        clk : out Std_logic := '0';

        -- ===================== Common effects' interface ====================== --

        -- Input sample
        sample_in : out Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0')
    );
end entity SignalGenerator;

architecture logic of SignalGenerator is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;  

    -- Negation of module's enable signal
    signal disable_in : Std_logic := '1';

    -- Real-converted input signal
    signal sample_tmp : Real;

begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Clock signal
    clock_tb(CLK_PERIOD, clk);

    -- Reset signal
    reset_tb(SYS_RESET_TICKS * CLK_PERIOD, reset_n);

    -- =================================================================================
    -- Input signals' generation 
    -- =================================================================================
    
    -- Generate input signal : sin
    inputSin : if INPUT_TYPE = "sin" generate
        -- Transform wave into the signed value using saturation
        sample_in <= real_to_signed_sat(sample_tmp, SAMPLE_WIDTH);
        -- Generate sinusoidal wave
        generate_sin(
            SYS_CLK_HZ   => SYS_CLK_HZ,
            FREQUENCY_HZ => INPUT_FREQ_HZ,
            PHASE_SHIFT  => 0.0,
            AMPLITUDE    => Real(INPUT_AMPLITUDE * Real(2**(SAMPLE_WIDTH - 1) - 1)),
            OFFSET       => 0.0,
            reset_n      => reset_n,
            clk          => clk,
            wave         => sample_tmp
        );
    end generate;

    -- Generate input signal : sin with uniform noise
    inputSinRand : if INPUT_TYPE = "sin_rand" generate
        -- Transform wave into the signed value using saturation
        sample_in <= real_to_signed_sat(sample_tmp, SAMPLE_WIDTH);
        -- Generate sinusoidal with white noise wave
        generate_random_sin(
            SYS_CLK_HZ   => SYS_CLK_HZ,
            FREQUENCY_HZ => INPUT_FREQ_HZ,
            PHASE_SHIFT  => 0.0,
            AMPLITUDE    => Real(INPUT_AMPLITUDE * Real(2**(SAMPLE_WIDTH - 1) - 1)),
            OFFSET       => 0.0,
            RNG_MEAN     => INPUT_RAND_MEAN * Real(2**(SAMPLE_WIDTH - 1) - 1),
            RNG_STD_DEV  => INPUT_RAND_STD_DEV * Real(2**(SAMPLE_WIDTH - 1) - 1),
            reset_n      => reset_n,
            clk          => clk,
            wave         => sample_tmp
        );
    end generate;

end architecture logic;

-- ===================================================================================================================================
-- ------------------------------------------------------- Pipe's testbench --------------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- General entity for effect's testing
entity SamplesGenerator is
    generic(

        -- ========================= General parameters ========================= --

        -- Frequency of the system clock
        SYS_CLK_HZ : Positive;
        -- Count of system clock's ticks that the reset signal is active at the beggining
        SYS_RESET_TICKS : Positive;
        -- Width of the samples
        SAMPLE_WIDTH : Positive := 16;

        -- ===================== Input signal's parameters ====================== --

        -- Type of the input wave (available: [sin/sin_rand])
        INPUT_TYPE : String;

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Positive;
        -- Amplitude of the input wave in normalized range <0;1>
        INPUT_AMPLITUDE : Real;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive;

        -- Mean of the gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_MEAN : Real;
        -- Standard deviation gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_STD_DEV : Real

    );
    port(

        -- ========================== System signals ============================ --

        -- Reset signal
        reset_n : out Std_logic := '0';
        -- System clock
        clk : out Std_logic := '0';

        -- ===================== Common effects' interface ====================== --

        -- Input sample
        sample_in : out Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');
        -- Signal for new sample on input
        valid_in : out Std_logic := '0'
    );
end entity SamplesGenerator;

architecture logic of SamplesGenerator is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;  

    -- Negation of module's enable signal
    signal disable_in : Std_logic := '1';

    -- Real-converted input signal
    signal sample_tmp : Real;

begin

    -- =================================================================================
    -- Internal components
    -- =================================================================================

    toptestbench_inst: entity work.SignalGenerator
    generic map (
        SYS_CLK_HZ         => SYS_CLK_HZ,
        SYS_RESET_TICKS    => SYS_RESET_TICKS,
        SAMPLE_WIDTH       => SAMPLE_WIDTH,
        INPUT_TYPE         => INPUT_TYPE,
        INPUT_FREQ_HZ      => INPUT_FREQ_HZ,
        INPUT_AMPLITUDE    => INPUT_AMPLITUDE,
        INPUT_RAND_MEAN    => INPUT_RAND_MEAN,
        INPUT_RAND_STD_DEV => INPUT_RAND_STD_DEV
    )
    port map (
        reset_n   => reset_n,
        clk       => clk,
        sample_in => sample_in
    );

    -- =================================================================================
    -- Input periodic flags
    -- =================================================================================

    -- Generate sampling pulse 
    generate_clk(
        SYS_CLK_HZ       => SYS_CLK_HZ,
        FREQUENCY_HZ     => INPUT_SAMPLING_FREQ_HZ,
        reset_n          => reset_n,
        clk              => clk,
        wave             => valid_in
    );

end architecture logic;


-- ===================================================================================================================================
-- ------------------------------------------------------- Effect's testbench --------------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- General entity for effect's testing
entity EffectTestbench is
    generic(

        -- ========================= General parameters ========================= --

        -- Frequency of the system clock
        SYS_CLK_HZ : Positive;
        -- Count of system clock's ticks that the reset signal is active at the beggining
        SYS_RESET_TICKS : Positive;
        -- Width of the samples
        SAMPLE_WIDTH : Positive := 16;

        -- ===================== Input signal's parameters ====================== --

        -- Type of the input wave (available: [sin/sin_rand])
        INPUT_TYPE : String;

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Positive;
        -- Amplitude of the input wave in normalized range <0;1>
        INPUT_AMPLITUDE : Real;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive;

        -- Mean of the gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_MEAN : Real;
        -- Standard deviation gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_STD_DEV : Real;

        -- ==================== Enable signal's parameters ====================== --

        -- Frequency of pulling down the `enable_in` input port (disabled when 0)
        CYCLIC_DISABLE_FREQ_HZ : Natural := 50;
        -- Number of system clock's cycles that the `enable_in` port is held low
        CYCLIC_DISABLE_CLK : Positive := 1
    );
    port(

        -- ========================== System signals ============================ --

        -- Reset signal
        reset_n : out Std_logic := '0';
        -- System clock
        clk : out Std_logic := '0';

        -- ===================== Common effects' interface ====================== --

        -- Module's enable signal
        enable_in : out Std_logic := '1';
        -- Input sample
        sample_in : out Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');
        -- Signal for new sample on input
        valid_in : out Std_logic := '0'
    );
end entity EffectTestbench;

architecture logic of EffectTestbench is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;  

    -- Negation of module's enable signal
    signal disable_in : Std_logic := '1';

    -- Real-converted input signal
    signal sample_tmp : Real;

begin

    -- =================================================================================
    -- Internal bench
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

    -- Control `enable_in` signal with it's negation
    enable_in <= not(disable_in);    

    -- =================================================================================
    -- Input periodic flags
    -- =================================================================================

    -- Generate cyclic disabling signal
    generate_clk(
        SYS_CLK_HZ       => SYS_CLK_HZ,
        FREQUENCY_HZ     => CYCLIC_DISABLE_FREQ_HZ,
        HIGH_CLK         => CYCLIC_DISABLE_CLK,
        reset_n          => reset_n,
        clk              => clk,
        wave             => disable_in
    );   

end architecture logic;