-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-20 13:35:53
-- @ Modified time: 2021-05-20 13:36:15
-- @ Description: 
--    
--    Scetch testing number of bits of result of basic vhdl operations on `std_logic_vector`-base types
--    
-- @ Note: This suimulation should fail indicating size of the result of operation performed in the process
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DivisionBisTest is
end entity DivisionBisTest;

architecture logic of DivisionBisTest is
begin

    -- Multiplication division testing
    process is
        constant TWO_POW_DIV : Natural := 3;
        constant ARG_WIDTH: Natural := 8;
        variable A : Signed(ARG_WIDTH - 1 downto 0) := to_signed(5, ARG_WIDTH);
        variable B : Signed(ARG_WIDTH - 1 downto 0) := to_signed(8, ARG_WIDTH);
        variable C : Signed(ARG_WIDTH - 1 - 1 downto 0);
    begin
    
        C := A * B / 2**TWO_POW_DIV;
        wait;

    end process;

end architecture logic;
