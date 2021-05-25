-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-25 14:42:57
-- @ Modified time: 2021-05-25 14:42:59
-- @ Description: 
--    
--    Module of the IIR-filter-based delay guitar effect with adjustable depth and attenuation.
--    
-- @ Note: This module uses preconfigured BRAM block that has to be named `DelayEffectBram` and so it can be spwawned only once
--     in the project.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.edge.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity DelayEffect is
    generic(
        -- Width of the input sample
        SAMPLE_WIDTH : Positive range 2 to Positive'High;

        -- ====================== Effect-specific parameters ==================== --

        -- Width of the @in attenuation_in port
        ATTENUATION_WIDTH : Positive;
        -- Width of the @in depth port
        DEPTH_WIDTH : Positive;

        -- =========================== BRAM parameters ========================== --

        -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
        BRAM_SAMPLES_NUM : Positive;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive
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

        -- Depth level (index of the delayed sample being summed with the input)
        depth_in : in unsigned(DEPTH_WIDTH - 1 downto 0);
        -- Attenuation level pf the delayed summant (treated as value in <0,0.5) range)
        attenuation_in : in unsigned(ATTENUATION_WIDTH - 1 downto 0)

    );
end entity DelayEffect;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of DelayEffect is

    -- Signal activated hight for one cycle when rising edge detected on @p in valid_in
    signal new_sample : Std_logic;

    -- ========================= Input buffers ========================== --

    -- Input sample buffer
    signal sample_in_buf : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- Output sample buffer
    signal sample_out_buf : Signed(SAMPLE_WIDTH - 1 downto 0);

    -- Buffer for attenuation level input
    signal attenuation_buf : unsigned(ATTENUATION_WIDTH - 1 downto 0);
    -- Depth level (index of the delayed sample being summed with the input)
    signal depth_buf : unsigned(DEPTH_WIDTH - 1 downto 0);

    -- ==================== Internal lines/buffers ====================== --

    -- Internal result of samples' summation
    signal result : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- Internal result of delayed sample's attenuation
    signal delayed_sample : Signed(SAMPLE_WIDTH - 1 downto 0);

    -- =============== Internal delay line's interface ================== --

    -- Delay line's manual reset signal
    signal delay_manual_reset_n : Std_logic;
    -- Delayline's reset signal (<= `reset_n` and `delay_manual_reset_n`)
    signal delay_reset_n : Std_logic;

    -- Enable line; when high the module starts processing samples on the input
    signal delay_enable_in : Std_logic;
    -- Busy line (active high)
    signal delay_busy_out : Std_logic;

    -- Delay level
    signal delay_delay_in : Unsigned(DEPTH_WIDTH - 1 downto 0);
    
    -- Data lines
    signal delay_data_in : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    signal delay_data_out : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);

    -- ========================== BRAM's signals ======================== --

    -- BRAM declaration
    component DelayEffectBram
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

    -- BRAM's reset signal
    signal bram_reset : Std_logic;
    -- Address lines
    signal bram_addr_in : Std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
    -- Data lines
    signal bram_data_out, bram_data_in : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    -- Enable/write enable lines
    signal bram_en_in : Std_logic;
    signal bram_wen_in : std_logic_vector(0 downto 0);

begin

    -- =================================================================================
    -- Internal components and connections
    -- =================================================================================

    -- ============================= Input edge detector ============================ --

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

    -- ==================================== BRAM ==================================== --

    -- BRAM is reset with high signal
    bram_reset <= not(reset_n);

    -- Internal BRAM block
    delayEffectBramInstance: DelayEffectBram
    port map (
        clka  => clk,
        rsta  => bram_reset,
        ena   => bram_en_in,
        wea   => bram_wen_in,
        addra => bram_addr_in,
        dina  => bram_data_in,
        douta => bram_data_out
    );

    -- ================================= Delay line ================================= --

    -- Delay line can be also reset manually
    delay_reset_n <= reset_n and delay_manual_reset_n;

    -- Delay magnitude seen by the delay line is 1 less than the module's depth input's value
    delay_delay_in <= depth_buf - 1 when depth_buf > to_unsigned(0, DEPTH_WIDTH) else to_unsigned(0, DEPTH_WIDTH);

    -- Output of the output sample buffer is connected to the delay line's input
    delay_data_in <= Std_logic_vector(sample_out_buf);

    -- Internal delay line
    delayLineInstance: entity work.DelayLine(logic)
    generic map (
        DATA_WIDTH       => SAMPLE_WIDTH,
        DELAY_WIDTH      => DEPTH_WIDTH,
        SOFT_START       => TRUE,
        BRAM_SAMPLES_NUM => BRAM_SAMPLES_NUM,
        BRAM_ADDR_WIDTH  => BRAM_ADDR_WIDTH,
        BRAM_LATENCY     => BRAM_LATENCY
    )
    port map (
        reset_n       => delay_reset_n,
        clk           => clk,
        enable_in     => delay_enable_in,
        busy_out      => delay_busy_out,
        delay_in      => delay_delay_in,
        data_in       => delay_data_in,
        data_out      => delay_data_out,
        bram_addr_out => bram_addr_in,
        bram_data_in  => bram_data_out,
        bram_data_out => bram_data_in,
        bram_en_out   => bram_en_in,
        bram_wen_out  => bram_wen_in
    );

    -- ======================== Delayed sample's attenuation ======================== --

    -- Attenuated version of the delayed sample is computed asynchronously by the multiplying block
    delayed_sample <= resize(
        Signed(resize(attenuation_buf, ATTENUATION_WIDTH + 1)) * Signed(delay_data_out) / 2**(ATTENUATION_WIDTH + 1),
    SAMPLE_WIDTH);

    -- ============================= Samples' summation ============================= --

    -- Internal summation of samples with saturation
    sumsignedsat_inst: entity work.sumSignedSat
      port map (
        a_in       => sample_in_buf,
        b_in       => delayed_sample,
        result_out => result,
        err_out    => open
      );

    -- ============================== Other connections ============================= --

    -- Connect output buffer to the output
    sample_out <= sample_out_buf;

    -- =================================================================================
    -- Module's logic
    -- =================================================================================

    process(reset_n, clk) is

        -- Module's state
        type Stage is (IDLE_ST, DELAY_ST);
        variable state : Stage;

        -- Auxiliary variable used to test falling edge of the delay line's `busy` signal
        variable delay_busy_prev : Std_logic;

    begin

        -- Reset condition
        if(reset_n = '0') then

            -- Reset outputs
            valid_out <= '0';
            -- Reset internal buffers
            sample_in_buf <= (others => '0');
            sample_out_buf <= (others => '0');
            attenuation_buf <= (others => '0');
            depth_buf <= (others => '0');
            delay_manual_reset_n <= '1';
            delay_busy_prev := '0';
            -- Keep delay line's `enable` signal inactive
            delay_enable_in <= '0';
            -- Reset module's state
            state := IDLE_ST;

        -- Normal operation
        elsif(rising_edge(clk)) then

            -- Keep `valid_out` low by default
            valid_out <= '0';
            -- Keep delay line active by default
            delay_manual_reset_n <= '1';               
            -- Keep delay line's `enable` signal inactive by default
            delay_enable_in <= '0';         

            -- If module is enabled
            if(enable_in = '1') then

                -- State machine
                case state is

                    -- Idle state
                    when IDLE_ST =>

                        -- Check whether new sample arrived
                        if(new_sample = '1') then

                            -- Push input data to internal buffers
                            sample_in_buf <= sample_in;
                            attenuation_buf <= attenuation_in;
                            depth_buf <= depth_in;
                            -- Enable delay line to buffer previous output sample and get a new delayed sample
                            delay_enable_in <= '1';
                            -- Reset internal buffer used to test falling edge of the delay line's `busy` signal
                            delay_busy_prev := '0';
                            -- Go to the next state
                            state := DELAY_ST;

                        end if;

                    -- Waiting for end of delay line's processing
                    when DELAY_ST =>

                        -- Wait for rising edge on the delay line's `busy` output
                        if(delay_busy_prev = '1' and delay_busy_out = '0') then

                            -- If requested `depth` was zero
                            if(depth_buf = to_unsigned(0, DEPTH_WIDTH)) then
                                -- Push not-modified input sample to the output
                                sample_out_buf <= sample_in_buf;
                            -- If non-zero depth was requested
                            else
                                -- Push sum of the input sample snd delayed sample to the output
                                sample_out_buf <= result;
                            end if;

                            -- Inform that the new sample arrived on the output
                            valid_out <= '1';
                            -- Back to the IDLE state
                            state := IDLE_ST;

                        -- Else keep waiting for the end of delay line's processing
                        else
                            delay_busy_prev := delay_busy_out;
                        end if;

                end case;

            -- If module is disabled
            else

                -- Reset delay line
                delay_manual_reset_n <= '0';

                -- Check whether a new sample arrived or module was disabled during processing the old one
                if(new_sample = '1' or state /= IDLE_ST) then

                    -- Output unprocessed input sample
                    if(state /= IDLE_ST) then
                        sample_out_buf <= sample_in_buf;
                    else
                        sample_out_buf <= sample_in;
                    end if;

                    -- Signal new sample on the output
                    valid_out <= '1';
                    -- Reset state
                    state := IDLE_ST;                    

                end if;

                -- Reset module's state
                state := IDLE_ST;            

            end if;

        end if;

    end process;

end architecture logic;
