-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    Tremolo effect's testbench 
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;
use work.tremolo.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity TremoloEffectTb is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Positive := 200_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- ======================== Effect's parameters ========================= --

        -- Generator type
        GENERATOR_TYPE : Generator := QUADRUPLET;
        -- Width of the input sample
        SAMPLE_WIDTH : Positive range 2 to 32 := 16;

        -- ====================== Modulation's parameters ======================= --

        -- Width of the modulating sample
        MODULATION_SAMPLE_WIDTH : Positive range 2 to 32 := 16;
        -- Width of the `ticks_per_sample` input
        MODULATION_TICKS_PER_SAMPLE_WIDTH : Positive := 16;

        -- ==================== QuadrupletGenerator-specific ==================== --

        -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
        BRAM_SAMPLES_NUM : Positive := 129;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive := 8;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive := 2;
        
        -- ======================= Simulation's parameters ====================== --

        -- Frequency of the input wave
        INPUT_FREQU_HZ : Positive := 1_000;
        -- Amplitude of the input wave in normalized range (0; 1>
        INPUT_AMPLITUDE : Real := 1.0;
        
        -- Frequency of the modulating wave [Hz]
        MODULATION_FREQ_HZ : Positive := 6;

        -- Frequency of the module's input samples [Hz]
        SAMPLING_FREQUENCY_HZ : Positive := 44_100
    );
end entity TremoloEffectTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of TremoloEffectTb is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    
    
    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- ====================== Module's interface ====================== --

    -- Module's enable signal
    signal enable_in : Std_logic := '1';
    -- Input and output samples
    signal sample_in, sample_out :  Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');
    -- Signal for new sample on input (rising-edge-active)
    signal valid_in : Std_logic := '0';
    -- Signal for new sample on output (rising-edge-active)
    signal valid_out : Std_logic;
    
    -- Module's saturation
    signal ticks_per_modulation_sample : Unsigned(MODULATION_TICKS_PER_SAMPLE_WIDTH - 1 downto 0);

    -- ====================== Auxiliary signals ====================== --

    -- Real-converted input signal
    signal sample_in_tmp : Real;

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

    -- Instance of the tremolo effect's module
    tremoloeffect_inst: entity work.TremoloEffect
      generic map (
        GENERATOR_TYPE                    => GENERATOR_TYPE,
        SAMPLE_WIDTH                      => SAMPLE_WIDTH,
        MODULATION_SAMPLE_WIDTH           => MODULATION_SAMPLE_WIDTH,
        MODULATION_TICKS_PER_SAMPLE_WIDTH => MODULATION_TICKS_PER_SAMPLE_WIDTH,
        BRAM_SAMPLES_NUM                  => BRAM_SAMPLES_NUM,
        BRAM_ADDR_WIDTH                   => BRAM_ADDR_WIDTH,
        BRAM_LATENCY                      => BRAM_LATENCY
      )
      port map (
        reset_n                     => reset_n,
        clk                         => clk,
        enable_in                   => enable_in,
        valid_in                    => valid_in,
        valid_out                   => valid_out,
        sample_in                   => sample_in,
        sample_out                  => sample_out,
        ticks_per_modulation_sample => ticks_per_modulation_sample
      );

    -- =================================================================================
    -- Input signals' generation (all signals changed at falling edge to not interfere
    -- with module)
    -- =================================================================================

    -- Generate input signal
    sample_in <= to_signed(integer(sample_in_tmp), SAMPLE_WIDTH);
    generate_sin(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => INPUT_FREQU_HZ,
        PHASE_SHIFT  => 0.0,
        AMPLITUDE    => Real(INPUT_AMPLITUDE) * (2**(SAMPLE_WIDTH - 1) - 1),
        OFFSET       => 0.0,
        reset_n      => reset_n,
        clk          => clk,
        wave         => sample_in_tmp
    );

    -- `valid_in` generator
    process is
    begin

        -- Keep module disabled
        enable_in <= '0';
        -- Reset condition
        valid_in <= '0';

        -- Wait for end of reset
        wait until reset_n = '1';

        -- Enable module
        enable_in <= '1';

        -- Update `valid_in` in predefined sequence
        loop

            -- Wait for rising edge
            wait until rising_edge(clk);

            -- Inform about new sample
            valid_in <= '1';
            -- Wait a cycle to pull `vali_in` low
            wait for CLK_PERIOD;
            valid_in <= '0';

            -- Wait a gap time before triggering the next cycle
            wait for 1 sec / SAMPLING_FREQUENCY_HZ - CLK_PERIOD;

        end loop;
    end process;

    -- =================================================================================
    -- Auxiliary procedures
    -- =================================================================================

    -- When triangle modulator is used
    triangleModulatorCase : if GENERATOR_TYPE = TRIANGLE generate
        
        ticks_per_modulation_sample <= to_unsigned(
            SYS_CLK_HZ / MODULATION_FREQ_HZ / 2**(MODULATION_SAMPLE_WIDTH + 1), ticks_per_modulation_sample'length
        );

    end generate;

    -- When quadruplet modulator is used
    quadrupletModulatorCase : if GENERATOR_TYPE = QUADRUPLET generate
        
        ticks_per_modulation_sample <= to_unsigned(
            SYS_CLK_HZ / MODULATION_FREQ_HZ / (BRAM_SAMPLES_NUM * 4  - 4), ticks_per_modulation_sample'length
        );
        
    end generate;

end architecture logic;
