-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-04-26 14:32:00
-- @ Modified time: 2021-04-26 14:32:08
-- @ Description: 
--    
--    Shift registers' testbench
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.sim.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity ShiftRegTb is
end entity ShiftRegTb;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of ShiftRegTb is
     
    -- Type of signal generation
    type Generation is (SCHEDULED, RANDOM);

    -- System clock period
    constant CLK_PERIOD : Time := 20 ns;
    
    -- Min time between random toggles of the enable signal
    constant MIN_ENABLE_TOGGLE_TIME : Time := 10 ns;
    -- Max time between random toggles of the enable signal
    constant MAX_ENABLE_TOGGLE_TIME : Time := 1000 ns;

    -- Width of the cocunter
    constant REGISTER_WIDTH : Positive := 8;
     
    -- MIN time between randomization of the register's load input
    constant MIN_LOAD_PUSH_TOGGLE_TIME : Time := 10 ns;
    -- Max time between randomization of the register's load input
    constant MAX_LOAD_PUSH_TOGGLE_TIME : Time := 1000 ns;
    -- MIN time between randomization of the register's shift input
    constant MIN_SHIFT_TOGGLE_TIME : Time := 10 ns;
    -- Max time between randomization of the register's shift input
    constant MAX_SHIFT_TOGGLE_TIME : Time := 100 ns;
    -- MIN time between randomization of the register's input input
    constant MIN_IN_VALUE_RANDOMIZE_TIME : Time := 10 ns;
    -- Max time between randomization of the register's input input
    constant MAX_IN_VALUE_RANDOMIZE_TIME : Time := 10000 ns;


    -- Reset (asynchronous)
    signal reset_n	: Std_logic;
    -- Clock    
    signal clk : Std_logic := '0';

    ------------------------------------------------------------------------------------
    -- ============== Parallel-to-Serial specifc signals and constants ============== --
    ------------------------------------------------------------------------------------

    -- Loads register on the rising edge (parallel-to-serial)
    signal load_pts : Std_logic := '0';
    -- Shifts register on the rising edge (parallel-to-serial)
    signal shift_pts : Std_logic := '0';
    -- Load value (active high) (parallel-to-serial)
    signal in_parallel_pts : Std_logic_vector(REGISTER_WIDTH - 1 downto 0) := (others => '0');
    -- Output bit (parallel-to-serial)
    signal out_bit_pts : Std_logic;

    ------------------------------------------------------------------------------------
    -- ============== Serial-to-Parallel specifc signals and constants ============== --
    ------------------------------------------------------------------------------------

    -- Pushes register's value to the output on the rising edge (serial-to-parallel)
    signal push_stp : Std_logic := '0';
    -- Shifts register on the rising edge (serial-to-parallel)
    signal shift_stp : Std_logic := '0';
    -- Output bit (serial-to-parallel)
    signal in_bit_stp : Std_logic := '0';
    -- Load value (active high) ((serial-to-parallel)
    signal out_parallel_stp : Std_logic_vector(REGISTER_WIDTH - 1 downto 0) := (others => '0');

begin

    -- =================================================================================
    -- System signals
    -- =================================================================================

    -- Reset signal
    reset_n <= '0', '1' after CLK_PERIOD;

    -- Clock signal
    clk <= not clk after CLK_PERIOD / 2 when reset_n /= '0' else '0';
    
    -- =================================================================================
    -- Parallel to serial register's test
    -- =================================================================================
    
    -- Counter instance
    pts_inst: entity work.ParallelToSerialReg(logic)
    generic map (
        REGISTER_WIDTH => REGISTER_WIDTH
    )
    port map (
        reset_n     => reset_n,
        clk         => clk,
        load        => load_pts,
        shift        => shift_pts,
        in_parallel => in_parallel_pts,
        out_bit     => out_bit_pts
    );

    -- Random enable signal
    load_pts <= not load_pts after rand_time(MIN_LOAD_PUSH_TOGGLE_TIME, MAX_LOAD_PUSH_TOGGLE_TIME);
    shift_pts <= not shift_pts after rand_time(MIN_SHIFT_TOGGLE_TIME, MAX_SHIFT_TOGGLE_TIME);

    -- Load value's path
    process is
        -- State of the egnerating machine
        variable gen : Generation := SCHEDULED;
    begin
        -- Planned generation
        if(gen = SCHEDULED) then

            -- -- Switch to random generation
            gen := RANDOM;

        -- Random generation
        else
            in_parallel_pts <= rand_logic_vector(REGISTER_WIDTH);
            wait for rand_time(MIN_IN_VALUE_RANDOMIZE_TIME, MAX_IN_VALUE_RANDOMIZE_TIME);
        end if;
    end process;

    -- =================================================================================
    -- Parallel to serial register's test
    -- =================================================================================
    
    -- Counter instance
    stp_inst: entity work.SerialToParallelReg(logic)
    generic map (
        REGISTER_WIDTH => REGISTER_WIDTH
    )
    port map (
        reset_n      => reset_n,
        clk          => clk,
        push         => push_stp,
        shift        => shift_stp,
        in_bit       => in_bit_stp,
        out_parallel => out_parallel_stp
    );

    -- Random enable signal
    push_stp <= not push_stp after rand_time(MIN_LOAD_PUSH_TOGGLE_TIME, MAX_LOAD_PUSH_TOGGLE_TIME);
    shift_stp <= not shift_stp after rand_time(MIN_SHIFT_TOGGLE_TIME, MAX_SHIFT_TOGGLE_TIME);

    -- Input value's path
    process is
        -- State of the egnerating machine
        variable gen : Generation := SCHEDULED;
    begin
        -- Planned generation
        if(gen = SCHEDULED) then

            -- -- Switch to random generation
            gen := RANDOM;

        -- Random generation
        else
            in_bit_stp <= not in_bit_stp;
            wait for rand_time(MIN_IN_VALUE_RANDOMIZE_TIME, MAX_IN_VALUE_RANDOMIZE_TIME);
        end if;
    end process;

end architecture logic;
