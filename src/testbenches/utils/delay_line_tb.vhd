-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-25 17:56:24
-- @ Modified time: 2021-05-25 17:56:31
-- @ Description: 
--    
--    Testbench for the BRAM-base  delay line module
--    
-- @ Note: This testbench utilizes externally defined BRAM IP named `DelayLineTbBram`.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity DelayLineTb is
    generic(

        -- System clock frequency
        SYS_CLK_HZ : Positive := 200_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- ======================== Module's parameters ========================= --

        -- Width of the input sample
        DATA_WIDTH : Positive := 16;
        -- Width of the @in depth port
        DELAY_WIDTH : Positive := 7;

        -- Smooth start mechanism
        SOFT_START : boolean := TRUE;

        -- ========================= BRAM's parameters ========================== --

        -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
        BRAM_SAMPLES_NUM : Positive := 100;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive := 7;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive := 2;

        -- ===================== Module's resetting signal ====================== --

        -- -------------------------------------------------------------------------
        -- @Note: Reset signal on the simulated module can be raised periodically
        --    to check how it's output behaves in such condition. The signal is 
        --    generated as periodically triggerred low state lasting as many cycle
        --    as given in the PERIODIC_RESET_CYCLES. If PERIODIC_RESET_FREQ_HZ
        --    is equal to 0, no periodic reset is performed.
        -- -------------------------------------------------------------------------

        -- Number of reset cycles
        PERIODIC_RESET_CYCLES : Positive := 2;
        -- Frequency of the input signal 
        PERIODIC_RESET_FREQ_HZ : Natural := 50;        

        -- ===================== Input signal's parameters ====================== --

        -- Type of the input wave (available: [sin])
        INPUT_TYPE : String := "sin";

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Positive := 1000;
        -- Amplitude of the input wave in normalized range <0; 1>
        INPUT_AMPLITUDE : Real := 0.5;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive := 100_000;        

        -- ================== Line's delay's stimulus signals =================== --

        -- -------------------------------------------------------------------------
        -- @Note: Stimulus signals for effect's parameters are generated as random 
        --    steps with given frequency and amplitude.
        -- -------------------------------------------------------------------------

        -- Amplitudes of `delay_in` input's values in normalized range <0; 1>
        DELAY_AMPLITUDE : Real := 0.25;
        -- Frequency of the changes of `depth_in` input
        DELAY_TOGGLE_FREQ_HZ : Natural := 0
    );
end entity DelayLineTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of DelayLineTb is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    
    
    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- ===================== Module's interface ======================= --

    -- Module's manual reset signal (ANDed with `reset_n`)
    signal manual_module_reset_n : Std_logic := '0';
    -- Module's reset signal
    signal module_reset_n : Std_logic := '0';

    -- Enable line; when high the module starts processing samples on the input
    signal enable_in : Std_logic;
    -- Busy line (active high)
    signal busy_out : Std_logic;

    -- Delay level
    signal delay_in : Unsigned(DELAY_WIDTH - 1 downto 0);
    
    -- Data lines
    signal data_in : Std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal data_out : Std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- ======================= BRAM's interface ======================= --

    -- BRAM declaration
    component DelayLineTbBram
    port (
        clka : in Std_logic;
        rsta : in Std_logic;
        ena : in Std_logic;
        wea : in Std_logic_vector(0 downto 0);
        addra : in Std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
        dina : in Std_logic_vector(DATA_WIDTH - 1 downto 0);
        douta : out Std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
    end component;

    -- BRAM reset line
    signal bram_reset : Std_logic;
    -- Address lines
    signal bram_addr_in : Std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
    -- Data lines
    signal bram_data_out : Std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal bram_data_in : Std_logic_vector(DATA_WIDTH - 1 downto 0);
    -- Enable/write enable lines
    signal bram_en_in : Std_logic;
    signal bram_wen_in : Std_logic_vector(0 downto 0);

    -- ====================== Auxiliary signals ====================== --

    -- Real-converted input signal
    signal data_tmp : Real;
    -- Real-converted delay value
    signal delay_tmp : Real;

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

    -- Connect BRAM's reset
    bram_reset <= not(reset_n);

    -- Instance of the BRAM
    delayLineTbBramInstance: DelayLineTbBram
    port map (
        clka  => clk,
        rsta  => bram_reset,
        ena   => bram_en_in,
        wea   => bram_wen_in,
        addra => bram_addr_in,
        dina  => bram_data_in,
        douta => bram_data_out
    );

    -- Instance of the module
    delayLineInstance: entity work.DelayLine(logic)
    generic map (
        DATA_WIDTH       => DATA_WIDTH,
        DELAY_WIDTH      => DELAY_WIDTH,
        SOFT_START       => SOFT_START,
        BRAM_SAMPLES_NUM => BRAM_SAMPLES_NUM,
        BRAM_ADDR_WIDTH  => BRAM_ADDR_WIDTH,
        BRAM_LATENCY     => BRAM_LATENCY
    )
    port map (
        reset_n       => module_reset_n,
        clk           => clk,
        enable_in     => enable_in,
        busy_out      => busy_out,
        delay_in      => delay_in,
        data_in       => data_in,
        data_out      => data_out,
        bram_addr_out => bram_addr_in,
        bram_data_in  => bram_data_out,
        bram_data_out => bram_data_in,
        bram_en_out   => bram_en_in,
        bram_wen_out  => bram_wen_in
    );

    -- Connect module's reset
    module_reset_n <= reset_n and not(manual_module_reset_n);

    -- =================================================================================
    -- Input signals' generation 
    -- =================================================================================    

    -- Generate input signal : sin
    inputSin : if INPUT_TYPE = "sin" generate
        data_in <= Std_logic_vector(to_signed(integer(data_tmp), DATA_WIDTH));
        generate_sin(
            SYS_CLK_HZ   => SYS_CLK_HZ,
            FREQUENCY_HZ => INPUT_FREQ_HZ,
            PHASE_SHIFT  => 0.0,
            AMPLITUDE    => Real(INPUT_AMPLITUDE * (2**(DATA_WIDTH - 1) - 1)),
            OFFSET       => 0.0,
            reset_n      => reset_n,
            clk          => clk,
            wave         => data_tmp
        );
    end generate;

    -- Generate `delay` signal
    delay_in <= to_unsigned(Natural(delay_tmp), DELAY_WIDTH);
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => DELAY_TOGGLE_FREQ_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(DELAY_AMPLITUDE * BRAM_SAMPLES_NUM)),
        reset_n      => reset_n,
        clk          => clk,
        wave         => delay_tmp
    );

    -- =================================================================================
    -- Input signal's sampling process
    -- =================================================================================

    -- Generate sampling pulse 
    generate_clk(
        SYS_CLK_HZ       => SYS_CLK_HZ,
        FREQUENCY_HZ     => INPUT_SAMPLING_FREQ_HZ,
        reset_n          => reset_n,
        clk              => clk,
        wave             => enable_in
    );

    -- Generate cyclic reset signal
    generate_clk(
        SYS_CLK_HZ       => SYS_CLK_HZ,
        FREQUENCY_HZ     => PERIODIC_RESET_FREQ_HZ,
        HIGH_CLK         => PERIODIC_RESET_CYCLES,
        reset_n          => reset_n,
        clk              => clk,
        wave             => manual_module_reset_n
    );    

end architecture logic;
