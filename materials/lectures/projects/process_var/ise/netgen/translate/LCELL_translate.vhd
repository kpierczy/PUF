--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.20131013
--  \   \         Application: netgen
--  /   /         Filename: LCELL_translate.vhd
-- /___/   /\     Timestamp: Tue Mar 12 09:26:42 2019
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -rpw 100 -tpw 0 -ar Structure -w -dir netgen/translate -ofmt vhdl -sim PROCESS_VAR.ngd LCELL_translate.vhd 
-- Device	: 3s50atq144-5
-- Input file	: PROCESS_VAR.ngd
-- Output file	: D:\Home\Pozniak\Dokumenty\Wyklady\PUF-EiTI\projekty\process_var\ise\netgen\translate\LCELL_translate.vhd
-- # of Entities	: 1
-- Design Name	: PROCESS_VAR
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

entity PROCESS_VAR is
  port (
    Y1 : out STD_LOGIC_VECTOR ( 2 downto 0 ); 
    Y2 : out STD_LOGIC_VECTOR ( 2 downto 0 ); 
    A : in STD_LOGIC_VECTOR ( 2 downto 0 ) 
  );
end PROCESS_VAR;

architecture Structure of PROCESS_VAR is
  signal A_0_IBUF_3 : STD_LOGIC; 
  signal A_1_IBUF_4 : STD_LOGIC; 
  signal A_2_IBUF_5 : STD_LOGIC; 
  signal Y2_0_OBUF_14 : STD_LOGIC; 
  signal Y2_1_OBUF_15 : STD_LOGIC; 
  signal Y2_2_OBUF_16 : STD_LOGIC; 
  signal GND : STD_LOGIC; 
  signal Madd_add0000_addsub0000_cy : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal Madd_add0000_addsub0000_lut : STD_LOGIC_VECTOR ( 2 downto 2 ); 
begin
  Madd_add0000_addsub0000_xor_2_1 : X_LUT2
    generic map(
      INIT => X"A"
    )
    port map (
      ADR0 => Madd_add0000_addsub0000_lut(2),
      O => Madd_add0000_addsub0000_lut(2),
      ADR1 => GND
    );
  Madd_add0001_addsub0000_xor_1_11 : X_LUT2
    generic map(
      INIT => X"6"
    )
    port map (
      ADR0 => A_1_IBUF_4,
      ADR1 => A_0_IBUF_3,
      O => Y2_1_OBUF_15
    );
  Madd_add0001_addsub0000_xor_2_11 : X_LUT3
    generic map(
      INIT => X"6C"
    )
    port map (
      ADR0 => A_0_IBUF_3,
      ADR1 => A_2_IBUF_5,
      ADR2 => A_1_IBUF_4,
      O => Y2_2_OBUF_16
    );
  A_2_IBUF : X_BUF
    port map (
      I => A(2),
      O => A_2_IBUF_5
    );
  A_1_IBUF : X_BUF
    port map (
      I => A(1),
      O => A_1_IBUF_4
    );
  A_0_IBUF : X_BUF
    port map (
      I => A(0),
      O => A_0_IBUF_3
    );
  Madd_add0000_addsub0000_xor_1_11_INV_0 : X_INV
    port map (
      I => Madd_add0000_addsub0000_cy(0),
      O => Madd_add0000_addsub0000_cy(0)
    );
  Madd_add0001_addsub0000_xor_0_11_INV_0 : X_INV
    port map (
      I => A_0_IBUF_3,
      O => Y2_0_OBUF_14
    );
  Y1_0_OBUF : X_OBUF
    port map (
      I => Madd_add0000_addsub0000_cy(0),
      O => Y1(0)
    );
  Y1_1_OBUF : X_OBUF
    port map (
      I => Madd_add0000_addsub0000_cy(0),
      O => Y1(1)
    );
  Y1_2_OBUF : X_OBUF
    port map (
      I => Madd_add0000_addsub0000_lut(2),
      O => Y1(2)
    );
  Y2_0_OBUF : X_OBUF
    port map (
      I => Y2_0_OBUF_14,
      O => Y2(0)
    );
  Y2_1_OBUF : X_OBUF
    port map (
      I => Y2_1_OBUF_15,
      O => Y2(1)
    );
  Y2_2_OBUF : X_OBUF
    port map (
      I => Y2_2_OBUF_16,
      O => Y2(2)
    );
  NlwBlock_PROCESS_VAR_GND : X_ZERO
    port map (
      O => GND
    );
  NlwBlockROC : X_ROC
    generic map (ROC_WIDTH => 100 ns)
    port map (O => GSR);
  NlwBlockTOC : X_TOC
    port map (O => GTS);

end Structure;

