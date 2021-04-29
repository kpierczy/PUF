-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-26 17:19:40
-- @ Modified time: 2021-04-26 17:19:57
-- @ Description: 
--    
--    Implementation of the UART transmitter module
--    
-- @ Note: 'not buffered internally' means 'don't touch when module is busy'
-- ===================================================================================================================================

-- ===================================================================================================================================
-- A generic UART transmitter with adjustable baudrate
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.uart.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity UartTx is

    generic(
        -- Frequency of the clock beating the entity (used to compute width of the @in baud_period input)
        SYS_CLK_HZ : Positive;
        -- Minimal baud rate possible to be grenerated by the entity (used to compute width of the @in baud_period input)
        BAUD_RATE_MIN : Positive;
        -- Data width
        DATA_WIDTH : Positive range 5 to 8;
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
        -- Ration of the @in clk frequency to the baud frequency (minus 1)
        baud_period : in Natural range 0 to SYS_CLK_HZ / BAUD_RATE_MIN - 1;
        -- Data to be transfered (latched on @in clk rising edge when @in transfer high and @out busy's low)
        data : in Std_logic_vector(DATA_WIDTH - 1 downto 0);

        -- 'Module busy' signal (active high)
        busy : out Std_logic;
        -- Serial output
        tx : out Std_logic

    );

end entity UartTx;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of UartTx is

    -- Output serial signal before optional negation
    signal txNonInv : Std_logic;

begin

    -- Assert proper ratio of the system clock and baud rate
    assert (SYS_CLK_HZ / BAUD_RATE_MIN >= 1)
        report 
            "UartTx: Invalid value of the SYS_CLK_HZ (" & integer'image(SYS_CLK_HZ) & ")" & 
            "or/and BAUD_RATE_MIN (" & integer'image(BAUD_RATE_MIN) & ")"
    severity error;

    -- =================================================================================
    -- State machine of the transmitter
    -- =================================================================================

    -- Negate serial signal (optional)
    tx <= txNonInv xor SIGNAL_NEGATION;
    
    process(reset_n, clk) is

        -- Stages of the transmitter
        type Stage is (IDLE_ST, START_ST, DATA_ST, PARITY_ST, STOP_ST);
        -- Actual stage
        variable state : Stage;

        -- Period of the single baud (in @in clk's periods) minus 1
        variable baudPeriod : Natural range 0 to SYS_CLK_HZ / BAUD_RATE_MIN - 1;
        -- Data buffer (Stop does not need to be standalone signals. Shift register fills empty bits with suitable values)
        variable dataBuf : Std_logic_vector(data'range);
        -- State of the parity bit of data
        variable parityBit : Std_logic;

        -- Baud counter
        variable baudCounter : Natural range 0 to SYS_CLK_HZ / BAUD_RATE_MIN - 1;
        -- Counter of data/stop bits transmitted
        variable bitsCounter : Natural range 0 to data'length - 1;

    begin
        -- Reset condition
        if(reset_n = '0') then

            -- Set outputs to default
            busy <= '0';
            txNonInv <= '0';
            -- Set internal buffers to default
            baudPeriod := 0;
            dataBuf    := (others => '0');
            parityBit  := '0';
            -- Set internal counters to default
            baudCounter := 0;
            bitsCounter :=  0;
            -- Default state: IDLE_ST
            state := IDLE_ST;

        -- Normal operation
        elsif(rising_edge(clk)) then

            -- State machine
            case state is 
                           
                -- Idle state
                when IDLE_ST =>
                     
                    -- Activation of the transmission
                    if(transfer = '1') then
                        -- Signal that the entity is busy
                        busy <= '1'; 
                        -- Push start bit to serial output
                        txNonInv <= '1';
                        -- Fetch baud period
                        baudPeriod := baud_period;
                        -- Fetch data to be sent
                        dataBuf := data;
                        -- Compute parity bit from input data
                        if(DATA_NEGATION = '1') then 
                            parityBit := parity_gen(not(data), PARITY_TYPE);
                        else
                            parityBit := parity_gen(data, PARITY_TYPE);
                        end if;
                        -- Go to the start bit transmission state
                        state := START_ST;
                    end if;

                -- Start bit sending
                when START_ST =>

                    -- If single baud's period didn't passed
                    if(baudCounter /= baudPeriod) then
                        -- Increment baud counter
                        baudCounter := baudCounter + 1;
                    -- Otherwise
                    else
                        -- Push first data bit to the serial output     
                        txNonInv <= dataBuf(0) xor DATA_NEGATION;
                        -- Shift dtaa in the buffer
                        dataBuf(dataBuf'left - 1 downto 0) := dataBuf(dataBuf'left downto 1);
                        dataBuf(dataBuf'left) := '0';
                        -- Reset baud counter   
                        baudCounter := 0;
                        -- Change state to 'data sending'   
                        state := DATA_ST;
                    end if;

                -- Data bits sending
                when DATA_ST =>

                    -- If all but last data bits wasn't sent yet
                    if(bitsCounter /= DATA_WIDTH - 1) then

                        -- If single baud's period didn't passed
                        if(baudCounter /= baudPeriod) then
                            -- Increment baud counter
                            baudCounter := baudCounter + 1;
                        -- Otherwise
                        else
                            -- Push first data bit to the serial output     
                            txNonInv <= dataBuf(0) xor DATA_NEGATION;
                            -- Shift dtaa in the buffer
                            dataBuf(dataBuf'left - 1 downto 0) := dataBuf(dataBuf'left downto 1);
                            dataBuf(dataBuf'left) := '0';
                            -- Increment counter of sent data bits
                            bitsCounter := bitsCounter + 1;
                            -- Reset baud counter
                            baudCounter := 0;
                        end if;

                    -- Otherwise
                    else

                        -- If single baud's period didn't passed
                        if(baudCounter /= baudPeriod) then
                            baudCounter := baudCounter + 1; -- Increment baud counter
                        -- Otherwise (all data bits was sent)
                        else

                            -- Reset baud counter
                            baudCounter := 0;
                            -- Reset bits counter
                            bitsCounter := 0;
    
                            -- If parity bit has to be sent
                            if(PARITY_USED = '1') then
                                -- Push parity bit to the serial output
                                txNonInv <= parityBit;
                                -- Go to the 'parity transmission' state
                                state := PARITY_ST;
                            -- Else, transmit stop bit
                            else
                                -- Push stop bit to the serial output    
                                txNonInv <= '0';
                                -- Go to the 'stop bit(s) transmission' state
                                state := STOP_ST;
                            end if;
                            
                        end if;

                    end if;

                -- Parity bit sending
                when PARITY_ST =>

                    -- If single baud's period didn't passed
                    if(baudCounter /= baudPeriod) then
                        -- Increment baud counter
                        baudCounter := baudCounter + 1; 
                    -- Otherwise
                    else
                        -- Push stop bit to the serial output
                        txNonInv <= '0';
                        -- Reset baud counter
                        baudCounter := 0;
                        -- Change state to 'stop bit(s) sending'
                        state := STOP_ST;
                    end if;

                -- Stop bit(s) sending
                when STOP_ST =>

                    -- If all stop bits wasn't sent yet
                    if(bitsCounter /= STOP_BITS - 1) then

                        -- If single baud's period didn't passed
                        if(baudCounter /= baudPeriod) then
                            -- Increment baud counter
                            baudCounter := baudCounter + 1;
                        -- Otherwise
                        else
                            -- Push stop bit to the serial output
                            txNonInv <= '0';
                            -- Reset baud counter
                            baudCounter := 0;
                            -- Increment counter of sent data bits
                            bitsCounter := bitsCounter + 1;
                        end if;

                    -- Otherwise
                    else

                        -- If single baud's period didn't passed
                        if(baudCounter /= baudPeriod) then
                            -- Increment baud counter
                            baudCounter := baudCounter + 1;
                        -- Otherwise (All stop bits were sent)
                        else
                            -- Reset baud counter
                            baudCounter := 0;
                            -- Reset bits counter
                            bitsCounter := 0;
                            -- Signal that the entity is busy
                            busy <= '0'; 
                            -- Push idle state to the serial output
                            txNonInv <= '0';
                            -- Go to the 'stop bit(s) transmission' state
                            state := IDLE_ST;
                        end if;

                    end if;

            end case;

        end if; -- if(rising_edge(clk))

    end process;

end architecture logic;
