-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-20 15:40:44
-- @ Modified time: 2021-05-20 15:40:45
-- @ Description: 
--    
--    `QuadrupleGenerator` is a module generating periodic wave based on the data hold in the connected BRAM block. Generator assumes
--    that a desired wave can be created using symetry of samples in the first quarter (Q1[t]) as described (N is number of samples
--    in the BRAM; every quarter is covered by N - 1 samples):
--
--      - Q1[t] =   BRAM[t]    , t in <0; N)
--      - Q2[t] =   BRAM[N - t], t in <N; 2N - 1)
--      - Q3[t] = - BRAM[t]    , t in <2N; 3N - 1)
--      - Q4[t] = - BRAM[N - t], t in <3N; 3N - 1)
--    
--    This is true for basic periodic function as sine wave, triangle wave or square wave. Module is accommodated to function along 
--    with native BRAM interface. Latency of the BRAM read operation can be set via generics.
--
--    Generator can also be used in the unsigned mode where samples are shifted by the half of amplitude up and treated as unsigned
--    values.
--
-- @ Note: Samples are assumed to be U2-coded signed values
-- @ Note: Last sample in the memory is assumed to be local maximum of the wave. As so number of samples per wave's period is 4N - 4.
--     For example to generate sine wave containing 1024 evenly spaced samples per period one need to provide BRAM block containing
--     257 (evenly spaced) samples taken from range <0;pi/2>.
-- @ Note: Samples are assumed to be allocated from the address 0x0 in the BRAM.
-- @ Note: Latency of the module is one @in clk's cycle longer than BRAM's latency.
-- ===================================================================================================================================

-- ===================================================================================================================================
-- ------------------------------------------------------------- Entity --------------------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.generator.all;

entity QuadrupletGenerator is
    generic(
        -- Output mode
        MODE : SIGNESS := SIGNED_OUT;
        -- Number of samples in a quarter
        SAMPLES_NUM : Positive;
        -- Width of the single sample
        SAMPLE_WIDTH : Positive;
        -- Width of the address port
        ADDR_WIDTH : Positive;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive
    );
    port(
        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Signal starting generation of the next sample (active high)
        en_in : in Std_logic;
        -- Data lines
        sample_out : out Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
        -- Line is pulled to '1' when module is processing a sample
        busy_out : out Std_logic;

        -- ================= BRAM Interface ================= --

        -- Address lines
        bram_addr_out : out Std_logic_vector(ADDR_WIDTH - 1 downto 0);
        -- Data lines
        bram_data_in : in Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
        -- Enable line
        bram_en_out : out Std_logic
    );
end entity QuadrupletGenerator;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of QuadrupletGenerator is

    -- Adress port buffer
    signal bram_addr_buf : Std_logic_vector(ADDR_WIDTH - 1 downto 0);

begin

    -- Assert address port is wide enought to be able to address all samples
    assert (2**ADDR_WIDTH >= SAMPLES_NUM)
        report 
            "[QuadrupleGenerator] Adress port too narrow to address all samples!"
    severity error;

    -- =================================================================================
    -- Module's logic
    -- =================================================================================

    -- Connect output buffer of address port
    bram_addr_out <= bram_addr_buf;

    -- State machine
    process(reset_n, clk) is

        -- Stages of the module
        type Stage is (IDLE_ST, WAIT_FOR_DATA_ST);
        -- Actual stage
        variable state : Stage;

        -- Types of quarters
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
            busy_out <= '0';
            bram_addr_buf <= Std_logic_vector(to_unsigned(0, ADDR_WIDTH));
            bram_en_out <= '0';
            latency_ticks := 0;
            -- Reset quarter
            quarter_samples := 0;
            quarter := Q1;
            -- Reset state
            state := IDLE_ST;

        -- Normal operation
        elsif(rising_edge(clk)) then

            -- State machine
            case state is 

                -- Waiting for rising edge on the `sample_clk` input
                when IDLE_ST =>

                    if(en_in = '1') then

                        -- Mark module as busy_out
                        busy_out <= '1';
                        -- Enable read from BRAM
                        bram_en_out <= '1';
                        -- Initialize latency counter
                        latency_ticks := BRAM_LATENCY;
                        -- Change state
                        state := WAIT_FOR_DATA_ST;

                    end if;

                -- Wait for data from BRAM
                when WAIT_FOR_DATA_ST =>

                    -- Check whether latency gap ended
                    if(latency_ticks = 0) then

                        -- Output appropriate sample
                        case quarter is
                            when Q1|Q2 => 
                                if(MODE = SIGNED_OUT) then
                                    sample_out <=  Std_logic_vector(bram_data_in);
                                else
                                    sample_out <= Std_logic_vector(
                                        Unsigned(bram_data_in) + to_unsigned(2**(SAMPLE_WIDTH - 1), SAMPLE_WIDTH));
                                end if;
                            when Q3|Q4 => 
                                if(MODE = SIGNED_OUT) then
                                    sample_out <= Std_logic_vector(-Signed(bram_data_in));
                                else
                                    sample_out <= Std_logic_vector(
                                       to_unsigned(2**(SAMPLE_WIDTH - 1), SAMPLE_WIDTH) - Unsigned(bram_data_in)
                                    );
                                end if;
                        end case;

                        -- Increment or decrement next read address
                        case quarter is
                            when Q1|Q3 => bram_addr_buf <=  Std_logic_vector(Unsigned(bram_addr_buf) + 1);
                            when Q2|Q4 => bram_addr_buf <=  Std_logic_vector(Unsigned(bram_addr_buf) - 1);
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
            
                        -- Disable request for read
                        bram_en_out <= '0';
                        -- Mark module as free
                        busy_out <= '0';
                        -- Change state
                        state := IDLE_ST;

                    -- Else, decrement latency cycles' counter
                    else
                        latency_ticks := latency_ticks - 1;
                    end if;

            end case;
            
        end if;
        
    end process;

end architecture;
