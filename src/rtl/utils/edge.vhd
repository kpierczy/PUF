-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-25 21:45:23
-- @ Modified time: 2021-04-25 21:45:27
-- @ Description: 
--    
--    Edge-detection-related utilities
--    
-- ===================================================================================================================================

package edge is

    -- Type of the edge
    type Edge is (RISING, FALLING, BOTH);

end package edge;

-- ===================================================================================================================================
-- A generic, synchronous edge detector
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.edge.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity EdgeDetector is

    generic(
        -- Active state of the @out detection output
        OUTPUT_ACTIVE : Std_logic := '1';
        -- Edge to be detected
        EDGE_DETECTED: Edge
    );
    port (
        -- System reset (active low
        reset_n :in std_logic;
        -- System clock
        clk :in std_logic;
        -- Sensed signal
        sig :in std_logic;
        -- 'Edge detected' output (active high)
        detection :out std_logic
   );

end entity EdgeDetector;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of EdgeDetector is

    -- Actual value of the input signal
    signal actual : std_logic;
    -- Previous value of the input signal
    signal previous : std_logic;
    -- Internal detection signal
    signal detection_internal : std_logic;

 begin

    -- =================================================================================
    -- Synchronous update of the internal latch registers
    -- =================================================================================
    process(reset_n, clk)
    begin
        -- Reset state
        if(reset_n = '0') then
            previous <= '0';
            actual <= '0';
        -- Active state
        elsif(rising_edge(clk)) then
            previous <= actual;
            actual <= sig;
        end if;
    end process;

    -- =================================================================================
    -- Output control
    -- =================================================================================

    -- Rising edge detection
    rising_detection: if EDGE_DETECTED = RISING generate
    detection_internal <= (not previous) and actual;
    end generate;
    -- Falling edge detection
    falling_detection: if EDGE_DETECTED = FALLING generate
    detection_internal <= previous and (not actual);
    end generate;
    -- Both edges detection
    both_detection: if EDGE_DETECTED = BOTH generate
    detection_internal <= previous xor actual;
    end generate;
    
    -- Reset state
    detection <= not (OUTPUT_ACTIVE xor (reset_n and detection_internal));

 end logic;


 -- ===================================================================================================================================
-- A generic, synchronous edge detector without input buffering. Desired to used with synchronous inputs.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.edge.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity EdgeDetectorSync is

    generic(
        -- Active state of the @out detection output
        OUTPUT_ACTIVE : Std_logic := '1';
        -- Edge to be detected
        EDGE_DETECTED: Edge
    );
    port (
        -- System reset (active low
        reset_n :in std_logic;
        -- System clock
        clk :in std_logic;
        -- Sensed signal
        sig :in std_logic;
        -- 'Edge detected' output (active high)
        detection :out std_logic
   );

end entity EdgeDetectorSync;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of EdgeDetectorSync is

    -- Previous value of the input signal
    signal previous : std_logic;
    -- Internal detection signal
    signal detection_internal : std_logic;

 begin

    -- =================================================================================
    -- Synchronous update of the internal latch register
    -- =================================================================================
    process(reset_n, clk)
    begin
        -- Reset state
        if(reset_n = '0') then
            previous <= '0';
        -- Active state
        elsif(rising_edge(clk)) then
            previous <= sig;
        end if;
    end process;

    -- =================================================================================
    -- Output control
    -- =================================================================================

    -- Rising edge detection
    rising_detection: if EDGE_DETECTED = RISING generate
    detection_internal <= (not previous) and sig;
    end generate;
    -- Falling edge detection
    falling_detection: if EDGE_DETECTED = FALLING generate
    detection_internal <= previous and (not sig);
    end generate;
    -- Both edges detection
    both_detection: if EDGE_DETECTED = BOTH generate
    detection_internal <= previous xor sig;
    end generate;
    
    -- Reset state
    detection <= not (OUTPUT_ACTIVE xor (reset_n and detection_internal));

 end logic;
