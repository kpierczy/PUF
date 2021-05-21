-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-21 00:18:59
-- @ Modified time: 2021-05-21 00:19:10
-- @ Description: 
--    
--    Quadruplet generator's testbench
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity QuadrupleGeneratorTb is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Positive := 200_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- Number of samples in a quarter
        SAMPLES_NUM : Positive := 64;
        -- Width of the single sample
        SAMPLE_WIDTH : Positive := 16;
        -- Width of the address port
        ADDR_WIDTH : Positive := 6;
        -- Offset address of samples in the memory
        SAMPLE_ADDR_OFFSET : Natural := 0;
        -- Latency (in cycles of @in clk) fof the BRAM read (1 for data collection on the next cycle after ena_out = '1')
        BRAM_LATENCY : Positive := 2;

        -- Path to the file containing data of the BRAM block (every line has to hold sample's value in decimal coding)
        data_path : String := "/home/cris/Desktop/PUF/src/utils/generators/xilinx-coe-generator/out/aux_bram_init.txt";

        -- Time between subsequent requests for a new sample to the module
        SAMPLES_GAP : Time := 5 ns
    );
end entity QuadrupleGeneratorTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of QuadrupleGeneratorTb is

    -- BRAM declaration
    component QuadrupletGeneratorTbBram
    port (
        clka : in Std_logic;
        rsta : in Std_logic;
        ena : in Std_logic;
        wea : in Std_logic_vector(0 downto 0);
        addra : in Std_logic_vector(5 downto 0);
        dina : in Std_logic_vector(15 downto 0);
        douta : out Std_logic_vector(15 downto 0)
    );
    end component;

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    
    
    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- ====================== Module's interface ====================== --

    -- Next clk's cycle after `sample_clk`'s rising edge a new sample is read from memory
    signal sample_clk : Std_logic;
    -- Data lines
    signal sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- Line is pulled to '1' when module is processing a sample
    signal busy : Std_logic;

    -- ================= BRAM Interface ================= --

    -- Address lines
    signal addr_out : Std_logic_vector(ADDR_WIDTH - 1 downto 0);
    -- Data lines
    signal data_in : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    -- Enable line
    signal ena_out : Std_logic;

    -- ===================== Verification signals ===================== --

    -- Desired value of sample
    signal sample_expected : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- `Output valid` bit flag
    signal sample_valid : std_logic;

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

    -- Instance of the clipping effect's module
    quadrupletGeneratorInstance : entity work.QuadrupletGenerator
    generic map (
        SAMPLES_NUM        => SAMPLES_NUM,
        SAMPLE_WIDTH       => SAMPLE_WIDTH,
        ADDR_WIDTH         => ADDR_WIDTH,
        SAMPLE_ADDR_OFFSET => SAMPLE_ADDR_OFFSET,
        BRAM_LATENCY       => BRAM_LATENCY
    )
    port map (
        reset_n    => reset_n,
        clk        => clk,
        sample_clk => sample_clk,
        sample_out => sample_out,
        busy       => busy,
        addr_out   => addr_out,
        data_in    => data_in,
        ena_out    => ena_out
    );

    -- BRAM instance
    quadrupletGeneratorBramInstance : QuadrupletGeneratorTbBram
    PORT MAP (
        clka => clk,
        rsta => not(reset_n),
        ena => ena_out,
        wea => (others => '0'),
        addra => addr_out,
        dina => (others => '0'),
        douta => data_in
    );

    -- =================================================================================
    -- Procedure's validation
    -- =================================================================================

    -- Validate Module
    process is



    begin

        sample_clk <= '0';
        -- Wait for end of reset
        wait until reset_n = '1';

        -- Validate module's output in loop
        loop

            wait until rising_edge(clk);
            sample_clk <= '1';
            wait for CLK_PERIOD;
            sample_clk <= '0';
            wait until falling_edge(busy);
            wait for SAMPLES_GAP;
            
        end loop;

    end process;

end architecture logic;
