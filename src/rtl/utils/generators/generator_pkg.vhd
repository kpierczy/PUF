-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-24 02:18:50
-- @ Modified time: 2021-05-24 02:20:16
-- @ Description: 
--    
--    Common generator's package
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package generator_pkg is

    -- Type of the generator
    type GeneratorType is (TRIANGLE, QUADRUPLET);

    -- Quadruplet generator's mode
    type Signess is (SIGNED_OUT, UNSIGNED_OUT);

end package generator_pkg;
