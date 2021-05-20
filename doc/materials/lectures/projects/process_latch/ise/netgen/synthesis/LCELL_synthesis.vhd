--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.20131013
--  \   \         Application: netgen
--  /   /         Filename: LCELL_synthesis.vhd
-- /___/   /\     Timestamp: Wed Mar 25 09:51:24 2020
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -ar Structure -tm PROCESS_LATCH -w -dir netgen/synthesis -ofmt vhdl -sim PROCESS_LATCH.ngc LCELL_synthesis.vhd 
-- Device	: xc3s50a-5-tq144
-- Input file	: PROCESS_LATCH.ngc
-- Output file	: D:\Home\Pozniak\Dokumenty\Wyklady\PUF-EiTI\projekty\process_latch\ise\netgen\synthesis\LCELL_synthesis.vhd
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
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

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
  signal N0 : STD_LOGIC; 
  signal N1 : STD_LOGIC; 
  signal N11 : STD_LOGIC; 
  signal ascii_0_IBUF_11 : STD_LOGIC; 
  signal ascii_1_IBUF_12 : STD_LOGIC; 
  signal ascii_2_IBUF_13 : STD_LOGIC; 
  signal ascii_3_IBUF_14 : STD_LOGIC; 
  signal ascii_4_IBUF_15 : STD_LOGIC; 
  signal ascii_5_IBUF_16 : STD_LOGIC; 
  signal ascii_6_IBUF_17 : STD_LOGIC; 
  signal ascii_7_IBUF_18 : STD_LOGIC; 
  signal control_OBUF_20 : STD_LOGIC; 
  signal control_or0000 : STD_LOGIC; 
  signal digit_OBUF_23 : STD_LOGIC; 
  signal digit_and0000_24 : STD_LOGIC; 
  signal digit_or0000 : STD_LOGIC; 
  signal high_char_OBUF_27 : STD_LOGIC; 
  signal high_char_and0000 : STD_LOGIC; 
  signal high_char_and00001_29 : STD_LOGIC; 
  signal high_char_and00002_30 : STD_LOGIC; 
  signal high_char_or0000 : STD_LOGIC; 
  signal low_char_OBUF_33 : STD_LOGIC; 
  signal low_char_and0000 : STD_LOGIC; 
  signal low_char_and00001_35 : STD_LOGIC; 
  signal low_char_and00002_36 : STD_LOGIC; 
  signal low_char_cmp_ge00001_37 : STD_LOGIC; 
  signal low_char_cmp_le0000 : STD_LOGIC; 
  signal low_char_cmp_le00011_39 : STD_LOGIC; 
  signal low_char_or0000 : STD_LOGIC; 
begin
  XST_GND : GND
    port map (
      G => N0
    );
  XST_VCC : VCC
    port map (
      P => N1
    );
  control_3 : LDC
    port map (
      CLR => control_or0000,
      D => N1,
      G => low_char_cmp_le0000,
      Q => control_OBUF_20
    );
  digit_4 : LDCP
    port map (
      CLR => digit_or0000,
      D => N0,
      G => low_char_cmp_le0000,
      PRE => digit_and0000_24,
      Q => digit_OBUF_23
    );
  high_char_5 : LDCP
    port map (
      CLR => high_char_or0000,
      D => N0,
      G => low_char_cmp_le0000,
      PRE => high_char_and0000,
      Q => high_char_OBUF_27
    );
  low_char_6 : LDCP
    port map (
      CLR => low_char_or0000,
      D => N0,
      G => low_char_cmp_le0000,
      PRE => low_char_and0000,
      Q => low_char_OBUF_33
    );
  low_char_or00001 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => high_char_and0000,
      I1 => digit_and0000_24,
      O => low_char_or0000
    );
  high_char_or00001 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => low_char_and0000,
      I1 => digit_and0000_24,
      O => high_char_or0000
    );
  digit_or00001 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => low_char_and0000,
      I1 => high_char_and0000,
      O => digit_or0000
    );
  low_char_cmp_le00001 : LUT3
    generic map(
      INIT => X"01"
    )
    port map (
      I0 => ascii_5_IBUF_16,
      I1 => ascii_6_IBUF_17,
      I2 => ascii_7_IBUF_18,
      O => low_char_cmp_le0000
    );
  control_or00001 : LUT3
    generic map(
      INIT => X"FE"
    )
    port map (
      I0 => high_char_and0000,
      I1 => low_char_and0000,
      I2 => digit_and0000_24,
      O => control_or0000
    );
  low_char_cmp_le00011 : LUT4
    generic map(
      INIT => X"15FF"
    )
    port map (
      I0 => ascii_2_IBUF_13,
      I1 => ascii_1_IBUF_12,
      I2 => ascii_0_IBUF_11,
      I3 => ascii_3_IBUF_14,
      O => low_char_cmp_le00011_39
    );
  low_char_cmp_ge00001 : LUT4
    generic map(
      INIT => X"FFFE"
    )
    port map (
      I0 => ascii_2_IBUF_13,
      I1 => ascii_3_IBUF_14,
      I2 => ascii_0_IBUF_11,
      I3 => ascii_1_IBUF_12,
      O => low_char_cmp_ge00001_37
    );
  digit_and0000_SW0 : LUT4
    generic map(
      INIT => X"A8FF"
    )
    port map (
      I0 => ascii_3_IBUF_14,
      I1 => ascii_1_IBUF_12,
      I2 => ascii_2_IBUF_13,
      I3 => ascii_4_IBUF_15,
      O => N11
    );
  digit_and0000 : LUT4
    generic map(
      INIT => X"0010"
    )
    port map (
      I0 => ascii_7_IBUF_18,
      I1 => ascii_6_IBUF_17,
      I2 => ascii_5_IBUF_16,
      I3 => N11,
      O => digit_and0000_24
    );
  ascii_7_IBUF : IBUF
    port map (
      I => ascii(7),
      O => ascii_7_IBUF_18
    );
  ascii_6_IBUF : IBUF
    port map (
      I => ascii(6),
      O => ascii_6_IBUF_17
    );
  ascii_5_IBUF : IBUF
    port map (
      I => ascii(5),
      O => ascii_5_IBUF_16
    );
  ascii_4_IBUF : IBUF
    port map (
      I => ascii(4),
      O => ascii_4_IBUF_15
    );
  ascii_3_IBUF : IBUF
    port map (
      I => ascii(3),
      O => ascii_3_IBUF_14
    );
  ascii_2_IBUF : IBUF
    port map (
      I => ascii(2),
      O => ascii_2_IBUF_13
    );
  ascii_1_IBUF : IBUF
    port map (
      I => ascii(1),
      O => ascii_1_IBUF_12
    );
  ascii_0_IBUF : IBUF
    port map (
      I => ascii(0),
      O => ascii_0_IBUF_11
    );
  digit_OBUF : OBUF
    port map (
      I => digit_OBUF_23,
      O => digit
    );
  low_char_OBUF : OBUF
    port map (
      I => low_char_OBUF_33,
      O => low_char
    );
  control_OBUF : OBUF
    port map (
      I => control_OBUF_20,
      O => control
    );
  high_char_OBUF : OBUF
    port map (
      I => high_char_OBUF_27,
      O => high_char
    );
  low_char_and00001 : LUT4
    generic map(
      INIT => X"4000"
    )
    port map (
      I0 => ascii_7_IBUF_18,
      I1 => ascii_6_IBUF_17,
      I2 => ascii_5_IBUF_16,
      I3 => low_char_cmp_le00011_39,
      O => low_char_and00001_35
    );
  low_char_and00002 : LUT4
    generic map(
      INIT => X"4000"
    )
    port map (
      I0 => ascii_7_IBUF_18,
      I1 => ascii_6_IBUF_17,
      I2 => ascii_5_IBUF_16,
      I3 => low_char_cmp_ge00001_37,
      O => low_char_and00002_36
    );
  low_char_and0000_f5 : MUXF5
    port map (
      I0 => low_char_and00002_36,
      I1 => low_char_and00001_35,
      S => ascii_4_IBUF_15,
      O => low_char_and0000
    );
  high_char_and00001 : LUT4
    generic map(
      INIT => X"0200"
    )
    port map (
      I0 => ascii_6_IBUF_17,
      I1 => ascii_7_IBUF_18,
      I2 => ascii_5_IBUF_16,
      I3 => low_char_cmp_le00011_39,
      O => high_char_and00001_29
    );
  high_char_and00002 : LUT4
    generic map(
      INIT => X"0200"
    )
    port map (
      I0 => ascii_6_IBUF_17,
      I1 => ascii_7_IBUF_18,
      I2 => ascii_5_IBUF_16,
      I3 => low_char_cmp_ge00001_37,
      O => high_char_and00002_30
    );
  high_char_and0000_f5 : MUXF5
    port map (
      I0 => high_char_and00002_30,
      I1 => high_char_and00001_29,
      S => ascii_4_IBUF_15,
      O => high_char_and0000
    );

end Structure;

