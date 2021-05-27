-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-22 11:00:23
-- @ Modified time: 2021-05-22 16:15:54
-- @ Description: 
--    
--    
-- @ Note: When tremolo effect is used with Quadruplet generator this is assummed that underlying block of BRAM is named
--     TremoloEffectBram. In such case only one instance of the effect can be spawned.
-- ===================================================================================================================================

-- ------------------------------------------------------------ Package --------------------------------------------------------------

package tremolo is

    -- Type of the generator sued
    type Generator is (QUADRUPLET, TRIANGLE);

end package;

-- ===================================================================================================================================
-- ------------------------------------------------------- Generator's wrapper --------------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.edge.all;
use work.tremolo.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity TremoloEffect is

    -- =======================================================================================
    -- @ Note: When triangle generator us used, parameter LFO_SAMPLE_WIDTH not only
    --     determines range of the modulating values, but also period of the modulating wave.
    --
    -- @ Note: Tremolo's depth is a parameter used to calculate definite shape of the 
    --     modulating wave. The following formula is used: m(t) = 1 - g(t) * D, where
    -- 
    --        - m(t): shape of the modulating wave, m(t) in <0, 1>
    --        - g(t): output of the internal LFO (Low Frequency Oscilator), g(t) in <0, 1>
    --        - D: depth paramerer
    --
    -- =======================================================================================

    generic(
        -- Generator type
        GENERATOR_TYPE : Generator;
        -- Width of the input sample
        SAMPLE_WIDTH : Positive range 2 to Positive'High;

        -- ====================== Modulation's parameters ======================= --

        -- Width of the modulation wave's depth input
        DEPTH_WIDTH : Positive;

        -- Width of the modulating sample
        LFO_SAMPLE_WIDTH : Positive;

        -- Width of the `ticks_per_sample` input
        TICKS_PER_SAMPLE_WIDTH : Positive;

        -- ==================== QuadrupletGenerator-specific ==================== --

        -- -------------------------------------------------------------------------
        -- BRAM-base termolo's generator is not used at the moment
        -- -------------------------------------------------------------------------

        -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
        BRAM_SAMPLES_NUM : Positive := 1;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive := 1;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive := 1

    );
    port(

        -- ==================== Effects' common interface =================== --

        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Enable signal (when module's disabled, samples are not modified) (active high)
        enable_in : in Std_logic;
        -- `New input sample` signal (rising-edge-active)
        valid_in : in Std_logic;
        -- `Output sample ready` signal (rising-edge-active)
        valid_out : out Std_logic;

        -- Input sample
        sample_in : in Signed(SAMPLE_WIDTH - 1 downto 0);
        -- Gained sample
        sample_out : out Signed(SAMPLE_WIDTH - 1 downto 0);

        -- =================== Effect's-specific interface ================== --

        -- Tremolo's depth aprameter (treated as value in <0, 1) range)
        depth_in : in Unsigned(DEPTH_WIDTH - 1 downto 0);
        -- Number of system clock's ticks per modulation sample (minus 1)
        ticks_per_modulation_sample_in : in Unsigned(TICKS_PER_SAMPLE_WIDTH - 1 downto 0)

    );

end entity TremoloEffect;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of TremoloEffect is


    -- Signal activated hight for one cycle when rising edge detected on @p in valid_in
    signal new_sample : Std_logic;

    -- Internal partial result of modulation
    signal modulation : Unsigned(LFO_SAMPLE_WIDTH - 1 downto 0);    
    -- Internal result of modulation
    signal result : Signed(SAMPLE_WIDTH - 1 downto 0);    
    
    -- =============================== Input buffers ================================ --

    -- Input sample buffer
    signal sample_buf : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- Depth value buffer
    signal depth_buf : Unsigned(DEPTH_WIDTH - 1 downto 0);

    -- ======================== Signals for the internal LFO ======================== --

    -- Modulation sample buffer
    signal generator_sample_raw : Std_logic_vector(LFO_SAMPLE_WIDTH - 1 downto 0);
    signal generator_sample : Unsigned(LFO_SAMPLE_WIDTH - 1 downto 0);
    -- Generator's input initializing generation of the next sample (active high)
    signal generator_enable : Std_logic;

begin

    -- =================================================================================
    -- Internal components
    -- =================================================================================

    -- `valid_in` edge detector
    edgeDetectotInstance : entity work.EdgeDetectorSync(logic)
    generic map(
        OUTPUT_ACTIVE => '1',
        EDGE_DETECTED => RISING
    )
    port map(
        reset_n   => reset_n,
        clk       => clk,
        sig       => valid_in,
        detection => new_sample
    );

    -- Internal generator
    tremoloEffectGeneratorInstance: entity work.TremoloEffectGenerator(logic)
    generic map (
        GENERATOR_TYPE   => GENERATOR_TYPE,
        SAMPLE_WIDTH     => LFO_SAMPLE_WIDTH,
        BRAM_SAMPLES_NUM => BRAM_SAMPLES_NUM,
        BRAM_ADDR_WIDTH  => BRAM_ADDR_WIDTH,
        BRAM_LATENCY     => BRAM_LATENCY
    )
    port map (
        reset_n    => reset_n,
        clk        => clk,
        en_in      => generator_enable,
        sample_out => generator_sample_raw
    );

    -- Convert bitvector to number
    generator_sample <= Unsigned(generator_sample_raw);

    -- =================================================================================
    -- Common logic
    -- =================================================================================

    -- Compute modulating value as m(t) = g'max - (g(t) * d(t)) / d'max
    --    - m(t) : modulating wave
    --    - g(t) : generator's output
    --    - g'max : max value of generator wave
    --    - d(t) : depth actual value
    --    - d'max : max value of depth
    modulation <= resize(
          (2**LFO_SAMPLE_WIDTH - 1) - (generator_sample * depth_buf) / 2**DEPTH_WIDTH,
    LFO_SAMPLE_WIDTH);

    -- Compute result sample as y(t) = (x(t) * m(t)) / m'max
    --    - m(t) : modulating wave
    --    - d(t) : depth actual value
    --    - d'max : max value of depth
    result <= resize(
        sample_buf * Signed(resize(modulation, LFO_SAMPLE_WIDTH + 1)) / 2**LFO_SAMPLE_WIDTH,
    SAMPLE_WIDTH);

    -- Output state machine
    process(reset_n, clk) is

        -- Stages of the module
        type Stage is (IDLE_ST, OUTPUT_ST);
        -- Actual stage
        variable state : Stage;

    begin

        -- Reset condition
        if(reset_n = '0') then

            -- Keep outputs low
            valid_out <= '0';
            sample_out <= (others => '0');
            -- Reset internal buffers
            depth_buf <= (others => '0');
            sample_buf <= (others => '0');
            -- Reset state
            state := IDLE_ST;

        -- Normal operation
        elsif(rising_edge(clk)) then
            
            -- Deactivate `sample ready` output by defau
            valid_out <= '0';

            -- When module's enabled
            if(enable_in = '1') then

                -- State machine
                case state is 

                    -- Waiting for new sample
                    when IDLE_ST =>

                        -- Check if new sample arrived
                        if(new_sample = '1') then

                            -- Latch input sample
                            depth_buf <= depth_in;
                            sample_buf <= sample_in;
                            state := OUTPUT_ST;

                        end if;

                    -- Output computed sample
                    when OUTPUT_ST =>

                        -- Push processed sample to the output
                        sample_out <= result;
                        -- Signal new sample on the output
                        valid_out <= '1';
                        -- Reset state
                        state := IDLE_ST;
                        
                end case;

            -- When module's disabled
            else 

                -- Check if new sample arrived or module's was turned off during processing
                if(new_sample = '1' or state /= IDLE_ST) then

                    -- Output unprocessed input sample
                    if(state /= IDLE_ST) then
                        sample_out <= sample_buf;
                    else
                        sample_out <= sample_in;
                    end if;

                    -- Signal new sample on the output
                    valid_out <= '1';
                    -- Reset state
                    state := IDLE_ST;
                    
                end if;

            end if;

        end if;

    end process;

    -- =================================================================================
    -- Triangle generator logic
    -- =================================================================================

    -- When triangle generator is used
    triangleGeneratorCase : if GENERATOR_TYPE = TRIANGLE generate

        process(reset_n, clk) is

            -- Counter of input samples since last wave sample's update
            variable ticks_since_last_modulation_sample : unsigned(TICKS_PER_SAMPLE_WIDTH - 1 downto 0);
   
        begin

            -- Reset condition
            if(reset_n = '0') then

                -- Keep generator disabled
                generator_enable <= '0';
                -- Reset internal counter
                ticks_since_last_modulation_sample := to_unsigned(0, TICKS_PER_SAMPLE_WIDTH);

            -- Regular generation
            elsif(rising_edge(clk)) then

                -- Generate modulation samples only when module is enabled
                if(enable_in = '1') then

                    -- Check whether next sample is ot be generated
                    if(ticks_since_last_modulation_sample < ticks_per_modulation_sample_in) then
                        generator_enable <= '0';
                        ticks_since_last_modulation_sample := ticks_since_last_modulation_sample + 1;
                    else
                        generator_enable <= '1';
                        ticks_since_last_modulation_sample := to_unsigned(0, TICKS_PER_SAMPLE_WIDTH);
                    end if;

                -- Else, reset internal counter
                else 
                    ticks_since_last_modulation_sample := to_unsigned(0, TICKS_PER_SAMPLE_WIDTH);
                end if;

            end if;

        end process;

    end generate;

    -- =================================================================================
    -- Quadruplet generator logic
    -- =================================================================================

    -- When quadruplet generator is used
    quadrupletGeneratorCase : if GENERATOR_TYPE = QUADRUPLET generate

        process(reset_n, clk) is

            -- Generator's latency
            constant GENERATOR_LATENCY : Positive := BRAM_LATENCY + 1; 
            -- Counter of input samples since last wave sample's update
            variable ticks_since_last_modulation_sample : Unsigned(TICKS_PER_SAMPLE_WIDTH - 1 downto 0);
            -- Multiplexer choosing apropriate value of ticks per modulation's sample
            variable ticks_per_modulation_sample_actual : 
                Unsigned(maximum(TICKS_PER_SAMPLE_WIDTH, 3) - 1 downto 0);

        begin

            -- Reset condition
            if(reset_n = '0') then

                -- Keep generator disabled
                generator_enable <= '0';
                -- Reset internal counter
                ticks_since_last_modulation_sample := to_unsigned(0, TICKS_PER_SAMPLE_WIDTH);

            -- Regular generation
            elsif(rising_edge(clk)) then

                -- Generate modulation samples only when module is enabled
                if(enable_in = '1') then

                    -- If too high modulation frequency is used, select valid frequency
                    ticks_per_modulation_sample_actual := 
                        ticks_per_modulation_sample_in when 
                            ticks_per_modulation_sample_in > to_unsigned(GENERATOR_LATENCY, ticks_per_modulation_sample_actual'length) 
                        else to_unsigned(GENERATOR_LATENCY, ticks_per_modulation_sample_actual'length);

                    -- Check whether next sample is to be generated
                    if(ticks_since_last_modulation_sample < ticks_per_modulation_sample_actual) then
                        generator_enable <= '0';
                        ticks_since_last_modulation_sample := ticks_since_last_modulation_sample + 1;
                    else
                        generator_enable <= '1';
                        ticks_since_last_modulation_sample := to_unsigned(0, TICKS_PER_SAMPLE_WIDTH);
                    end if;

                -- Else, reset internal counter
                else 
                    ticks_since_last_modulation_sample := to_unsigned(0, TICKS_PER_SAMPLE_WIDTH);
                    ticks_per_modulation_sample_actual := to_unsigned(GENERATOR_LATENCY, ticks_per_modulation_sample_actual'length);
                end if;

            end if;

        end process;

    end generate;

end architecture logic;

-- ===================================================================================================================================
-- ------------------------------------------------------- Generator's wrapper --------------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.tremolo.all;
use work.generator.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity TremoloEffectGenerator is
    generic(
        -- Generator type
        GENERATOR_TYPE : Generator;
        -- Width of the single sample
        SAMPLE_WIDTH : Positive;

        -- ==================== QuadrupletGenerator-specific ==================== --

        -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
        BRAM_SAMPLES_NUM : Positive := 1024;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive := 10;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive := 0
    );
    port(
        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Signal starting generation of the next sample (active high)
        en_in : in Std_logic;
        -- Data lines
        sample_out : out Std_logic_vector(SAMPLE_WIDTH - 1 downto 0)
    );
end entity TremoloEffectGenerator;


-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of TremoloEffectGenerator is


    -- BRAM declaration
    component TremoloEffectBram
    port (
        clka : in Std_logic;
        rsta : in Std_logic;
        ena : in Std_logic;
        wea : in Std_logic_vector(0 downto 0);
        addra : in Std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
        dina : in Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
        douta : out Std_logic_vector(SAMPLE_WIDTH - 1 downto 0)
    );
    end component;

    -- Address lines
    signal bram_addr_in : Std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
    -- Data lines
    signal bram_data_out : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    -- Enable line
    signal bram_en_in : Std_logic;

begin

    -- Logic of the generator using TriangleGenerator entity
    triangleGeneratorCase : if GENERATOR_TYPE = TRIANGLE generate

        -- Generator's instance
        triangleGeneratorInstance : entity work.TriangleGenerator
        generic map (
            MODE         => UNSIGNED_OUT,
            SAMPLE_WIDTH => SAMPLE_WIDTH
        )
        port map (
            reset_n    => reset_n,
            clk        => clk,
            en_in      => en_in,
            sample_out => sample_out
        );

    end generate;

    -- Logic of the generator using QuadrupletGenerator entity
    quadrupletGeneratorCase : if GENERATOR_TYPE = QUADRUPLET generate

        -- Generator's instance
        quadrupletGeneratorInstance : entity work.QuadrupletGenerator
        generic map (
            MODE         => UNSIGNED_OUT,
            SAMPLES_NUM  => BRAM_SAMPLES_NUM,
            SAMPLE_WIDTH => SAMPLE_WIDTH,
            ADDR_WIDTH   => BRAM_ADDR_WIDTH,
            BRAM_LATENCY => BRAM_LATENCY
        )
        port map (
            reset_n       => reset_n,
            clk           => clk,
            en_in         => en_in,
            sample_out    => sample_out,
            busy_out      => open,
            bram_addr_out => bram_addr_in,
            bram_data_in  => bram_data_out,
            bram_en_out   => bram_en_in
        );

        -- BRAM instance
        quadrupletGeneratorBramInstance : TremoloEffectBram
        PORT MAP (
            clka => clk,
            rsta => not(reset_n),
            ena => bram_en_in,
            wea => (others => '0'),
            addra => bram_addr_in,
            dina => (others => '0'),
            douta => bram_data_out
        );

    end generate;    

end architecture logic;
