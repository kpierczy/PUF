--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.20131013
--  \   \         Application: netgen
--  /   /         Filename: LCELL_timesim.vhd
-- /___/   /\     Timestamp: Tue Jun 04 10:13:42 2019
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -s 4 -pcf PROCESS_SYNC.pcf -rpw 100 -tpw 0 -ar Structure -tm PROCESS_SYNC -insert_pp_buffers true -w -dir netgen/par -ofmt vhdl -sim PROCESS_SYNC.ncd LCELL_timesim.vhd 
-- Device	: 3s50atq144-4 (PRODUCTION 1.42 2013-10-13)
-- Input file	: PROCESS_SYNC.ncd
-- Output file	: D:\Home\Pozniak\Dokumenty\Wyklady\PUF-EiTI\projekty\process_sync\ise\netgen\par\LCELL_timesim.vhd
-- # of Entities	: 1
-- Design Name	: PROCESS_SYNC
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

entity PROCESS_SYNC is
  port (
    C : in STD_LOGIC := 'X'; 
    D : in STD_LOGIC := 'X'; 
    E : in STD_LOGIC := 'X'; 
    L : in STD_LOGIC := 'X'; 
    Q : out STD_LOGIC; 
    R : in STD_LOGIC := 'X'; 
    S : in STD_LOGIC := 'X' 
  );
end PROCESS_SYNC;

architecture Structure of PROCESS_SYNC is
  signal C_BUFGP : STD_LOGIC; 
  signal D_IBUF_0 : STD_LOGIC; 
  signal L_IBUF_0 : STD_LOGIC; 
  signal R_IBUF_0 : STD_LOGIC; 
  signal S_IBUF_0 : STD_LOGIC; 
  signal Q_O : STD_LOGIC; 
  signal C_BUFGP_IBUFG_99 : STD_LOGIC; 
  signal D_IBUF_106 : STD_LOGIC; 
  signal E_IBUF_113 : STD_LOGIC; 
  signal L_IBUF_120 : STD_LOGIC; 
  signal R_IBUF_127 : STD_LOGIC; 
  signal S_IBUF_134 : STD_LOGIC; 
  signal C_BUFGP_BUFG_S_INVNOT : STD_LOGIC; 
  signal C_BUFGP_BUFG_I0_INV : STD_LOGIC; 
  signal Q_or0001 : STD_LOGIC; 
  signal Q_or0000 : STD_LOGIC; 
  signal Q_OUTPUT_OTCLK1INV_72 : STD_LOGIC; 
  signal Q_OUTPUT_OFF_OFF1_RST : STD_LOGIC; 
  signal Q_OUTPUT_OFF_OCEINV_92 : STD_LOGIC; 
  signal Q_OBUF_86 : STD_LOGIC; 
  signal Q_OUTPUT_OFF_OREV_USED_84 : STD_LOGIC; 
  signal Q_OUTPUT_OFF_ODDRIN1_MUX : STD_LOGIC; 
  signal GND : STD_LOGIC; 
  signal VCC : STD_LOGIC; 
begin
  Q_OBUF : X_OBUF
    generic map(
      LOC => "PAD70"
    )
    port map (
      I => Q_O,
      O => Q
    );
  C_BUFGP_IBUFG : X_BUF
    generic map(
      LOC => "PAD93",
      PATHPULSE => 741 ps
    )
    port map (
      I => C,
      O => C_BUFGP_IBUFG_99
    );
  D_IBUF : X_BUF
    generic map(
      LOC => "PAD69",
      PATHPULSE => 741 ps
    )
    port map (
      I => D,
      O => D_IBUF_106
    );
  E_IBUF : X_BUF
    generic map(
      LOC => "IPAD65",
      PATHPULSE => 741 ps
    )
    port map (
      I => E,
      O => E_IBUF_113
    );
  L_IBUF : X_BUF
    generic map(
      LOC => "PAD71",
      PATHPULSE => 741 ps
    )
    port map (
      I => L,
      O => L_IBUF_120
    );
  R_IBUF : X_BUF
    generic map(
      LOC => "PAD68",
      PATHPULSE => 741 ps
    )
    port map (
      I => R,
      O => R_IBUF_127
    );
  S_IBUF : X_BUF
    generic map(
      LOC => "PAD72",
      PATHPULSE => 741 ps
    )
    port map (
      I => S,
      O => S_IBUF_134
    );
  C_BUFGP_BUFG : X_BUFGMUX
    generic map(
      LOC => "BUFGMUX_X1Y0"
    )
    port map (
      I0 => C_BUFGP_BUFG_I0_INV,
      I1 => GND,
      S => C_BUFGP_BUFG_S_INVNOT,
      O => C_BUFGP
    );
  C_BUFGP_BUFG_SINV : X_INV
    generic map(
      LOC => "BUFGMUX_X1Y0",
      PATHPULSE => 741 ps
    )
    port map (
      I => '1',
      O => C_BUFGP_BUFG_S_INVNOT
    );
  C_BUFGP_BUFG_I0_USED : X_BUF
    generic map(
      LOC => "BUFGMUX_X1Y0",
      PATHPULSE => 741 ps
    )
    port map (
      I => C_BUFGP_IBUFG_99,
      O => C_BUFGP_BUFG_I0_INV
    );
  Q_OUTPUT_OTCLK1INV : X_BUF
    generic map(
      LOC => "PAD70",
      PATHPULSE => 741 ps
    )
    port map (
      I => C_BUFGP,
      O => Q_OUTPUT_OTCLK1INV_72
    );
  Q_OUTPUT_OFF_OFF1_RSTOR : X_BUF
    generic map(
      LOC => "PAD70",
      PATHPULSE => 741 ps
    )
    port map (
      I => Q_or0000,
      O => Q_OUTPUT_OFF_OFF1_RST
    );
  Q_43 : X_FF
    generic map(
      LOC => "PAD70",
      INIT => '0'
    )
    port map (
      I => Q_OUTPUT_OFF_ODDRIN1_MUX,
      CE => Q_OUTPUT_OFF_OCEINV_92,
      CLK => Q_OUTPUT_OTCLK1INV_72,
      SET => Q_OUTPUT_OFF_OREV_USED_84,
      RST => Q_OUTPUT_OFF_OFF1_RST,
      O => Q_OBUF_86
    );
  Q_OUTPUT_OFF_OMUX : X_BUF
    generic map(
      LOC => "PAD70",
      PATHPULSE => 741 ps
    )
    port map (
      I => Q_OBUF_86,
      O => Q_O
    );
  Q_OUTPUT_OFF_OREV_USED : X_BUF
    generic map(
      LOC => "PAD70",
      PATHPULSE => 741 ps
    )
    port map (
      I => Q_or0001,
      O => Q_OUTPUT_OFF_OREV_USED_84
    );
  Q_OUTPUT_OFF_OCEINV : X_BUF
    generic map(
      LOC => "PAD70",
      PATHPULSE => 741 ps
    )
    port map (
      I => E_IBUF_113,
      O => Q_OUTPUT_OFF_OCEINV_92
    );
  Q_OUTPUT_OFF_O1_DDRMUX : X_BUF
    generic map(
      LOC => "PAD70",
      PATHPULSE => 741 ps
    )
    port map (
      I => D_IBUF_0,
      O => Q_OUTPUT_OFF_ODDRIN1_MUX
    );
  Q_or00001 : X_LUT4
    generic map(
      INIT => X"FF02",
      LOC => "SLICE_X23Y2"
    )
    port map (
      ADR0 => L_IBUF_0,
      ADR1 => D_IBUF_0,
      ADR2 => S_IBUF_0,
      ADR3 => R_IBUF_0,
      O => Q_or0000
    );
  Q_or00011 : X_LUT4
    generic map(
      INIT => X"FAF0",
      LOC => "SLICE_X23Y2"
    )
    port map (
      ADR0 => L_IBUF_0,
      ADR1 => VCC,
      ADR2 => S_IBUF_0,
      ADR3 => D_IBUF_0,
      O => Q_or0001
    );
  D_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD69",
      PATHPULSE => 741 ps
    )
    port map (
      I => D_IBUF_106,
      O => D_IBUF_0
    );
  L_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD71",
      PATHPULSE => 741 ps
    )
    port map (
      I => L_IBUF_120,
      O => L_IBUF_0
    );
  R_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD68",
      PATHPULSE => 741 ps
    )
    port map (
      I => R_IBUF_127,
      O => R_IBUF_0
    );
  S_IFF_IMUX : X_BUF
    generic map(
      LOC => "PAD72",
      PATHPULSE => 741 ps
    )
    port map (
      I => S_IBUF_134,
      O => S_IBUF_0
    );
  NlwBlock_PROCESS_SYNC_GND : X_ZERO
    port map (
      O => GND
    );
  NlwBlock_PROCESS_SYNC_VCC : X_ONE
    port map (
      O => VCC
    );
  NlwBlockROC : X_ROC
    generic map (ROC_WIDTH => 100 ns)
    port map (O => GSR);
  NlwBlockTOC : X_TOC
    port map (O => GTS);

end Structure;

