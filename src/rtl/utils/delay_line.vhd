-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-25 15:56:14
-- @ Modified time: 2021-05-25 15:56:15
-- @ Description: 
--    
--    This module implements BRAM-circular-buffer-based delay line.
--    
-- @ Note: The delay line (optionally) implemets `soft start` mechanism. When it is used the output is hold zeroed if requested delay
--     is higher than the number of already bufferred samples. This can be used to reduce starting noise in the sound effects 
--     resulting from using uninitialized cells of the BRAM as valid samples.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity DelayLine is
    generic(
        -- Width of the input sample
        DATA_WIDTH : Positive;
        -- Width of the @in depth port
        DELAY_WIDTH : Positive;

        -- Smooth start mechanism
        SOFT_START : boolean;

        -- =========================== BRAM parameters ========================== --

        -- Number of BRAM cells used to buffer samples
        BRAM_SAMPLES_NUM : Positive;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive
    );
    port(
        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Enable line; when high the module starts processing samples on the input
        enable_in : in Std_logic;
        -- Busy line (active high)
        busy_out : out Std_logic;

        -- Delay level
        delay_in : in Unsigned(DELAY_WIDTH - 1 downto 0);
        
        -- Data lines
        data_in : in Std_logic_vector(DATA_WIDTH - 1 downto 0);
        data_out : out Std_logic_vector(DATA_WIDTH - 1 downto 0);

        -- ============================ BRAM interface ========================== --

        -- Address lines
        bram_addr_out : out Std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
        -- Data lines
        bram_data_in : in Std_logic_vector(DATA_WIDTH - 1 downto 0);
        bram_data_out : out Std_logic_vector(DATA_WIDTH - 1 downto 0);
        -- Enable/write enable lines
        bram_en_out : out Std_logic;
        bram_wen_out : out std_logic_vector(0 downto 0)
    );
end entity DelayLine;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of DelayLine is

    -- Input buffers
    signal delay_buf : Unsigned(BRAM_ADDR_WIDTH - 1 downto 0);
    signal data_buf : Std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- Next BRAM address to be written
    signal next_addr : Unsigned(BRAM_ADDR_WIDTH - 1 downto 0);

    -- Number of already bufferred samples
    signal bufferred_samples_num : Unsigned(BRAM_ADDR_WIDTH downto 0);

begin

    -- Assert that delay level's width is not bigger than BRAM's adress port
    assert (DELAY_WIDTH >= BRAM_ADDR_WIDTH)
        report 
            "[DelayLine] Delay input cannot be wider than BRAM address port!"
    severity error;

    -- Assert that number of BRAM cell's used is addressable
    assert (BRAM_SAMPLES_NUM <= 2**BRAM_ADDR_WIDTH)
        report 
            "[DelayLine] BRAM address port is too narrow to address all cells!"
    severity error;

    -- =================================================================================
    -- Module's logic
    -- =================================================================================

    -- Connect BRAM data output to the internal data buffer
    bram_data_out <= Std_logic_vector(data_buf);

    -- Module's logic
    process(reset_n, clk) is

        -- Module's state
        type Stage is (IDLE_ST, WRITE_ST, READ_ST);
        variable state : Stage;

        -- Actual delay calcultaed when the `soft start` mechaqnism used
        variable actual_delay : unsigned(BRAM_ADDR_WIDTH - 1 downto 0);

        -- Read latency cycles to be waited for data read from BRAM
        variable latency_ticks : Natural;

        -- Flag used in the `soft start` mode to mark that the 0-value samples should be rpdouced on output
        variable zero_out : Std_logic;

    begin

        -- Reset condition
        if(reset_n = '0') then

            -- Keep outputs in reset state
            busy_out <= '0';
            data_out <= (others => '0');
            bram_addr_out <= (others => '0');
            bram_en_out <= '0';
            bram_wen_out <= (others => '0');
            -- Reset internal buffers
            delay_buf <= (others => '0');
            data_buf <= (others => '0');
            next_addr <= (others => '0');
            bufferred_samples_num <= (others => '0');
            actual_delay := (others => '0');
            zero_out := '0';
            -- Reset internal counter
            latency_ticks := 0;
            -- Reset module's state
            state := IDLE_ST;

        -- Operational state
        elsif(rising_edge(clk)) then

            -- by default do not produce 0 on output
            zero_out := '0';

            -- State machine
            case state is

                -- Idle state
                when IDLE_ST =>

                    -- Wait for the sample to arrive
                    if(enable_in = '1') then

                        -- Fetch inputs
                        delay_buf <= resize(delay_in, BRAM_ADDR_WIDTH);
                        data_buf <= data_in;
                        -- Mark module as busy
                        busy_out <= '1';
                        -- Set write address
                        bram_addr_out <= Std_logic_vector(next_addr);
                        -- Enable BRAM write
                        bram_en_out <= '1';
                        bram_wen_out <= (others => '1');
                        -- Go to the write state
                        state := WRITE_ST;

                    end if;

                -- Writing data to the BRAM
                when WRITE_ST =>

                    -- Disable writing line of the BRAM
                    bram_wen_out <= (others => '0');

                    -- Increment address of the next cell to write
                    if(next_addr < to_unsigned(Natural(BRAM_SAMPLES_NUM) - 1, BRAM_ADDR_WIDTH)) then
                        next_addr <= next_addr + 1;
                    else
                        next_addr <= to_unsigned(0, BRAM_ADDR_WIDTH);
                    end if;

                    -- Check whether `soft start` is used
                    if(SOFT_START) then

                        -- Increment number of already bufferred samples
                        if(bufferred_samples_num < to_unsigned(Natural(BRAM_SAMPLES_NUM), BRAM_ADDR_WIDTH + 1)) then
                            bufferred_samples_num <= bufferred_samples_num + 1;
                        end if;
                        
                        -- Check whether given delay does not excceeds number of already bufffered samples
                        if(resize(delay_buf, BRAM_ADDR_WIDTH + 1) < bufferred_samples_num) then
                            actual_delay := delay_buf;
                        -- Else, mark that the '0' output should be produced
                        else
                            zero_out := '1';
                        end if;

                    -- If no `soft start` used, just use given delay
                    else
                        actual_delay := delay_buf;
                    end if;

                    -- Check whether '0' output should be produced
                    if(zero_out = '1') then

                            -- Disable BRAM interface
                            bram_en_out <= '0';
                            -- Copy input data to the output
                            data_out <= (others => '0');
                            -- Mark module as idle
                            busy_out <= '0';
                            -- Go to the idle state
                            state := IDLE_ST;

                    -- If delayed output should be produced
                    else

                        -- Check whether any delay is required
                        if(actual_delay /= to_unsigned(0, BRAM_ADDR_WIDTH)) then

                            -- Check whether address of delayed samle can be calulated by simple substraction
                            if(next_addr >= actual_delay) then
                                bram_addr_out <= Std_logic_vector(next_addr - actual_delay);
                            -- Else, perform modulo substraction
                            else
                                bram_addr_out <= Std_logic_vector(
                                    (to_unsigned(Natural(BRAM_SAMPLES_NUM) - 1, BRAM_ADDR_WIDTH)) - -- End of the BRAM minus ...
                                    (actual_delay - next_addr - 1)                                  -- Difference between write adress and delay (minus 1)
                                );
                            end if;

                            -- Initialize read latency cycles' counter
                            latency_ticks := BRAM_LATENCY;
                            -- Go to the read state
                            state := READ_ST;

                        -- If no delay is required
                        else

                            -- Disable BRAM interface
                            bram_en_out <= '0';
                            -- Copy input data to the output
                            data_out <= data_buf;
                            -- Mark module as idle
                            busy_out <= '0';
                            -- Go to the idle state
                            state := IDLE_ST;

                        end if;

                    end if;

                -- Reading data from the BRAM
                when READ_ST =>

                    -- Check whether latency gap ended
                    if(latency_ticks = 0) then

                        -- Disable BRAM interface
                        bram_en_out <= '0';
                        -- Copy read data to the output
                        data_out <= bram_data_in;
                        -- Mark module as idle
                        busy_out <= '0';
                        -- Go to the idle state
                        state := IDLE_ST;                        

                    -- Else, decrement latency cycles' counter
                    else
                        latency_ticks := latency_ticks - 1;
                    end if;

            end case;

        end if;

    end process;

end architecture logic;
