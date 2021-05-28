-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-23 01:16:51
-- @ Modified time: 2021-05-23 01:16:52
-- @ Description: 
--    
--    Wrapper around XADC core used with the AnalogSequenceReader module. Module is assummed to operate in External MUX Sequencer
--    mode with event-driven conversion.
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ===================================================================================================================================
-- ------------------------------------------------------------ Package --------------------------------------------------------------
-- ===================================================================================================================================

package xadc is

    -- Sample's width (to not use raw '12')
    constant XADC_SAMPLE_WIDTH :Positive := 12;

    -- Array of XADC's samples vectors' array
    type xadcSamplesArray is array(natural range <>) of Std_logic_vector(XADC_SAMPLE_WIDTH - 1 downto 0);

end package xadc;

-- ===================================================================================================================================
-- ------------------------------------------------------------- Entity --------------------------------------------------------------
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity AnalogSequenceReaderXadcInterface is
    generic(
        -- Number of additional reset cycles
        RESET_CYCLES : Natural := 3
    );
    port(
        -- System clock
        clk : in Std_logic;
        -- Asynchronous reset
        reset_n : in Std_logic;

        -- Address lines mapped to the registers containing conversion results from auxiliary channels
        xadc_daddr_in : in Std_logic_vector(3 downto 0);
        -- `DPR Enable` line
        xadc_den_in : in Std_logic;
        -- `DRP Data Ready` line
        xadc_drdy_out : out Std_logic;
        -- `DRP Output Data` lines mapped to the bits representing samples' values
        xadc_do_out : out Std_logic_vector(11 downto 0);
        -- `Start conversion` line
        xadc_convst_in : in Std_logic;
        -- Analog inputs
        xadc_anal_in_p, xadc_anal_in_n : in Std_logic;
        -- External MUX select lines (mapped to range <0x0; 0xF>)
        xadc_muxaddr_out : out Std_logic_vector(3 downto 0);
        -- `End of conversion` line
        xadc_eoc_out : out Std_logic;
        -- `XADC Busy` line
        xadc_busy_out : out Std_logic
    );
end entity AnalogSequenceReaderXadcInterface;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of AnalogSequenceReaderXadcInterface is

    -- Width of the DRP adress port
    constant DRP_ADDR_WIDTH : Natural := 7;

    -- Offset of the first auxiliary channel's register in DRP (@note 'qualified expression' unsigned')
    constant AUX_CHN_OFFSET : Std_logic_vector(6 downto 0) := Std_logic_vector(resize(Unsigned'(X"10"), DRP_ADDR_WIDTH));

    -- XADC declaration
    component AnalogSequenceReaderXadc
    port (
        di_in : in Std_logic_vector(15 downto 0);
        daddr_in : in Std_logic_vector(DRP_ADDR_WIDTH - 1 downto 0);
        den_in : in Std_logic;
        dwe_in : in Std_logic;
        drdy_out : out Std_logic;
        do_out : out Std_logic_vector(15 downto 0);
        dclk_in : in Std_logic;
        reset_in : in Std_logic;
        convst_in : in Std_logic;
        vp_in : in Std_logic;
        vn_in : in Std_logic;
        vauxp0 : in Std_logic;
        vauxn0 : in Std_logic;
        channel_out : out Std_logic_vector(4 downto 0);
        muxaddr_out : out Std_logic_vector(4 downto 0);
        eoc_out : out Std_logic;
        alarm_out : out Std_logic;
        eos_out : out Std_logic;
        busy_out : out Std_logic
    );
    end component;

    -- Vector-wide or function
    function vector_wide_or(vec_1, vec_2 : Std_logic_vector) return Std_logic_vector is
        variable ret : Std_logic_vector(vec_1'range);
    begin
        for i in vec_1'range loop
            ret(i) := vec_1(i) or vec_2(i);
        end loop;
        return ret;
    end function;

    -- XADC output data lines
    signal do_out_lines : Std_logic_vector(15 downto 0);

    -- XADC DPR address lines
    signal daddr_in_lines : Std_logic_vector(DRP_ADDR_WIDTH - 1 downto 0);
    -- XADC external MUX select lines
    signal muxaddr_out_lines : Std_logic_vector(4 downto 0);

    -- Internal reset signal
    signal reset_int : Std_logic;

begin

    -- Concatenate address parts
    daddr_in_lines <= vector_wide_or(AUX_CHN_OFFSET, Std_logic_vector(resize(Unsigned(xadc_daddr_in), DRP_ADDR_WIDTH)));

    -- =================================================================================
    -- XADC instance
    -- =================================================================================

    -- Instance of the XADC
    analogSequenceReaderXadcInstance: AnalogSequenceReaderXadc
    port map (
        di_in => (others => '0'),
        daddr_in => daddr_in_lines,
        den_in => xadc_den_in,
        dwe_in => '0',
        drdy_out => xadc_drdy_out,
        do_out => do_out_lines,
        dclk_in => not(clk),
        reset_in => reset_int,
        convst_in => xadc_convst_in,
        vp_in => '0',
        vn_in => '0',
        vauxp0 => xadc_anal_in_p,
        vauxn0 => xadc_anal_in_n,
        channel_out => open,
        muxaddr_out => muxaddr_out_lines,
        eoc_out => xadc_eoc_out,
        alarm_out => open,
        eos_out => open,
        busy_out => xadc_busy_out
    );

    -- Map output data lines
    xadc_do_out <= do_out_lines(15 downto 4);

    -- Map mux select lines
    xadc_muxaddr_out <= muxaddr_out_lines(xadc_muxaddr_out'range);

    -- =================================================================================
    -- Reset state machine
    -- =================================================================================

    process (reset_n, clk) is
        -- Reset cycles' counter
        variable reset_cycles_left : Natural;
    begin

        -- Reset condition
        if(reset_n = '0') then

            reset_int <= '1';
            if(RESET_CYCLES /= 0) then
                reset_cycles_left := RESET_CYCLES - 1;
            else
                reset_cycles_left := 0;
            end if;

        -- After reset
        elsif(rising_edge(clk)) then

            -- If not activated yet
            if(reset_int = '1') then
                -- Check number of cycles left
                if(reset_cycles_left /= 0) then
                    reset_cycles_left := reset_cycles_left - 1;
                -- Exit reset state
                else
                    reset_int <= '0';
                end if;
            end if;

        end if;

    end process;

end architecture;
