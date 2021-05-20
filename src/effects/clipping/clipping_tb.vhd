-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    Clipping effect's testbench 
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity ClippingEffectTb is
    generic(
        -- System clock frequency
        SYS_CLK_HZ : Positive := 200_000_000;        
        -- Initial system reset time (in system clock's cycles)
        SYS_RESET_TICKS : Positive := 10;

        -- Width of the input sample
        SAMPLE_WIDTH : Positive range 1 to 32 := 16;
        -- Width of the gain input (gain's width must be smaller than sample's width)
        GAIN_WIDTH : Positive range 1 to 31 := 12;
        -- Index of the 2's power that the multiplication's result is divided by before saturation
        TWO_POW_DIV : Natural range 0 to 31 := 11;
        
        -- Frequency of the input wave
        SAMPLE_FREQU_HZ : Positive := 44_100;
        -- Amplitude of the input wave in normalized range (0; 1>
        SAMPLE_AMPLITUDE : Real := 0.5;
        
        -- Frequency of the input wave
        GAIN_FREQU_HZ : Positive := 44_100;
        -- Phase shift of the gain wave with respsect to sample wave
        GAIN_PHAZE_SHIFT : Real := 0.0;
        -- Amplitude of the gain input wave in normalized range (0; 1>
        GAIN_AMPLITUDE : Real := 0.75;

        -- Amplitudes of clips in normalized range (0; 1>
        SATURATION_AMPLITUDE : Real := 0.75;
        -- Time between subsequent changes in saturation value
        SATURATION_TOGGLE_HZ : Positive := 22_050;

        -- Time between end of conversion and start of the next conversion
        CONVERSIONS_GAP : Time := 5 ns
    );
end entity ClippingEffectTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of ClippingEffectTb is

    -- Peiord of the system clock
    constant CLK_PERIOD : Time := 1 sec / SYS_CLK_HZ;    
    
    -- Reset signal
    signal reset_n : Std_logic := '0';
    -- System clock
    signal clk : Std_logic := '0';

    -- ====================== Module's interface ====================== --

    -- Input values to the unsigned procedures
    signal sample_in, sample_out :  Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');
    -- Signal for new sample on input (rising-edge-active)
    signal valid_in : std_logic := '0';
    -- Signal for new sample on output (rising-edge-active)
    signal valid_out : std_logic;
    -- Module's gain
    signal gain_in : Unsigned(GAIN_WIDTH - 1 downto 0);
    -- Module's saturation
    signal saturation_in : Unsigned(SAMPLE_WIDTH - 2 downto 0);

    -- ===================== Verification signals ===================== --

    -- Desired value of gain and sample multiplication  (with 2-power division)
    signal mul_out_expected : Signed(SAMPLE_WIDTH + GAIN_WIDTH - TWO_POW_DIV downto 0) := (others => '0');
    -- Desired value of sample 
    signal sample_out_expected : Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');
    -- `Valid output` flag tracking whether module works fine
    signal sample_out_valid : std_logic := '0';

    -- ====================== Auxiliary signals ====================== --

    -- Real-converted input signal
    signal sample_in_tmp : Real;
    -- Real-converted gain signal
    signal gain_in_tmp : Real;
    -- Real-converted saturation signal
    signal saturation_in_tmp : Real;

begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Clock signal
    clock_tb(CLK_PERIOD, clk);

    -- Reset signal
    reset_tb(SYS_RESET_TICKS * CLK_PERIOD, reset_n);

    -- =================================================================================
    -- Input signals' generation (all signals changed at falling edge to not interfere
    -- with module)
    -- =================================================================================

    -- Generate input signal
    sample_in <= to_signed(integer(sample_in_tmp), SAMPLE_WIDTH);
    generate_sin(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => SAMPLE_FREQU_HZ,
        PHASE_SHIFT  => 0.0,
        AMPLITUDE    => Real(SAMPLE_AMPLITUDE) * (2**(SAMPLE_WIDTH - 1) - 1),
        OFFSET       => 0.0,
        reset_n      => reset_n,
        clk          => clk,
        wave         => sample_in_tmp
    );


    -- Generate gain signal
    gain_in <= to_unsigned(Natural(gain_in_tmp), GAIN_WIDTH);
    generate_sin(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => SAMPLE_FREQU_HZ,
        PHASE_SHIFT  => GAIN_PHAZE_SHIFT,
        AMPLITUDE    => Real(GAIN_AMPLITUDE) * (2**(GAIN_WIDTH - 1) - 1),
        OFFSET       => Real(GAIN_AMPLITUDE) * (2**(GAIN_WIDTH - 1) - 1),
        reset_n      => reset_n,
        clk          => clk,
        wave         => gain_in_tmp
    );

    -- Generate saturation signal
    saturation_in <= to_unsigned(Natural(saturation_in_tmp), SAMPLE_WIDTH - 1);
    generate_random_stairs(
        SYS_CLK_HZ   => SYS_CLK_HZ,
        FREQUENCY_HZ => SAMPLE_FREQU_HZ,
        MIN_VAL      => 0.0,
        MAX_VAL      => Real(Integer(SATURATION_AMPLITUDE * (2**(SAMPLE_WIDTH - 1) - 1))),
        reset_n      => reset_n,
        clk          => clk,
        wave         => saturation_in_tmp
    );

    -- `valid_in` generator
    process is
    begin

        -- Reset condition
        valid_in <= '0';

        -- Wait for end of reset
        wait until reset_n = '1';

        -- Update `valid_in` in predefined sequence
        loop

            -- Wait for rising edge
            wait until rising_edge(clk);

            -- Inform about new sample
            valid_in <= '1';
            -- Wait a cycle to pull `vali_in` low
            wait for CLK_PERIOD;
            valid_in <= '0';

            -- Wait for the end of conversion
            wait until falling_edge(valid_out);

            -- Wait a gap time before triggering the next cycle
            wait for CONVERSIONS_GAP;

        end loop;
    end process;

    -- =================================================================================
    -- Module's instance
    -- =================================================================================

    -- Instance of the clipping effect's module
    clippingEffectInstance : entity work.ClippingEffect(logic)
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

    -- =================================================================================
    -- Procedure's validation
    -- =================================================================================

    -- Validate Module
    process is

        -- Sample buffer latched on rising edge of the  `valid_in` signal
        variable sample_buf : Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');
        -- Sample buffer latched on rising edge of the  `valid_in` signal
        variable gain_buf : Unsigned(GAIN_WIDTH - 1 downto 0) := (others => '0');
        -- Sample buffer latched on rising edge of the  `valid_in` signal
        variable saturation_buf : Unsigned(SAMPLE_WIDTH - 2 downto 0) := (others => '0');
        
        -- Local result of multiplication
        variable result : Signed(SAMPLE_WIDTH + GAIN_WIDTH - TWO_POW_DIV downto 0) := (others => '0');
        -- Local copy of expected output of the block
        variable sample_out_expected_var : Signed(SAMPLE_WIDTH - 1 downto 0) := (others => '0');

        -- High limit for the output value
        variable high_limit : Signed(SAMPLE_WIDTH - 1 downto 0);
        -- Low limit for the output value
        variable low_limit : Signed(SAMPLE_WIDTH - 1 downto 0);

    begin

        -- Keep output signals low
        sample_out_expected <= (others => '0');
        mul_out_expected <= (others => '0');
        sample_out_valid <= '0';
        -- Keep interal buffers low
        sample_buf := (others => '0');
        gain_buf := (others => '0');
        saturation_buf := (others => '0');
        result := (others => '0');
        sample_out_expected_var := (others => '0');
        high_limit := (others => '0');
        low_limit := (others => '0');

        -- Wait for end of reset
        wait until reset_n = '1';

        -- Validate module's output in loop
        loop

            -- Wait on the next rising edge after `valid_in` is pulled high
            wait until valid_in = '1';
            wait for CLK_PERIOD;
            -- Sample input data
            sample_buf := sample_in;
            gain_buf := gain_in;
            saturation_buf := saturation_in;

            -- Wait on the nex clk's falling edge after `valid_out` pulled high
            wait until valid_out = '1';
            wait until falling_edge(clk);
            
            -- Compute multiplication with division
            result := resize(sample_buf * Signed(resize(gain_buf, GAIN_WIDTH + 1)) / 2**TWO_POW_DIV, result'length);
            -- Make multiplication's result visible to the simulation
            mul_out_expected <= result;
            -- Compute saturation limits
            high_limit :=  Signed(resize(saturation_buf, SAMPLE_WIDTH));
            low_limit  := -Signed(resize(saturation_buf, SAMPLE_WIDTH));
            -- Compute expected output
            if(result > resize(high_limit, result'length)) then
                sample_out_expected_var := high_limit;
            elsif(result < resize(low_limit, result'length)) then
                sample_out_expected_var := low_limit;
            else
                sample_out_expected_var := resize(result, SAMPLE_WIDTH);
            end if;
            -- Make expected output visible
            sample_out_expected <= sample_out_expected_var;
            -- Check whether output matches desired one
            if(sample_out /= sample_out_expected_var) then
                sample_out_valid <= '0';
            else
                sample_out_valid <= '1';
            end if;
            
        end loop;

    end process;

end architecture logic;
