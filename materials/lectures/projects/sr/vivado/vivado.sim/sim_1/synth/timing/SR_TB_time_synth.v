// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
// Date        : Wed Jun 05 12:57:27 2019
// Host        : ktp6 running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               D:/Home/Pozniak/Dokumenty/Wyklady/PUF-EiTI/projekty/sr/vivado/vivado.sim/sim_1/synth/timing/SR_TB_time_synth.v
// Design      : SR_IMPL
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

module SR_ASYNC
   (aQ_OBUF,
    aS_IBUF_BUFG,
    aR_IBUF);
  output aQ_OBUF;
  input aS_IBUF_BUFG;
  input aR_IBUF;

  wire aQ_OBUF;
  wire aR_IBUF;
  wire aS_IBUF_BUFG;

  (* XILINX_LEGACY_PRIM = "LDC" *) 
  LDCE #(
    .INIT(1'b0)) 
    Q_reg
       (.CLR(aR_IBUF),
        .D(aS_IBUF_BUFG),
        .G(aS_IBUF_BUFG),
        .GE(1'b1),
        .Q(aQ_OBUF));
endmodule

(* NotValidForBitStream *)
module SR_IMPL
   (sR,
    sS,
    sQ,
    aR,
    aS,
    aQ);
  input sR;
  input sS;
  output sQ;
  input aR;
  input aS;
  output aQ;

  wire aQ;
  wire aQ_OBUF;
  wire aR;
  wire aR_IBUF;
  wire aS;
  wire aS_IBUF;
  wire aS_IBUF_BUFG;
  wire sQ;
  wire sQ_OBUF;
  wire sR;
  wire sR_IBUF;
  wire sS;
  wire sS_IBUF;

initial begin
 $sdf_annotate("SR_TB_time_synth.sdf",,,,"tool_control");
end
  OBUF aQ_OBUF_inst
       (.I(aQ_OBUF),
        .O(aQ));
  IBUF aR_IBUF_inst
       (.I(aR),
        .O(aR_IBUF));
  BUFG aS_IBUF_BUFG_inst
       (.I(aS_IBUF),
        .O(aS_IBUF_BUFG));
  IBUF aS_IBUF_inst
       (.I(aS),
        .O(aS_IBUF));
  SR_ASYNC asyn
       (.aQ_OBUF(aQ_OBUF),
        .aR_IBUF(aR_IBUF),
        .aS_IBUF_BUFG(aS_IBUF_BUFG));
  OBUF sQ_OBUF_inst
       (.I(sQ_OBUF),
        .O(sQ));
  IBUF sR_IBUF_inst
       (.I(sR),
        .O(sR_IBUF));
  IBUF sS_IBUF_inst
       (.I(sS),
        .O(sS_IBUF));
  SR_SYNC syn
       (.Q(sQ_OBUF),
        .sR_IBUF(sR_IBUF),
        .sS_IBUF(sS_IBUF));
endmodule

module SR_SYNC
   (Q,
    sS_IBUF,
    sR_IBUF);
  output Q;
  input sS_IBUF;
  input sR_IBUF;

  wire Q;
  wire Qreg_i_1_n_0;
  wire Qres;
  wire sR_IBUF;
  wire sS_IBUF;

  LUT2 #(
    .INIT(4'h2)) 
    Qreg_i_1
       (.I0(sS_IBUF),
        .I1(sR_IBUF),
        .O(Qreg_i_1_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    Qreg_i_2
       (.I0(sR_IBUF),
        .I1(Q),
        .O(Qres));
  FDCE #(
    .INIT(1'b0)) 
    Qreg_reg
       (.C(Qreg_i_1_n_0),
        .CE(1'b1),
        .CLR(Qres),
        .D(1'b1),
        .Q(Q));
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
