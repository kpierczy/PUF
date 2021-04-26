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

    -- Random function's seed
    shared variable seed1, seed2 : Integer := 999;

    -- Generates random Real number in range
    impure function rand_real(min_val, max_val : Real) return Real;
    
    -- Generates random Time value in range
    impure function rand_time(min_val, max_val : Time; unit : Time := ns) return Time;

    -- Generates random Integer value in range
    impure function rand_int(min_val, max_val : Integer) return Integer;

    -- Generates  random logic vector with the given length
    impure function rand_logic_vector(len : Integer) return Std_logic_vector; 

end package sim;

-- -------------------------------------------------------------- Body ---------------------------------------------------------------

package body sim is

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

end package body sim;
