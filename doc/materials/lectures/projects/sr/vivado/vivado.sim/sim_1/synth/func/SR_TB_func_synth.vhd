-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
-- Date        : Sat Apr 27 22:34:12 2019
-- Host        : ktp6 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -mode funcsim -nolib -force -file
--               D:/Home/Pozniak/Dokumenty/Wyklady/ZMPSR/projekty/sr/vivado/vivado.sim/sim_1/synth/func/SR_TB_func_synth.vhd
-- Design      : SR_IMPL
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity SR_ASYNC is
  port (
    aQ_OBUF : out STD_LOGIC;
    aS_IBUF_BUFG : in STD_LOGIC;
    aR_IBUF : in STD_LOGIC
  );
end SR_ASYNC;

architecture STRUCTURE of SR_ASYNC is
  attribute XILINX_LEGACY_PRIM : string;
  attribute XILINX_LEGACY_PRIM of Q_reg : label is "LDC";
begin
Q_reg: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => aR_IBUF,
      D => aS_IBUF_BUFG,
      G => aS_IBUF_BUFG,
      GE => '1',
      Q => aQ_OBUF
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity SR_SYNC is
  port (
    Q : out STD_LOGIC;
    sS_IBUF : in STD_LOGIC;
    sR_IBUF : in STD_LOGIC
  );
end SR_SYNC;

architecture STRUCTURE of SR_SYNC is
  signal \^q\ : STD_LOGIC;
  signal Qreg_i_1_n_0 : STD_LOGIC;
  signal Qres : STD_LOGIC;
begin
  Q <= \^q\;
Qreg_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => sS_IBUF,
      I1 => sR_IBUF,
      O => Qreg_i_1_n_0
    );
Qreg_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => sR_IBUF,
      I1 => \^q\,
      O => Qres
    );
Qreg_reg: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => Qreg_i_1_n_0,
      CE => '1',
      CLR => Qres,
      D => '1',
      Q => \^q\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity SR_IMPL is
  port (
    sR : in STD_LOGIC;
    sS : in STD_LOGIC;
    sQ : out STD_LOGIC;
    aR : in STD_LOGIC;
    aS : in STD_LOGIC;
    aQ : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of SR_IMPL : entity is true;
end SR_IMPL;

architecture STRUCTURE of SR_IMPL is
  signal aQ_OBUF : STD_LOGIC;
  signal aR_IBUF : STD_LOGIC;
  signal aS_IBUF : STD_LOGIC;
  signal aS_IBUF_BUFG : STD_LOGIC;
  signal sQ_OBUF : STD_LOGIC;
  signal sR_IBUF : STD_LOGIC;
  signal sS_IBUF : STD_LOGIC;
begin
aQ_OBUF_inst: unisim.vcomponents.OBUF
     port map (
      I => aQ_OBUF,
      O => aQ
    );
aR_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => aR,
      O => aR_IBUF
    );
aS_IBUF_BUFG_inst: unisim.vcomponents.BUFG
     port map (
      I => aS_IBUF,
      O => aS_IBUF_BUFG
    );
aS_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => aS,
      O => aS_IBUF
    );
asyn: entity work.SR_ASYNC
     port map (
      aQ_OBUF => aQ_OBUF,
      aR_IBUF => aR_IBUF,
      aS_IBUF_BUFG => aS_IBUF_BUFG
    );
sQ_OBUF_inst: unisim.vcomponents.OBUF
     port map (
      I => sQ_OBUF,
      O => sQ
    );
sR_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => sR,
      O => sR_IBUF
    );
sS_IBUF_inst: unisim.vcomponents.IBUF
     port map (
      I => sS,
      O => sS_IBUF
    );
syn: entity work.SR_SYNC
     port map (
      Q => sQ_OBUF,
      sR_IBUF => sR_IBUF,
      sS_IBUF => sS_IBUF
    );
end STRUCTURE;
