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

    -- Generates sine wave updating samples at falling edge of the clock
    procedure generate_sin(
        -- System cl    ock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Positive;
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

    -- Generates random `stairs` with values in given range
    procedure generate_random_stairs(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Positive;
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
        constant FREQUENCY_HZ : Positive;
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
        variable ticks : Positive;
    begin

        -- Reset condition
        ticks := 0;
        wave <= 0.0;

        -- Wait for end of reset
        wait until reset_n = '1';
        wait until falling_edge(clk);

        -- Update wave on falling edges
        loop
            ticks := ticks + 1;
            wave <= AMPLITUDE * sin(Real(ticks) * Real(FREQUENCY_HZ) / Real(SYS_CLK_HZ) + PHASE_SHIFT) + OFFSET;
            wait for CLK_PERIOD;
        end loop;
    
    end procedure;


    -- Generates random `stairs` with values in given range
    procedure generate_random_stairs(
        -- System clock's frequency
        constant SYS_CLK_HZ : Positive;
        -- Wave's frequency
        constant FREQUENCY_HZ : Positive;
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
        -- Peiord of the system clock
        constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ; 
    begin

        -- Reset condition
        wave <= 0.0;

        -- Wait for end of reset
        wait until reset_n = '1';

        -- Update saturation on falling edges
        loop
            wait until falling_edge(clk);
            wave <= rand_real(MIN_VAL, MAX_VAL);
            wait for CLK_PERIOD * (SYS_CLK_HZ / FREQUENCY_HZ);
        end loop;

    end procedure;

end package body sim;
