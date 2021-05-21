-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-21 00:18:59
-- @ Modified time: 2021-05-21 00:19:10
-- @ Description: 
--    
--    Quadruplet generator's testbench
--    
-- ===================================================================================================================================

library std;
use std.textio.all;
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
        -- Latency (in cycles of @in clk) fof the BRAM read (0 for data collection on the next cycle after ena_out = '1')
        BRAM_LATENCY : Positive := 2;

        -- Path to the file containing data of the BRAM block (every line has to hold sample's value in decimal coding)
        MIF_PATH : String := "/home/cris/Desktop/PUF/src/utils/generators/xilinx-coe-generator/out/aux_bram_init.mif";

        -- Frequency of `new sample` requests (rounded down to natural fraction of SYS_CLK_HZ)
        NEW_SAMPLE_HZ : Positive range 1 to SYS_CLK_HZ / (BRAM_LATENCY + 2) := 44_100 * (SAMPLES_NUM * 4 - 3)
    );
end entity QuadrupleGeneratorTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of QuadrupleGeneratorTb is

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

    -- Address lines
    signal addr_out : Std_logic_vector(ADDR_WIDTH - 1 downto 0);
    -- Data lines
    signal data_in : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    -- Enable line
    signal ena_out : Std_logic;

    -- ===================== Verification signals ===================== --

    -- Type to load BRAM image
    type RamImage is array (0 to SAMPLES_NUM - 1) of Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);

    -- Desired value of sample
    signal sample_expected : Signed(SAMPLE_WIDTH - 1 downto 0);

    -- ======================== Helper content ======================== --
    
    -- Initializes BRAM image from binary MIF file
    impure function init_ram_bin(path : String) return RamImage is
        -- MIF file to be read
        file text_file : text open read_mode is path;
        -- Foile's line
        variable text_line : line;
        -- Ram conent
        variable ram_content : RamImage;
    begin
        -- Read lines and convert to numeric values
        for i in 0 to SAMPLES_NUM - 1 loop
            readline(text_file, text_line);
            bread(text_line, ram_content(i));
        end loop;
        -- Return BRAM content
        return ram_content;
    end function;

    -- BRAM content
    signal bram : RamImage := init_ram_bin(MIF_PATH);

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

    -- Saples generating process
    process is
    begin

        -- Keep module inactive
        sample_clk <= '0';

        -- Wait for end of reset
        wait until reset_n = '1';
        -- Start samples generation on rising edge
        wait until rising_edge(clk);

        -- Validate module's output in loop
        loop

            -- Pull trigger high ...
            sample_clk <= '1';
            wait for CLK_PERIOD;
            -- ... and back low after one cycle
            sample_clk <= '0';
            -- Wait for end of module's work
            wait until falling_edge(busy);
            -- Wait until next sample (take into account module's delay)
            if (1 sec / NEW_SAMPLE_HZ - (BRAM_LATENCY + 2) * CLK_PERIOD > 0 sec) then
                -- Wait one cycle less in case SYS_CLK_HZ is not multiple of NEW_SAMPLE_HZ
                if (1 sec / NEW_SAMPLE_HZ - (BRAM_LATENCY + 3) * CLK_PERIOD > 0 sec) then
                    wait for 1 sec / NEW_SAMPLE_HZ - (BRAM_LATENCY + 3) * CLK_PERIOD;
                end if;
                -- Start samples generation on rising edge
                wait until rising_edge(clk);
            end if;
            
        end loop;

    end process;

    -- Validate Module
    process is

        -- Types of quarters
        type QuarterId is (Q1, Q2, Q3, Q4);
        -- Actual stage
        variable quarter : QuarterId;
        -- Count of output samples from the actual quarter
        variable quarter_sample_num : Natural;

        -- Variable representation fo expected sample
        variable sample_expected_var : signed(SAMPLE_WIDTH - 1 downto 0);

    begin

        -- Reset validation signals 
        sample_expected <= (others => '0');
        -- Reset quarters
        quarter := Q1;
        quarter_sample_num := 0;
        sample_expected_var := Signed(bram(quarter_sample_num));

        -- Wait for end of reset
        wait until reset_n = '1';

        -- Validate module's output in loop
        loop

            -- Wait for new sample on the output
            wait until falling_edge(busy);
            -- Wait until next falling edge of the clk to let `sample_out` signal stabilize
            wait until falling_edge(clk);
            -- Compare expected output with actual
            if(sample_out /= sample_expected_var) then
                sample_expected <= (others => 'X');
            else
                sample_expected <= sample_expected_var;
            end if;

            -- Update quarter, if needed
            if(quarter_sample_num = SAMPLES_NUM - 1 and (quarter = Q1 or quarter = Q3)) then
                if(quarter = Q1) then 
                    quarter := Q2;
                elsif(quarter = Q3) then 
                    quarter := Q4;
                end if;
            elsif(quarter_sample_num = 0 and (quarter = Q2 or quarter = Q4)) then
                if(quarter = Q2) then 
                    quarter := Q3;
                elsif(quarter = Q4) then 
                    quarter := Q1;
                end if;
            end if;
            
            -- Update sample index
            case quarter is
                when Q1|Q3 => 
                    quarter_sample_num := quarter_sample_num + 1;
                when Q2|Q4 => 
                    quarter_sample_num := quarter_sample_num - 1;
            end case;
                        
            -- Update next expected sample
            case quarter is
                when Q1|Q2 => 
                    sample_expected_var :=  Signed(bram(quarter_sample_num));
                when Q3|Q4 => 
                    sample_expected_var := -Signed(bram(quarter_sample_num));
            end case;

        end loop;
        
    end process;

end architecture logic;
