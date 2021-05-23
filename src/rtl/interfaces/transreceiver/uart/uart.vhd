-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-26 17:31:31
-- @ Modified time: 2021-04-26 17:31:32
-- @ Description: 
--    
--    Uart-related package
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

-- ------------------------------------------------------------- Header --------------------------------------------------------------

package uart is

    -- Type of the edge
    type ParityType is (EVEN, ODD);

    -- Reception errors (usable to index Std_logic_vector)
    type UartErrors is record
        start_err  : Std_logic;
        stop_err   : Std_logic;
        parity_err : Std_logic;
    end record;

    -- Oversampling type
    type UartOvs is (X8, X16);

    -- Parity bit generator. Returns '1' if number of bits set in @p data is even (for EVEN) or odd (for ODD) and '0' otherwise
    function parity_gen(data : Std_logic_vector; parity_type: ParityType) return Std_logic;

    -- Sends a word throught the serial interface
    procedure uart_tx_tb (
        constant BAUD_RATE       : in  Natural;          -- Transfer speed
        constant PARITY_USED     : in  Std_logic;        -- Parity bit usage
        constant PARITY_TYPE     : in  ParityType;       -- Parity bit type
        constant STOP_BITS       : in  Natural;          -- Stop bits number (1-2)
        constant SIGNAL_NEGATION : in  Std_logic;        -- Optional logical negation of the entire signal
        constant DATA_NEGATION   : in  Std_logic;        -- Optional logical negation of the data bits
        constant DATA            : in  Std_logic_vector; -- Word to be sent
        signal   tx              : out Std_logic         -- wysylany sygnal szeregowy
    );

    -- Receive a word throught the serial interface
    procedure uart_rx_tb (
        constant BAUD_RATE       : in  Natural;          -- Transfer speed
        constant PARITY_USED     : in  Std_logic;        -- Parity bit usage
        constant PARITY_TYPE     : in  ParityType;       -- Parity bit type
        constant STOP_BITS       : in  Natural;          -- Stop bits number (1-2)
        constant SIGNAL_NEGATION : in  Std_logic;        -- Optional logical negation of the entire signal
        constant DATA_NEGATION   : in  Std_logic;        -- Optional logical negation of the data bits
        signal   rx              : in  Std_logic;        -- Serial wire
        signal   err             : out UartErrors;       -- Reception error
        variable data            : out Std_logic_vector  -- Word to be received
    );

end package uart;

-- -------------------------------------------------------------- Body ---------------------------------------------------------------

package body uart is

    -- Parity bit generator. Returns '1' if number of bits set in @p data is even (for EVEN) or odd (for ODD) and '0' otherwise
    function parity_gen(data : Std_logic_vector; parity_type: ParityType) return Std_logic is
    begin

        -- Switch initial value for odd parity
        if (parity_type = EVEN) then
            return xor_reduce(data);
        else 
            return not(xor_reduce(data));
        end if;

    end function;

    -- Sends a word throught the serial interface
    procedure uart_tx_tb (
        constant BAUD_RATE       : in  Natural;          -- Transfer speed
        constant PARITY_USED     : in  Std_logic;        -- Parity bit usage
        constant PARITY_TYPE     : in  ParityType;       -- Parity bit type
        constant STOP_BITS       : in  Natural;          -- Stop bits number (1-2)
        constant SIGNAL_NEGATION : in  Std_logic;        -- Optional logical negation of the entire signal
        constant DATA_NEGATION   : in  Std_logic;        -- Optional logical negation of the data bits
        constant DATA            : in  Std_logic_vector; -- Word to be sent
        signal   tx              : out Std_logic         -- Serial wire
    ) is

        -- Function to invert serial signal
        function tx_neg(tx : std_logic) return std_logic is
        begin
            return TX xor SIGNAL_NEGATION;
        end function;

        -- Time of the single bit
        constant BAUD_PERIOD : Time := 1 sec / BAUD_RATE;

        -- Parity bit
        variable parityBit : Std_logic := '0';
        -- Data to be sent
        variable dataToTransmit : Std_logic_vector(DATA'range);

    begin

        -- Establish data to be used basing on the optional negation
        if(DATA_NEGATION = '1') then
            dataToTransmit := not(DATA);
        else
            dataToTransmit := DATA;
        end if;

        -- Send start bit
        tx <= tx_neg('1');
        wait for BAUD_PERIOD;
        -- Send data bits
        for i in 0 to dataToTransmit'length - 1 loop
            tx <= tx_neg(dataToTransmit(i));
            wait for BAUD_PERIOD;
        end loop;
        -- Transmit parity bit
        if (PARITY_USED = '1') then
            -- Produce parity bits depending on parity type
            if (PARITY_TYPE = EVEN) then
                parityBit := xor_reduce(dataToTransmit);
            else
                parityBit := not(xor_reduce(dataToTransmit));
            end if;
            -- Transmit bit
            tx <= tx_neg(parityBit);
            wait for BAUD_PERIOD;
        end if;
        -- Transmit stop bits
        for i in 0 to STOP_BITS - 1 loop
            tx <= tx_neg('0');
            wait for BAUD_PERIOD;
        end loop;

    end procedure;

    -- Receive a word throught the serial interface
    procedure uart_rx_tb (
        constant BAUD_RATE       : in  Natural;          -- Transfer speed
        constant PARITY_USED     : in  Std_logic;        -- Parity bit usage
        constant PARITY_TYPE     : in  ParityType;       -- Parity bit type
        constant STOP_BITS       : in  Natural;          -- Stop bits number (1-2)
        constant SIGNAL_NEGATION : in  Std_logic;        -- Optional logical negation of the entire signal
        constant DATA_NEGATION   : in  Std_logic;        -- Optional logical negation of the data bits
        signal   rx              : in  Std_logic;        -- Serial wire
        signal   err             : out UartErrors;       -- Reception error
        variable data            : out Std_logic_vector  -- Word to be received
    ) is

        -- Function to invert serial signal
        function rx_neg(rx : std_logic) return std_logic is
        begin
            return rx xor SIGNAL_NEGATION;
        end function;

        -- Data buffer
        variable dataBuf :std_logic_vector(data'range);
        -- error buffer
        variable errBuf : UartErrors;

        -- Time of the single bit
        constant BAUD_PERIOD : Time := 1 sec / BAUD_RATE;

        -- Expected parity bit
        variable parityExpected : Std_logic := '0';
        -- Data to be sent
        variable dataToTransmit : Std_logic_vector(DATA'range);

    begin
    
        -- Clear intenrla buffer
        dataBuf := (others => '0');
        -- Clear error flags
        errBuf.start_err := '0';
        errBuf.stop_err := '0';
        errBuf.parity_err := '0';
        err.start_err <= '0';
        err.stop_err <= '0';
        err.parity_err <= '0';
    
        -- Wait for start bit
        wait until rx_neg(rx) = '1';

        -- Wait half period to sample start bit
        wait for BAUD_PERIOD / 2;
        if (rx_neg(rx) /= '1') then
            errBuf.start_err := '1';
        end if;
        -- Wait and sample data bits
        for i in 0 to data'length - 1 loop
            wait for BAUD_PERIOD;
            dataBuf(i) := rx_neg(RX) xor DATA_NEGATION;
        end loop;
        -- Sample and check parity
        parityExpected := xor_reduce(dataBuf) when PARITY_TYPE = EVEN else not(xor_reduce(dataBuf));
        wait for BAUD_PERIOD;
        if (PARITY_USED = '1') then
            errBuf.parity_err := rx_neg(rx) xor parityExpected;
        end if;
        -- Sample stop bits
        for i in 0 to STOP_BITS - 1 loop
            wait for BAUD_PERIOD;
            errBuf.stop_err := rx_neg(rx) xor '0';
        end loop;

        -- Output result
        err <= errBuf;
        if ((errBuf.parity_err or errBuf.start_err or errBuf.stop_err) = '1') then
            data := (others => 'X');
        else
            data := dataBuf;
        end if;

    end procedure;

end package body uart;
