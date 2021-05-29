-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-22 23:16:18
-- @ Modified time: 2021-05-22 23:20:49
-- @ Description: 
--    
--    Analog sequence reader's testbench
--    
-- @ Note: `design.txt` file containing input signals for simulation's analog line must be MANUALLY added as `simulation source file`
--     to the project. Otherwise XADC's `busy` line will stay high infinitely. Thanks Xilinx for (not) describing it in the doc...
-- ===================================================================================================================================

library std;
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.xadc.all;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity AnalogSequenceReaderTb is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Positive := 100_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- Frequency of conversions
        SAMPLING_FREQ_HZ : Positive := 50_000;
        -- Number of channels sampled in sequence by the ADC
        CHANNELS_NUM : Positive range 1 to 16 := 9
    );
end entity AnalogSequenceReaderTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of AnalogSequenceReaderTb is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;

    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- ====================== Module's interface ====================== --

    -- External MUX's select lines
    signal mux_sel_out : Std_logic_vector(3 downto 0);
    -- Sampled outputs
    signal channels_out : xadcSamplesArray(0 to CHANNELS_NUM - 1);

begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Clock signal
    clock_tb(CLK_PERIOD, clk);

    -- Reset signal
    reset_tb(SYS_RESET_TICKS * CLK_PERIOD, reset_n);

    -- =================================================================================
    -- Module's instance
    -- =================================================================================

    -- Instance of the analog reader's module
    analogSequenceReaderInstance: entity work.AnalogSequenceReader(logic)
    generic map (
        SYS_CLK_HZ       => SYS_CLK_HZ,
        SAMPLING_FREQ_HZ => SAMPLING_FREQ_HZ,
        CHANNELS_NUM     => CHANNELS_NUM
    )
    port map (
        reset_n      => reset_n,
        clk          => clk,
        anal_in_p    => '0',
        anal_in_n    => '0',
        mux_sel_out  => mux_sel_out,
        channels_out => channels_out
    );

end architecture logic;
