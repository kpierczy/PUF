// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
// Date        : Tue Mar 12 23:06:46 2019
// Host        : ktp6 running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               D:/Home/Pozniak/Dokumenty/Wyklady/PUF-EiTI/projekty/process_sync/vivado/process_sync.sim/sim_1/synth/timing/PROCESS_SYNC_IMP_TB_time_synth.v
// Design      : PROCESS_SYNC
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xa7a15tcpg236-2I
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

(* NotValidForBitStream *)
module PROCESS_SYNC
   (R,
    S,
    L,
    E,
    C,
    D,
    Q);
  input R;
  input S;
  input L;
  input E;
  input C;
  input D;
  output Q;

  wire C;
  wire C_IBUF;
  wire C_IBUF_BUFG;
  wire D;
  wire D_IBUF;
  wire E;
  wire E_IBUF;
  wire L;
  wire L_IBUF;
  wire Q;
  wire Q_OBUF;
  wire Q_reg_C_n_0;
  wire Q_reg_LDC_i_1_n_0;
  wire Q_reg_LDC_i_2_n_0;
  wire Q_reg_LDC_n_0;
  wire Q_reg_P_n_0;
  wire R;
  wire R_IBUF;
  wire S;
  wire S_IBUF;

initial begin
 $sdf_annotate("PROCESS_SYNC_IMP_TB_time_synth.sdf",,,,"tool_control");
end
  BUFG C_IBUF_BUFG_inst
       (.I(C_IBUF),
        .O(C_IBUF_BUFG));
  IBUF C_IBUF_inst
       (.I(C),
        .O(C_IBUF));
  IBUF D_IBUF_inst
       (.I(D),
        .O(D_IBUF));
  IBUF E_IBUF_inst
       (.I(E),
        .O(E_IBUF));
  IBUF L_IBUF_inst
       (.I(L),
        .O(L_IBUF));
  OBUF Q_OBUF_inst
       (.I(Q_OBUF),
        .O(Q));
  LUT3 #(
    .INIT(8'hB8)) 
    Q_OBUF_inst_i_1
       (.I0(Q_reg_P_n_0),
        .I1(Q_reg_LDC_n_0),
        .I2(Q_reg_C_n_0),
        .O(Q_OBUF));
  FDCE #(
    .INIT(1'b0)) 
    Q_reg_C
       (.C(C_IBUF_BUFG),
        .CE(E_IBUF),
        .CLR(Q_reg_LDC_i_2_n_0),
        .D(D_IBUF),
        .Q(Q_reg_C_n_0));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  LDCE #(
    .INIT(1'b0)) 
    Q_reg_LDC
       (.CLR(Q_reg_LDC_i_2_n_0),
        .D(1'b1),
        .G(Q_reg_LDC_i_1_n_0),
        .GE(1'b1),
        .Q(Q_reg_LDC_n_0));
  LUT4 #(
    .INIT(16'h00EA)) 
    Q_reg_LDC_i_1
       (.I0(S_IBUF),
        .I1(D_IBUF),
        .I2(L_IBUF),
        .I3(R_IBUF),
        .O(Q_reg_LDC_i_1_n_0));
  LUT4 #(
    .INIT(16'hAAAE)) 
    Q_reg_LDC_i_2
       (.I0(R_IBUF),
        .I1(L_IBUF),
        .I2(S_IBUF),
        .I3(D_IBUF),
        .O(Q_reg_LDC_i_2_n_0));
  FDPE #(
    .INIT(1'b1)) 
    Q_reg_P
       (.C(C_IBUF_BUFG),
        .CE(E_IBUF),
        .D(D_IBUF),
        .PRE(Q_reg_LDC_i_1_n_0),
        .Q(Q_reg_P_n_0));
  IBUF R_IBUF_inst
       (.I(R),
        .O(R_IBUF));
  IBUF S_IBUF_inst
       (.I(S),
        .O(S_IBUF));
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
