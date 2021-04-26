-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-26 14:09:47
-- @ Modified time: 2021-04-26 14:09:47
-- @ Description: 
--    
--    Implementation of the parallel-to-serial shift register
--    
-- ===================================================================================================================================

-- ===================================================================================================================================
-- A generic shift register with asynchronous parallel input and synchronous serial output. When @in enable is pulled low, the 
-- register's value is equal to the value of the parallel input. On the rising edge of the @in enable, the input is latched and it
-- no longer influences the register's value. Serial output is changed only on the rising edge of the @p in clk input when the @in 
-- enable signal is pulled high.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity ParallelToSerialReg is

    generic(
        -- Width of the register
        REGISTER_WIDTH : Positive := 8;
        -- Fill value for the emptied (shifted) bits
        FILL_STATE : Std_logic := '0'
    );
    port(
        -- Reset signal (active low)
        reset_n : in Std_logic;
        -- Clock signal (shifts register's value is @in enable is high)
        clk : in Std_logic;
        -- Enable signal (active high) (asynchronously latches @in load)
        enable : in Std_logic;
        -- Load value
        in_parallel : in Std_logic_vector(REGISTER_WIDTH - 1 downto 0);
        -- Output bit
        out_bit : out Std_logic
    );

end entity ParallelToSerialReg;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of ParallelToSerialReg is
    
    -- Latched load value
    signal reg : Std_logic_vector(REGISTER_WIDTH - 1 downto 0);

begin

    -- =================================================================================
    -- Registers's logic
    -- =================================================================================

    -- Regsiter's logic
    latch : process (reset_n, in_parallel, enable, clk) is
    begin
        -- Reset condition
        if(reset_n = '0') then
            reg <= (others => '0');
            out_bit <= '0';
        -- Transparent input, when register disabled (latched on enable)
        elsif (enable = '0') then
            reg <= in_parallel;
        -- Shift
        elsif (rising_edge(clk)) then
            -- Output set
            out_bit <= reg(0);
            -- Shift
            reg <= FILL_STATE & reg(REGISTER_WIDTH - 1 downto 1);
        end if;
    end process;

end architecture logic;


-- ===================================================================================================================================
-- A generic shift register with synchronous serial input and asynchronous parallel output. When @in enable is pulled low, the 
-- parallel output is equal to the value of the register. On the rising edge of the @in enable, the output is latched and it
-- no longer reflect the register's value. Serial input is sampled only on the rising edge of the @p in clk input when the @in enable
-- signal is pulled high. 
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity SerialToParallelReg is

    generic(
        -- Width of the register
        REGISTER_WIDTH : Positive := 8
    );
    port(
        -- Reset signal (active low)
        reset_n : in Std_logic;
        -- Clock signal (shifts register's value is @in enable is high)
        clk : in Std_logic;
        -- Enable signal (active high) (asynchronously latches @out out_parallel when pulled high)
        enable : in Std_logic;
        -- Input bit
        in_bit : in Std_logic;
        -- Output parallel value
        out_parallel : out Std_logic_vector(REGISTER_WIDTH - 1 downto 0)
    );

end entity SerialToParallelReg;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of SerialToParallelReg is
    
    -- Latched load value
    signal reg : Std_logic_vector(REGISTER_WIDTH - 1 downto 0);

begin

    -- =================================================================================
    -- Registers's logic
    -- =================================================================================

    -- Regsiter's logic
    latch : process (reset_n, in_bit, enable, clk) is
    begin
        -- Reset condition
        if(reset_n = '0') then
            reg <= (others => '0');
            out_parallel <= (others => '0');
        -- Transparent output, when register disabled (latched on enable)
        elsif (enable = '0') then
            out_parallel <= reg;
        -- Shift
        elsif (rising_edge(clk)) then
            reg <= reg(REGISTER_WIDTH - 2 downto 0) & in_bit;
        end if;
    end process;

end architecture logic;
