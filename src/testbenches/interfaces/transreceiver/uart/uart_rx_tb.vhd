-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-26 18:18:27
-- @ Modified time: 2021-04-26 18:20:05
-- @ Description:
-- 
--     Uart receiver package's testbench 
--
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
library work;
use work.uart.all;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity UartRxTb is
    generic(
        -- Frequency of the clock beating the entity (used to compute width of the @in baud_period input)
        SYS_CLK_HZ : Positive := 100_000_000;
        -- Minimal baud rate possible to be grenerated by the entity (used to compute width of the @in baud_period input)
        BAUD_RATE_MIN : Positive := 9600;
        -- Baud rate
        BAUD_RATE : Positive := 25_000_000;
        -- Data width
        DATA_WIDTH : Positive range 5 to 8 := 8;
        -- Parity usage
        PARITY_USED : Std_logic := '1';
        -- Parity type
        PARITY_TYPE : ParityType := EVEN;
        -- Number of stopbits
        STOP_BITS : Positive range 1 to 2 := 1;
        -- Signal negation (Defaults to standard RS-232, i.e. negated signal and data)
        SIGNAL_NEGATION : Std_logic := '1';
        -- Data negation (Defaults to standard RS-232, i.e. negated signal and data)
        DATA_NEGATION : Std_logic := '1'
    );
end entity UartRxTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of UartRxTb is  

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    

    -- Reset signal (asynchronous)
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic;
    -- Ratio of the @in clk frequency to the baud frequency (minus 1)
    signal baud_period : Natural range 0 to SYS_CLK_HZ / BAUD_RATE_MIN - 1 := SYS_CLK_HZ / BAUD_RATE -1;
    -- Serial input 
    signal rx : Std_logic := '0' xor SIGNAL_NEGATION;

    -- 'Module busy' signal (active high)
    signal busy : Std_logic;
    -- Eror flags (active high) (if error occured, flag is set for the single @in clk cycle when @out busy goes low)
    signal err : UartErrors;
    -- Data to be transfered (latched on @in clk rising edge when @in enable high and @out busy low)
    signal data : Std_logic_vector(DATA_WIDTH - 1 downto 0);
    -- Buffer containing data to be transfered via RX line
    signal dataToTransmit : Std_logic_vector(data'range);
    -- Data that was received by the UART module
    signal dataReceived : Std_logic_vector(data'range);
    
begin
    
    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Clock signal
    clock_tb(CLK_PERIOD, clk);

    -- =================================================================================
    -- Internal components
    -- =================================================================================

    -- Receiver instance
    uartReceiver : entity work.UartRx(logic)
    generic map(
        SYS_CLK_HZ      => SYS_CLK_HZ,
        BAUD_RATE_MIN   => BAUD_RATE_MIN,
        DATA_WIDTH      => DATA_WIDTH,
        PARITY_USED     => PARITY_USED,
        PARITY_TYPE     => PARITY_TYPE,
        STOP_BITS       => STOP_BITS,
        SIGNAL_NEGATION => SIGNAL_NEGATION,
        DATA_NEGATION   => DATA_NEGATION
    )
    port map(
        reset_n     => reset_n,
        clk         => clk,
        baud_period => baud_period,
        rx          => rx,
        busy        => busy,
        err         => err,
        data        => data
    );

    -- =================================================================================
    -- Test logic
    -- =================================================================================

    -- Sending process
    process is

        -- Period of the single bit
        constant BAUD_PERIOD :time := 1 sec / BAUD_RATE;
        -- Parity value to be send
        variable parityBit : std_logic := '0';

    begin

        -- Set reset signal (active low)
        reset_n <= '0';
        -- Keep RX line idle
        rx <= '0' xor SIGNAL_NEGATION;
        -- Zero data buffer
        dataToTransmit <= (others=>'0');

        -- Wait for start
        wait for CLK_PERIOD * 10;
        -- Disable reset signal
        reset_n <= '1';
        -- Wait for start
        wait for CLK_PERIOD * 10;

        -- Send data in loop
        loop
            -- Transmit data via RX line
            uart_tx_tb(
                BAUD_RATE,
                PARITY_USED,
                PARITY_TYPE,
                STOP_BITS,
                SIGNAL_NEGATION,
                DATA_NEGATION,
                dataToTransmit,
                rx);
            -- Wait for next transmission
            wait for 9 * CLK_PERIOD;
            -- Update data value
            dataToTransmit <= std_logic_vector(unsigned(dataToTransmit) + 7);
            wait for CLK_PERIOD;
        end loop;

    end process; 

    -- Verifying process
    process is
    begin

        -- Reset buffer for received data
        dataReceived <= (others => '0');

        -- Send data in loop
        loop
            -- Wait for data reception
            wait until falling_edge(busy);
            -- Push data to the buffer on the next clock cycle
            wait for CLK_PERIOD;
            if((err.parity_err or err.start_err or err.stop_err) = '1') then
                dataReceived <= (others => 'X');
            elsif(data /= dataToTransmit) then
                dataReceived <= (others => 'X');
            else
                dataReceived <= data;
            end if;
        end loop;

    end process; 

end architecture logic;
