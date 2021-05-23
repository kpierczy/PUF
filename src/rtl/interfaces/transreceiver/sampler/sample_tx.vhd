-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-12 14:18:44
-- @ Modified time: 2021-05-12 14:18:51
-- @ Description: 
--    
--    Sample transmitting module based on the UartTx entity. Module provides a simple two-wire interface that enables observing
--    it's state and starting data transmission.
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.uart.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity SampleTx is

    generic(

        -- Frequency of the clock beating the entity (used to compute width of the @in baud_period input)
        SYS_CLK_HZ : Positive;

        -- =============== Module-specific settings =============== --

        -- Sample byte width
        SAMPLE_BYTES : Positive;

        -- ==================== UART Settings ===================== --

        -- Transmission baud rate
        BAUD_RATE : Positive;
        -- Parity usage
        PARITY_USED : Std_logic;
        -- Parity type
        PARITY_TYPE : ParityType;
        -- Number of stopbits
        STOP_BITS : Positive range 1 to 2;
        -- Signal negation (Defaults to standard RS-232, i.e. negated signal and data)
        SIGNAL_NEGATION : Std_logic := '1';
        -- Data negation (Defaults to standard RS-232, i.e. negated signal and data)
        DATA_NEGATION : Std_logic := '1'
    );
    port(
        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;
        -- Transfer initialization signal (active high)
        transfer : in Std_logic;
        -- Sample to be transfered (latched on @in clk rising edge when @in transfer high and @out busy's low)
        sample : in Std_logic_vector(SAMPLE_BYTES * 8 - 1 downto 0);

        -- 'Module busy' signal (active high)
        busy : out Std_logic;
        -- Serial output
        tx : out Std_logic

    );

end entity SampleTx;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of SampleTx is

    -- Size of the byte (just to not raw '8' in the code)
    constant BYTE_WIDTH : Positive := 8;

    -- ===================== UART Signals ===================== --

    -- Uart transmission start signal
    signal uartTransmit : std_logic;
    -- Uart data to be transmitted
    signal uartData : std_logic_vector(BYTE_WIDTH - 1 downto 0);
    -- Uart busy signal
    signal uartBusy : std_logic;

begin

    -- Assert proper ratio of the system clock and baud rate
    assert (SYS_CLK_HZ / BAUD_RATE >= 2)
        report 
            "SampleTx: Invalid value of the SYS_CLK_HZ (" & integer'image(SYS_CLK_HZ) & ")" & 
            "or/and BAUD_RATE (" & integer'image(BAUD_RATE) & ")"
    severity error;

    -- =================================================================================
    -- Intenral UART entity
    -- =================================================================================

    -- Transmitter instance
    uartTransmitter : entity work.UartTx(logic)
    generic map(
        SYS_CLK_HZ      => SYS_CLK_HZ,
        BAUD_RATE_MIN   => BAUD_RATE,
        DATA_WIDTH      => BYTE_WIDTH,
        PARITY_USED     => PARITY_USED,
        PARITY_TYPE     => PARITY_TYPE,
        STOP_BITS       => STOP_BITS,
        SIGNAL_NEGATION => SIGNAL_NEGATION,
        DATA_NEGATION   => DATA_NEGATION
    )
    port map(
        reset_n     => reset_n,
        clk         => clk,
        baud_period => SYS_CLK_HZ / BAUD_RATE - 1,
        transfer    => uartTransmit,
        data        => uartData,
        busy        => uartBusy,
        tx          => tx
    );    

    -- =================================================================================
    -- Module's state machine
    -- =================================================================================

    process(reset_n, clk) is

        -- Stages of the transmiter
        type Stage is (IDLE_ST, PREPARE_TRANSMIT_ST, TRANSMIT_ST);
        -- Actual stage
        variable state : Stage;

        -- Sample buffer (First byte is directly fetched to the UART input's)
        variable sampleBuf : Std_logic_vector((SAMPLE_BYTES - 1) * BYTE_WIDTH - 1 downto 0);
        -- Oversampling pulse counter
        variable bytesTransmitted : Natural range 0 to SAMPLE_BYTES;

    begin
        -- Reset condition
        if(reset_n = '0') then

            -- Set outputs to default
            busy <= '0';
            -- Reset internal signals
            uartTransmit <= '0';
            uartData <= (others => '0');
            -- Reset process' variables
            sampleBuf := (others => '0');
            bytesTransmitted := 0;
            -- Default state: IDLE_ST
            state := IDLE_ST;

        -- Normal operation
        elsif(rising_edge(clk)) then

            -- Dafult state of the UART transmission: disabled
            uartTransmit <= '0';

            -- State machine
            case state is

                -- IDLE_ST
                when IDLE_ST =>

                    -- Transmit input pulled high
                    if(transfer = '1') then

                        -- Fetch data to the internal buffer
                        sampleBuf := sample(sample'left downto BYTE_WIDTH);
                        -- Zero counter of the transmitted bytes
                        bytesTransmitted := 0;
                        -- Set module's state to busy
                        busy <= '1';
                        -- Fetch first byte to the UART's input
                        uartData <= sample(BYTE_WIDTH - 1 downto 0);
                        -- Enable UART Transmission
                        uartTransmit <= '1';
                        -- Switch state to PREPARE_TRANSMIT_ST
                        state := PREPARE_TRANSMIT_ST;

                    end if;

                -- Wait for UART to start transmission
                when PREPARE_TRANSMIT_ST =>

                    if(uartBusy = '1') then
                        -- Switch state to TRANSMIT_ST
                        state := TRANSMIT_ST;
                    end if;

                -- TRANSMIT_ST
                when TRANSMIT_ST =>

                    -- Check whether UART transmitted last byte
                    if(uartBusy = '0') then

                        -- Increment number of transmitted bytes
                        bytesTransmitted := bytesTransmitted + 1;
                        -- If there are some bytes to be transmitted
                        if(bytesTransmitted /= SAMPLE_BYTES) then

                            -- Fetch data (@note @v dampleBuf does not hold first byte of the transmitted sample)
                            uartData <= sampleBuf(bytesTransmitted * BYTE_WIDTH  - 1 downto (bytesTransmitted - 1) * BYTE_WIDTH);
                            -- Enable UART to transmit the next byte
                            uartTransmit <= '1';
                            -- Switch state to PREPARE_TRANSMIT_ST
                            state := PREPARE_TRANSMIT_ST;

                        -- Else, if all bytes was transmitted
                        else

                            -- Switch module to the not-busy state
                            busy <= '0';
                            -- Switch state to IDLE_ST
                            state := IDLE_ST;

                        end if;

                    end if;

            end case;

        end if;

    end process;

end architecture logic;
