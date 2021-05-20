--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.20131013
--  \   \         Application: netgen
--  /   /         Filename: LCELL_translate.vhd
-- /___/   /\     Timestamp: Tue Mar 12 22:57:53 2019
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -intstyle ise -rpw 100 -tpw 0 -ar Structure -w -dir netgen/translate -ofmt vhdl -sim PROCESS_SYNC.ngd LCELL_translate.vhd 
-- Device	: 3s50atq144-4
-- Input file	: PROCESS_SYNC.ngd
-- Output file	: D:\Home\Pozniak\Dokumenty\Wyklady\PUF-EiTI\projekty\process_sync\ise\netgen\translate\LCELL_translate.vhd
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
  signal D_IBUF_6 : STD_LOGIC; 
  signal E_IBUF_8 : STD_LOGIC; 
  signal L_IBUF_10 : STD_LOGIC; 
  signal Q_OBUF_12 : STD_LOGIC; 
  signal Q_or0000 : STD_LOGIC; 
  signal Q_or0001 : STD_LOGIC; 
  signal R_IBUF_16 : STD_LOGIC; 
  signal S_IBUF_18 : STD_LOGIC; 
  signal C_BUFGP_IBUFG_2 : STD_LOGIC; 
begin
  Q_1 : X_FF
    generic map(
      INIT => '0'
    )
    port map (
      CLK => C_BUFGP,
      CE => E_IBUF_8,
      RST => Q_or0000,
      I => D_IBUF_6,
      SET => Q_or0001,
      O => Q_OBUF_12
    );
  Q_or00011 : X_LUT3
    generic map(
      INIT => X"F8"
    )
    port map (
      ADR0 => L_IBUF_10,
      ADR1 => D_IBUF_6,
      ADR2 => S_IBUF_18,
      O => Q_or0001
    );
  Q_or00001 : X_LUT4
    generic map(
      INIT => X"FF04"
    )
    port map (
      ADR0 => S_IBUF_18,
      ADR1 => L_IBUF_10,
      ADR2 => D_IBUF_6,
      ADR3 => R_IBUF_16,
      O => Q_or0000
    );
  D_IBUF : X_BUF
    port map (
      I => D,
      O => D_IBUF_6
    );
  E_IBUF : X_BUF
    port map (
      I => E,
      O => E_IBUF_8
    );
  L_IBUF : X_BUF
    port map (
      I => L,
      O => L_IBUF_10
    );
  R_IBUF : X_BUF
    port map (
      I => R,
      O => R_IBUF_16
    );
  S_IBUF : X_BUF
    port map (
      I => S,
      O => S_IBUF_18
    );
  C_BUFGP_BUFG : X_CKBUF
    port map (
      I => C_BUFGP_IBUFG_2,
      O => C_BUFGP
    );
  C_BUFGP_IBUFG : X_CKBUF
    port map (
      I => C,
      O => C_BUFGP_IBUFG_2
    );
  Q_OBUF : X_OBUF
    port map (
      I => Q_OBUF_12,
      O => Q
    );
  NlwBlockROC : X_ROC
    generic map (ROC_WIDTH => 100 ns)
    port map (O => GSR);
  NlwBlockTOC : X_TOC
    port map (O => GTS);

end Structure;

