-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-23 22:35:50
-- @ Modified time: 2021-04-23 22:37:26
-- @ Description:
-- 
--     Sample transmitter package's testbench 
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

entity SampleTxTb is
    generic(
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- System clock frequency
        SYS_CLK_HZ : Positive := 100_000_000;

        -- Bytes in the sample
        SAMPLE_BYTES : Positive := 2;

        -- Baud rate of the transmitter's entity
        BAUD_RATE : Positive := 25_000_000; -- 921_600;
        -- Parity bit usage
        PARITY_USED : Std_logic := '1';
        -- Type of parity
        PARITY_TYPE : ParityType := EVEN;
        -- Number of stopbits
        STOP_BITS : Positive := 1;
        -- Signal negation
        SIGNAL_NEGATION : Std_logic := '1';
        -- Data negation
        DATA_NEGATION : Std_logic := '1'
    );
end entity SampleTxTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of SampleTxTb is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    
    -- Size of the byte (just to not raw '8' in the code)
    constant BYTE_WIDTH : Positive := 8;    

    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- Transmitter enable signal
    signal transfer : Std_logic := '0';

    -- Busy flag
    signal busy : Std_logic;
    -- Serial output
    signal tx : Std_logic;

    -- Data input
    signal sampleToTransmit : Std_logic_vector(SAMPLE_BYTES * BYTE_WIDTH - 1 downto 0) := 
        Std_logic_vector(to_unsigned(11, SAMPLE_BYTES * BYTE_WIDTH));
    -- Received data signal (for testing)
    signal sampleReceived : Std_logic_vector(SAMPLE_BYTES * BYTE_WIDTH - 1 downto 0) := (others => '0');

    -- Reception error buffer
    signal uartErr : UartErrors := (
        start_err  => '0',
        stop_err   => '0',
        parity_err => '0'
    );

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
    sampleTransmitter : entity work.SampleTx(logic)
    generic map(
        SYS_CLK_HZ      => SYS_CLK_HZ,
        BAUD_RATE       => BAUD_RATE,
        SAMPLE_BYTES    => SAMPLE_BYTES,
        PARITY_USED     => PARITY_USED,
        PARITY_TYPE     => PARITY_TYPE,
        STOP_BITS       => STOP_BITS,
        SIGNAL_NEGATION => SIGNAL_NEGATION,
        DATA_NEGATION   => DATA_NEGATION
    )
    port map(
        reset_n     => reset_n,
        clk         => clk,
        transfer    => transfer,
        sample      => sampleToTransmit,
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
        sampleToTransmit <= (others=>'0');

        -- Wait for system start
        wait for SYS_RESET_TICKS * CLK_PERIOD;
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
            sampleToTransmit <= std_logic_vector(unsigned(sampleToTransmit) + 7);
            wait for 10 * CLK_PERIOD;
        end loop;

    end process;    

    -- Error checking
    process is
        -- Bytes received
        variable bytesReceived : Natural range 0 to SAMPLE_BYTES := 0;
        -- Buffer for received data
        variable sampleReceivedBuf : Std_logic_vector(SAMPLE_BYTES * BYTE_WIDTH - 1 downto 0) := (others => '0');
        -- Buffer for byte received
        variable byteBuf : std_logic_vector(BYTE_WIDTH - 1 downto 0) := (others => '0');
    begin

        -- Reset received word
        sampleReceived <= (others => '0');
        sampleReceivedBuf := (others => '0');
        -- Reset number of received bytes
        bytesReceived := 0;

        loop

            -- Check whether all bytes was received
            if(bytesReceived < SAMPLE_BYTES) then

                -- Receive serial byte
                uart_rx_tb(
                    BAUD_RATE,
                    PARITY_USED,
                    PARITY_TYPE,
                    STOP_BITS,
                    SIGNAL_NEGATION,
                    DATA_NEGATION,
                    tx,
                    uartErr,
                    byteBuf
                );

                -- Put received byte into sample buffer
                sampleReceivedBuf((bytesReceived + 1) * BYTE_WIDTH - 1 downto bytesReceived * BYTE_WIDTH) := byteBuf;

                -- Increment number of received bytes
                bytesReceived := bytesReceived + 1;

            -- If all bytes was received
            else 

                -- Reset counter of received byte
                bytesReceived := 0;
                -- Copy received sample from the bufer
                sampleReceived <= sampleReceivedBuf;

                -- Check whether correct word received
                if(sampleReceivedBuf /= sampleToTransmit) then
                    sampleReceived <= (others => 'X');            
                end if;

            end if;

        end loop;
    
    end process;

end architecture logic;
