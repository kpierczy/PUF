-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
-- Date        : Tue Mar 12 08:31:47 2019
-- Host        : ktp6 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -mode funcsim -nolib -force -file
--               D:/Home/Pozniak/Dokumenty/Wyklady/PUF-EiTI/projekty/process_var/vivado/process_var.sim/sim_1/impl/func/PROCESS_VAR_IMP_TB_func_impl.vhd
-- Design      : PROCESS_VAR
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xa7a15tcpg236-2I
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity PROCESS_VAR is
  port (
    A : in STD_LOGIC_VECTOR ( 2 downto 0 );
    Y1 : out STD_LOGIC_VECTOR ( 2 downto 0 );
    Y2 : out STD_LOGIC_VECTOR ( 2 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of PROCESS_VAR : entity is true;
  attribute ECO_CHECKSUM : string;
  attribute ECO_CHECKSUM of PROCESS_VAR : entity is "6069b75b";
end PROCESS_VAR;

architecture STRUCTURE of PROCESS_VAR is
  signal A_IBUF : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal Y1_OBUF : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal Y2_OBUF : STD_LOGIC_VECTOR ( 2 downto 0 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \Y2_OBUF[1]_inst_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \Y2_OBUF[2]_inst_i_1\ : label is "soft_lutpair0";
begin
\A_IBUF[0]_inst\: unisim.vcomponents.IBUF
     port map (
      I => A(0),
      O => A_IBUF(0)
    );
\A_IBUF[1]_inst\: unisim.vcomponents.IBUF
     port map (
      I => A(1),
      O => A_IBUF(1)
    );
\A_IBUF[2]_inst\: unisim.vcomponents.IBUF
     port map (
      I => A(2),
      O => A_IBUF(2)
    );
\Y1_OBUF[0]_inst\: unisim.vcomponents.OBUF
     port map (
      I => Y1_OBUF(0),
      O => Y1(0)
    );
\Y1_OBUF[0]_inst_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => Y1_OBUF(0),
      O => Y1_OBUF(0)
    );
\Y1_OBUF[1]_inst\: unisim.vcomponents.OBUF
     port map (
      I => Y1_OBUF(1),
      O => Y1(1)
    );
\Y1_OBUF[1]_inst_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => Y1_OBUF(0),
      I1 => Y1_OBUF(1),
      O => Y1_OBUF(1)
    );
\Y1_OBUF[2]_inst\: unisim.vcomponents.OBUF
     port map (
      I => Y1_OBUF(2),
      O => Y1(2)
    );
\Y1_OBUF[2]_inst_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E1"
    )
        port map (
      I0 => Y1_OBUF(0),
      I1 => Y1_OBUF(1),
      I2 => Y1_OBUF(2),
      O => Y1_OBUF(2)
    );
\Y2_OBUF[0]_inst\: unisim.vcomponents.OBUF
     port map (
      I => Y2_OBUF(0),
      O => Y2(0)
    );
\Y2_OBUF[0]_inst_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => A_IBUF(0),
      O => Y2_OBUF(0)
    );
\Y2_OBUF[1]_inst\: unisim.vcomponents.OBUF
     port map (
      I => Y2_OBUF(1),
      O => Y2(1)
    );
\Y2_OBUF[1]_inst_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => A_IBUF(0),
      I1 => A_IBUF(1),
      O => Y2_OBUF(1)
    );
\Y2_OBUF[2]_inst\: unisim.vcomponents.OBUF
     port map (
      I => Y2_OBUF(2),
      O => Y2(2)
    );
\Y2_OBUF[2]_inst_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => A_IBUF(0),
      I1 => A_IBUF(1),
      I2 => A_IBUF(2),
      O => Y2_OBUF(2)
    );
end STRUCTURE;
