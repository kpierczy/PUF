-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-23 22:35:50
-- @ Modified time: 2021-04-23 22:37:26
-- @ Description:
-- 
--     Uart transmitter package's testbench 
--
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_misc.all;
library work;
use work.uart.all;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity uart_tx_tb is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Natural := 200_000_000;
        -- Minimal baud rate of the transmitter's entity
        BAUD_RATE_MIN : Positive := 9600;
        -- Baud rate of the transmitter's entity
        BAUD_RATE : Positive := 921_600;
        -- Data width
        DATA_WIDTH : Positive := 8;
        -- Parity bit usage
        PARITY_USED : Std_logic := '1';
        -- Type of parity
        PARITY_TYPE : ParityType := EVEN;
        -- Number of stopbits
        STOP_BITS : Positive := 1;
        -- Signal negation
        SIGNAL_NEGATION : Std_logic := '0';
        -- Data negation
        DATA_NEGATION : Std_logic := '1'
    );
end entity uart_tx_tb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of uart_tx_tb is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    

    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';
    -- Ratio of the system clock's frequency and baud rate (minus 1)
    signal baud_period : Natural range 0 to SYS_CLK_HZ / BAUD_RATE_MIN - 1 := SYS_CLK_HZ / BAUD_RATE - 1;
    -- Serial output
    signal tx : Std_logic;

    -- Busy flag
    signal busy : Std_logic;
    -- Transmitter enable signal
    signal transfer : Std_logic := '0';
    -- Data input
    signal dataToTransmit : Std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    -- Received data signal (for testing)
    signal dataReceived : Std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    -- Transmission errors
    signal err : UartErrors;

begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Clock signal
    clk <= not clk after CLK_PERIOD / 2 when reset_n /= '0' else '0';

    -- =================================================================================
    -- Internal components
    -- =================================================================================

    -- Transmitter instance
    uartTransmitter : entity work.UartTx(logic)
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
        transfer      => transfer,
        data        => dataToTransmit,
        busy        => busy,
        tx          => tx
    );

    -- =================================================================================
    -- Test logic
    -- =================================================================================

    -- Sending process
    process is
    begin
        -- Set reset signal (active low)
        reset_n <= '0';
        -- Disable TX module
        transfer <= '0';
        -- Zero data buffer
        dataToTransmit <= (others=>'0');

        -- Wait for system start
        wait for 10 * CLK_PERIOD;
        -- Disable reset signal
        reset_n <= '1';
        -- Wait for transmission start
        wait for 5 * CLK_PERIOD;

        -- Send data in loop
        loop
            transfer  <= '1';
            wait for CLK_PERIOD;
            transfer  <= '0';
            wait for CLK_PERIOD;
            wait until busy = '0';
            dataToTransmit <= std_logic_vector(unsigned(dataToTransmit) + 7);
            wait for 10 * CLK_PERIOD;
        end loop;

    end process;    

    -- Error checking
    process is
        -- Received data signal buf (for testing)
        variable dataReceivedBuf : Std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    begin

        -- Reset received word
        dataReceived <= (others => '0');
        -- Reset error signals
        err.parity_err <= '0';
        err.start_err <= '0';
        err.stop_err <= '0';

        wait for 15 * CLK_PERIOD;

        loop

            -- Receive serial data
            uart_rx_tb(
                BAUD_RATE,
                PARITY_USED,
                PARITY_TYPE,
                STOP_BITS,
                SIGNAL_NEGATION,
                DATA_NEGATION,
                tx,
                err,
                dataReceivedBuf
            );

            -- Get data from the buffer
            dataReceived <= dataReceivedBuf;

            -- Check whether correct word received
            if(dataReceivedBuf /= dataToTransmit) then
                dataReceived <= (others => 'X');            
            end if;

        end loop;
    
    end process;

end architecture logic;
