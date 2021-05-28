-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-28 03:17:40
-- @ Modified time: 2021-05-28 03:17:41
-- @ Description: 
--    
--    Configuration of the project's general parameters
--    
-- ===================================================================================================================================

package config is

    -- Speed of the system clock
    constant CONFIG_SYS_CLK_HZ : Positive := 100_000_000;

    -- Width of the input sample
    constant CONFIG_SAMPLE_WIDTH : Positive range 2 to Positive'high := 16;

end package config;
