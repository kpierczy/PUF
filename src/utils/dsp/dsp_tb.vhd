-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 17:50:15
-- @ Modified time: 2021-05-19 18:40:34
-- @ Description: 
--    
--    DSP package's testbench 
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.dsp.all;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity DspTb is
    generic(
        -- Data width
        DATA_WIDTH : Positive := 8;
        -- Min time between random toggles of the input data
        MIN_DATA_TOGGLE_TIME : Time := 10 ns;
        -- Max time between random toggles of the input data
        MAX_DATA_TOGGLE_TIME : Time := 1000 ns
    );
end entity DspTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of DspTb is

    -- Input values to the unsigned procedures
    signal a_unsigned, b_unsigned :  Unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');
    -- Input values to the signed procedures
    signal a_signed, b_signed :  Signed(DATA_WIDTH - 1 downto 0) := (others => '0');

    -- Result of unsigned summation
    signal sum_unsigned : Unsigned(DATA_WIDTH - 1 downto 0);
    -- Expected result of unsigned summation
    signal sum_unsigned_expected : Unsigned(sum_unsigned'length - 1 downto 0);
    -- Error flag of unsigned summation
    signal sum_unsigned_err : std_logic;
    -- `Valid output` flag for unsigned summation
    signal sum_unsigned_valid : std_logic;

    -- Result of signed summation
    signal sum_signed : Signed(DATA_WIDTH - 1 downto 0);
    -- Expected result of signed summation
    signal sum_signed_expected : Signed(sum_signed'length - 1 downto 0);
    -- Error flag of signed summation
    signal sum_signed_err : std_logic;
    -- `Valid output` flag for signed summation
    signal sum_signed_valid : std_logic;

    -- Result of unsigned multiplication
    signal mul_unsigned : Unsigned(DATA_WIDTH * 2 - 2 downto 0);
    -- Expected result of unsigned multiplication
    signal mul_unsigned_expected : Unsigned(mul_unsigned'length - 1 downto 0);
    -- Error flag of unsigned multiplication
    signal mul_unsigned_err : std_logic;
    -- `Valid output` flag for unsigned multiplication
    signal mul_unsigned_valid : std_logic;

    -- Result of signed multiplication
    signal mul_signed : Signed(DATA_WIDTH - 1 downto 0);
    -- Expected result of signed multiplication
    signal mul_signed_expected : Signed(mul_signed'length - 1 downto 0);
    -- Error flag of signed multiplication
    signal mul_signed_err : std_logic;
    -- `Valid output` flag for signed multiplication
    signal mul_signed_valid : std_logic;

begin

    -- =================================================================================
    -- Input signals' generation
    -- =================================================================================

    -- `a_unsigned` generation
    process is
    begin
        a_unsigned <= Unsigned(rand_logic_vector(DATA_WIDTH));
        wait for rand_time(MIN_DATA_TOGGLE_TIME, MAX_DATA_TOGGLE_TIME);
    end process;


    -- `b_unsigned` generation
    process is
    begin
        b_unsigned <= Unsigned(rand_logic_vector(DATA_WIDTH));
        wait for rand_time(MIN_DATA_TOGGLE_TIME, MAX_DATA_TOGGLE_TIME);
    end process;


    -- `a_signed` generation
    process is
    begin
        a_signed <= Signed(rand_logic_vector(DATA_WIDTH));
        wait for rand_time(MIN_DATA_TOGGLE_TIME, MAX_DATA_TOGGLE_TIME);
    end process;


    -- `b_signed` generation
    process is
    begin
        b_signed <= Signed(rand_logic_vector(DATA_WIDTH));
        wait for rand_time(MIN_DATA_TOGGLE_TIME, MAX_DATA_TOGGLE_TIME);
    end process;


    -- =================================================================================
    -- Procedure's instances
    -- =================================================================================

    -- Summation of two unsigned numbers with saturation
    sumUnsignedSat(
        a_in       => a_unsigned,
        b_in       => b_unsigned,
        result_out => sum_unsigned,
        err_out    => sum_unsigned_err
    );

    -- Summation of two signed numbers with saturation
    sumSignedSat(
        a_in       => a_signed,
        b_in       => b_signed,
        result_out => sum_signed,
        err_out    => sum_signed_err
    );

    -- Multiplication of two unsigned numbers with saturation
    mulUnsignedSat(
        a_in       => a_unsigned,
        b_in       => b_unsigned,
        result_out => mul_unsigned,
        err_out    => mul_unsigned_err
    );

    -- Multiplication of two signed numbers with saturation
    mulSignedSat(
        a_in       => a_signed,
        b_in       => b_signed,
        result_out => mul_signed,
        err_out    => mul_signed_err
    );

    -- =================================================================================
    -- Procedure's validation
    -- =================================================================================

    -- Validate unsigned summation with saturation
    process(sum_unsigned) is
        -- Length of the result
        constant RESULT_WIDTH : Positive := sum_unsigned_expected'length;
        -- Max unsigned value with RESULT_WIDTH bits
        constant MAX_VALUE : Unsigned(RESULT_WIDTH - 1 downto 0) := (others => '1');
        -- Local copy of expected result of unsigned summation
        variable sum_unsigned_expected_var : Unsigned(RESULT_WIDTH - 1 downto 0);
    begin
        -- Establish expected sum value
        if(resize(a_unsigned, RESULT_WIDTH + 1) + resize(b_unsigned, RESULT_WIDTH + 1) > MAX_VALUE) then
            sum_unsigned_expected_var := MAX_VALUE;
        else
            sum_unsigned_expected_var := a_unsigned + b_unsigned;
        end if;
        -- Make expected value observable
        sum_unsigned_expected <= sum_unsigned_expected_var;
        -- Check if procedure's output is as expected
        if(sum_unsigned = sum_unsigned_expected_var) then
            sum_unsigned_valid <= '1';
        else
            sum_unsigned_valid <= '0';
        end if;
    end process;


    -- Validate signed summation with saturation
    process(sum_signed) is
        -- Length of the result
        constant RESULT_WIDTH : Positive := sum_signed_expected'length;
        -- Max signed value with RESULT_WIDTH bits
        constant MAX_VALUE : Signed(RESULT_WIDTH - 1 downto 0) := (
            RESULT_WIDTH - 1 => '0', others => '1');
        -- Max signed value with RESULT_WIDTH bits
        constant MIN_VALUE : Signed(RESULT_WIDTH - 1 downto 0) := (
            RESULT_WIDTH - 1 => '1', others => '0');
        -- Local copy of expected result of signed summation
        variable sum_signed_expected_var : Signed(RESULT_WIDTH - 1 downto 0);
    begin
        -- Establish expected sum value
        if(resize(a_signed, RESULT_WIDTH + 1) + resize(b_signed, RESULT_WIDTH + 1) > MAX_VALUE) then
            sum_signed_expected_var := MAX_VALUE;
        elsif(resize(a_signed, RESULT_WIDTH + 1) + resize(b_signed, RESULT_WIDTH + 1) < MIN_VALUE) then
            sum_signed_expected_var := MIN_VALUE;        
        else
            sum_signed_expected_var := a_signed + b_signed;
        end if;
        -- Make expected value observable
        sum_signed_expected <= sum_signed_expected_var;
        -- Check if procedure's output is as expected
        if(sum_signed = sum_signed_expected_var) then
            sum_signed_valid <= '1';
        else
            sum_signed_valid <= '0';
        end if;
    end process;


    -- Validate unsigned multiplication with saturation
    process(mul_unsigned) is
        -- Length of the result
        constant RESULT_WIDTH : Positive := mul_unsigned_expected'length;
        -- Max unsigned value with RESULT_WIDTH bits
        constant MAX_VALUE : Unsigned(RESULT_WIDTH - 1 downto 0) := (others => '1');
        -- Local copy of expected result of unsigned multiplication
        variable mul_unsigned_expected_var : Unsigned(RESULT_WIDTH - 1 downto 0);
    begin
        -- Establish expected multiplication's value
        if(resize(a_unsigned, RESULT_WIDTH * 2) * resize(b_unsigned, RESULT_WIDTH * 2) > MAX_VALUE) then
            mul_unsigned_expected_var := MAX_VALUE;
        else
            mul_unsigned_expected_var := resize(a_unsigned * b_unsigned, RESULT_WIDTH);
        end if;
        -- Make expected value observable
        mul_unsigned_expected <= mul_unsigned_expected_var;
        -- Check if procedure's output is as expected
        if(mul_unsigned = mul_unsigned_expected_var) then
            mul_unsigned_valid <= '1';
        else
            mul_unsigned_valid <= '0';
        end if;
    end process;


    -- Validate signed multiplication with saturation
    process(mul_signed) is
        -- Length of the result
        constant RESULT_WIDTH : Positive := mul_signed_expected'length;
        -- Max signed value with RESULT_WIDTH bits
        constant MAX_VALUE : Signed(RESULT_WIDTH - 1 downto 0) := (
            RESULT_WIDTH - 1 => '0', others => '1');
        -- Max signed value with RESULT_WIDTH bits
        constant MIN_VALUE : Signed(RESULT_WIDTH - 1 downto 0) := (
            RESULT_WIDTH - 1 => '1', others => '0');
        -- Local copy of expected result of signed multiplication
        variable mul_signed_expected_var : Signed(RESULT_WIDTH - 1 downto 0);
    begin
        -- Establish expected multiplication's value
        if(resize(a_signed, RESULT_WIDTH * 2) * resize(b_signed, RESULT_WIDTH * 2) > MAX_VALUE) then
            mul_signed_expected_var := MAX_VALUE;
        elsif(resize(a_signed, RESULT_WIDTH * 2) * resize(b_signed, RESULT_WIDTH * 2) < MIN_VALUE) then
            mul_signed_expected_var := MIN_VALUE;        
        else
            mul_signed_expected_var := resize(a_signed * b_signed, RESULT_WIDTH);
        end if;
        -- Make expected value observable
        mul_signed_expected <= mul_signed_expected_var;
        -- Check if procedure's output is as expected
        if(mul_signed = mul_signed_expected_var) then
            mul_signed_valid <= '1';
        else
            mul_signed_valid <= '0';
        end if;
    end process;


end architecture logic;