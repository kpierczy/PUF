-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-25 14:42:57
-- @ Modified time: 2021-05-25 14:42:59
-- @ Description: 
--    
--    Module of the IIR-filter-based delay guitar effect with adjustable depth and attenuation.
--    
-- @ Note: This module uses preconfigured BRAM block that has to be named `DelayEffectBram` and so it can be spwawned only once
--     in the project.
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.dsp.all;

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

entity DelayEffect is
    generic(
        -- Width of the input sample
        SAMPLE_WIDTH : Positive range 2 to Positive'High;

        -- ====================== Effect-specific parameters ==================== --

        -- Width of the @in attenuation_in port
        ATTENUATION_WIDTH : Positive;
        -- Width of the @in depth port
        DEPTH_WIDTH : Positive;

        -- =========================== BRAM parameters ========================== --

        -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
        BRAM_SAMPLES_NUM : Positive;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive
    );
    port(
        -- ==================== Effects' common interface =================== --

        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Enable signal (when module's disabled, samples are not modified) (active high)
        enable_in : in Std_logic;
        -- `New input sample` signal (rising-edge-active)
        valid_in : in Std_logic;
        -- `Output sample ready` signal (rising-edge-active)
        valid_out : out Std_logic;

        -- Input sample
        sample_in : in Signed(SAMPLE_WIDTH - 1 downto 0);
        -- Gained sample
        sample_out : out Signed(SAMPLE_WIDTH - 1 downto 0);

        -- =================== Effect's-specific interface ================== --

        -- Attenuation level pf the delayed summant (treated as value in <0,1> range)
        attenuation_in : in unsigned(ATTENUATION_WIDTH - 1 downto 0);
        -- Depth level (index of the delayed sample being summed with the input)
        depth_in : in unsigned(DEPTH_WIDTH - 1 downto 0)

    );
end entity DelayEffect;

-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of DelayEffect is

    -- Signal activated hight for one cycle when rising edge detected on @p in valid_in
    signal new_sample : Std_logic;

    -- ========================= Input buffers ========================== --

    -- Input sample buffer
    signal sample_buf : Signed(SAMPLE_WIDTH - 1 downto 0);

    -- Input sample buffer
    signal sample_buf : Signed(SAMPLE_WIDTH - 1 downto 0);
    -- Buffer for attenuation level input
    signal attenuation_buf : unsigned(ATTENUATION_WIDTH - 1 downto 0);
    -- Depth level (index of the delayed sample being summed with the input)
    signal depth_buf : unsigned(DEPTH_WIDTH - 1 downto 0);

    -- ==================== Internal lines/buffers ====================== --

    -- Internal result of samples' summation
    signal result : Signed(SAMPLE_WIDTH - 1 downto 0);

    -- ========================== BRAM's signals ======================== --

    -- BRAM declaration
    component DelayEffectBram
    port (
        clka : in Std_logic;
        rsta : in Std_logic;
        ena : in Std_logic;
        wea : in Std_logic_vector(0 downto 0);
        addra : in Std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
        dina : in Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
        douta : out Std_logic_vector(SAMPLE_WIDTH - 1 downto 0)
    );
    end component;

    -- Address lines
    signal bram_addr_in : Std_logic_vector(BRAM_ADDR_WIDTH - 1 downto 0);
    -- Data lines
    signal bram_data_out, bram_data_in : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    -- Enable/write enable lines
    signal bram_en_in, bram_wen_in : Std_logic;

begin

end architecture logic;
