// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
// Date        : Tue Mar 17 23:15:56 2020
// Host        : ktp6 running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               D:/Home/Pozniak/Dokumenty/Wyklady/PUF-EiTI/projekty/process_var/vivado/process_var.sim/sim_1/synth/timing/PROCESS_VAR_IMP_TB_time_synth.v
// Design      : PROCESS_VAR
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xa7a15tcpg236-2I
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* NotValidForBitStream *)
module PROCESS_VAR
   (A,
    Y1,
    Y2);
  input [2:0]A;
  output [2:0]Y1;
  output [2:0]Y2;

  wire [2:0]A;
  wire [2:0]A_IBUF;
  wire [2:0]Y1;
  wire [2:0]Y1_OBUF;
  wire [2:0]Y2;
  wire [2:0]Y2_OBUF;

initial begin
 $sdf_annotate("PROCESS_VAR_IMP_TB_time_synth.sdf",,,,"tool_control");
end
  IBUF \A_IBUF[0]_inst 
       (.I(A[0]),
        .O(A_IBUF[0]));
  IBUF \A_IBUF[1]_inst 
       (.I(A[1]),
        .O(A_IBUF[1]));
  IBUF \A_IBUF[2]_inst 
       (.I(A[2]),
        .O(A_IBUF[2]));
  OBUF \Y1_OBUF[0]_inst 
       (.I(Y1_OBUF[0]),
        .O(Y1[0]));
  LUT1 #(
    .INIT(2'h1)) 
    \Y1_OBUF[0]_inst_i_1 
       (.I0(Y1_OBUF[0]),
        .O(Y1_OBUF[0]));
  OBUF \Y1_OBUF[1]_inst 
       (.I(Y1_OBUF[1]),
        .O(Y1[1]));
  LUT2 #(
    .INIT(4'h9)) 
    \Y1_OBUF[1]_inst_i_1 
       (.I0(Y1_OBUF[0]),
        .I1(Y1_OBUF[1]),
        .O(Y1_OBUF[1]));
  OBUF \Y1_OBUF[2]_inst 
       (.I(Y1_OBUF[2]),
        .O(Y1[2]));
  LUT3 #(
    .INIT(8'hE1)) 
    \Y1_OBUF[2]_inst_i_1 
       (.I0(Y1_OBUF[0]),
        .I1(Y1_OBUF[1]),
        .I2(Y1_OBUF[2]),
        .O(Y1_OBUF[2]));
  OBUF \Y2_OBUF[0]_inst 
       (.I(Y2_OBUF[0]),
        .O(Y2[0]));
  LUT1 #(
    .INIT(2'h1)) 
    \Y2_OBUF[0]_inst_i_1 
       (.I0(A_IBUF[0]),
        .O(Y2_OBUF[0]));
  OBUF \Y2_OBUF[1]_inst 
       (.I(Y2_OBUF[1]),
        .O(Y2[1]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \Y2_OBUF[1]_inst_i_1 
       (.I0(A_IBUF[0]),
        .I1(A_IBUF[1]),
        .O(Y2_OBUF[1]));
  OBUF \Y2_OBUF[2]_inst 
       (.I(Y2_OBUF[2]),
        .O(Y2[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \Y2_OBUF[2]_inst_i_1 
       (.I0(A_IBUF[0]),
        .I1(A_IBUF[1]),
        .I2(A_IBUF[2]),
        .O(Y2_OBUF[2]));
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
