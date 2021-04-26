 -- ===================================================================================================================================
 -- @ Author: Krzysztof Pierczyk
 -- @ Create Time: 2021-04-26 01:37:43
 -- @ Modified time: 2021-04-26 13:33:45
 -- @ Description: 
 --    
 --    Testbench for simulation utilities package
 --    
 -- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity sim_tb is
end entity sim_tb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of sim_tb is
     
    -- Example signal used for testing edge-detection
    signal real_val : Real := 0.0;
    -- Output of the rising-edge detector
    signal time_val : Time := 0 ns;
    -- Output of the falling-edge detector
    signal integer_val : Integer := 0;
    -- Output of the both-edges detector
    signal std_logic_vec_val : Std_logic_vector(7 downto 0) := (others => '0');

begin
    
    -- =================================================================================
    -- Random generators test
    -- =================================================================================

    process is
    begin
        real_val <= rand_real(0.0, 100.0);
        time_val <= rand_time(0 ns, 100 ns);
        integer_val <= rand_int(0, 100);
        std_logic_vec_val <= rand_logic_vector(8);
        wait for 50 ns;
    end process;
    

end architecture logic;
