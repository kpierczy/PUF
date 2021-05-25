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

-- ------------------------------------------------------------- Header --------------------------------------------------------------

package sim is

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

    -- Generates sine wave summed with the uniform noised from the given range
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
        -- Lower bound of the random summant
        constant LOW_RAND : Real := 0.0;
        -- Higher bound of the random summant
        constant HIGH_RAND : Real := 0.0;
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal wave : out Real
    );

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

    -- Generates random `stairs` with values in given range updating samples at rising edge of the clock
    procedure generate_random_stairs(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Wave's min val
        constant MIN_VAL : Real;
        -- Wave's max val
        constant MAX_VAL : Real;
        -- System reset
        signal reset_n : in std_logic;
        -- System clock
        signal clk : in std_logic;
        -- Output wave
        signal wave : out Real
    );

end package sim;

-- -------------------------------------------------------------- Body ---------------------------------------------------------------

package body sim is

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
    -- Random generators
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
            wave <= AMPLITUDE * sin(2 * MATH_PI * Real(ticks) * Real(FREQUENCY_HZ) / Real(SYS_CLK_HZ) + PHASE_SHIFT) + OFFSET;
            wait for CLK_PERIOD;
        end loop;

    end procedure;

    -- Generates sine wave summed with the uniform noised from the given range
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
        -- Lower bound of the random summant
        constant LOW_RAND : Real := 0.0;
        -- Higher bound of the random summant
        constant HIGH_RAND : Real := 0.0;
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
            wave <= AMPLITUDE * sin(2 * MATH_PI * Real(ticks) * Real(FREQUENCY_HZ) / Real(SYS_CLK_HZ) + PHASE_SHIFT) +
                    OFFSET + 
                    rand_real(LOW_RAND, HIGH_RAND);
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

    -- Generates random `stairs` with values in given range
    procedure generate_random_stairs(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Natural;
        -- Wave's min val
        constant MIN_VAL : Real;
        -- Wave's max val
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
