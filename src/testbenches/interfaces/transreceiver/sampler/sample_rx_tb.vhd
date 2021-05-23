-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-12 23:04:02
-- @ Modified time: 2021-05-12 23:43:04
-- @ Description: 
--    
--    Sample receiver package's testbench 
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

entity SampleRxTb is
    generic(
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- System clock frequency
        SYS_CLK_HZ : Positive := 200_000_000;

        -- Bytes in the sample
        SAMPLE_BYTES : Positive := 3;
        -- Gap cycles between subsequent samples transmitted 
        SAMPLE_GAP : Natural := 1;

        -- Baud rate of the transmitter's entity
        BAUD_RATE : Positive := 2_000_000;
        -- Parity bit usage
        PARITY_USED : Std_logic := '1';
        -- Type of parity
        PARITY_TYPE : ParityType := EVEN;
        -- Number of stopbits
        STOP_BITS : Positive := 1;
        -- Signal negation
        SIGNAL_NEGATION : Std_logic := '0';
        -- Data negation
        DATA_NEGATION : Std_logic := '0'
    );
end entity SampleRxTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of SampleRxTb is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    
    -- Size of the byte (just to not raw '8' in the code)
    constant BYTE_WIDTH : Positive := 8;    

    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- Busy flag
    signal busy : Std_logic;
    -- Receiving errors
    signal err : UartErrors := (
        start_err  => '0',
        stop_err   => '0',
        parity_err => '0'
    );
    -- Serial input
    signal rx : Std_logic := '0' xor SIGNAL_NEGATION;

    -- Data input (for testing)
    signal sampleToTransmit : Std_logic_vector(SAMPLE_BYTES * BYTE_WIDTH - 1 downto 0) := 
        Std_logic_vector(to_unsigned(11, SAMPLE_BYTES * BYTE_WIDTH));
    -- Received data signal (buffer)
    signal sampleReceivedBuf : Std_logic_vector(SAMPLE_BYTES * BYTE_WIDTH - 1 downto 0) := (others => '0');
    -- Received data signal
    signal sampleReceived : Std_logic_vector(SAMPLE_BYTES * BYTE_WIDTH - 1 downto 0) := (others => '0');

begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Clock signal
    clock_tb(CLK_PERIOD, clk);

    -- Reset signal
    reset_tb(SYS_RESET_TICKS * CLK_PERIOD, reset_n);

    -- =================================================================================
    -- Internal components
    -- =================================================================================

    -- Receiver instance
    sampleReceiver : entity work.SampleRx(logic)
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
        busy        => busy,
        rx          => rx,
        sample      => sampleReceivedBuf,
        err         => err
    );

    -- =================================================================================
    -- Test logic
    -- =================================================================================

    -- Sending process
    process is
        -- Bytes transmitted
        variable bytesTransmitted : Natural range 0 to SAMPLE_BYTES := 0;
        -- Buffer for byte to be transmitted
        variable byteBuf : std_logic_vector(BYTE_WIDTH - 1 downto 0) := (others => '0');
    begin

        -- Zero data buffers
        sampleToTransmit <= (others=>'0');
        byteBuf := (others=>'0');
        -- Reset number of received bytes
        bytesTransmitted := 0;

        -- Wait for end of reset state
        wait until rising_edge(reset_n);

        -- Wait a few cycle to let receiver stand up
        wait for SYS_RESET_TICKS * CLK_PERIOD;

        -- Start transmitting loop
        loop

            -- Check whether all bytes was transmitted
            if(bytesTransmitted < SAMPLE_BYTES) then

                -- Select byte to be transmitted
                byteBuf := sampleToTransmit((bytesTransmitted + 1) * BYTE_WIDTH - 1 downto bytesTransmitted * BYTE_WIDTH);

                -- Transmit serial byte
                uart_tx_tb(
                    BAUD_RATE,
                    PARITY_USED,
                    PARITY_TYPE,
                    STOP_BITS,
                    SIGNAL_NEGATION,
                    DATA_NEGATION,
                    byteBuf,
                    rx
                );

                -- Increment number of transmitted bytes
                bytesTransmitted := bytesTransmitted + 1;

            -- If all bytes was transmitted
            else 

                -- Reset counter of received byte
                bytesTransmitted := 0;
                -- Change value of the next sample to be transmitted
                sampleToTransmit <= Std_logic_vector(Unsigned(sampleToTransmit) + to_unsigned(7, SAMPLE_BYTES * BYTE_WIDTH));
                -- Wait a few cycle before sending nex samples
                wait for CLK_PERIOD * SAMPLE_GAP;

            end if;

        end loop;

    end process;    

    -- Receiving process checking
    process is
    begin

        -- Zero data buffers
        sampleReceived <= (others=>'0');

        -- Wait for end of reset state
        wait until rising_edge(reset_n);

        -- Receive samples in loop
        loop 

            -- Wait for data reception
            wait until falling_edge(busy);

            -- Push data to the buffer
            if((err.parity_err or err.start_err or err.stop_err) = '1') then
                sampleReceived <= (others => 'X');
            elsif(sampleReceivedBuf /= sampleToTransmit) then
                sampleReceived <= (others => 'X');
            else
                sampleReceived <= sampleReceivedBuf;
            end if;

        end loop;        
    
    end process;

end architecture logic;
