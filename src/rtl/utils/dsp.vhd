-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 16:17:31
-- @ Modified time: 2021-05-19 16:17:33
-- @ Description: 
--    
--    Implementation of the basic DSP blocks
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

-- ------------------------------------------------------------ Package --------------------------------------------------------------

package dsp is

    -- ===================================================================
    -- ------------------------ Saturation blocks ------------------------
    -- ===================================================================

    -- Summation of two unsigned numbers with saturation
    procedure sumUnsignedSat(
        -- Inputs
        signal a_in, b_in : in  Unsigned;
        -- Output
        signal result_out : out Unsigned;
        -- Error flag (overflow)
        signal err_out : out Std_logic
    );

    -- Summation of two signed numbers with saturation
    procedure sumSignedSat(
        -- Inputs
        signal a_in, b_in : in  Signed;
        -- Output
        signal result_out : out Signed;
        -- Error flag (overflow)
        signal err_out : out Std_logic
    );

    -- Multiplication of two unsigned numbers with saturation
    procedure mulUnsignedSat( 
        -- Number of bits to be shifted right after multiplication
        constant TWO_POW_DIV : in Natural := 0;
        -- Inputs
        signal a_in, b_in : in  Unsigned;
        -- Output
        signal result_out : out Unsigned;
        -- Error flag (overflow)
        signal err_out : out Std_logic
    );

    -- Multiplication of two signed numbers with saturation
    procedure mulSignedSat(
        -- Number of bits to be shifted right after multiplication
        constant TWO_POW_DIV : in Natural := 0;
        -- Inputs
        signal a_in, b_in : in  Signed;
        -- Output
        signal result_out : out Signed;
        -- Error flag (overflow)
        signal err_out : out Std_logic
    );

end package dsp;

-- -------------------------------------------------------------- Body ---------------------------------------------------------------

package body dsp is

    -- =====================================================================
    -- ----------------------------- Summation -----------------------------
    -- =====================================================================

    -- Summation of two unsigned numbers with saturation
    procedure sumUnsignedSat(
        -- Inputs
        signal a_in, b_in : in  Unsigned;
        -- Output
        signal result_out : out Unsigned;
        -- Error flag (overflow)
        signal err_out : out Std_logic
    ) is

        -- Max unsigned value with DATA_WIDTH bits
        constant MAX_VALUE : Unsigned(result_out'length - 1 downto 0) := (others => '1');

        -- Result of the summation
        variable result : Unsigned(maximum(a_in'length, b_in'length) downto 0);

    begin

        -- Sum inputs
        result := resize(a_in, result'length) + resize(b_in, result'length);

        -- If output is able to hold any result of summation
        if (result_out'length >= result'length) then

            -- Pass result to the output
            result_out <= resize(result, result_out'length);
            -- No error can occur
            err_out <= '0';

        -- If output is not able to hold any result of summation
        else

            -- If overflow occurred
            if(result > MAX_VALUE) then
                -- Set output to max value
                result_out <= MAX_VALUE;
                -- Set error flag
                err_out <= '1';
            else
                -- Pass result to output
                result_out <= result(result_out'length - 1 downto 0);
                -- Set error flag
                err_out <= '1';
            end if;

        end if;

    end procedure;


    -- Summation of two signed numbers with saturation
    procedure sumSignedSat(
        -- Inputs
        signal a_in, b_in : in  Signed;
        -- Output
        signal result_out : out Signed;
        -- Error flag (overflow)
        signal err_out : out Std_logic
    ) is

        -- Max signed value with DATA_WIDTH bits
        constant MAX_VALUE : Signed(result_out'length - 1 downto 0) :=
            (result_out'length - 1 => '0', others => '1');
        -- Min signed value with DATA_WIDTH bits
        constant MIN_VALUE : Signed(result_out'length - 1 downto 0) :=
            (result_out'length - 1 => '1', others => '0');

        -- Result of the summation
        variable result : Signed(maximum(a_in'length, b_in'length) downto 0);

    begin

        -- Sum inputs
        result := resize(a_in, result'length) + resize(b_in, result'length);

        -- If output is able to hold any result of summation
        if (result_out'length >= result'length) then

            -- Pass result to the output (with sign extension)
            result_out<= resize(result, result_out'length);
            -- No error can occur
            err_out <= '0';

        -- If output is not able to hold any result of summation
        else

            -- If overflow occurred
            if(result > MAX_VALUE) then
                -- Set output to max value
                result_out <= MAX_VALUE;
                -- Set error flag
                err_out <= '1';
            -- If underflow occurred
            elsif(result < MIN_VALUE) then
                -- Set output to min value
                result_out <= MIN_VALUE;
                -- Set error flag
                err_out <= '1';
            -- If no error occurred
            else
                -- Pass result to output
                result_out <= result(result_out'length - 1 downto 0);
                -- Clear error flag
                err_out <= '0';
            end if;

        end if;

    end procedure;

    -- -- =====================================================================
    -- -- --------------------------- Multiplication --------------------------
    -- -- =====================================================================

    -- Multiplication of two unsigned numbers with saturation
    procedure mulUnsignedSat(
        -- Number of bits to be shifted right after multiplication
        constant TWO_POW_DIV : in Natural := 0;
        -- Inputs
        signal a_in, b_in : in Unsigned;
        -- Output
        signal result_out : out Unsigned;
        -- Error flag (overflow)
        signal err_out : out Std_logic
    ) is

        -- Max value on output
        constant MAX_VALUE : Unsigned(result_out'length - 1 downto 0) := (others => '1');

        -- Result of the multiplication
        variable result : Unsigned(a_in'length + b_in'length - TWO_POW_DIV - 1 downto 0);

    begin

        -- Multiply inputs
        result := resize(a_in * b_in / 2**TWO_POW_DIV, result'length);

        -- If overflow occurred
        if(result > MAX_VALUE) then
            -- Set output to max value
            result_out <= MAX_VALUE;
            -- Set error flag
            err_out <= '1';
        -- If no error occurred
        else
            -- Pass result to output
            result_out <= result(result_out'length - 1 downto 0);
            -- Clear error flag
            err_out <= '0';
        end if;

    end procedure;


    -- Multiplication of two signed numbers with saturation
    procedure mulSignedSat(
        -- Number of bits to be shifted right after multiplication
        constant TWO_POW_DIV : in Natural := 0;
        -- Inputs
        signal a_in, b_in : in  Signed;
        -- Output
        signal result_out : out Signed;
        -- Error flag (overflow)
        signal err_out : out Std_logic
    ) is

        -- Max signed value with DATA_WIDTH bits
        constant MAX_VALUE : Signed(result_out'length - 1 downto 0) :=
            (result_out'length - 1 => '0', others => '1');
        -- Min signed value with DATA_WIDTH bits
        constant MIN_VALUE : Signed(result_out'length - 1 downto 0) :=
            (result_out'length - 1 => '1', others => '0');

        -- Result of the multiplication
        variable result : Unsigned(a_in'length + b_in'length - TWO_POW_DIV - 1 downto 0);

    begin

        -- Multiply inputs
        result := resize(a_in * b_in / 2**TWO_POW_DIV, result'length);

        -- If overflow occurred
        if(result > MAX_VALUE) then
            -- Set output to max value
            result_out <= MAX_VALUE;
            -- Set error flag
            err_out <= '1';
        -- If overflow occurred
        elsif(result < MIN_VALUE) then
            -- Set output to max value
            result_out <= MIN_VALUE;
            -- Set error flag
            err_out <= '1';
        -- If no error occurred
        else
            -- Pass result to output
            result_out <= result(result_out'length - 1 downto 0);
            -- Clear error flag
            err_out <= '0';
        end if;

    end procedure;

end package body dsp;
