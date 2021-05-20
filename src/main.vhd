library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.uart.all;
use work.sim.all;

entity main is
    
    generic(
        SYS_CLK_HZ : Positive := 100_000_000;
        BAUD_RATE_MIN : Positive := 9600;
        DATA_WIDTH : Positive := 8;
        PARITY_USED : std_logic := '1';
        PARITY_TYPE : ParityType := EVEN;
        STOP_BITS : Positive := 2;
        SIGNAL_NEGATION : Std_logic := '0';
        DATA_NEGATION : Std_logic := '0';
        SAMPLE_WIDTH : Positive := 16;
        GAIN_WIDTH : Positive := 12;
        TWO_POW_DIV : Natural := 7
    );
    port(
        reset_n : in Std_logic;
        clk : in Std_logic;
        transfer : in Std_logic;
        dataTx : in Std_logic_vector(DATA_WIDTH - 1 downto 0);
        dataRx : out Std_logic_vector(DATA_WIDTH - 1 downto 0);
        busyTx, busyRx : out Std_logic;
        tx : out Std_logic;
        rx : in Std_logic;
        err : out UartErrors;
        valid_in : in std_logic;
        valid_out : out std_logic;
        sample_in : in Signed(SAMPLE_WIDTH - 1 downto 0);
        gain_in : in Unsigned(GAIN_WIDTH - 1 downto 0);
        saturation_in : in Unsigned(SAMPLE_WIDTH - 2 downto 0);
        sample_out : out Signed(SAMPLE_WIDTH - 1 downto 0)
    );

end entity;

architecture logic of main is

    signal baud_period : Natural range 0 to SYS_CLK_HZ / BAUD_RATE_MIN - 1 := 10;

begin

    -- Transmitter
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
        transfer    => transfer,
        data        => dataTx,
        busy        => busyTx,
        tx          => tx
    );

    -- Receiver
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
        data        => dataRx,
        busy        => busyRx,
        err         => err,
        rx          => rx
    );

    -- Clipping effect
    clipper : entity work.ClippingEffect(logic)
    generic map(
        SAMPLE_WIDTH => SAMPLE_WIDTH,
        GAIN_WIDTH   => GAIN_WIDTH,
        TWO_POW_DIV  => TWO_POW_DIV
    )
    port map(
        reset_n       => reset_n,
        clk           => clk,
        valid_in      => valid_in,
        valid_out     => valid_out,
        sample_in     => sample_in,
        gain_in       => gain_in,
        saturation_in => saturation_in,
        sample_out    => sample_out
    );

end architecture;
