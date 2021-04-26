-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-26 17:31:31
-- @ Modified time: 2021-04-26 17:31:32
-- @ Description: 
--    
--    Uart-related package
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;

-- ------------------------------------------------------------- Header --------------------------------------------------------------

package uart is

    -- Type of the edge
    type Parity is (EVEN, ODD);

    -- Reception errors (usable to index Std_logic_vector)
    type UartErrors is record
        start_err  : Std_logic;
        stop_err   : Std_logic;
        parity_err : Std_logic;
    end record;

    -- Oversampling type
    type UartOvs is (X8, X16);

    -- Parity bit generator. Returns '1' if number of bits set in @p data is even (for EVEN) or odd (for ODD) and '0' otherwise
    function parity_gen(data : Std_logic_vector; parity_type: Parity) return Std_logic;

end package uart;

-- -------------------------------------------------------------- Body ---------------------------------------------------------------

package body uart is

    -- Parity bit generator. Returns '1' if number of bits set in @p data is even (for EVEN) or odd (for ODD) and '0' otherwise
    function parity_gen(data : Std_logic_vector; parity_type: Parity) return Std_logic is
        -- Intermediate result
        variable intermediate : Std_logic := '0';
    begin

        -- Switch initial value for odd parity
        if (parity_type = EVEN) then
            intermediate := '1';
        end if;
        -- XOR calculations
        for i in 0 to (data'length - 1) loop
            intermediate := data(i) xor intermediate;
        end loop;
        -- Return value
        return intermediate;

    end function;

end package body uart;
