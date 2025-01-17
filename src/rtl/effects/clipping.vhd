-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 15:50:05
-- @ Modified time: 2021-05-19 15:50:07
-- @ Description: 
--    
--    Clipping effect module with dynamically parametrized saturation level
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.edge.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity ClippingEffect is

    generic(
        -- Width of the input sample
        SAMPLE_WIDTH : Positive range 2 to Positive'high;
        -- Width of the gain input
        GAIN_WIDTH : Positive;
        -- Index of the 2's power that the multiplication's result is divided by before saturation
        TWO_POW_DIV : Natural := 8
    );
    port(

        -- ==================== Effects' common interface =================== --

        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Enable signal (when module's disabled, samples are not modified)
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

        -- Gain input
        gain_in : in Unsigned(GAIN_WIDTH - 1 downto 0);
        -- Saturation level (for absolute value of the signal)
        saturation_in : in Unsigned(SAMPLE_WIDTH - 2 downto 0)
    );

end entity ClippingEffect;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of ClippingEffect is

    -- Signal activated hight for one cycle when rising edge detected on @p in valid_in
    signal new_sample : Std_logic;

    -- Input sample buffer
    signal sample_buf : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- Gain value buffer
    signal gain_buf : Signed(GAIN_WIDTH downto 0);
    -- Saturation value buffer
    signal high_saturation_buf : Signed(SAMPLE_WIDTH - 1 downto 0);
    signal low_saturation_buf : Signed(SAMPLE_WIDTH - 1 downto 0);
    
    -- Internal result of multiplying
    signal result : Signed(SAMPLE_WIDTH + GAIN_WIDTH - TWO_POW_DIV downto 0);

begin

    -- Assert that gain's result is wide anough to not get zeroed when shifted left
    assert (SAMPLE_WIDTH + GAIN_WIDTH > TWO_POW_DIV)
        report 
            "[ClippingEffect] Sample's width of the gain's result must be bigger TWO_POW_DIV parameter." &
            "Otherwise module's output will be constant zero"
    severity error;

    -- Assert that gain's range is higher than number of bits shifted on division
    assert (GAIN_WIDTH > TWO_POW_DIV)
        report 
            "[ClippingEffect] Gain's range is smalled than divisison factor. Effective gain will be less than 1!"
    severity warning;

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

    -- =================================================================================
    -- Module's logic
    -- =================================================================================

    -- Make asynchronous multiplication
    result <= resize(sample_buf * gain_buf / 2**TWO_POW_DIV, result'length);

    -- State machine
    process(reset_n, clk) is

        -- Stages of the module
        type Stage is (IDLE_ST, COMPUTE_ST);
        -- Actual stage
        variable state : Stage;

    begin

        -- Reset condition
        if(reset_n = '0') then

            -- Keep outputs low
            valid_out <= '0';
            sample_out <= (others => '0');
            -- Reset internal buffers
            sample_buf <= (others => '0');
            gain_buf <= (others => '0');
            high_saturation_buf <= (others => '0');
            low_saturation_buf <= (others => '0');
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

                        -- Check fi new sample arrived
                        if(new_sample = '1') then

                            -- Fetch input vectorssample
                            sample_buf          <=  sample_in;
                            gain_buf            <=  Signed(resize(gain_in, GAIN_WIDTH + 1));
                            high_saturation_buf <=  Signed(resize(saturation_in, SAMPLE_WIDTH));
                            low_saturation_buf  <= -Signed(resize(saturation_in, SAMPLE_WIDTH));
                            -- Change state
                            state := COMPUTE_ST;

                        end if;

                    -- Outputing computed sample
                    when COMPUTE_ST =>

                        -- Saturate from top
                        if(result > resize(high_saturation_buf, result'length)) then
                            sample_out <= high_saturation_buf;
                        -- Saturate from bottom
                        elsif(result < resize(low_saturation_buf, result'length)) then
                            sample_out <= low_saturation_buf;
                        -- Output without saturation
                        else
                            sample_out <= resize(result, SAMPLE_WIDTH);
                        end if;

                        -- Signal new sample on output
                        valid_out <= '1';
                        -- Change state
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

end architecture logic;