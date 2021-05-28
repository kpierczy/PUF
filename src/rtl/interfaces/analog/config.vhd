-- ===================================================================================================================================
-- @ Author: Krzysztof Pierczyk
-- @ Create Time: 2021-05-28 03:13:37
-- @ Modified time: 2021-05-28 03:13:38
-- @ Description: 
--    
--    Configruation of the AnalogSequenceReader module
--    
-- ===================================================================================================================================

package xadc_config is

    -- Sampling frequency of subsequent XADC's conversions [Hz]
    constant CONFIG_XADC_SAMPLING_FREQ_HZ : Positive := 1000;

    -- Number of external channels (i.e. potentiometers) read by the XADC
    constant CONFIG_XADC_CHANNELS_NUM : Positive := 9;

end package xadc_config;
