-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    Testbench for the top module of the project.
-- 
-- @ Note: Configuration of project's modules should be set in dedicated `*config.vhd` files.
-- @ Note: Analog stimulus signals for XADC should be defined in the `data/xadc-analog-input.txt` file
-- @ Note: Intergation simulation of the whole project is not convinient, as XADC is configured in the `external mux` mode. It 
--     results in need of generation of a strange analog-stimulus file where a single channel is used to set value of all 9 parameters
--     of the effect's chain.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;
use work.uart.all;
use work.config.all;
use work.transreceiver_config.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity TopTb is
    generic(

        -- ============================================= System parameters ============================================== --

        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;
        
        -- --------------------- Input signal's parameters --------------------- --

        
        -- Type of the input wave (available: [sin/sin_rand])
        INPUT_TYPE : String := "sin";

        -- Frequency of the input signal 
        INPUT_FREQ_HZ : Natural := 440;
        -- Amplitude of the input wave in normalized range <0; 1>
        INPUT_AMPLITUDE : Real := 0.6;
        -- Sampling frequency of the input signal
        INPUT_SAMPLING_FREQ_HZ : Positive := 44_100;

        -- Mean of the gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_MEAN : Real := 0.0;
        -- Standard deviation gaussian distribution summed with the sin wave in normalized range <0;1> (1 is max sample value)
        INPUT_RAND_STD_DEV : Real := 0.02;


        -- ============================================== Effects' setup ================================================ --

        -- -------------------------------------------------------------------- --
        -- `enable` signals of all effects can be configured to be toggled in
        -- a PWM manner with the constant frequency and '1'/'0'-times ratio.
        -- If no toggling is required, corresponding frequency should be set
        -- to '0'. If *_PWM parameter is set to <= 0.0, the effect will be disabled.
        -- For values != 0, effect will be enabled.
        --
        -- Also the phase shift of the signal can be defined in the normalized
        -- range <0,1>
        -- -------------------------------------------------------------------- --

        -- Frequency of the PWM wave controlling `enable` pin of the clipping effect
        CLIPPING_ENABLE_PWM_FREQ_HZ : Natural := 0;
        -- Width of the PWM pulse (in <0,1> range)
        CLIPPING_ENABLE_PWM_WIDTH : Real := 0.0;
        -- Phase shift of the PWM pulse (in <0,1> range)
        CLIPPING_ENABLE_PWM_PHASE_SHIFT : Real := 0.0;

        -- Frequency of the PWM wave controlling `enable` pin of the tremolo effect
        TREMOLO_ENABLE_PWM_FREQ_HZ : Natural := 0;
        -- Width of the PWM pulse (in <0,1> range)
        TREMOLO_ENABLE_PWM_WIDTH : Real := 1.0;
        -- Phase shift of the PWM pulse (in <0,1> range)
        TREMOLO_ENABLE_PWM_PHASE_SHIFT : Real := 0.0;

        -- Frequency of the PWM wave controlling `enable` pin of the delay effect
        DELAY_ENABLE_PWM_FREQ_HZ : Natural := 0;
        -- Width of the PWM pulse (in <0,1> range)
        DELAY_ENABLE_PWM_WIDTH : Real := 0.0;
        -- Phase shift of the PWM pulse (in <0,1> range)
        DELAY_ENABLE_PWM_PHASE_SHIFT : Real := 0.0;

        -- Frequency of the PWM wave controlling `enable` pin of the flanger effect
        FLANGER_ENABLE_PWM_FREQ_HZ : Natural := 0;
        -- Width of the PWM pulse (in <0,1> range)
        FLANGER_ENABLE_PWM_WIDTH : Real := 0.0;
        -- Phase shift of the PWM pulse (in <0,1> range)
        FLANGER_ENABLE_PWM_PHASE_SHIFT : Real := 0.0

    );
end entity TopTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of TopTb is

        -- Number of bytes in a single sample
        constant BYTES_IN_SAMPLE : Natural := CONFIG_SAMPLE_WIDTH / CONFIG_TRANSRECEIVER_BYTE_SIZE;

        -- Reset signal (asynchronous)
        signal reset_n : Std_logic;
        -- System clock
        signal clk : Std_logic;

        -- Input signal being transmitter withi serial interface
        signal sample_in : Signed(CONFIG_SAMPLE_WIDTH - 1 downto 0) := (others => '0');
        -- Output signal being received within serial interface
        signal sample_out : Signed(CONFIG_SAMPLE_WIDTH - 1 downto 0) := (others => '0');

        -- Select signal for external MUX
        signal mux_sel_out : Std_logic_vector(3 downto 0);

        -- ====================== Effect's `enable` signals ===================== --

        -- Enable input (active high)
        signal clipping_enable_in : Std_logic;
        -- Enable input (active high)
        signal tremolo_enable_in : Std_logic;

        -- Enable input (active high)
        signal delay_enable_in : Std_logic;
        -- Enable input (active high)
        signal flanger_enable_in : Std_logic;

        -- ============================= Serial lines =========================== --

        -- Serial input line
        signal rx : Std_logic := '0';
        -- Serial output line
        signal tx : Std_logic  := '0';
        -- Error output from the samples' receiver
        signal err : UartErrors;

begin

    -- =================================================================================
    -- Common effects' benchtable
    -- =================================================================================
    
    -- Instance of the common features regarding guitar effects' testing
    pipeTestbenchInstance: entity work.SignalGenerator(logic)
    generic map (
        SYS_CLK_HZ             => CONFIG_SYS_CLK_HZ,
        SYS_RESET_TICKS        => SYS_RESET_TICKS,
        SAMPLE_WIDTH           => CONFIG_SAMPLE_WIDTH,
        INPUT_TYPE             => INPUT_TYPE,
        INPUT_FREQ_HZ          => INPUT_FREQ_HZ,
        INPUT_AMPLITUDE        => INPUT_AMPLITUDE,
        INPUT_RAND_MEAN        => INPUT_RAND_MEAN,
        INPUT_RAND_STD_DEV     => INPUT_RAND_STD_DEV
    )
    port map (
        reset_n   => reset_n,
        clk       => clk,
        sample_in => sample_in
    );

    -- =================================================================================
    -- Module's instance
    -- =================================================================================

    -- Instance of the effects pipe module
    top_inst: entity work.Top
    port map (
        reset_n            => reset_n,
        clk                => clk,
        clipping_enable_in => clipping_enable_in,
        tremolo_enable_in  => tremolo_enable_in,
        delay_enable_in    => delay_enable_in,
        flanger_enable_in  => flanger_enable_in,
        anal_in_p          => '0',
        anal_in_n          => '0',
        mux_sel_out        => mux_sel_out,
        rx                 => rx,
        tx                 => tx
    );

    -- =================================================================================
    -- Samples' transmission
    -- =================================================================================

    -- Process transmitting input samples with constant (sampling) frequency
    process is

        -- Sample to be transmitted
        variable sample_to_transmit : Std_logic_vector(CONFIG_SAMPLE_WIDTH - 1 downto 0);
        -- Buffer for byte to be transmitted
        variable byte_to_transmit : std_logic_vector(CONFIG_TRANSRECEIVER_BYTE_SIZE - 1 downto 0);
        -- Bytes transmitted
        variable num_bytes_transmitted : Natural range 0 to BYTES_IN_SAMPLE;
        -- Time stamp of the next sample to be transmitted
        variable next_sample_time : time;

    begin

        -- Zero data buffers
        sample_to_transmit := (others=>'0');
        byte_to_transmit := (others => '0');
        num_bytes_transmitted := BYTES_IN_SAMPLE;

        -- Wait for end of reset state
        wait until reset_n = '1';

        -- Set time of the next sample
        next_sample_time := now;

        -- Start transmitting loop
        loop

            -- Check whether all bytes was transmitted
            if(num_bytes_transmitted = BYTES_IN_SAMPLE) then

                -- Reset counter of received byte
                num_bytes_transmitted := 0;

                -- Assert that sampling frequency is not greater than transmission's time
                assert(next_sample_time >= now)
                    report
                        "[TopTestbench] Time of sample's transmission is higher than sampling perio!"
                severity error;

                -- Wait a few cycle before sending nex samples
                wait for next_sample_time - now;

                -- Sample current value of the input signal
                sample_to_transmit := Std_logic_vector(sample_in);
                -- Set time of the next sample
                next_sample_time := now + 1 sec / INPUT_SAMPLING_FREQ_HZ;

            else

                -- Select byte to be transmitted
                byte_to_transmit := sample_to_transmit(
                    (num_bytes_transmitted + 1) * CONFIG_TRANSRECEIVER_BYTE_SIZE - 1 downto 
                    num_bytes_transmitted * CONFIG_TRANSRECEIVER_BYTE_SIZE
                );

                -- Transmit serial byte
                uart_tx_tb(
                    CONFIG_TRANSRECEIVER_BAUD_RATE,
                    CONFIG_TRANSRECEIVER_PARITY_USED,
                    CONFIG_TRANSRECEIVER_PARITY_TYPE,
                    CONFIG_TRANSRECEIVER_STOP_BITS,
                    CONFIG_TRANSRECEIVER_SIGNAL_NEGATION,
                    CONFIG_TRANSRECEIVER_DATA_NEGATION,
                    byte_to_transmit,
                    rx
                );

                -- Increment number of transmitted bytes
                num_bytes_transmitted := num_bytes_transmitted + 1;

            end if;

        end loop;

    end process;

    -- =================================================================================
    -- Samples' reception
    -- =================================================================================

    -- Error checking
    process is

        -- Buffer for received sample
        variable sample_received : Std_logic_vector(CONFIG_SAMPLE_WIDTH - 1 downto 0) := (others => '0');
        -- Number of received bytes
        variable num_bytes_received : Natural range 0 to BYTES_IN_SAMPLE := 0;
        -- Buffer for received byte
        variable byte_received : std_logic_vector(CONFIG_TRANSRECEIVER_BYTE_SIZE - 1 downto 0) := (others => '0');

    begin

        -- Reset received word
        sample_received := (others => '0');
        byte_received := (others => '0');
        -- Reset number of received bytes
        num_bytes_received := 0;
        -- Reset reception errors
        err <= (
            start_err  => '0',
            stop_err   => '0',
            parity_err => '0'
        );

        loop

            -- Check whether all bytes was received
            if(num_bytes_received < BYTES_IN_SAMPLE) then

                -- Receive serial byte
                uart_rx_tb(
                    CONFIG_TRANSRECEIVER_BAUD_RATE,
                    CONFIG_TRANSRECEIVER_PARITY_USED,
                    CONFIG_TRANSRECEIVER_PARITY_TYPE,
                    CONFIG_TRANSRECEIVER_STOP_BITS,
                    CONFIG_TRANSRECEIVER_SIGNAL_NEGATION,
                    CONFIG_TRANSRECEIVER_DATA_NEGATION,
                    tx,
                    err,
                    byte_received
                );

                -- Put received byte into sample buffer
                sample_received(
                    (num_bytes_received + 1) * CONFIG_TRANSRECEIVER_BYTE_SIZE - 1 downto 
                    num_bytes_received * CONFIG_TRANSRECEIVER_BYTE_SIZE
                ) := byte_received;

                -- Increment number of received bytes
                num_bytes_received := num_bytes_received + 1;

            -- If all bytes was received
            else 

                -- Reset counter of received byte
                num_bytes_received := 0;
                -- Copy received sample from the bufer
                sample_out <= Signed(sample_received);
                -- Wait for the next rising edge of the system clk after reception
                wait until rising_edge(clk);

            end if;

        end loop;
    
    end process;

    -- =================================================================================
    -- `Enable` signal's generation
    -- =================================================================================

    -- Control clipping effect's `enabel` signal
    generate_pwm(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => CLIPPING_ENABLE_PWM_FREQ_HZ,
        PHASE_SHIFT  => CLIPPING_ENABLE_PWM_PHASE_SHIFT,
        PWM_WIDTH    => CLIPPING_ENABLE_PWM_WIDTH,
        reset_n      => reset_n,
        clk          => clk,
        pwm          => clipping_enable_in
    );

    -- Control tremolo effect's `enabel` signal
    generate_pwm(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => TREMOLO_ENABLE_PWM_FREQ_HZ,
        PHASE_SHIFT  => TREMOLO_ENABLE_PWM_PHASE_SHIFT,
        PWM_WIDTH    => TREMOLO_ENABLE_PWM_WIDTH,
        reset_n      => reset_n,
        clk          => clk,
        pwm          => tremolo_enable_in
    );

    -- Control delay effect's `enabel` signal
    generate_pwm(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => DELAY_ENABLE_PWM_FREQ_HZ,
        PHASE_SHIFT  => DELAY_ENABLE_PWM_PHASE_SHIFT,
        PWM_WIDTH    => DELAY_ENABLE_PWM_WIDTH,
        reset_n      => reset_n,
        clk          => clk,
        pwm          => delay_enable_in
    );

    -- Control flanger effect's `enabel` signal
    generate_pwm(
        SYS_CLK_HZ   => CONFIG_SYS_CLK_HZ,
        FREQUENCY_HZ => FLANGER_ENABLE_PWM_FREQ_HZ,
        PHASE_SHIFT  => FLANGER_ENABLE_PWM_PHASE_SHIFT,
        PWM_WIDTH    => FLANGER_ENABLE_PWM_WIDTH,
        reset_n      => reset_n,
        clk          => clk,
        pwm          => flanger_enable_in
    );
    
end architecture logic;
