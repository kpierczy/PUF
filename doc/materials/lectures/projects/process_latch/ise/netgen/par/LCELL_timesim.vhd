--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.20131013
--  \   \         Application: netgen
--  /   /         Filename: LCELL_timesim.vhd
-- /___/   /\     Timestamp: Wed Mar 25 12:43:51 2020
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -s 5 -pcf PROCESS_LATCH.pcf -rpw 100 -tpw 0 -ar Structure -tm PROCESS_LATCH -insert_pp_buffers true -w -dir netgen/par -ofmt vhdl -sim PROCESS_LATCH.ncd LCELL_timesim.vhd 
-- Device	: 3s50atq144-5 (PRODUCTION 1.42 2013-10-13)
-- Input file	: PROCESS_LATCH.ncd
-- Output file	: D:\Home\Pozniak\Dokumenty\Wyklady\PUF-EiTI\projekty\process_latch\ise\netgen\par\LCELL_timesim.vhd
-- # of Entities	: 1
-- Design Name	: PROCESS_LATCH
-- Xilinx	: C:\CAD\Xilinx\14.7\ISE_DS\ISE\
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library SIMPRIM;
use SIMPRIM.VCOMPONENTS.ALL;
use SIMPRIM.VPACKAGE.ALL;

entity PROCESS_LATCH is
  port (
    digit : out STD_LOGIC; 
    low_char : out STD_LOGIC; 
    control : out STD_LOGIC; 
    high_char : out STD_LOGIC; 
    ascii : in STD_LOGIC_VECTOR ( 7 downto 0 ) 
  );
end PROCESS_LATCH;

architecture Structure of PROCESS_LATCH is
  signal ascii_0_IBUF_0 : STD_LOGIC; 
  signal ascii_1_IBUF_0 : STD_LOGIC; 
  signal ascii_2_IBUF_0 : STD_LOGIC; 
  signal ascii_3_IBUF_0 : STD_LOGIC; 
  signal ascii_4_IBUF_0 : STD_LOGIC; 
  signal ascii_5_IBUF_0 : STD_LOGIC; 
  signal ascii_6_IBUF_0 : STD_LOGIC; 
  signal ascii_7_IBUF_0 : STD_LOGIC; 
  signal digit_and0000_128 : STD_LOGIC; 
  signal low_char_cmp_le0000_0 : STD_LOGIC; 
  signal low_char_and0000 : STD_LOGIC; 
  signal high_char_and0000 : STD_LOGIC; 
  signal low_char_cmp_le00011_0 : STD_LOGIC; 
  signal low_char_cmp_ge00001_0 : STD_LOGIC; 
  signal N11_0 : STD_LOGIC; 
  signal ascii_0_IBUF_147 : STD_LOGIC; 
  signal ascii_1_IBUF_154 : STD_LOGIC; 
  signal ascii_2_IBUF_161 : STD_LOGIC; 
  signal ascii_3_IBUF_168 : STD_LOGIC; 
  signal ascii_4_IBUF_175 : STD_LOGIC; 
  signal ascii_5_IBUF_182 : STD_LOGIC; 
  signal ascii_6_IBUF_189 : STD_LOGIC; 
  signal ascii_7_IBUF_196 : STD_LOGIC; 
  signal digit_O : STD_LOGIC; 
  signal low_char_O : STD_LOGIC; 
  signal low_char_OUTPUT_OFF_ODDRIN1_MUX : STD_LOGIC; 
  signal low_char_OBUF_255 : STD_LOGIC; 
  signal low_char_OUTPUT_OFF_O1INV_260 : STD_LOGIC; 
  signal low_char_OUTPUT_OFF_OFF1_SET : STD_LOGIC; 
  signal low_char_OUTPUT_OFF_OFF1_RSTAND_257 : STD_LOGIC; 
  signal low_char_OUTPUT_OTCLK1INVNOT : STD_LOGIC; 
  signal control_O : STD_LOGIC; 
  signal control_OUTPUT_OFF_ODDRIN1_MUX : STD_LOGIC; 
  signal control_OBUF_281 : STD_LOGIC; 
  signal control_OUTPUT_OFF_O1INV_285 : STD_LOGIC; 
  signal control_OUTPUT_OFF_OFF1_RSTAND_283 : STD_LOGIC; 
  signal control_OUTPUT_OTCLK1INVNOT : STD_LOGIC; 
  signal high_char_O : STD_LOGIC; 
  signal high_char_and0000_F5MUX_341 : STD_LOGIC; 
  signal high_char_and00001_339 : STD_LOGIC; 
  signal high_char_and0000_BXINV_334 : STD_LOGIC; 
  signal high_char_and00002_332 : STD_LOGIC; 
  signal low_char_and0000_F5MUX_366 : STD_LOGIC; 
  signal low_char_and00001_364 : STD_LOGIC; 
  signal low_char_and0000_BXINV_359 : STD_LOGIC; 
  signal low_char_and00002_357 : STD_LOGIC; 
  signal low_char_cmp_ge00001_389 : STD_LOGIC; 
  signal N11 : STD_LOGIC; 
  signal low_char_cmp_le0000 : STD_LOGIC; 
  signal low_char_cmp_le00011_413 : STD_LOGIC; 
  signal high_char_or0000 : STD_LOGIC; 
  signal control_or0000 : STD_LOGIC; 
  signal digit_or0000 : STD_LOGIC; 
  signal low_char_or0000 : STD_LOGIC; 
  signal digit_and0000_pack_1 : STD_LOGIC; 
  signal digit_OUTPUT_OTCLK1INVNOT : STD_LOGIC; 
  signal digit_OUTPUT_OFF_O1INV_228 : STD_LOGIC; 
  signal digit_OBUF_223 : STD_LOGIC; 
  signal digit_OUTPUT_OFF_ODDRIN1_MUX : STD_LOGIC; 
  signal digit_OUTPUT_OFF_OFF1_SET : STD_LOGIC; 
  signal digit_OUTPUT_OFF_OFF1_RSTAND_225 : STD_LOGIC; 
  signal high_char_OUTPUT_OTCLK1INVNOT : STD_LOGIC; 
  signal high_char_OUTPUT_OFF_O1INV_317 : STD_LOGIC; 
  signal high_char_OBUF_312 : STD_LOGIC; 
  signal high_char_OUTPUT_OFF_ODDRIN1_MUX : STD_LOGIC; 
  signal high_char_OUTPUT_OFF_OFF1_SET : STD_LOGIC; 
  signal high_char_OUTPUT_OFF_OFF1_RSTAND_314 : STD_LOGIC; 
  signal VCC : STD_LOGIC; 
  signal NlwInverterSignal_low_char_CLK : STD_LOGIC; 
  signal NlwInverterSignal_control_CLK : STD_LOGIC; 
  signal GND : STD_LOGIC; 
  signal NlwInverterSignal_digit_CLK : STD_LOGIC; 
  signal NlwInverterSignal_high_char_CLK : STD_LOGIC; 
begin
  ascii_0_IBUF : X_BUF
    generic map(
      LOC => "PAD143",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii(0),
      O => ascii_0_IBUF_147
    );
  ascii_1_IBUF : X_BUF
    generic map(
      LOC => "PAD133",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii(1),
      O => ascii_1_IBUF_154
    );
  ascii_2_IBUF : X_BUF
    generic map(
      LOC => "PAD136",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii(2),
      O => ascii_2_IBUF_161
    );
  ascii_3_IBUF : X_BUF
    generic map(
      LOC => "PAD135",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii(3),
      O => ascii_3_IBUF_168
    );
  ascii_4_IBUF : X_BUF
    generic map(
      LOC => "PAD134",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii(4),
      O => ascii_4_IBUF_175
    );
  ascii_5_IBUF : X_BUF
    generic map(
      LOC => "PAD144",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii(5),
      O => ascii_5_IBUF_182
    );
  ascii_6_IBUF : X_BUF
    generic map(
      LOC => "PAD132",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii(6),
      O => ascii_6_IBUF_189
    );
  ascii_7_IBUF : X_BUF
    generic map(
      LOC => "PAD131",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii(7),
      O => ascii_7_IBUF_196
    );
  digit_OBUF : X_OBUF
    generic map(
      LOC => "PAD140"
    )
    port map (
      I => digit_O,
      O => digit
    );
  low_char_OBUF : X_OBUF
    generic map(
      LOC => "PAD141"
    )
    port map (
      I => low_char_O,
      O => low_char
    );
  low_char_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD141",
      PATHPULSE => 624 ps
    )
    port map (
      I => '0',
      O => low_char_OUTPUT_OFF_O1INV_260
    );
  low_char_OUTPUT_OFF_O1_DDRMUX : X_BUF
    generic map(
      LOC => "PAD141",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_OUTPUT_OFF_O1INV_260,
      O => low_char_OUTPUT_OFF_ODDRIN1_MUX
    );
  low_char_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD141",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_OBUF_255,
      O => low_char_O
    );
  low_char_145 : X_LATCHE
    generic map(
      LOC => "PAD141",
      INIT => '0'
    )
    port map (
      I => low_char_OUTPUT_OFF_ODDRIN1_MUX,
      GE => VCC,
      CLK => NlwInverterSignal_low_char_CLK,
      SET => low_char_OUTPUT_OFF_OFF1_SET,
      RST => low_char_OUTPUT_OFF_OFF1_RSTAND_257,
      O => low_char_OBUF_255
    );
  low_char_OUTPUT_OFF_OFF1_SETOR : X_BUF
    generic map(
      LOC => "PAD141",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_and0000,
      O => low_char_OUTPUT_OFF_OFF1_SET
    );
  low_char_OUTPUT_OFF_OFF1_RSTAND : X_BUF
    generic map(
      LOC => "PAD141",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_or0000,
      O => low_char_OUTPUT_OFF_OFF1_RSTAND_257
    );
  low_char_OUTPUT_OTCLK1INV : X_INV
    generic map(
      LOC => "PAD141",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_cmp_le0000_0,
      O => low_char_OUTPUT_OTCLK1INVNOT
    );
  control_OBUF : X_OBUF
    generic map(
      LOC => "PAD142"
    )
    port map (
      I => control_O,
      O => control
    );
  control_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD142",
      PATHPULSE => 624 ps
    )
    port map (
      I => '1',
      O => control_OUTPUT_OFF_O1INV_285
    );
  control_OUTPUT_OFF_O1_DDRMUX : X_BUF
    generic map(
      LOC => "PAD142",
      PATHPULSE => 624 ps
    )
    port map (
      I => control_OUTPUT_OFF_O1INV_285,
      O => control_OUTPUT_OFF_ODDRIN1_MUX
    );
  control_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD142",
      PATHPULSE => 624 ps
    )
    port map (
      I => control_OBUF_281,
      O => control_O
    );
  control_160 : X_LATCHE
    generic map(
      LOC => "PAD142",
      INIT => '0'
    )
    port map (
      I => control_OUTPUT_OFF_ODDRIN1_MUX,
      GE => VCC,
      CLK => NlwInverterSignal_control_CLK,
      SET => GND,
      RST => control_OUTPUT_OFF_OFF1_RSTAND_283,
      O => control_OBUF_281
    );
  control_OUTPUT_OFF_OFF1_RSTAND : X_BUF
    generic map(
      LOC => "PAD142",
      PATHPULSE => 624 ps
    )
    port map (
      I => control_or0000,
      O => control_OUTPUT_OFF_OFF1_RSTAND_283
    );
  control_OUTPUT_OTCLK1INV : X_INV
    generic map(
      LOC => "PAD142",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_cmp_le0000_0,
      O => control_OUTPUT_OTCLK1INVNOT
    );
  high_char_OBUF : X_OBUF
    generic map(
      LOC => "PAD139"
    )
    port map (
      I => high_char_O,
      O => high_char
    );
  high_char_and0000_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X1Y22",
      PATHPULSE => 624 ps
    )
    port map (
      I => high_char_and0000_F5MUX_341,
      O => high_char_and0000
    );
  high_char_and0000_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X1Y22"
    )
    port map (
      IA => high_char_and00002_332,
      IB => high_char_and00001_339,
      SEL => high_char_and0000_BXINV_334,
      O => high_char_and0000_F5MUX_341
    );
  high_char_and0000_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X1Y22",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii_4_IBUF_0,
      O => high_char_and0000_BXINV_334
    );
  low_char_and0000_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X0Y22",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_and0000_F5MUX_366,
      O => low_char_and0000
    );
  low_char_and0000_F5MUX : X_MUX2
    generic map(
      LOC => "SLICE_X0Y22"
    )
    port map (
      IA => low_char_and00002_357,
      IB => low_char_and00001_364,
      SEL => low_char_and0000_BXINV_359,
      O => low_char_and0000_F5MUX_366
    );
  low_char_and0000_BXINV : X_BUF
    generic map(
      LOC => "SLICE_X0Y22",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii_4_IBUF_0,
      O => low_char_and0000_BXINV_359
    );
  low_char_cmp_ge00001_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X1Y23",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_cmp_ge00001_389,
      O => low_char_cmp_ge00001_0
    );
  low_char_cmp_ge00001_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X1Y23",
      PATHPULSE => 624 ps
    )
    port map (
      I => N11,
      O => N11_0
    );
  low_char_cmp_le0000_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X0Y24",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_cmp_le0000,
      O => low_char_cmp_le0000_0
    );
  low_char_cmp_le00011_XUSED : X_BUF
    generic map(
      LOC => "SLICE_X0Y23",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_cmp_le00011_413,
      O => low_char_cmp_le00011_0
    );
  low_char_or0000_YUSED : X_BUF
    generic map(
      LOC => "SLICE_X0Y25",
      PATHPULSE => 624 ps
    )
    port map (
      I => digit_and0000_pack_1,
      O => digit_and0000_128
    );
  digit_OUTPUT_OTCLK1INV : X_INV
    generic map(
      LOC => "PAD140",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_cmp_le0000_0,
      O => digit_OUTPUT_OTCLK1INVNOT
    );
  digit_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD140",
      PATHPULSE => 624 ps
    )
    port map (
      I => digit_OBUF_223,
      O => digit_O
    );
  digit_OUTPUT_OFF_O1_DDRMUX : X_BUF
    generic map(
      LOC => "PAD140",
      PATHPULSE => 624 ps
    )
    port map (
      I => digit_OUTPUT_OFF_O1INV_228,
      O => digit_OUTPUT_OFF_ODDRIN1_MUX
    );
  digit_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD140",
      PATHPULSE => 624 ps
    )
    port map (
      I => '0',
      O => digit_OUTPUT_OFF_O1INV_228
    );
  digit_128 : X_LATCHE
    generic map(
      LOC => "PAD140",
      INIT => '0'
    )
    port map (
      I => digit_OUTPUT_OFF_ODDRIN1_MUX,
      GE => VCC,
      CLK => NlwInverterSignal_digit_CLK,
      SET => digit_OUTPUT_OFF_OFF1_SET,
      RST => digit_OUTPUT_OFF_OFF1_RSTAND_225,
      O => digit_OBUF_223
    );
  digit_OUTPUT_OFF_OFF1_SETOR : X_BUF
    generic map(
      LOC => "PAD140",
      PATHPULSE => 624 ps
    )
    port map (
      I => digit_and0000_128,
      O => digit_OUTPUT_OFF_OFF1_SET
    );
  digit_OUTPUT_OFF_OFF1_RSTAND : X_BUF
    generic map(
      LOC => "PAD140",
      PATHPULSE => 624 ps
    )
    port map (
      I => digit_or0000,
      O => digit_OUTPUT_OFF_OFF1_RSTAND_225
    );
  high_char_OUTPUT_OTCLK1INV : X_INV
    generic map(
      LOC => "PAD139",
      PATHPULSE => 624 ps
    )
    port map (
      I => low_char_cmp_le0000_0,
      O => high_char_OUTPUT_OTCLK1INVNOT
    );
  high_char_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD139",
      PATHPULSE => 624 ps
    )
    port map (
      I => high_char_OBUF_312,
      O => high_char_O
    );
  high_char_OUTPUT_OFF_O1_DDRMUX : X_BUF
    generic map(
      LOC => "PAD139",
      PATHPULSE => 624 ps
    )
    port map (
      I => high_char_OUTPUT_OFF_O1INV_317,
      O => high_char_OUTPUT_OFF_ODDRIN1_MUX
    );
  high_char_OUTPUT_OFF_O1INV : X_BUF
    generic map(
      LOC => "PAD139",
      PATHPULSE => 624 ps
    )
    port map (
      I => '0',
      O => high_char_OUTPUT_OFF_O1INV_317
    );
  high_char_176 : X_LATCHE
    generic map(
      LOC => "PAD139",
      INIT => '0'
    )
    port map (
      I => high_char_OUTPUT_OFF_ODDRIN1_MUX,
      GE => VCC,
      CLK => NlwInverterSignal_high_char_CLK,
      SET => high_char_OUTPUT_OFF_OFF1_SET,
      RST => high_char_OUTPUT_OFF_OFF1_RSTAND_314,
      O => high_char_OBUF_312
    );
  high_char_OUTPUT_OFF_OFF1_SETOR : X_BUF
    generic map(
      LOC => "PAD139",
      PATHPULSE => 624 ps
    )
    port map (
      I => high_char_and0000,
      O => high_char_OUTPUT_OFF_OFF1_SET
    );
  high_char_OUTPUT_OFF_OFF1_RSTAND : X_BUF
    generic map(
      LOC => "PAD139",
      PATHPULSE => 624 ps
    )
    port map (
      I => high_char_or0000,
      O => high_char_OUTPUT_OFF_OFF1_RSTAND_314
    );
  high_char_and00002 : X_LUT4
    generic map(
      INIT => X"0020",
      LOC => "SLICE_X1Y22"
    )
    port map (
      ADR0 => low_char_cmp_ge00001_0,
      ADR1 => ascii_7_IBUF_0,
      ADR2 => ascii_6_IBUF_0,
      ADR3 => ascii_5_IBUF_0,
      O => high_char_and00002_332
    );
  high_char_and00001 : X_LUT4
    generic map(
      INIT => X"0020",
      LOC => "SLICE_X1Y22"
    )
    port map (
      ADR0 => ascii_6_IBUF_0,
      ADR1 => ascii_7_IBUF_0,
      ADR2 => low_char_cmp_le00011_0,
      ADR3 => ascii_5_IBUF_0,
      O => high_char_and00001_339
    );
  low_char_and00002 : X_LUT4
    generic map(
      INIT => X"0800",
      LOC => "SLICE_X0Y22"
    )
    port map (
      ADR0 => ascii_5_IBUF_0,
      ADR1 => ascii_6_IBUF_0,
      ADR2 => ascii_7_IBUF_0,
      ADR3 => low_char_cmp_ge00001_0,
      O => low_char_and00002_357
    );
  low_char_and00001 : X_LUT4
    generic map(
      INIT => X"0800",
      LOC => "SLICE_X0Y22"
    )
    port map (
      ADR0 => ascii_5_IBUF_0,
      ADR1 => low_char_cmp_le00011_0,
      ADR2 => ascii_7_IBUF_0,
      ADR3 => ascii_6_IBUF_0,
      O => low_char_and00001_364
    );
  digit_and0000_SW0 : X_LUT4
    generic map(
      INIT => X"C8FF",
      LOC => "SLICE_X1Y23"
    )
    port map (
      ADR0 => ascii_1_IBUF_0,
      ADR1 => ascii_3_IBUF_0,
      ADR2 => ascii_2_IBUF_0,
      ADR3 => ascii_4_IBUF_0,
      O => N11
    );
  low_char_cmp_ge00001 : X_LUT4
    generic map(
      INIT => X"FFFE",
      LOC => "SLICE_X1Y23"
    )
    port map (
      ADR0 => ascii_1_IBUF_0,
      ADR1 => ascii_3_IBUF_0,
      ADR2 => ascii_2_IBUF_0,
      ADR3 => ascii_0_IBUF_0,
      O => low_char_cmp_ge00001_389
    );
  low_char_cmp_le00001 : X_LUT4
    generic map(
      INIT => X"0005",
      LOC => "SLICE_X0Y24"
    )
    port map (
      ADR0 => ascii_5_IBUF_0,
      ADR1 => VCC,
      ADR2 => ascii_7_IBUF_0,
      ADR3 => ascii_6_IBUF_0,
      O => low_char_cmp_le0000
    );
  low_char_cmp_le00011 : X_LUT4
    generic map(
      INIT => X"1F3F",
      LOC => "SLICE_X0Y23"
    )
    port map (
      ADR0 => ascii_0_IBUF_0,
      ADR1 => ascii_2_IBUF_0,
      ADR2 => ascii_3_IBUF_0,
      ADR3 => ascii_1_IBUF_0,
      O => low_char_cmp_le00011_413
    );
  control_or00001 : X_LUT4
    generic map(
      INIT => X"FFFA",
      LOC => "SLICE_X0Y26"
    )
    port map (
      ADR0 => digit_and0000_128,
      ADR1 => VCC,
      ADR2 => low_char_and0000,
      ADR3 => high_char_and0000,
      O => control_or0000
    );
  high_char_or00001 : X_LUT4
    generic map(
      INIT => X"EEEE",
      LOC => "SLICE_X0Y26"
    )
    port map (
      ADR0 => digit_and0000_128,
      ADR1 => low_char_and0000,
      ADR2 => VCC,
      ADR3 => VCC,
      O => high_char_or0000
    );
  digit_or00001 : X_LUT4
    generic map(
      INIT => X"FFAA",
      LOC => "SLICE_X0Y27"
    )
    port map (
      ADR0 => low_char_and0000,
      ADR1 => VCC,
      ADR2 => VCC,
      ADR3 => high_char_and0000,
      O => digit_or0000
    );
  digit_and0000 : X_LUT4
    generic map(
      INIT => X"0004",
      LOC => "SLICE_X0Y25"
    )
    port map (
      ADR0 => N11_0,
      ADR1 => ascii_5_IBUF_0,
      ADR2 => ascii_7_IBUF_0,
      ADR3 => ascii_6_IBUF_0,
      O => digit_and0000_pack_1
    );
  low_char_or00001 : X_LUT4
    generic map(
      INIT => X"FAFA",
      LOC => "SLICE_X0Y25"
    )
    port map (
      ADR0 => high_char_and0000,
      ADR1 => VCC,
      ADR2 => digit_and0000_128,
      ADR3 => VCC,
      O => low_char_or0000
    );
  ascii_0_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD143",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii_0_IBUF_147,
      O => ascii_0_IBUF_0
    );
  ascii_1_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD133",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii_1_IBUF_154,
      O => ascii_1_IBUF_0
    );
  ascii_2_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD136",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii_2_IBUF_161,
      O => ascii_2_IBUF_0
    );
  ascii_3_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD135",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii_3_IBUF_168,
      O => ascii_3_IBUF_0
    );
  ascii_4_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD134",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii_4_IBUF_175,
      O => ascii_4_IBUF_0
    );
  ascii_5_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD144",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii_5_IBUF_182,
      O => ascii_5_IBUF_0
    );
  ascii_6_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD132",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii_6_IBUF_189,
      O => ascii_6_IBUF_0
    );
  ascii_7_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD131",
      PATHPULSE => 624 ps
    )
    port map (
      I => ascii_7_IBUF_196,
      O => ascii_7_IBUF_0
    );
  NlwBlock_PROCESS_LATCH_VCC : X_ONE
    port map (
      O => VCC
    );
  NlwInverterBlock_low_char_CLK : X_INV
    port map (
      I => low_char_OUTPUT_OTCLK1INVNOT,
      O => NlwInverterSignal_low_char_CLK
    );
  NlwInverterBlock_control_CLK : X_INV
    port map (
      I => control_OUTPUT_OTCLK1INVNOT,
      O => NlwInverterSignal_control_CLK
    );
  NlwBlock_PROCESS_LATCH_GND : X_ZERO
    port map (
      O => GND
    );
  NlwInverterBlock_digit_CLK : X_INV
    port map (
      I => digit_OUTPUT_OTCLK1INVNOT,
      O => NlwInverterSignal_digit_CLK
    );
  NlwInverterBlock_high_char_CLK : X_INV
    port map (
      I => high_char_OUTPUT_OTCLK1INVNOT,
      O => NlwInverterSignal_high_char_CLK
    );
  NlwBlockROC : X_ROC
    generic map (ROC_WIDTH => 100 ns)
    port map (O => GSR);
  NlwBlockTOC : X_TOC
    port map (O => GTS);

end Structure;

