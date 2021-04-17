// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
// Date        : Wed Mar 25 10:11:12 2020
// Host        : ktp6 running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               D:/Home/Pozniak/Dokumenty/Wyklady/PUF-EiTI/projekty/process_latch/vivado/process_latch.sim/sim_1/synth/timing/PROCESS_LATCH_IMP_TB_time_synth.v
// Design      : PROCESS_LATCH
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xa7a15tcpg236-2I
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

module LDCP_UNIQ_BASE_
   (Q,
    CLR,
    D,
    G,
    PRE);
  output Q;
  input CLR;
  input D;
  input G;
  input PRE;

  wire CLR;
  wire D;
  wire D0;
  wire G;
  wire G0;
  wire GND_1;
  wire PRE;
  wire Q;
  wire VCC_1;

  GND GND
       (.G(GND_1));
  LUT3 #(
    .INIT(8'h32)) 
    L3_1
       (.I0(PRE),
        .I1(CLR),
        .I2(D),
        .O(D0));
  LUT3 #(
    .INIT(8'hFE)) 
    L3_2
       (.I0(G),
        .I1(CLR),
        .I2(PRE),
        .O(G0));
  LDCE #(
    .INIT(1'b0)) 
    L7
       (.CLR(GND_1),
        .D(D0),
        .G(G0),
        .GE(VCC_1),
        .Q(Q));
  VCC VCC
       (.P(VCC_1));
endmodule

module LDCP_HD1
   (Q,
    CLR,
    D,
    G,
    PRE);
  output Q;
  input CLR;
  input D;
  input G;
  input PRE;

  wire CLR;
  wire D;
  wire D0;
  wire G;
  wire G0;
  wire GND_1;
  wire PRE;
  wire Q;
  wire VCC_1;

  GND GND
       (.G(GND_1));
  LUT3 #(
    .INIT(8'h32)) 
    L3_1
       (.I0(PRE),
        .I1(CLR),
        .I2(D),
        .O(D0));
  LUT3 #(
    .INIT(8'hFE)) 
    L3_2
       (.I0(G),
        .I1(CLR),
        .I2(PRE),
        .O(G0));
  LDCE #(
    .INIT(1'b0)) 
    L7
       (.CLR(GND_1),
        .D(D0),
        .G(G0),
        .GE(VCC_1),
        .Q(Q));
  VCC VCC
       (.P(VCC_1));
endmodule

(* NotValidForBitStream *)
module PROCESS_LATCH
   (ascii,
    low_char,
    high_char,
    digit,
    control);
  input [7:0]ascii;
  output low_char;
  output high_char;
  output digit;
  output control;

  wire [7:0]ascii;
  wire [7:0]ascii_IBUF;
  wire control;
  wire control_OBUF;
  wire control_reg_i_1_n_0;
  wire digit;
  wire digit_OBUF;
  wire digit_reg_i_1_n_0;
  wire high_char;
  wire high_char_OBUF;
  wire high_char_reg_i_2_n_0;
  wire low_char;
  wire low_char0;
  wire low_char05_out;
  wire low_char12_out;
  wire low_char_OBUF;
  wire low_char_reg_i_1_n_0;
  wire low_char_reg_i_2_n_0;
  wire low_char_reg_i_4_n_0;
  wire low_char_reg_i_5_n_0;

initial begin
 $sdf_annotate("PROCESS_LATCH_IMP_TB_time_synth.sdf",,,,"tool_control");
end
  IBUF \ascii_IBUF[0]_inst 
       (.I(ascii[0]),
        .O(ascii_IBUF[0]));
  IBUF \ascii_IBUF[1]_inst 
       (.I(ascii[1]),
        .O(ascii_IBUF[1]));
  IBUF \ascii_IBUF[2]_inst 
       (.I(ascii[2]),
        .O(ascii_IBUF[2]));
  IBUF \ascii_IBUF[3]_inst 
       (.I(ascii[3]),
        .O(ascii_IBUF[3]));
  IBUF \ascii_IBUF[4]_inst 
       (.I(ascii[4]),
        .O(ascii_IBUF[4]));
  IBUF \ascii_IBUF[5]_inst 
       (.I(ascii[5]),
        .O(ascii_IBUF[5]));
  IBUF \ascii_IBUF[6]_inst 
       (.I(ascii[6]),
        .O(ascii_IBUF[6]));
  IBUF \ascii_IBUF[7]_inst 
       (.I(ascii[7]),
        .O(ascii_IBUF[7]));
  OBUF control_OBUF_inst
       (.I(control_OBUF),
        .O(control));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  LDCE #(
    .INIT(1'b0)) 
    control_reg
       (.CLR(control_reg_i_1_n_0),
        .D(low_char_reg_i_1_n_0),
        .G(low_char_reg_i_1_n_0),
        .GE(1'b1),
        .Q(control_OBUF));
  LUT4 #(
    .INIT(16'hF888)) 
    control_reg_i_1
       (.I0(ascii_IBUF[5]),
        .I1(low_char_reg_i_4_n_0),
        .I2(ascii_IBUF[6]),
        .I3(low_char_reg_i_5_n_0),
        .O(control_reg_i_1_n_0));
  OBUF digit_OBUF_inst
       (.I(digit_OBUF),
        .O(digit));
  (* INIT = "1'b0" *) 
  LDCP_UNIQ_BASE_ digit_reg
       (.CLR(digit_reg_i_1_n_0),
        .D(1'b0),
        .G(low_char_reg_i_1_n_0),
        .PRE(low_char0),
        .Q(digit_OBUF));
  LUT2 #(
    .INIT(4'h8)) 
    digit_reg_i_1
       (.I0(low_char_reg_i_5_n_0),
        .I1(ascii_IBUF[6]),
        .O(digit_reg_i_1_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    digit_reg_i_2
       (.I0(low_char_reg_i_4_n_0),
        .I1(ascii_IBUF[5]),
        .O(low_char0));
  OBUF high_char_OBUF_inst
       (.I(high_char_OBUF),
        .O(high_char));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  LDCE #(
    .INIT(1'b0)) 
    high_char_reg
       (.CLR(low_char05_out),
        .D(low_char12_out),
        .G(high_char_reg_i_2_n_0),
        .GE(1'b1),
        .Q(high_char_OBUF));
  LUT3 #(
    .INIT(8'h08)) 
    high_char_reg_i_1
       (.I0(ascii_IBUF[6]),
        .I1(low_char_reg_i_5_n_0),
        .I2(ascii_IBUF[5]),
        .O(low_char12_out));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hAAFFAAAB)) 
    high_char_reg_i_2
       (.I0(low_char_reg_i_4_n_0),
        .I1(ascii_IBUF[7]),
        .I2(ascii_IBUF[6]),
        .I3(ascii_IBUF[5]),
        .I4(low_char_reg_i_5_n_0),
        .O(high_char_reg_i_2_n_0));
  OBUF low_char_OBUF_inst
       (.I(low_char_OBUF),
        .O(low_char));
  (* INIT = "1'b0" *) 
  LDCP_HD1 low_char_reg
       (.CLR(low_char_reg_i_2_n_0),
        .D(1'b0),
        .G(low_char_reg_i_1_n_0),
        .PRE(low_char05_out),
        .Q(low_char_OBUF));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h01)) 
    low_char_reg_i_1
       (.I0(ascii_IBUF[7]),
        .I1(ascii_IBUF[6]),
        .I2(ascii_IBUF[5]),
        .O(low_char_reg_i_1_n_0));
  LUT4 #(
    .INIT(16'h3888)) 
    low_char_reg_i_2
       (.I0(low_char_reg_i_4_n_0),
        .I1(ascii_IBUF[5]),
        .I2(low_char_reg_i_5_n_0),
        .I3(ascii_IBUF[6]),
        .O(low_char_reg_i_2_n_0));
  LUT3 #(
    .INIT(8'h80)) 
    low_char_reg_i_3
       (.I0(ascii_IBUF[6]),
        .I1(low_char_reg_i_5_n_0),
        .I2(ascii_IBUF[5]),
        .O(low_char05_out));
  LUT6 #(
    .INIT(64'h0002000200020202)) 
    low_char_reg_i_4
       (.I0(ascii_IBUF[4]),
        .I1(ascii_IBUF[6]),
        .I2(ascii_IBUF[7]),
        .I3(ascii_IBUF[3]),
        .I4(ascii_IBUF[1]),
        .I5(ascii_IBUF[2]),
        .O(low_char_reg_i_4_n_0));
  LUT6 #(
    .INIT(64'h000000001F5FFFFE)) 
    low_char_reg_i_5
       (.I0(ascii_IBUF[2]),
        .I1(ascii_IBUF[1]),
        .I2(ascii_IBUF[3]),
        .I3(ascii_IBUF[0]),
        .I4(ascii_IBUF[4]),
        .I5(ascii_IBUF[7]),
        .O(low_char_reg_i_5_n_0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
