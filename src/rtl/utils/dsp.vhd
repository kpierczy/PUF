-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-19 16:17:31
-- @ Modified time: 2021-05-19 16:17:33
-- @ Description: 
--    
--    Implementation of the basic DSP blocks
--    
-- ===================================================================================================================================

-- ===================================================================================================================================
-- ------------------------------------------------------- Unsigned Summation --------------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sumUnsignedSat is
    port(
        -- Inputs
        a_in, b_in : in  Unsigned;
        -- Output
        result_out : out Unsigned;
        -- Error flag (overflow)
        err_out : out Std_logic
    );
end entity;

architecture logic of sumUnsignedSat is

    -- Max unsigned value with DATA_WIDTH bits
    constant MAX_VALUE : Unsigned(result_out'length - 1 downto 0) := (others => '1');

    -- Result of the summation
    signal result : Unsigned(maximum(a_in'length, b_in'length) downto 0);

begin

    -- Sum inputs
    result <= resize(a_in, result'length) + resize(b_in, result'length);

    -- Saturation logic
    process(result) is
    begin

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

    end process;

end architecture logic;

-- ===================================================================================================================================
-- -------------------------------------------------------- Signed Summation ---------------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sumSignedSat is
    port(
        -- Inputs
        a_in, b_in : in  Signed;
        -- Output
        result_out : out Signed;
        -- Error flag (overflow)
        err_out : out Std_logic
    );
end entity sumSignedSat;

architecture logic of sumSignedSat is

    -- Max signed value with DATA_WIDTH bits
    constant MAX_VALUE : Signed(result_out'length - 1 downto 0) :=
        (result_out'length - 1 => '0', others => '1');
    -- Min signed value with DATA_WIDTH bits
    constant MIN_VALUE : Signed(result_out'length - 1 downto 0) :=
        (result_out'length - 1 => '1', others => '0');

    -- Result of the summation
    signal result : Signed(maximum(a_in'length, b_in'length) downto 0);

begin

    -- Sum inputs
    result <= resize(a_in, result'length) + resize(b_in, result'length);

    -- Saturation logic
    process(result) is
    begin

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

    end process;

end architecture logic;

-- ===================================================================================================================================
-- ----------------------------------------------------- Unsigned Multiplication -----------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mulUnsignedSat is
    generic(
        -- Number of bits to be shifted right after multiplication
        TWO_POW_DIV : in Natural := 0
    );
    port(
        -- Inputs
        a_in, b_in : in Unsigned;
        -- Output
        result_out : out Unsigned;
        -- Error flag (overflow)
        err_out : out Std_logic
    );
end entity mulUnsignedSat;

architecture logic of mulUnsignedSat is

    -- Max value on output
    constant MAX_VALUE : Unsigned(result_out'length - 1 downto 0) := (others => '1');

    -- Result of the multiplication
    signal result : Unsigned(a_in'length + b_in'length - TWO_POW_DIV - 1 downto 0);

begin

    -- Multiply inputs
    result <= resize(a_in * b_in / to_unsigned(Natural(2**TWO_POW_DIV), a_in'length + b_in'length), result'length);

    -- Saturation logic
    process(result) is
    begin

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

    end process;

end architecture logic;

-- ===================================================================================================================================
-- ------------------------------------------------------ Signed Multiplication ------------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mulSignedSat is
    generic(
        -- Number of bits to be shifted right after multiplication
        TWO_POW_DIV : in Natural := 0
    );
    port(
        -- Inputs
        a_in, b_in : in  Signed;
        -- Output
        result_out : out Signed;
        -- Error flag (overflow)
        err_out : out Std_logic
    );
end entity mulSignedSat;

architecture logic of mulSignedSat is

    -- Max signed value with DATA_WIDTH bits
    constant MAX_VALUE : Signed(result_out'length - 1 downto 0) :=
        (result_out'length - 1 => '0', others => '1');
    -- Min signed value with DATA_WIDTH bits
    constant MIN_VALUE : Signed(result_out'length - 1 downto 0) :=
        (result_out'length - 1 => '1', others => '0');

    -- Result of the multiplication
    signal result : Signed(a_in'length + b_in'length - TWO_POW_DIV - 1 downto 0);

begin

    -- Multiply inputs
    result <= resize(a_in * b_in / to_signed(Integer(2**TWO_POW_DIV), a_in'length + b_in'length), result'length);

    -- Saturation logic
    process(result) is
    begin

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

    end process;

end architecture logic;
