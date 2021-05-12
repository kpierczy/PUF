-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-26 17:19:40
-- @ Modified time: 2021-04-26 17:19:57
-- @ Description: 
--    
--    Implementation of the UART receiver module
--    
-- @ Note: 'not buffered internally' means 'don't touch when module is busy'
-- ===================================================================================================================================

-- ===================================================================================================================================
-- A generic UART receiver with adjustable baudrate and oversampling rate
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.uart.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity UartRx is

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
        -- Ratio of the @in clk frequency to the baud frequency (minus 1)
        baud_period : in Natural range 0 to SYS_CLK_HZ / BAUD_RATE_MIN - 1;
        -- Serial input 
        rx : in Std_logic;
        
        -- 'Module busy' signal (active high)
        busy : out Std_logic;
        -- Eror flags (active high) (if error occured, flag is set for the single @in clk cycle when @out busy goes low)
        err : out UartErrors;
        -- Data to be transfered (latched on @in clk rising edge when @in enable high and @out busy low)
        data : out Std_logic_vector(DATA_WIDTH - 1 downto 0)
    );

end entity UartRx;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of UartRx is

    -- Input serial with non-inverted phase
    signal rxNonInv : std_logic_vector(1 downto 0);

begin

    -- Assert proper ratio of the system clock and baud rate
    assert (SYS_CLK_HZ / BAUD_RATE_MIN >= 2)
        report 
            "UartTx: Invalid value of the SYS_CLK_HZ (" & integer'image(SYS_CLK_HZ) & ")" & 
            "or/and BAUD_RATE_MIN (" & integer'image(BAUD_RATE_MIN) & ")"
    severity error;

    -- =================================================================================
    -- State machine of the receiver
    -- =================================================================================

    process(reset_n, clk) is

        -- Stages of the receiver
        type Stage is (IDLE_ST, START_ST, DATA_ST, PARITY_ST, STOP_ST);
        -- Actual stage
        variable state : Stage;

        -- Period of the oversampling pulse (in @in clk's periods) minus 1
        variable baudPeriod : Natural range 0 to SYS_CLK_HZ / BAUD_RATE_MIN - 1;
        -- Data buffer (Stop does not need to be standalone signals. Shift register fills empty bits with suitable values)
        variable dataBuf : Std_logic_vector(data'range);
        -- Error bits' buffer
        variable errBuf : UartErrors;

        -- Oversampling pulse counter
        variable baudCounter : Natural range 0 to SYS_CLK_HZ / BAUD_RATE_MIN - 1;
        -- Counter of data/stop bits received
        variable bitsCounter : Natural range 0 to data'length - 1;

    begin
        -- Reset condition
        if(reset_n = '0') then

            -- Set outputs to default
            busy <= '0';
            err.start_err <= '0';
            err.stop_err <= '0';
            err.parity_err <= '0';
            data <= (others => '0');
            -- Set internal buffers to default
            rxNonInv <= (others => '0');
            baudPeriod := 0;
            dataBuf := (others => '0');
            errBuf.start_err := '0';
            errBuf.stop_err := '0';
            errBuf.parity_err := '0';
            -- Set internal counters to default
            baudCounter := 0;
            bitsCounter :=  0;
            -- Default state: IDLE_ST
            state := IDLE_ST;

        -- Normal operation
        elsif(rising_edge(clk)) then

            -- Shift previously sampled value
            rxNonInv(0) <= rxNonInv(1);
            -- Sample serial line
            rxNonInv(1) <= rx xor SIGNAL_NEGATION;

            -- Keep error outputs low at default
            err.start_err <= '0';
            err.stop_err <= '0';
            err.parity_err <= '0';
            
            -- State machine
            case state is 

                -- Idle state
                when IDLE_ST =>
                    
                    -- Activation of the reception
                    if(rxNonInv(1) = '1' and rxNonInv(0) = '0' and baud_period /= 0) then
                        -- Signal that the entity is busy
                        busy <= '1';
                        -- Fetch baud period
                        baudPeriod := baud_period;
                        -- Go to the start bit transmission state
                        state := START_ST;
                    end if;

                -- Start bit receiving
                when START_ST =>

                    -- If single baud's period didn't passed
                    if(baudCounter /= baudPeriod / 2 ) then
                        -- Increment baud counter
                        baudCounter := baudCounter + 1;
                    -- Otherwise
                    else
                        -- Sample start bit from the serial output     
                        errBuf.start_err := rxNonInv(0) xor '1';
                        -- Reset baud counter   
                        baudCounter := 0;
                        -- Change state to 'data receiving'   
                        state := DATA_ST;
                    end if;

                -- Data bits receiving
                when DATA_ST =>

                    -- If all bits wasn't received yet
                    if(bitsCounter /= DATA_WIDTH) then

                        -- If single baud's period didn't passed
                        if(baudCounter /= baudPeriod) then
                            -- Increment baud counter
                            baudCounter := baudCounter + 1;
                        -- Otherwise
                        else
                            -- Shift buffer content
                            dataBuf(dataBuf'left - 1 downto 0) := dataBuf(dataBuf'left downto 1);
                            -- Sample next data bit from the serial input
                            dataBuf(dataBuf'left) := rxNonInv(0);
                            -- Increment counter of sent data bits
                            bitsCounter := bitsCounter + 1;
                            -- Reset baud counter
                            baudCounter := 0;
                        end if;

                    -- If all bits was received
                    else

                        -- Reset bits counter
                        bitsCounter := 0;

                        -- If parity bit has to be sent
                        if(PARITY_USED = '1') then
                            -- Go to the 'parity reception' state
                            state := PARITY_ST;
                        -- Else, transmit stop bit
                        else
                            -- Go to the 'stop bit(s) reception' state
                            state := STOP_ST;
                        end if;

                    end if;

                -- Parity bit reciving
                when PARITY_ST =>

                    -- If single baud's period didn't passed
                    if(baudCounter /= baudPeriod) then
                        -- Increment baud counter
                        baudCounter := baudCounter + 1; 
                    -- Otherwise
                    else
                        -- Verify parity bit
                        errBuf.parity_err := rxNonInv(0) xor parity_gen(dataBuf, PARITY_TYPE);
                        -- Reset baud counter
                        baudCounter := 0;
                        -- Change state to 'stop bit(s) sending'
                        state := STOP_ST;
                    end if;

                -- Stop bit(s) sending
                when STOP_ST =>

                    -- If all stop bits wasn't sent yet
                    if(bitsCounter /= STOP_BITS) then

                        -- If single baud's period didn't passed
                        if(baudCounter /= baudPeriod) then
                            -- Increment baud counter
                            baudCounter := baudCounter + 1;
                        -- Otherwise
                        else
                            -- Sample stop bit from the serial output     
                            errBuf.stop_err := rxNonInv(0);
                            -- Reset baud counter
                            baudCounter := 0;
                            -- Increment counter of sent data bits
                            bitsCounter := bitsCounter + 1;
                        end if;

                    -- Otherwise
                    else

                        -- Signal end of reception
                        busy <= '0';
                        -- Output error flags
                        err <= errBuf;
                        -- Update received word
                        if((errBuf.start_err or errBuf.stop_err or errBuf.parity_err) = '0') then
                            data <= dataBuf when DATA_NEGATION = '0' else not(dataBuf);
                        else
                            data <= (others => '0');
                        end if;

                        -- Reset bits counter
                        bitsCounter := 0;
                        -- Go to the 'stop bit(s) transmission' state
                        state := IDLE_ST;

                    end if;

            end case;

        end if; -- if(rising_edge(clk))

    end process;

end architecture logic;
