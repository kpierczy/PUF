-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-12 14:18:44
-- @ Modified time: 2021-05-12 14:18:51
-- @ Description: 
--    
--    Sample receiving module based on the UartRx entity
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.uart.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------


-- =============================================================================
-- @brief Sample receiving module based on the UartRx entity. Module provides 
--    a simple four-wire interface that enables observing it's state and
--    identifying receiving errors. When all bytes of the new sample are
--    the @out busy port is pulled from high to low and new sample is pushed
--    to the @out data port.
--    If any error occurse during reception of the sample, state of the @out
--    data is not changed even though @out busy state transits. Additionally,
--    @out err output is loaded with all reception errors ORed for a signle
--    cycle of the system clock.
-- =============================================================================
entity SampleRx is

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
        -- Serial input
        rx : in Std_logic;

        -- 'Module busy' signal (active high)
        busy : out Std_logic;
        -- Sample received (pushed on @in busy falling edge when no error occured during sample's reception)
        sample : out Std_logic_vector(SAMPLE_BYTES * 8 - 1 downto 0);
        -- ORed state of the error flags of received bytes
        err : out UartErrors
    );

end entity SampleRx;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of SampleRx is

    -- Size of the byte (just to not raw '8' in the code)
    constant BYTE_WIDTH : Positive := 8;

    -- ===================== UART Signals ===================== --

    -- Uart transmission start signal
    signal uartErr : UartErrors;
    -- Uart data to be transmitted
    signal uartData : std_logic_vector(BYTE_WIDTH - 1 downto 0);
    -- Uart busy signal
    signal uartBusy : std_logic;

begin

    -- Assert proper ratio of the system clock and baud rate
    assert (SYS_CLK_HZ / BAUD_RATE >= 2)
        report 
            "SampleRx: Invalid value of the SYS_CLK_HZ (" & integer'image(SYS_CLK_HZ) & ")" & 
            "or/and BAUD_RATE (" & integer'image(BAUD_RATE) & ")"
    severity error;

    -- =================================================================================
    -- Intenral UART entity
    -- =================================================================================

    -- Receiver instance
    uartReceiver : entity work.UartRx(logic)
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
        rx          => rx,
        busy        => uartBusy,
        err         => uartErr,
        data        => uartData
    );    

    -- =================================================================================
    -- Module's state machine
    -- =================================================================================

    process(reset_n, clk) is

        -- Stages of the transmiter
        type Stage is (IDLE_ST, WAIT_FOR_BYTE_ST, RECEIVE_ST);
        -- Actual stage
        variable state : Stage;

        -- Oversampling pulse counter
        variable bytesReceived : Natural range 0 to SAMPLE_BYTES;
        -- Uart transmission start signal
        variable errBuf : UartErrors;
        -- Uart data to be transmitted
        variable sampleBuf : std_logic_vector((SAMPLE_BYTES - 1) * BYTE_WIDTH - 1 downto 0);

    begin
        -- Reset condition
        if(reset_n = '0') then

            -- Set outputs to default
            busy <= '0';
            err <= (
                start_err  => '0',
                stop_err   => '0',
                parity_err => '0'
            );
            sample <= (others => '0');
            -- Reset process' variables
            bytesReceived := 0;
            errBuf := (
                start_err  => '0',
                stop_err   => '0',
                parity_err => '0'
            );
            sampleBuf := (others => '0');
            -- Default state: IDLE_ST
            state := IDLE_ST;

        -- Normal operation
        elsif(rising_edge(clk)) then

            -- State machine
            case state is

                -- IDLE_ST
                when IDLE_ST =>

                    -- Check whether UART module started receiving
                    if(uartBusy = '1') then
                        -- Mark module as busy
                        busy <= '1';
                        -- Switch state to RECEIVE_ST
                        state := RECEIVE_ST;
                    end if;

                -- Wait for UART to start transmission
                when WAIT_FOR_BYTE_ST =>

                    if(uartBusy = '1') then
                        -- Switch state to TRANSMIT_ST
                        state := RECEIVE_ST;
                    end if;

                -- UART is receiving byte
                when RECEIVE_ST =>

                    -- Check whether UART received byte
                    if(uartBusy = '0') then

                        -- Increment number of received bytes
                        bytesReceived := bytesReceived + 1;

                        -- If there are some bytes to be received
                        if(bytesReceived /= SAMPLE_BYTES) then

                            -- Fetch received data to the internal buffer
                            sampleBuf(bytesReceived * BYTE_WIDTH  - 1 downto (bytesReceived - 1) * BYTE_WIDTH) := uartData;
                            -- Fetch error code of the UART module
                            errBuf.parity_err := errBuf.parity_err or uartErr.parity_err;
                            errBuf.start_err  := errBuf.start_err  or uartErr.start_err;
                            errBuf.stop_err   := errBuf.stop_err   or uartErr.stop_err;
                            -- Switch state to PREPARE_TRANSMIT_ST
                            state := WAIT_FOR_BYTE_ST;

                        -- Else, if all bytes was received
                        else

                            -- Switch module to the not-busy state
                            busy <= '0';
                            -- Push sample to the output port if no error occurred
                            if(not(errBuf.parity_err or errBuf.start_err or errBuf.stop_err) = '1') then
                                sample <= uartData & sampleBuf;
                            end if;
                            -- Output error code to the output
                            err <= errBuf;
                            -- Clear error buffer
                            errBuf := (
                                start_err  => '0',
                                stop_err   => '0',
                                parity_err => '0'
                            );
                            -- Reset number of bytes received
                            bytesReceived := 0;
                            -- Switch state to IDLE_ST
                            state := IDLE_ST;

                        end if;

                    end if;

            end case;

        end if;

    end process;

end architecture logic;
