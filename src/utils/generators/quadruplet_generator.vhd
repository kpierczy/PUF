-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-20 15:40:44
-- @ Modified time: 2021-05-20 15:40:45
-- @ Description: 
--    
--    `QuadrupleGenerator` is a module generating periodic wave based on the data hold in the connected BRAM block. Generator ussumes
--    that a desired wave can be created using symethry of samples in the first quarter (Q1[t]) as described (N is number of samples
--    in the quarter):
--
--      - Q2[t] =   Q1[N - t - 1]
--      - Q3[t] = - Q1[t]
--      - Q4[t] = - Q1[N - t - 1]
--    
--    This is true for basic periodic function as sine wave, saw wave or square wave. Module is accommodated to function along with
--    native BRAM interface.
--
-- @ Note: Last sample in the memory is assumed to be local maximum of the wave. Samples are treated as U2-coded signed values.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.edge.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity QuadrupletGenerator is
    generic(
        -- Number of samples in a quarter
        SAMPLES_NUM : Positive;
        -- Width of the single sample
        SAMPLE_WIDTH : Positive;
        -- Width of the address port
        ADDR_WIDTH : Positive;
        -- Offset address of samples in the memory
        SAMPLE_ADDR_OFFSET : Natural;
        -- Latency (in cycles of @in clk) fof the BRAM read (1 for data collection on the next cycle after ena_out = '1')
        BRAM_LATENCY : Positive := 1
    );
    port(
        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Next clk's cycle after `sample_clk`'s rising edge a new sample is read from memory
        sample_clk : in Std_logic;
        -- Data lines
        sample_out : out Signed(SAMPLE_WIDTH - 1 downto 0);
        -- Line is pulled to '1' when module is processing a sample
        busy : out Std_logic;

        -- ================= BRAM Interface ================= --

        -- Address lines
        addr_out : out Std_logic_vector(ADDR_WIDTH - 1 downto 0);
        -- Data lines
        data_in : in Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
        -- Enable line
        ena_out : out Std_logic
    );
end entity QuadrupletGenerator;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of QuadrupletGenerator is

    -- Signal activated hight for one cycle when rising edge detected on @p in sample_clk
    signal new_sample : Std_logic;
    -- Adress port buffer
    signal addr_buf : Std_logic_vector(ADDR_WIDTH - 1 downto 0);

begin

    -- Assert address port is wide enought to be able to address all samples
    assert (2**ADDR_WIDTH - SAMPLE_ADDR_OFFSET >= SAMPLES_NUM)
        report 
            "[QuadrupleGenerator] Adress port too narrow to address all samples!"
    severity error;

    -- =================================================================================
    -- Internal components
    -- =================================================================================

    -- `sample_clk` edge detector
    edgeDetectotInstance : entity work.EdgeDetectorSync(logic)
    generic map(
        OUTPUT_ACTIVE => '1',
        EDGE_DETECTED => RISING
    )
    port map(
        reset_n   => reset_n,
        clk       => clk,
        sig       => sample_clk,
        detection => new_sample
    );

    -- =================================================================================
    -- Module's logic
    -- =================================================================================

    -- Connect output buffer of address port
    addr_out <= addr_buf;

    -- State machine
    process(reset_n, clk) is

        -- Stages of the module
        type Stage is (IDLE_ST, WAIT_FOR_DATA_ST);
        -- Actual stage
        variable state : Stage;

        -- Stages of the module
        type QuarterId is (Q1, Q2, Q3, Q4);
        -- Actual stage
        variable quarter : QuarterId;

        -- Count of output samples from the actual quarter
        variable quarter_samples : Natural;
        -- Latency cycles to be waited for data from BRAM
        variable latency_ticks : Natural;

    begin

        -- Reset condition
        if(reset_n = '0') then

            -- Keep outputs low
            sample_out <= (others => '0');
            busy <= '0';
            addr_buf <= Std_logic_vector(to_unsigned(SAMPLE_ADDR_OFFSET, ADDR_WIDTH));
            ena_out <= '0';
            -- Reset internal buffers
            latency_ticks := 0;
            -- Reset quarter
            quarter_samples := 0;
            quarter := Q1;
            -- Reset state
            state := IDLE_ST;

        -- Normal operation
        elsif(rising_edge(clk)) then
            
            -- Disable request for read by default
            ena_out <= '0';

            -- State machine
            case state is 

                -- Waiting for rising edge on the `sample_clk` input
                when IDLE_ST =>

                    if(new_sample = '1') then

                        -- Mark module as busy
                        busy <= '1';
                        -- Enable read from BRAM
                        ena_out <= '1';
                        -- Initialize latency counter
                        latency_ticks := BRAM_LATENCY;
                        -- Change state
                        state := WAIT_FOR_DATA_ST;

                    end if;

                -- Wait for data from BRAM
                when WAIT_FOR_DATA_ST =>

                    -- Decrement latency cycles' counter
                    latency_ticks := latency_ticks - 1;

                    -- Check whether latency gap ended
                    if(latency_ticks = 0) then

                        -- Output appropriate sample
                        case quarter is
                            when Q1|Q2 => sample_out <=  Signed(data_in);
                            when Q3|Q4 => sample_out <= -Signed(data_in);
                        end case;

                        -- Increment or decrement next read address
                        case quarter is
                            when Q1|Q3 => addr_buf <=  Std_logic_vector(Unsigned(addr_buf) + 1);
                            when Q2|Q4 => addr_buf <=  Std_logic_vector(Unsigned(addr_buf) - 1);
                        end case;

                        -- Update address of the next sample
                        if(quarter_samples = SAMPLES_NUM - 2) then
                            
                            -- First/last sample is not output twice
                            quarter_samples := 0;

                            -- Update quarter
                            case quarter is
                                when Q1 => quarter := Q2;
                                when Q2 => quarter := Q3;
                                when Q3 => quarter := Q4;
                                when Q4 => quarter := Q1;
                            end case;

                        -- Else, increment number of samples from the actual quarter
                        else
                            quarter_samples := quarter_samples + 1;
                        end if;

                        -- Mark module as free
                        busy <= '0';
                        -- Change state
                        state := IDLE_ST;


                    end if;

            end case;
            
        end if;
        
    end process;

end architecture;
