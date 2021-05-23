-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-25 22:44:38
-- @ Modified time: 2021-04-25 22:44:45
-- @ Description: 
--    
--    Testbench for functionalities present in the 'edge' package
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.edge.all;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity EdgeTb is
end entity EdgeTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of EdgeTb is
     
     -- System clock period
     constant CLK_PERIOD : Time := 20 ns;

     -- MIN time between random toggles of the enable signal
     constant MIN_SIG_TOGGLE_TIME : Time := 10 ns;
     -- Max time between random toggles of the enable signal
     constant MAX_SIG_TOGGLE_TIME : Time := 100 ns;

    -- Reset (asynchronous)
    signal reset_n	: Std_logic;
    -- System clock signal
    signal clk : std_logic;

    -- Example signal used for testing edge-detection
    signal sig : Std_logic := '0';
    -- Example signal used for testing synchronous edge-detection
    signal sig_sync : Std_logic := '0';
    -- Output of the rising-edge detector
    signal rising_detection : Std_logic;
    -- Output of the falling-edge detector
    signal falling_detection : Std_logic;
    -- Output of the both-edges detector
    signal both_detection : Std_logic;
    -- Output of the synchronous rising-edge detector
    signal rising_detection_sync : Std_logic;
    -- Output of the synchronous falling-edge detector
    signal falling_detection_sync : Std_logic;
    -- Output of the synchronous both-edges detector
    signal both_detection_sync : Std_logic;

begin


    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Reset signal
    reset_n <= '0', '1' after CLK_PERIOD;

    -- Clock signal
    clk <= not clk after CLK_PERIOD / 2 when reset_n /= '0' else '0';
    
    -- =================================================================================
    -- Edges detection test
    -- =================================================================================

    -- Rising edge detector
    rising_detector: entity work.EdgeDetector(logic)
    generic map (
        EDGE_DETECTED => RISING
    )
    port map (
        reset_n   => reset_n,
        clk       => clk,
        sig       => sig,
        detection => rising_detection
    );

    -- Falling edge detector
    falling_detector: entity work.EdgeDetector(logic)
    generic map (
        EDGE_DETECTED => FALLING
    )
    port map (
        reset_n   => reset_n,
        clk       => clk,
        sig       => sig,
        detection => falling_detection
    );

    -- Both edges detector
    both_detector: entity work.EdgeDetector(logic)
    generic map (
        EDGE_DETECTED => BOTH
    )
    port map (
        reset_n   => reset_n,
        clk       => clk,
        sig       => sig,
        detection => both_detection
    );

    -- Example random signal
    sig <= not sig after rand_time(MIN_SIG_TOGGLE_TIME, MAX_SIG_TOGGLE_TIME);

    -- =================================================================================
    -- Edges detection test (synchronous)
    -- =================================================================================

    -- Rising edge detector
    rising_detector_sync: entity work.EdgeDetectorSync(logic)
    generic map (
        EDGE_DETECTED => RISING
    )
    port map (
        reset_n   => reset_n,
        clk       => clk,
        sig       => sig_sync,
        detection => rising_detection_sync
    );

    -- Falling edge detector
    falling_detector_sync: entity work.EdgeDetectorSync(logic)
    generic map (
        EDGE_DETECTED => FALLING
    )
    port map (
        reset_n   => reset_n,
        clk       => clk,
        sig       => sig_sync,
        detection => falling_detection_sync
    );

    -- Both edges detector
    both_detector_sync: entity work.EdgeDetectorSync(logic)
    generic map (
        EDGE_DETECTED => BOTH
    )
    port map (
        reset_n   => reset_n,
        clk       => clk,
        sig       => sig_sync,
        detection => both_detection_sync
    );

    -- Example random signal
    process (clk) is
        variable next_toggle : Time := 0 ns;
    begin
        if(rising_edge(clk) and (now > next_toggle)) then
            sig_sync <= not sig_sync;
            next_toggle := now + rand_time(MIN_SIG_TOGGLE_TIME, MAX_SIG_TOGGLE_TIME);
        end if;
    end process;

end architecture logic;
