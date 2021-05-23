-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    Tremolo effect's testbench 
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

entity TremoloEffect is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Positive := 200_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- ================ Module's parameters ================ --

        -- Width of the input sample
        SAMPLE_WIDTH : Positive range 2 to 32;
        -- Width of the modulating sample
        MODULATION_SAMPLE_WIDTH : Positive range 2 to 32;
        -- Width of the `modulation_freq` parameter input
        MODULATION_FREQ_WIDTH : Positive range 1 to 32;
        -- Number of samples in a single period of the modulation wave
        MODULATION_SAMPLES_NUM : Positive;

        -- Input wave's frequency
        SAMPLES_FREQ_HZ : Positive := 44_100;

        -- ============== Generator's parameters =============== --
        
        -- Width of the address port
        ADDR_WIDTH : Positive := 6;
        -- Offset address of samples in the memory
        SAMPLE_ADDR_OFFSET : Natural := 0;

        -- ================ BRAM's parameters ================== --

        -- Latency (in cycles of @in clk) fof the BRAM read (0 for data collection on the next cycle after ena_out = '1')
        BRAM_LATENCY : Positive := 2;

        -- ============== Auxiliary parameters ================= --

        -- Path to the file containing data of the BRAM block (every line has to hold sample's value in decimal coding)
        MIF_PATH : String := "/home/cris/Desktop/PUF/src/utils/generators/xilinx-coe-generator/out/aux_bram_init.mif"

    );
end entity TremoloEffect;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of TremoloEffect is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    
    -- Sampled signal's amplitude
    constant SAMPLES_AMPLITUDE : Real := 2**(SAMPLE_WIDTH - 1) - 1;

    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- ====================== Module's interface ====================== --

        -- Enable signal (when module's disabled, samples are not modified)
    signal enable_in : Std_logic;
        -- `New input sample` signal (rising-edge-active)
    signal valid_in : Std_logic;
        -- `Output sample ready` signal (rising-edge-active)
    signal valid_out : Std_logic;

        -- Input sample
    signal sample_in : Signed(SAMPLE_WIDTH - 1 downto 0);
        -- Gained sample
    signal sample_out : Signed(SAMPLE_WIDTH - 1 downto 0);

    -- Busy output (active high)
    signal module_busy : Std_logic;
    -- Number of input samples per modulation wave's sample (minus 1)
    signal samples_per_modulation_sample : Unsigned(MODULATION_FREQ_WIDTH - 1 downto 0);

    -- ================ Quadruplet generator's signals ================ --

    -- Generator's sample output
    signal modulation_sample_out : Unsigned(MODULATION_SAMPLE_WIDTH - 1 downto 0);
    -- Generator's `busy` signal (active hight)
    signal modulation_busy_out : Std_logic;
    -- Generator's input initializing generation of the next sample (rising-edge-active)
    signal modulation_next_sample_in : Std_logic;

    -- ======================== BRAM Interface ======================== --

    -- Address lines
    signal addr_out : Std_logic_vector(ADDR_WIDTH - 1 downto 0);
    -- Data lines
    signal data_in : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    -- Enable line
    signal ena_out : Std_logic;

    -- ===================== Verification signals ===================== --

    -- Type to load BRAM image
    type RamImage is array (0 to MODULATION_SAMPLES_NUM - 1) of Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);

    -- Desired value of sample
    signal sample_expected : Signed(SAMPLE_WIDTH - 1 downto 0);

    -- ======================== Helper content ======================== --

    -- Real-converted input signal
    signal sample_in_tmp : Real;
    
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
        for i in 0 to MODULATION_SAMPLES_NUM - 1 loop
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
    -- Input signals' generation (all signals changed at falling edge to not interfere
    -- with module)
    -- =================================================================================

    -- Generate input signal
    sample_in <= to_signed(integer(sample_in_tmp), SAMPLE_WIDTH);
    generate_sin(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => SAMPLES_FREQ_HZ,
        PHASE_SHIFT  => 0.0,
        AMPLITUDE    => SAMPLES_AMPLITUDE,
        OFFSET       => 0.0,
        reset_n      => reset_n,
        clk          => clk,
        wave         => sample_in_tmp
    );

    -- `valid_in` generator
    process is
    begin

        -- Reset condition
        valid_in <= '0';

        -- Wait for end of reset
        wait until reset_n = '1';

        -- Update `valid_in` in predefined sequence
        loop

            -- Wait for rising edge
            wait until rising_edge(clk);

            -- Inform about new sample
            valid_in <= '1';
            -- Wait a cycle to pull `vali_in` low
            wait for CLK_PERIOD;
            valid_in <= '0';

            -- Wait for the end of conversion
            wait until falling_edge(module_busy);

        end loop;
    end process;

    -- =================================================================================
    -- Module's instance
    -- =================================================================================

    -- Instance of the tremolo effect's module
    tremoloEffectInstance: entity work.TremoloEffect
      generic map (
        SAMPLE_WIDTH            => SAMPLE_WIDTH,
        MODULATION_SAMPLE_WIDTH => MODULATION_SAMPLE_WIDTH,
        MODULATION_FREQ_WIDTH   => MODULATION_FREQ_WIDTH,
        MODULATION_SAMPLES_NUM  => MODULATION_SAMPLES_NUM
      )
      port map (
        reset_n                       => reset_n,
        clk                           => clk,
        enable_in                     => enable_in,
        valid_in                      => valid_in,
        valid_out                     => valid_out,
        sample_in                     => sample_in,
        sample_out                    => sample_out,
        samples_per_modulation_sample => samples_per_modulation_sample,
        modulation_sample_in          => modulation_sample_out,
        modulation_busy_in            => modulation_busy_out,
        modulation_next_sample_out    => modulation_next_sample_in,
        busy                          => module_busy
      );

    -- Instance of the saw wave generator
    quadrupletGeneratorInstance : entity work.QuadrupletGenerator
    generic map (
        SAMPLES_NUM        => MODULATION_SAMPLES_NUM,
        SAMPLE_WIDTH       => SAMPLE_WIDTH,
        ADDR_WIDTH         => ADDR_WIDTH,
        SAMPLE_ADDR_OFFSET => SAMPLE_ADDR_OFFSET,
        BRAM_LATENCY       => BRAM_LATENCY
    )
    port map (
        reset_n    => reset_n,
        clk        => clk,
        sample_clk => modulation_next_sample_in,
        sample_out => modulation_next_sample_out,
        busy       => modulation_busy_out,
        addr_out   => addr_out,
        data_in    => data_in,
        ena_out    => ena_out
    );

    -- BRAM instance
    tremoloEffectBramInstance : TremoloEffectTbBram
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

        -- Sample buffer latched on rising edge of the  `valid_in` signal
        variable sample_buf : Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');
        -- Sample buffer latched on rising edge of the  `valid_in` signal
        variable gain_buf : Unsigned(GAIN_WIDTH - 1 downto 0) := (others => '0');
        -- Sample buffer latched on rising edge of the  `valid_in` signal
        variable saturation_buf : Unsigned(SAMPLE_WIDTH - 2 downto 0) := (others => '0');
        
        -- Local result of multiplication
        variable result : Signed(SAMPLE_WIDTH + GAIN_WIDTH - TWO_POW_DIV downto 0) := (others => '0');
        -- Local copy of expected output of the block
        variable sample_out_expected_var : Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');

        -- High limit for the output value
        variable high_limit : Signed(SAMPLE_WIDTH - 1 downto 0);
        -- Low limit for the output value
        variable low_limit : Signed(SAMPLE_WIDTH - 1 downto 0);

    begin

        -- Keep output signals low
        sample_out_expected <= (others => '0');
        mul_out_expected <= (others => '0');
        sample_out_valid <= '0';
        -- Keep interal buffers low
        sample_buf := (others => '0');
        gain_buf := (others => '0');
        saturation_buf := (others => '0');
        result := (others => '0');
        sample_out_expected_var := (others => '0');
        high_limit := (others => '0');
        low_limit := (others => '0');

        -- Wait for end of reset
        wait until reset_n = '1';

        -- Validate module's output in loop
        loop

            -- Wait on the next rising edge after `valid_in` is pulled high
            wait until valid_in = '1';
            wait for CLK_PERIOD;
            -- Sample input data
            sample_buf := sample_in;
            gain_buf := gain_in;
            saturation_buf := saturation_in;

            -- Wait on the nex clk's falling edge after `valid_out` pulled high
            wait until valid_out = '1';
            wait until falling_edge(clk);
            
            -- Compute multiplication with division
            result := resize(sample_buf * Signed(resize(gain_buf, GAIN_WIDTH + 1)) / 2**TWO_POW_DIV, result'length);
            -- Make multiplication's result visible to the simulation
            mul_out_expected <= result;
            -- Compute saturation limits
            high_limit :=  Signed(resize(saturation_buf, SAMPLE_WIDTH));
            low_limit  := -Signed(resize(saturation_buf, SAMPLE_WIDTH));
            -- Compute expected output
            if(result > resize(high_limit, result'length)) then
                sample_out_expected_var := high_limit;
            elsif(result < resize(low_limit, result'length)) then
                sample_out_expected_var := low_limit;
            else
                sample_out_expected_var := resize(result, SAMPLE_WIDTH);
            end if;
            -- Make expected output visible
            sample_out_expected <= sample_out_expected_var;
            -- Check whether output matches desired one
            if(sample_out /= sample_out_expected_var) then
                sample_out_valid <= '0';
            else
                sample_out_valid <= '1';
            end if;
            
        end loop;

    end process;

end architecture logic;
