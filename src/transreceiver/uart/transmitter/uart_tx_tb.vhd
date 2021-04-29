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
library work;
use work.uart.all;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity uart_tx_tb is
end entity uart_tx_tb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of uart_tx_tb is

    -- Peiord of the system clock
    constant CLK_PERIOD_NS : Positive := 10;
    
    -- Minimal baud rate of the transmitter's entity
    constant BAUD_RATE_MIN : Positive := 9600;
    -- Data width
    constant DATA_WIDTH : Positive := 8;
    -- Parity bit usage
    constant PARITY_USED : Boolean := True;
    -- Type of parity
    constant PARITY_TYPE : ParityType := EVEN;
    -- Number of stopbits
    constant STOP_BITS : Positive := 2;
    -- Signal negation
    constant SIGNAL_NEGATION : Std_logic := '0';
    -- Data negation
    constant DATA_NEGATION : Std_logic := '0';

    
    -- System clock frequency
    constant SYS_CLK_HZ : Positive := 1_000_000_000 / CLK_PERIOD_NS;
    -- Reset signal
    signal reset_n : Std_logic;
    -- System clock
    signal clk : Std_logic;
    -- Ratio of the system clock's frequency and baud rate (minus 1)
    signal baud_period : Natural range 0 to SYS_CLK_HZ / BAUD_RATE_MIN - 1 := SYS_CLK_HZ / (9600 * 6) - 1;
    -- Transmitter enable signal
    signal enable : Std_logic := '0';
    -- Data input
    signal data : Std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    -- Busy flag
    signal busy : Std_logic;
    -- Serial output
    signal tx : Std_logic;
    
begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Reset signal
    reset_n <= '0', '1' after (1 ns * CLK_PERIOD_NS);

    -- Clock signal
    clk <= not clk after (1 ns * CLK_PERIOD_NS) / 2 when reset_n /= '0' else '0';

    -- =================================================================================
    -- Internal components
    -- =================================================================================

    -- Timer generating baud pulse
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
        enable      => enable,
        data        => data,
        busy        => busy,
        tx          => tx
    );

    -- =================================================================================
    -- Test logic
    -- =================================================================================

    process(reset_n, clk) is

        type State is (WAITS, INITIALIZING, TRANSMITS);
        variable stage : State;
        variable counter : Natural range 0 to 10;

    begin

        if(reset_n = '0') then
            stage := WAITS;
            counter := 0;
            data <= (others => '0');
            enable <= '0';
        elsif(rising_edge(clk)) then

            case stage is
                
                when WAITS =>
                
                    enable <= '1';
                    data <= rand_logic_vector(DATA_WIDTH);
                    stage := INITIALIZING;
                    
                when INITIALIZING =>
                
                    if(busy = '1') then
                        enable <= '0';
                        stage := TRANSMITS;
                    end if;
                
                when TRANSMITS =>
                
                    if(busy = '0') then
                        stage := WAITS;
                    end if;
                    
            end case;
                        
        end if;

    end process;

end architecture logic;
