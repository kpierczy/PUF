// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
// Date        : Mon Apr 29 07:43:13 2019
// Host        : ktp6 running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               D:/Home/Pozniak/Dokumenty/Wyklady/ZMPSR/projekty/de_reg/vivado/vivado.sim/sim_1/impl/timing/DE_REG_TB_time_impl.v
// Design      : DE_REG_IMPL
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

module DE_REG_ASYNC
   (aQ_OBUF,
    aE_IBUF,
    aC_IBUF_BUFG,
    aL_IBUF,
    aR_IBUF,
    aS_IBUF,
    aV_IBUF,
    aD_IBUF);
  output [0:0]aQ_OBUF;
  input aE_IBUF;
  input aC_IBUF_BUFG;
  input aL_IBUF;
  input aR_IBUF;
  input aS_IBUF;
  input [0:0]aV_IBUF;
  input [0:0]aD_IBUF;

  wire Qreg10;
  wire \Qreg1[0]_C_i_1_n_0 ;
  wire \Qreg1_reg[0]_C_n_0 ;
  wire \Qreg1_reg[0]_LDC_i_1_n_0 ;
  wire \Qreg1_reg[0]_LDC_i_2_n_0 ;
  wire \Qreg1_reg[0]_LDC_n_0 ;
  wire \Qreg1_reg[0]_P_n_0 ;
  wire Qreg2;
  wire Qreg20__0;
  wire Qreg20_n_0;
  wire aC_IBUF_BUFG;
  wire [0:0]aD_IBUF;
  wire aE_IBUF;
  wire aL_IBUF;
  wire [0:0]aQ_OBUF;
  wire aR_IBUF;
  wire aS_IBUF;
  wire [0:0]aV_IBUF;

  LUT4 #(
    .INIT(16'h6F60)) 
    \Qreg1[0]_C_i_1 
       (.I0(aD_IBUF),
        .I1(Qreg2),
        .I2(aE_IBUF),
        .I3(\Qreg1_reg[0]_C_n_0 ),
        .O(\Qreg1[0]_C_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg1[0]_P_i_1 
       (.I0(aD_IBUF),
        .I1(Qreg2),
        .O(Qreg10));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[0]_C 
       (.C(aC_IBUF_BUFG),
        .CE(1'b1),
        .CLR(\Qreg1_reg[0]_LDC_i_2_n_0 ),
        .D(\Qreg1[0]_C_i_1_n_0 ),
        .Q(\Qreg1_reg[0]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  LDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[0]_LDC 
       (.CLR(\Qreg1_reg[0]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\Qreg1_reg[0]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\Qreg1_reg[0]_LDC_n_0 ));
  LUT4 #(
    .INIT(16'h5444)) 
    \Qreg1_reg[0]_LDC_i_1 
       (.I0(aR_IBUF),
        .I1(aS_IBUF),
        .I2(aL_IBUF),
        .I3(aV_IBUF),
        .O(\Qreg1_reg[0]_LDC_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hABAA)) 
    \Qreg1_reg[0]_LDC_i_2 
       (.I0(aR_IBUF),
        .I1(aV_IBUF),
        .I2(aS_IBUF),
        .I3(aL_IBUF),
        .O(\Qreg1_reg[0]_LDC_i_2_n_0 ));
  FDPE #(
    .INIT(1'b1)) 
    \Qreg1_reg[0]_P 
       (.C(aC_IBUF_BUFG),
        .CE(aE_IBUF),
        .D(Qreg10),
        .PRE(\Qreg1_reg[0]_LDC_i_1_n_0 ),
        .Q(\Qreg1_reg[0]_P_n_0 ));
  LUT3 #(
    .INIT(8'hFE)) 
    Qreg20
       (.I0(aL_IBUF),
        .I1(aR_IBUF),
        .I2(aS_IBUF),
        .O(Qreg20_n_0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h56A6)) 
    \Qreg2[0]_i_1 
       (.I0(aD_IBUF),
        .I1(\Qreg1_reg[0]_C_n_0 ),
        .I2(\Qreg1_reg[0]_LDC_n_0 ),
        .I3(\Qreg1_reg[0]_P_n_0 ),
        .O(Qreg20__0));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[0] 
       (.C(aC_IBUF_BUFG),
        .CE(aE_IBUF),
        .CLR(Qreg20_n_0),
        .D(Qreg20__0),
        .Q(Qreg2));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h1DE2)) 
    \aQ_OBUF[0]_inst_i_1 
       (.I0(\Qreg1_reg[0]_C_n_0 ),
        .I1(\Qreg1_reg[0]_LDC_n_0 ),
        .I2(\Qreg1_reg[0]_P_n_0 ),
        .I3(Qreg2),
        .O(aQ_OBUF));
endmodule

(* ECO_CHECKSUM = "69740c76" *) (* WIDTH = "1" *) 
(* NotValidForBitStream *)
module DE_REG_IMPL
   (sR,
    sS,
    sL,
    sV,
    sC,
    sE,
    sD,
    sQ,
    aR,
    aS,
    aL,
    aV,
    aC,
    aE,
    aD,
    aQ);
  input sR;
  input sS;
  input sL;
  input [0:0]sV;
  input sC;
  input sE;
  input [0:0]sD;
  output [0:0]sQ;
  input aR;
  input aS;
  input aL;
  input [0:0]aV;
  input aC;
  input aE;
  input [0:0]aD;
  output [0:0]aQ;

  wire aC;
  wire aC_IBUF;
  wire aC_IBUF_BUFG;
  wire [0:0]aD;
  wire [0:0]aD_IBUF;
  wire aE;
  wire aE_IBUF;
  wire aL;
  wire aL_IBUF;
  wire [0:0]aQ;
  wire [0:0]aQ_OBUF;
  wire aR;
  wire aR_IBUF;
  wire aS;
  wire aS_IBUF;
  wire [0:0]aV;
  wire [0:0]aV_IBUF;
  wire sC;
  wire sC_IBUF;
  wire sC_IBUF_BUFG;
  wire [0:0]sD;
  wire [0:0]sD_IBUF;
  wire sE;
  wire sE_IBUF;
  wire sL;
  wire sL_IBUF;
  wire [0:0]sQ;
  wire [0:0]sQ_OBUF;
  wire sR;
  wire sR_IBUF;
  wire sS;
  wire sS_IBUF;
  wire [0:0]sV;
  wire [0:0]sV_IBUF;

initial begin
 $sdf_annotate("DE_REG_TB_time_impl.sdf",,,,"tool_control");
end
  BUFG aC_IBUF_BUFG_inst
       (.I(aC_IBUF),
        .O(aC_IBUF_BUFG));
  IBUF aC_IBUF_inst
       (.I(aC),
        .O(aC_IBUF));
  IBUF \aD_IBUF[0]_inst 
       (.I(aD),
        .O(aD_IBUF));
  IBUF aE_IBUF_inst
       (.I(aE),
        .O(aE_IBUF));
  IBUF aL_IBUF_inst
       (.I(aL),
        .O(aL_IBUF));
  OBUF \aQ_OBUF[0]_inst 
       (.I(aQ_OBUF),
        .O(aQ));
  IBUF aR_IBUF_inst
       (.I(aR),
        .O(aR_IBUF));
  IBUF aS_IBUF_inst
       (.I(aS),
        .O(aS_IBUF));
  IBUF \aV_IBUF[0]_inst 
       (.I(aV),
        .O(aV_IBUF));
  DE_REG_ASYNC asyn
       (.aC_IBUF_BUFG(aC_IBUF_BUFG),
        .aD_IBUF(aD_IBUF),
        .aE_IBUF(aE_IBUF),
        .aL_IBUF(aL_IBUF),
        .aQ_OBUF(aQ_OBUF),
        .aR_IBUF(aR_IBUF),
        .aS_IBUF(aS_IBUF),
        .aV_IBUF(aV_IBUF));
  BUFG sC_IBUF_BUFG_inst
       (.I(sC_IBUF),
        .O(sC_IBUF_BUFG));
  IBUF sC_IBUF_inst
       (.I(sC),
        .O(sC_IBUF));
  IBUF \sD_IBUF[0]_inst 
       (.I(sD),
        .O(sD_IBUF));
  IBUF sE_IBUF_inst
       (.I(sE),
        .O(sE_IBUF));
  IBUF sL_IBUF_inst
       (.I(sL),
        .O(sL_IBUF));
  OBUF \sQ_OBUF[0]_inst 
       (.I(sQ_OBUF),
        .O(sQ));
  IBUF sR_IBUF_inst
       (.I(sR),
        .O(sR_IBUF));
  IBUF sS_IBUF_inst
       (.I(sS),
        .O(sS_IBUF));
  IBUF \sV_IBUF[0]_inst 
       (.I(sV),
        .O(sV_IBUF));
  DE_REG_SYNC syn
       (.sC_IBUF_BUFG(sC_IBUF_BUFG),
        .sD_IBUF(sD_IBUF),
        .sE_IBUF(sE_IBUF),
        .sL_IBUF(sL_IBUF),
        .sQ_OBUF(sQ_OBUF),
        .sR_IBUF(sR_IBUF),
        .sS_IBUF(sS_IBUF),
        .sV_IBUF(sV_IBUF));
endmodule

module DE_REG_SYNC
   (sQ_OBUF,
    sC_IBUF_BUFG,
    sD_IBUF,
    sE_IBUF,
    sL_IBUF,
    sS_IBUF,
    sV_IBUF,
    sR_IBUF);
  output [0:0]sQ_OBUF;
  input sC_IBUF_BUFG;
  input [0:0]sD_IBUF;
  input sE_IBUF;
  input sL_IBUF;
  input sS_IBUF;
  input [0:0]sV_IBUF;
  input sR_IBUF;

  wire Qreg1;
  wire Qreg10_n_0;
  wire Qreg2;
  wire Qrs;
  wire \lp[0].rs_n_1 ;
  wire \lp[0].rs_n_2 ;
  wire sC_IBUF_BUFG;
  wire [0:0]sD_IBUF;
  wire sE_IBUF;
  wire sL_IBUF;
  wire [0:0]sQ_OBUF;
  wire sR_IBUF;
  wire sS_IBUF;
  wire [0:0]sV_IBUF;

  LUT3 #(
    .INIT(8'h96)) 
    Q
       (.I0(Qreg1),
        .I1(Qreg2),
        .I2(Qrs),
        .O(sQ_OBUF));
  LUT3 #(
    .INIT(8'hFE)) 
    Qreg10
       (.I0(sL_IBUF),
        .I1(sR_IBUF),
        .I2(sS_IBUF),
        .O(Qreg10_n_0));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[0] 
       (.C(sC_IBUF_BUFG),
        .CE(1'b1),
        .CLR(Qreg10_n_0),
        .D(\lp[0].rs_n_2 ),
        .Q(Qreg1));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[0] 
       (.C(sC_IBUF_BUFG),
        .CE(1'b1),
        .CLR(Qreg10_n_0),
        .D(\lp[0].rs_n_1 ),
        .Q(Qreg2));
  SR_SYNC \lp[0].rs 
       (.Qreg1(Qreg1),
        .\Qreg1_reg[0] (\lp[0].rs_n_2 ),
        .Qreg2(Qreg2),
        .\Qreg2_reg[0] (\lp[0].rs_n_1 ),
        .Qrs(Qrs),
        .sD_IBUF(sD_IBUF),
        .sE_IBUF(sE_IBUF),
        .sL_IBUF(sL_IBUF),
        .sR_IBUF(sR_IBUF),
        .sS_IBUF(sS_IBUF),
        .sV_IBUF(sV_IBUF));
endmodule

module SR_SYNC
   (Qrs,
    \Qreg2_reg[0] ,
    \Qreg1_reg[0] ,
    sD_IBUF,
    Qreg1,
    sE_IBUF,
    Qreg2,
    sL_IBUF,
    sS_IBUF,
    sV_IBUF,
    sR_IBUF);
  output Qrs;
  output \Qreg2_reg[0] ;
  output \Qreg1_reg[0] ;
  input [0:0]sD_IBUF;
  input Qreg1;
  input sE_IBUF;
  input Qreg2;
  input sL_IBUF;
  input sS_IBUF;
  input [0:0]sV_IBUF;
  input sR_IBUF;

  wire Qreg1;
  wire \Qreg1_reg[0] ;
  wire Qreg2;
  wire \Qreg2_reg[0] ;
  wire Qreg_i_1_n_0;
  wire Qres;
  wire Qrs;
  wire [0:0]sD_IBUF;
  wire sE_IBUF;
  wire sL_IBUF;
  wire sR_IBUF;
  wire sS_IBUF;
  wire [0:0]sV_IBUF;

  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h96FF9600)) 
    \Qreg1[0]_i_1 
       (.I0(Qrs),
        .I1(sD_IBUF),
        .I2(Qreg2),
        .I3(sE_IBUF),
        .I4(Qreg1),
        .O(\Qreg1_reg[0] ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h96FF9600)) 
    \Qreg2[0]_i_1__0 
       (.I0(Qrs),
        .I1(sD_IBUF),
        .I2(Qreg1),
        .I3(sE_IBUF),
        .I4(Qreg2),
        .O(\Qreg2_reg[0] ));
  LUT4 #(
    .INIT(16'h00EC)) 
    Qreg_i_1
       (.I0(sL_IBUF),
        .I1(sS_IBUF),
        .I2(sV_IBUF),
        .I3(sR_IBUF),
        .O(Qreg_i_1_n_0));
  LUT5 #(
    .INIT(32'hFF020000)) 
    Qreg_i_2
       (.I0(sL_IBUF),
        .I1(sS_IBUF),
        .I2(sV_IBUF),
        .I3(sR_IBUF),
        .I4(Qrs),
        .O(Qres));
  FDCE #(
    .INIT(1'b0)) 
    Qreg_reg
       (.C(Qreg_i_1_n_0),
        .CE(1'b1),
        .CLR(Qres),
        .D(1'b1),
        .Q(Qrs));
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
