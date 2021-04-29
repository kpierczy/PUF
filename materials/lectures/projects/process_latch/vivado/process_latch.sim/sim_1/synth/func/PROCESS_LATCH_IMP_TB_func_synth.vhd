-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
-- Date        : Sun Mar 17 23:04:45 2019
-- Host        : ktp6 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -mode funcsim -nolib -force -file
--               D:/Home/Pozniak/Dokumenty/Wyklady/PUF-EiTI/projekty/process_latch/vivado/process_latch.sim/sim_1/synth/func/PROCESS_LATCH_IMP_TB_func_synth.vhd
-- Design      : PROCESS_LATCH
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xa7a15tcpg236-2I
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity PROCESS_LATCH is
  port (
    ascii : in STD_LOGIC_VECTOR ( 7 downto 0 );
    low_char : out STD_LOGIC;
    high_char : out STD_LOGIC;
    digit : out STD_LOGIC;
    control : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of PROCESS_LATCH : entity is true;
end PROCESS_LATCH;

architecture STRUCTURE of PROCESS_LATCH is
  signal ascii_IBUF : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal control_OBUF : STD_LOGIC;
  signal control_reg_i_1_n_0 : STD_LOGIC;
  signal digit_OBUF : STD_LOGIC;
  signal digit_reg_i_1_n_0 : STD_LOGIC;
  signal high_char_OBUF : STD_LOGIC;
  signal high_char_reg_i_2_n_0 : STD_LOGIC;
  signal low_char0 : STD_LOGIC;
  signal low_char05_out : STD_LOGIC;
  signal low_char12_out : STD_LOGIC;
  signal low_char_OBUF : STD_LOGIC;
  signal low_char_reg_i_1_n_0 : STD_LOGIC;
  signal low_char_reg_i_2_n_0 : STD_LOGIC;
  signal low_char_reg_i_4_n_0 : STD_LOGIC;
  signal low_char_reg_i_5_n_0 : STD_LOGIC;
  attribute XILINX_LEGACY_PRIM : string;
  attribute XILINX_LEGACY_PRIM of control_reg : label is "LDC";
  attribute XILINX_LEGACY_PRIM of high_char_reg : label is "LDC";
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of high_char_reg_i_2 : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of low_char_reg_i_1 : label is "soft_lutpair0";
begin
\ascii_IBUF[0]_inst\: unisim.vcomponents.IBUF
     port map (
      I => ascii(0),
      O => ascii_IBUF(0)
    );
\ascii_IBUF[1]_inst\: unisim.vcomponents.IBUF
     port map (
      I => ascii(1),
      O => ascii_IBUF(1)
    );
\ascii_IBUF[2]_inst\: unisim.vcomponents.IBUF
     port map (
      I => ascii(2),
      O => ascii_IBUF(2)
    );
\ascii_IBUF[3]_inst\: unisim.vcomponents.IBUF
     port map (
      I => ascii(3),
      O => ascii_IBUF(3)
    );
\ascii_IBUF[4]_inst\: unisim.vcomponents.IBUF
     port map (
      I => ascii(4),
      O => ascii_IBUF(4)
    );
\ascii_IBUF[5]_inst\: unisim.vcomponents.IBUF
     port map (
      I => ascii(5),
      O => ascii_IBUF(5)
    );
\ascii_IBUF[6]_inst\: unisim.vcomponents.IBUF
     port map (
      I => ascii(6),
      O => ascii_IBUF(6)
    );
\ascii_IBUF[7]_inst\: unisim.vcomponents.IBUF
     port map (
      I => ascii(7),
      O => ascii_IBUF(7)
    );
control_OBUF_inst: unisim.vcomponents.OBUF
     port map (
      I => control_OBUF,
      O => control
    );
control_reg: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => control_reg_i_1_n_0,
      D => low_char_reg_i_1_n_0,
      G => low_char_reg_i_1_n_0,
      GE => '1',
      Q => control_OBUF
    );
control_reg_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"F888"
    )
        port map (
      I0 => ascii_IBUF(5),
      I1 => low_char_reg_i_4_n_0,
      I2 => ascii_IBUF(6),
      I3 => low_char_reg_i_5_n_0,
      O => control_reg_i_1_n_0
    );
digit_OBUF_inst: unisim.vcomponents.OBUF
     port map (
      I => digit_OBUF,
      O => digit
    );
digit_reg: unisim.vcomponents.LDCP
    generic map(
      INIT => '0'
    )
        port map (
      CLR => digit_reg_i_1_n_0,
      D => '0',
      G => low_char_reg_i_1_n_0,
      PRE => low_char0,
      Q => digit_OBUF
    );
digit_reg_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => low_char_reg_i_5_n_0,
      I1 => ascii_IBUF(6),
      O => digit_reg_i_1_n_0
    );
digit_reg_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => low_char_reg_i_4_n_0,
      I1 => ascii_IBUF(5),
      O => low_char0
    );
high_char_OBUF_inst: unisim.vcomponents.OBUF
     port map (
      I => high_char_OBUF,
      O => high_char
    );
high_char_reg: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => low_char05_out,
      D => low_char12_out,
      G => high_char_reg_i_2_n_0,
      GE => '1',
      Q => high_char_OBUF
    );
high_char_reg_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"08"
    )
        port map (
      I0 => ascii_IBUF(6),
      I1 => low_char_reg_i_5_n_0,
      I2 => ascii_IBUF(5),
      O => low_char12_out
    );
high_char_reg_i_2: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AAFFAAAB"
    )
        port map (
      I0 => low_char_reg_i_4_n_0,
      I1 => ascii_IBUF(7),
      I2 => ascii_IBUF(6),
      I3 => ascii_IBUF(5),
      I4 => low_char_reg_i_5_n_0,
      O => high_char_reg_i_2_n_0
    );
low_char_OBUF_inst: unisim.vcomponents.OBUF
     port map (
      I => low_char_OBUF,
      O => low_char
    );
low_char_reg: unisim.vcomponents.LDCP
    generic map(
      INIT => '0'
    )
        port map (
      CLR => low_char_reg_i_2_n_0,
      D => '0',
      G => low_char_reg_i_1_n_0,
      PRE => low_char05_out,
      Q => low_char_OBUF
    );
low_char_reg_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"01"
    )
        port map (
      I0 => ascii_IBUF(7),
      I1 => ascii_IBUF(6),
      I2 => ascii_IBUF(5),
      O => low_char_reg_i_1_n_0
    );
low_char_reg_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"3888"
    )
        port map (
      I0 => low_char_reg_i_4_n_0,
      I1 => ascii_IBUF(5),
      I2 => low_char_reg_i_5_n_0,
      I3 => ascii_IBUF(6),
      O => low_char_reg_i_2_n_0
    );
low_char_reg_i_3: unisim.vcomponents.LUT3
    generic map(
      INIT => X"80"
    )
        port map (
      I0 => ascii_IBUF(6),
      I1 => low_char_reg_i_5_n_0,
      I2 => ascii_IBUF(5),
      O => low_char05_out
    );
low_char_reg_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0002000200020202"
    )
        port map (
      I0 => ascii_IBUF(4),
      I1 => ascii_IBUF(6),
      I2 => ascii_IBUF(7),
      I3 => ascii_IBUF(3),
      I4 => ascii_IBUF(1),
      I5 => ascii_IBUF(2),
      O => low_char_reg_i_4_n_0
    );
low_char_reg_i_5: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000001F5FFFFE"
    )
        port map (
      I0 => ascii_IBUF(2),
      I1 => ascii_IBUF(1),
      I2 => ascii_IBUF(3),
      I3 => ascii_IBUF(0),
      I4 => ascii_IBUF(4),
      I5 => ascii_IBUF(7),
      O => low_char_reg_i_5_n_0
    );
end STRUCTURE;
