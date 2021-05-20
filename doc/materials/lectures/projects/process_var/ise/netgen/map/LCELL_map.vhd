--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.20131013
--  \   \         Application: netgen
--  /   /         Filename: LCELL_map.vhd
-- /___/   /\     Timestamp: Wed Mar 18 13:09:41 2020
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -s 5 -pcf PROCESS_VAR.pcf -rpw 100 -tpw 0 -ar Structure -tm PROCESS_VAR -w -dir netgen/map -ofmt vhdl -sim PROCESS_VAR_map.ncd LCELL_map.vhd 
-- Device	: 3s50atq144-5 (PRODUCTION 1.42 2013-10-13)
-- Input file	: PROCESS_VAR_map.ncd
-- Output file	: D:\Home\Pozniak\Dokumenty\Wyklady\PUF-EiTI\projekty\process_var\ise\netgen\map\LCELL_map.vhd
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
  signal A_0_IBUF_0 : STD_LOGIC; 
  signal A_1_IBUF_0 : STD_LOGIC; 
  signal A_2_IBUF_0 : STD_LOGIC; 
  signal Y2_0_O : STD_LOGIC; 
  signal Y2_1_O : STD_LOGIC; 
  signal Y2_2_O : STD_LOGIC; 
  signal A_0_IBUF_63 : STD_LOGIC; 
  signal A_1_IBUF_70 : STD_LOGIC; 
  signal A_2_IBUF_77 : STD_LOGIC; 
  signal Y2_2_OBUF_99 : STD_LOGIC; 
  signal Y2_1_OBUF_91 : STD_LOGIC; 
  signal VCC : STD_LOGIC; 
begin
  Y2_0_OBUF : X_OBUF
    port map (
      I => Y2_0_O,
      O => Y2(0)
    );
  Y2_1_OBUF : X_OBUF
    port map (
      I => Y2_1_O,
      O => Y2(1)
    );
  Y2_2_OBUF : X_OBUF
    port map (
      I => Y2_2_O,
      O => Y2(2)
    );
  A_0_IBUF : X_BUF
    generic map(
      PATHPULSE => 624 ps
    )
    port map (
      I => A(0),
      O => A_0_IBUF_63
    );
  A_1_IBUF : X_BUF
    generic map(
      PATHPULSE => 624 ps
    )
    port map (
      I => A(1),
      O => A_1_IBUF_70
    );
  A_2_IBUF : X_BUF
    generic map(
      PATHPULSE => 624 ps
    )
    port map (
      I => A(2),
      O => A_2_IBUF_77
    );
  Madd_add0001_addsub0000_xor_2_11 : X_LUT4
    generic map(
      INIT => X"6C6C"
    )
    port map (
      ADR0 => A_0_IBUF_0,
      ADR1 => A_2_IBUF_0,
      ADR2 => A_1_IBUF_0,
      ADR3 => VCC,
      O => Y2_2_OBUF_99
    );
  Madd_add0001_addsub0000_xor_1_11 : X_LUT4
    generic map(
      INIT => X"6666"
    )
    port map (
      ADR0 => A_1_IBUF_0,
      ADR1 => A_0_IBUF_0,
      ADR2 => VCC,
      ADR3 => VCC,
      O => Y2_1_OBUF_91
    );
  Y2_0_OUTPUT_OFF_OMUX : X_INV
    generic map(
      PATHPULSE => 624 ps
    )
    port map (
      I => A_0_IBUF_0,
      O => Y2_0_O
    );
  Y2_1_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      PATHPULSE => 624 ps
    )
    port map (
      I => Y2_1_OBUF_91,
      O => Y2_1_O
    );
  Y2_2_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      PATHPULSE => 624 ps
    )
    port map (
      I => Y2_2_OBUF_99,
      O => Y2_2_O
    );
  A_0_IFF_IMUX : X_BUF
    generic map(
      PATHPULSE => 624 ps
    )
    port map (
      I => A_0_IBUF_63,
      O => A_0_IBUF_0
    );
  A_1_IFF_IMUX : X_BUF
    generic map(
      PATHPULSE => 624 ps
    )
    port map (
      I => A_1_IBUF_70,
      O => A_1_IBUF_0
    );
  A_2_IFF_IMUX : X_BUF
    generic map(
      PATHPULSE => 624 ps
    )
    port map (
      I => A_2_IBUF_77,
      O => A_2_IBUF_0
    );
  NlwBlock_PROCESS_VAR_VCC : X_ONE
    port map (
      O => VCC
    );
  NlwBlockROC : X_ROC
    generic map (ROC_WIDTH => 100 ns)
    port map (O => GSR);
  NlwBlockTOC : X_TOC
    port map (O => GTS);

end Structure;

