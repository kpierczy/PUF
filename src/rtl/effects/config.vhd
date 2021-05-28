-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-27 20:49:39
-- @ Modified time: 2021-05-27 20:49:40
-- @ Description: 
--    
--    Configuration file for project's parameters
--    
-- ===================================================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.generator_pkg.all;

-- ------------------------------------------------------------ Package --------------------------------------------------------------

package pipe_config is 

    -- ============================== Clipping effect's Configuration ============================= --

    -- --------------------------------------------------------------------------
    -- Values of the GAIN_WIDTH and TWO_POW_DIV was choosen so that the ffective
    -- range of the gain is <0;4) with 0.0039 precision (about 0.5 %)
    -- --------------------------------------------------------------------------

    -- Width of the gain input (gain's width must be smaller than sample's width)
    constant CONFIG_CLIPPING_GAIN_WIDTH : Positive := 10;
    -- Index of the 2's power that the multiplication's result is divided by before saturation
    constant CONFIG_CLIPPING_TWO_POW_DIV : Natural := 8;

    -- =============================== Tremolo effect's Configuration ============================= --

    -- -------------------------------------------------------------------------
    -- At the moment counter-based triangle LFO generator is choosen as 
    -- source of the mdoulating wave. The reson for this choice is mainly
    -- simplicity of implementation (i.e. number of resources required)
    -- -------------------------------------------------------------------------

    -- Generator type
    constant CONFIG_TREMOLO_GENERATOR_TYPE : GeneratorType := TRIANGLE;

    -- -------------------------------------------------------------------------
    -- `depth_in` input is treated as value from range <0, 1), so it's width
    -- impacts only granularity of the modulation wave's 'depth'. Value '10'
    -- provides 1/1024 granularity that should be enough for smooth adjustments.
    -- -------------------------------------------------------------------------

    -- Width of the modulation wave's depth input
    constant CONFIG_TREMOLO_DEPTH_WIDTH : Positive := 10;

    -- -------------------------------------------------------------------------
    -- Width of the modulating wave's sample determines also number of `steps`
    -- per single period as a simple counter-based triangle generator was used
    -- Assuming that sound samples come in the 16-bit format a 10-bit generator
    -- should be anough to smoothly modulate the signal.
    -- -------------------------------------------------------------------------

    -- Width of the modulating sample
    constant CONFIG_TREMOLO_LFO_SAMPLE_WIDTH : Positive := 10;

    -- -------------------------------------------------------------------------
    -- With 10-bit modulating samples the and 100MHz system clock the maximal
    -- frequenc of the modulating wave is ~97kHz. To assure minimal frequency
    -- about ~1Hz (0.74Hz) the 17-bit `modulation_ticks_per_sample` input
    -- is required
    -- -------------------------------------------------------------------------

    -- Width of the `ticks_per_sample` input
    constant CONFIG_TREMOLO_TICKS_PER_SAMPLE_WIDTH : Positive := 17;

    -- ================================ Delay effect's Configuration ============================== --

    -- -------------------------------------------------------------------------
    -- Attenuation level of the delayed summand is treated as value in range
    -- <0, 5), so width of his input impacts only granularity of the setup.
    -- 12-bit (1/4096 precision) should be enough to provide smooth control
    -- over the delayed samples' level.
    -- -------------------------------------------------------------------------

    -- Width of the @in attenuation_in port
    constant CONFIG_DELAY_ATTENUATION_WIDTH : Positive := 12;

    -- -------------------------------------------------------------------------
    -- Delay line's BRAM was configured to use 20 blocks of 36Kb BRAM. It can
    -- hold up to 45_000 samples what corresponds to slightly more than 1 second
    -- of recording. To address al versions of the delayed samplls the 16-bit
    -- address is required and so 16-bit `depth_in` input
    -- -------------------------------------------------------------------------

    -- Width of the @in depth port
    constant CONFIG_DELAY_DEPTH_WIDTH : Positive := 16;

    -- -------------------------------------------------------------------------
    -- Delay's block ram was composed of 20 blocks containing 36Kb each (not 
    -- 36KB). It can hold samples from withing about 1 second of recording 
    -- (assuming 16-bit samples). In the BRAM core the output register was used
    -- to isolate latencies of the blocks-choosing multiplexers what extended
    -- latency to 2 cycles.
    -- -------------------------------------------------------------------------

    -- Number of samples in a quarter (Valid only when GENERATOR_TYPE is QUADRUPLET)
    constant CONFIG_DELAY_BRAM_SAMPLES_NUM : Positive := 45_000;
    -- Width of the address port
    constant CONFIG_DELAY_BRAM_ADDR_WIDTH : Positive := 16;
    -- Latency of the BRAM read operation (1 for lack of output registers in the BRAM block)
    constant CONFIG_DELAY_BRAM_LATENCY : Positive := 2;

    -- =============================== Flanger effect's Configuration ============================= --

    -- -------------------------------------------------------------------------
    -- Strength level of the delayed summand is treated as value in range
    -- <0, 1), so width of his input impacts only granularity of the setup.
    -- 12-bit (1/4096 precision) should be enough to provide smooth control
    -- over the delayed samples' level.
    -- -------------------------------------------------------------------------

    -- Width of the @in attenuation_in port
    constant CONFIG_FLANGER_STRENGTH_WIDTH : Positive := 12;

    -- -------------------------------------------------------------------------
    -- As described below (@see 'Generator's BRAM parameters'), the internal
    -- LFO (Low Frequency Oscilator) generates numbers in range <0, 1024>. The
    -- `depth_in` input always scales this amplitude in range <0, 1) so it's
    -- width impacts only granularity of the setup. 10-bit width corresponding
    -- tot width of the LFO's samples is the highest reasonable setup that
    -- can be set in such configuration.
    -- -------------------------------------------------------------------------

    -- Width of the @in depth port
    constant CONFIG_FLANGER_DEPTH_WIDTH : Positive := 10;

    -- -------------------------------------------------------------------------
    -- @improtant: For the flanger effect to function properly it is crucial
    --    to relatively small frequencies of the LFO generator so that 
    --    osilcations in the delay's values doe not create too much distrotions
    --    in the input signal. Assuming 100MHz system clock and 1024 samples
    --    per LFO's period, the 20-bit input will quarante frequencies in range
    --    ~ <0.1, 97k> Hz. In fact the higher frequenies (in practice above 4Hz)
    --    should not be used but it is user's duty to properly scale 
    --    `ticks_per_delay_sample_in` input.
    -- 
    -- @note: f_LFO[t] = f_SYS / A_LFO / (ticks[t] + 1), where
    --
    --     - f_LFO[t] - frequency of the LFO in [Hz]
    --     - f_SYS - system clock's frequency in [Hz]
    --     - A_LFO - amplitude of the LFO generator
    --     - ticks[t] - value on the `ticks_per_delay_sample_in` input
    --
    -- -------------------------------------------------------------------------

    -- Width of the `ticks_per_delay_sample_in` input
    constant CONFIG_FLANGER_TICKS_PER_DELAY_SAMPLE_WIDTH : Positive := 20;

    -- ---------------------------------------------------------------------- --
    -- The first of incorporated BRAM blocks is used within the delay line 
    -- buffering historical sample in a FIFO maner (as a ring buffer). For
    -- 'flanger' effects delays in range of 10-25 ms are recommended to keep
    -- signals distrortions on reasonable level. Assuming 44100Hz sampling
    -- rate buffer should be able to hold about 662 samples (15 ms delay). 
    -- With 16-bit samples 1324-byte buffer is needed. A single 18Kb block RAM
    -- module can hold up to 1024 samples (yes, it's less than 18Kbits). To 
    -- effectively utilize a block, the full sapce is used. Should delay's 
    -- amplitude turn out too high, it can  always be limited by constraints 
    -- put on the `depth_in` input's values.
    -- ---------------------------------------------------------------------- --

    -- Number of usable cells in delay line's BRAM
    constant CONFIG_FLANGER_DELAY_BRAM_SAMPLES_NUM : Positive := 1024;
    -- Width of the delay line's address port
    constant CONFIG_FLANGER_DELAY_BRAM_ADDR_WIDTH : Positive := 10;

    -- ---------------------------------------------------------------------- --
    -- To isolate latencies of the BRAM Core's internal multiplexers a single
    -- output register stage was used. It extends BRAM latency to 2 cycles.
    -- ---------------------------------------------------------------------- --

    -- Latency of the delay line's BRAM read operation (1 for lack of output registers in the BRAM block)
    constant CONFIG_FLANGER_DELAY_BRAM_LATENCY : Positive := 2;

    -- ---------------------------------------------------------------------- --
    -- Granularity of the delay-modulating wave's samples should be able to 
    -- address (more or less) all delayed samples in the delay line. Taking
    -- into account above-mentioned size of the delay buffer, the 10-bit
    -- wave was choosen. With such granularity all samples can be addressed. 
    -- That translates to about 23ms of delay.
    --
    -- As quadruplet generator is used internally (@see QuadrupletGenerator)
    -- it is enough to hold first 257 samples of the sinusoid wave from range
    -- <0, 2pi>.
    -- ---------------------------------------------------------------------- --

    -- Number of usable cells in delay line's BRAM
    constant CONFIG_FLANGER_LFO_BRAM_SAMPLES_NUM : Positive := 257;
    -- Width of the delay line's address port
    constant CONFIG_FLANGER_LFO_BRAM_ADDR_WIDTH : Positive := 9;
    -- Width of the data hold in the generator's BRAM
    constant CONFIG_FLANGER_LFO_BRAM_DATA_WIDTH : Positive := 10;

    -- ---------------------------------------------------------------------- --
    -- To isolate latencies of the BRAM Core's internal multiplexers a single
    -- output register stage was used. It extends BRAM latency to 2 cycles.
    -- ---------------------------------------------------------------------- --

    -- Latency of the delay line's BRAM read operation (1 for lack of output registers in the BRAM block)
    constant CONFIG_FLANGER_LFO_BRAM_LATENCY : Positive := 2;

end package pipe_config;
