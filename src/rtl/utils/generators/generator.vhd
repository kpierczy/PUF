-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-27 23:24:49
-- @ Modified time: 2021-05-27 23:25:02
-- @ Description: 
--    
--    Common interface for Generatos
--    
-- ===================================================================================================================================

-- ------------------------------------------------------------- Entity --------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.generator_pkg.all;

entity Generator is
    generic(
        -- Generator type
        GENERATOR_TYPE : GeneratorType;
        -- Width of the single sample
        SAMPLE_WIDTH : Positive;

        -- ==================== QuadrupletGenerator-specific ==================== --

        -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
        BRAM_SAMPLES_NUM : Positive;
        -- Width of the address port
        BRAM_ADDR_WIDTH : Positive;
        -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
        BRAM_LATENCY : Positive
    );
    port(
        -- Reset signal (asynchronous)
        reset_n : in Std_logic;
        -- System clock
        clk : in Std_logic;

        -- Signal starting generation of the next sample (active high)
        en_in : in Std_logic;
        -- Data lines
        sample_out : out Std_logic_vector(SAMPLE_WIDTH - 1 downto 0)
    );
end entity Generator;


-- ---------------------------------------------------------- Architecture -----------------------------------------------------------

architecture logic of Generator is


    -- BRAM declaration
    component TremoloEffectBram
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
    signal bram_data_out : Std_logic_vector(SAMPLE_WIDTH - 1 downto 0);
    -- Enable line
    signal bram_en_in : Std_logic;

begin

    -- Logic of the generator using TriangleGenerator entity
    triangleGeneratorCase : if GENERATOR_TYPE = TRIANGLE generate

        -- Generator's instance
        triangleGeneratorInstance : entity work.TriangleGenerator
        generic map (
            MODE         => UNSIGNED_OUT,
            SAMPLE_WIDTH => SAMPLE_WIDTH
        )
        port map (
            reset_n    => reset_n,
            clk        => clk,
            en_in      => en_in,
            sample_out => sample_out
        );

    end generate;

    -- Logic of the generator using QuadrupletGenerator entity
    quadrupletGeneratorCase : if GENERATOR_TYPE = QUADRUPLET generate

        -- Generator's instance
        quadrupletGeneratorInstance : entity work.QuadrupletGenerator
        generic map (
            MODE         => UNSIGNED_OUT,
            SAMPLES_NUM  => BRAM_SAMPLES_NUM,
            SAMPLE_WIDTH => SAMPLE_WIDTH,
            ADDR_WIDTH   => BRAM_ADDR_WIDTH,
            BRAM_LATENCY => BRAM_LATENCY
        )
        port map (
            reset_n       => reset_n,
            clk           => clk,
            en_in         => en_in,
            sample_out    => sample_out,
            busy_out      => open,
            bram_addr_out => bram_addr_in,
            bram_data_in  => bram_data_out,
            bram_en_out   => bram_en_in
        );

        -- BRAM instance
        quadrupletGeneratorBramInstance : TremoloEffectBram
        PORT MAP (
            clka => clk,
            rsta => not(reset_n),
            ena => bram_en_in,
            wea => (others => '0'),
            addra => bram_addr_in,
            dina => (others => '0'),
            douta => bram_data_out
        );

    end generate;    

end architecture logic;
