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
-- A generic shift register with synchronous parallel input and synchronous serial output
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity ParallelToSerialReg is

    generic(
        -- Width of the register
        REGISTER_WIDTH : Positive;
        -- Fill value for the emptied (shifted) bits
        FILL_STATE : Std_logic := '0'
    );
    port(
        -- Reset signal (active low)
        reset_n : in Std_logic;
        -- Clock signal
        clk : in Std_logic;
        -- Shift signal (active high)
        shift : in Std_logic;
        -- Load signal (active high)
        load : in Std_logic;
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
    latch : process (reset_n, clk) is
    begin
        -- Reset condition
        if(reset_n = '0') then

            reg <= (others => '0');
            out_bit <= FILL_STATE;

        -- Active state
        elsif (rising_edge(clk)) then

            -- Fetch parallel data on rising edge of @in load signal
            if(load = '1') then
                reg <= in_parallel;
            -- Shift register otherwise
            elsif(shift = '1') then
                -- Output set
                out_bit <= reg(0);
                -- Shift
                reg <= FILL_STATE & reg(REGISTER_WIDTH - 1 downto 1);
            end if;

        end if;
    end process;

end architecture logic;


-- ===================================================================================================================================
-- A generic shift register with synchronous serial input and synchronous parallel output
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity SerialToParallelReg is

    generic(
        -- Width of the register
        REGISTER_WIDTH : Positive
    );
    port(
        -- Reset signal (active low)
        reset_n : in Std_logic;
        -- Clock signal
        clk : in Std_logic;
        -- Shift signal (active high)
        shift : in Std_logic;
        -- Push output signal (active high)
        push : in Std_logic;
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
    latch : process (reset_n, clk) is
    begin
        -- Reset condition
        if(reset_n = '0') then
            reg <= (others => '0');
            out_parallel <= (others => '0');
        -- Active state
        elsif (rising_edge(clk)) then
            -- Push register to output on the rising edge of @in push
            if (push = '1') then
                out_parallel <= reg;
            -- Shift register
            elsif(shift = '1') then
                reg <= reg(REGISTER_WIDTH - 2 downto 0) & in_bit;
            end if;
        end if;
    end process;

end architecture logic;
