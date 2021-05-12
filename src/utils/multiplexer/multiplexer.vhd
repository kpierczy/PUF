-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-12 15:11:33
-- @ Modified time: 2021-05-12 15:12:39
-- @ Description: 
--    
--    Universal multiplexer
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ===================================================================================================================================
-- ------------------------------------------------------------ Package --------------------------------------------------------------
-- ===================================================================================================================================

package multiplexer is

    -- Universal multiplexer's input
    type vectorsArray is array(natural range <>) of std_logic_vector;

end package;

-- ===================================================================================================================================
-- ------------------------------------------------------------- Module --------------------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.multiplexer.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity UniversalMultiplexer is
    generic(
        -- Width of the single data input
        DATA_WIDTH : positive := 8;
        -- Width of the @in sel input
        SEL_WIDTH : positive := 2
    );
    port (
        -- Array of data inputs
        data_in : in vectorsArray(2**SEL_WIDTH - 1 downto 0)(DATA_WIDTH - 1 downto 0);
        -- Select input
        sel : in std_logic_vector(SEL_WIDTH - 1 downto 0);
        -- Output data
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end UniversalMultiplexer;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of UniversalMultiplexer is
begin
    -- Assign proper input's element to the output
    data_out <= data_in(to_integer(unsigned(sel)));
end UniversalMultiplexer;
