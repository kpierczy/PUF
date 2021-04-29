// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1756540 Mon Jan 23 19:11:23 MST 2017
// Date        : Mon Apr 29 11:13:24 2019
// Host        : ktp6 running 64-bit major release  (build 9200)
// Command     : write_verilog -mode timesim -nolib -sdf_anno true -force -file
//               D:/Home/Pozniak/Dokumenty/Wyklady/ZMPSR/projekty/de_max/vivado/vivado.sim/sim_1/impl/timing/DE_MAX_TB_time_impl.v
// Design      : DE_MAX8
// Purpose     : This verilog netlist is a timing simulation representation of the design and should not be modified or
//               synthesized. Please ensure that this netlist is used with the corresponding SDF file.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps
`define XIL_TIMING

module DE_MAX
   (M_OBUF,
    E,
    CLK,
    R_IBUF,
    L_IBUF,
    S_IBUF,
    V_IBUF,
    D_IBUF);
  output [7:0]M_OBUF;
  input [0:0]E;
  input CLK;
  input R_IBUF;
  input L_IBUF;
  input S_IBUF;
  input [7:0]V_IBUF;
  input [7:0]D_IBUF;

  wire CLK;
  wire [7:0]D_IBUF;
  wire [0:0]E;
  wire E2_carry_n_0;
  wire E3_carry_n_0;
  wire \E3_inferred__0/i__carry_n_0 ;
  wire L_IBUF;
  wire [7:0]M_OBUF;
  wire [7:0]Q2;
  wire [7:0]Qreg1;
  wire [7:0]Qreg10;
  wire [7:0]Qreg10_0;
  wire [7:0]Qreg1_2;
  wire [7:0]Qreg2;
  wire [7:0]Qreg20;
  wire [7:0]Qreg20_1;
  wire [7:0]Qreg2_3;
  wire R_IBUF;
  wire S_IBUF;
  wire T;
  wire [7:0]V_IBUF;
  wire reg1_n_0;
  wire reg1_n_1;
  wire reg1_n_2;
  wire reg1_n_3;
  wire reg1_n_4;
  wire reg1_n_5;
  wire reg1_n_6;
  wire reg1_n_7;
  wire reg3_n_0;
  wire reg3_n_1;
  wire reg3_n_2;
  wire reg3_n_20;
  wire reg3_n_21;
  wire reg3_n_22;
  wire reg3_n_23;
  wire reg3_n_3;
  wire regm_n_0;
  wire regm_n_1;
  wire regm_n_12;
  wire regm_n_13;
  wire regm_n_14;
  wire regm_n_15;
  wire regm_n_2;
  wire regm_n_3;
  wire [2:0]NLW_E2_carry_CO_UNCONNECTED;
  wire [3:0]NLW_E2_carry_O_UNCONNECTED;
  wire [2:0]NLW_E3_carry_CO_UNCONNECTED;
  wire [3:0]NLW_E3_carry_O_UNCONNECTED;
  wire [2:0]\NLW_E3_inferred__0/i__carry_CO_UNCONNECTED ;
  wire [3:0]\NLW_E3_inferred__0/i__carry_O_UNCONNECTED ;

  CARRY4 E2_carry
       (.CI(1'b0),
        .CO({E2_carry_n_0,NLW_E2_carry_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b0),
        .DI({regm_n_12,regm_n_13,regm_n_14,regm_n_15}),
        .O(NLW_E2_carry_O_UNCONNECTED[3:0]),
        .S({regm_n_0,regm_n_1,regm_n_2,regm_n_3}));
  CARRY4 E3_carry
       (.CI(1'b0),
        .CO({E3_carry_n_0,NLW_E3_carry_CO_UNCONNECTED[2:0]}),
        .CYINIT(1'b1),
        .DI({reg3_n_20,reg3_n_21,reg3_n_22,reg3_n_23}),
        .O(NLW_E3_carry_O_UNCONNECTED[3:0]),
        .S({reg3_n_0,reg3_n_1,reg3_n_2,reg3_n_3}));
  CARRY4 \E3_inferred__0/i__carry 
       (.CI(1'b0),
        .CO({\E3_inferred__0/i__carry_n_0 ,\NLW_E3_inferred__0/i__carry_CO_UNCONNECTED [2:0]}),
        .CYINIT(1'b0),
        .DI({reg1_n_4,reg1_n_5,reg1_n_6,reg1_n_7}),
        .O(\NLW_E3_inferred__0/i__carry_O_UNCONNECTED [3:0]),
        .S({reg1_n_0,reg1_n_1,reg1_n_2,reg1_n_3}));
  DE_REG_SYNC reg1
       (.CLK(CLK),
        .D(Qreg20),
        .DI({reg1_n_4,reg1_n_5,reg1_n_6,reg1_n_7}),
        .D_IBUF(D_IBUF),
        .E(E),
        .Q(Qreg1),
        .Q2(Q2),
        .\Qreg1_reg[7]_0 (Qreg10),
        .\Qreg2_reg[7]_0 (Qreg2),
        .R_IBUF(R_IBUF),
        .S({reg1_n_0,reg1_n_1,reg1_n_2,reg1_n_3}));
  DE_REG_SYNC_0 reg2
       (.CLK(CLK),
        .D(Qreg20_1),
        .E(E),
        .Q(Qreg2),
        .Q2(Q2),
        .\Qreg1_reg[7]_0 (Qreg10_0),
        .\Qreg1_reg[7]_1 (Qreg1_2),
        .\Qreg2_reg[7]_0 (Qreg1),
        .\Qreg2_reg[7]_1 (Qreg2_3),
        .\Qreg2_reg[7]_2 (Qreg20),
        .\Qreg2_reg[7]_3 (Qreg10),
        .R_IBUF(R_IBUF));
  DE_REG_SYNC_1 reg3
       (.CLK(CLK),
        .CO(E3_carry_n_0),
        .D(Qreg20_1),
        .DI({reg3_n_20,reg3_n_21,reg3_n_22,reg3_n_23}),
        .E(T),
        .E_0(E),
        .Q(Qreg2_3),
        .Q2(Q2),
        .\Qreg2_reg[7]_0 (Qreg1_2),
        .\Qreg2_reg[7]_1 (\E3_inferred__0/i__carry_n_0 ),
        .\Qreg2_reg[7]_2 (Qreg10_0),
        .Qreg_reg(E2_carry_n_0),
        .R_IBUF(R_IBUF),
        .S({reg3_n_0,reg3_n_1,reg3_n_2,reg3_n_3}));
  DE_REG_SYNC_2 regm
       (.CLK(CLK),
        .DI({regm_n_12,regm_n_13,regm_n_14,regm_n_15}),
        .E(T),
        .L_IBUF(L_IBUF),
        .M_OBUF(M_OBUF),
        .Q(Qreg2),
        .Q2(Q2),
        .\Qreg1_reg[7]_0 (Qreg1),
        .R_IBUF(R_IBUF),
        .S({regm_n_0,regm_n_1,regm_n_2,regm_n_3}),
        .S_IBUF(S_IBUF),
        .V_IBUF(V_IBUF));
endmodule

(* ECO_CHECKSUM = "35d33cb" *) 
(* NotValidForBitStream *)
module DE_MAX8
   (R,
    S,
    L,
    V,
    C,
    E,
    D,
    M);
  input R;
  input S;
  input L;
  input [7:0]V;
  input C;
  input E;
  input [7:0]D;
  output [7:0]M;

  wire C;
  wire C_IBUF;
  wire C_IBUF_BUFG;
  wire [7:0]D;
  wire [7:0]D_IBUF;
  wire E;
  wire E_IBUF;
  wire L;
  wire L_IBUF;
  wire [7:0]M;
  wire [7:0]M_OBUF;
  wire R;
  wire R_IBUF;
  wire S;
  wire S_IBUF;
  wire [7:0]V;
  wire [7:0]V_IBUF;

initial begin
 $sdf_annotate("DE_MAX_TB_time_impl.sdf",,,,"tool_control");
end
  BUFG C_IBUF_BUFG_inst
       (.I(C_IBUF),
        .O(C_IBUF_BUFG));
  IBUF C_IBUF_inst
       (.I(C),
        .O(C_IBUF));
  IBUF \D_IBUF[0]_inst 
       (.I(D[0]),
        .O(D_IBUF[0]));
  IBUF \D_IBUF[1]_inst 
       (.I(D[1]),
        .O(D_IBUF[1]));
  IBUF \D_IBUF[2]_inst 
       (.I(D[2]),
        .O(D_IBUF[2]));
  IBUF \D_IBUF[3]_inst 
       (.I(D[3]),
        .O(D_IBUF[3]));
  IBUF \D_IBUF[4]_inst 
       (.I(D[4]),
        .O(D_IBUF[4]));
  IBUF \D_IBUF[5]_inst 
       (.I(D[5]),
        .O(D_IBUF[5]));
  IBUF \D_IBUF[6]_inst 
       (.I(D[6]),
        .O(D_IBUF[6]));
  IBUF \D_IBUF[7]_inst 
       (.I(D[7]),
        .O(D_IBUF[7]));
  IBUF E_IBUF_inst
       (.I(E),
        .O(E_IBUF));
  IBUF L_IBUF_inst
       (.I(L),
        .O(L_IBUF));
  OBUF \M_OBUF[0]_inst 
       (.I(M_OBUF[0]),
        .O(M[0]));
  OBUF \M_OBUF[1]_inst 
       (.I(M_OBUF[1]),
        .O(M[1]));
  OBUF \M_OBUF[2]_inst 
       (.I(M_OBUF[2]),
        .O(M[2]));
  OBUF \M_OBUF[3]_inst 
       (.I(M_OBUF[3]),
        .O(M[3]));
  OBUF \M_OBUF[4]_inst 
       (.I(M_OBUF[4]),
        .O(M[4]));
  OBUF \M_OBUF[5]_inst 
       (.I(M_OBUF[5]),
        .O(M[5]));
  OBUF \M_OBUF[6]_inst 
       (.I(M_OBUF[6]),
        .O(M[6]));
  OBUF \M_OBUF[7]_inst 
       (.I(M_OBUF[7]),
        .O(M[7]));
  IBUF R_IBUF_inst
       (.I(R),
        .O(R_IBUF));
  IBUF S_IBUF_inst
       (.I(S),
        .O(S_IBUF));
  IBUF \V_IBUF[0]_inst 
       (.I(V[0]),
        .O(V_IBUF[0]));
  IBUF \V_IBUF[1]_inst 
       (.I(V[1]),
        .O(V_IBUF[1]));
  IBUF \V_IBUF[2]_inst 
       (.I(V[2]),
        .O(V_IBUF[2]));
  IBUF \V_IBUF[3]_inst 
       (.I(V[3]),
        .O(V_IBUF[3]));
  IBUF \V_IBUF[4]_inst 
       (.I(V[4]),
        .O(V_IBUF[4]));
  IBUF \V_IBUF[5]_inst 
       (.I(V[5]),
        .O(V_IBUF[5]));
  IBUF \V_IBUF[6]_inst 
       (.I(V[6]),
        .O(V_IBUF[6]));
  IBUF \V_IBUF[7]_inst 
       (.I(V[7]),
        .O(V_IBUF[7]));
  DE_MAX inst
       (.CLK(C_IBUF_BUFG),
        .D_IBUF(D_IBUF),
        .E(E_IBUF),
        .L_IBUF(L_IBUF),
        .M_OBUF(M_OBUF),
        .R_IBUF(R_IBUF),
        .S_IBUF(S_IBUF),
        .V_IBUF(V_IBUF));
endmodule

module DE_REG_SYNC
   (S,
    DI,
    D,
    \Qreg1_reg[7]_0 ,
    Q2,
    Q,
    \Qreg2_reg[7]_0 ,
    D_IBUF,
    E,
    CLK,
    R_IBUF);
  output [3:0]S;
  output [3:0]DI;
  output [7:0]D;
  output [7:0]\Qreg1_reg[7]_0 ;
  input [7:0]Q2;
  input [7:0]Q;
  input [7:0]\Qreg2_reg[7]_0 ;
  input [7:0]D_IBUF;
  input [0:0]E;
  input CLK;
  input R_IBUF;

  wire CLK;
  wire [7:0]D;
  wire [3:0]DI;
  wire [7:0]D_IBUF;
  wire [0:0]E;
  wire [7:0]Q;
  wire [7:0]Q2;
  wire [7:0]Qreg1;
  wire [7:0]Qreg10;
  wire [7:0]\Qreg1_reg[7]_0 ;
  wire [7:0]Qreg2;
  wire [7:0]Qreg20;
  wire [7:0]\Qreg2_reg[7]_0 ;
  wire R_IBUF;
  wire [3:0]S;

  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[0]_i_1__1 
       (.I0(Qreg2[0]),
        .I1(Qreg1[0]),
        .I2(\Qreg2_reg[7]_0 [0]),
        .O(\Qreg1_reg[7]_0 [0]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg1[0]_i_1__2 
       (.I0(D_IBUF[0]),
        .I1(Qreg2[0]),
        .O(Qreg10[0]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[1]_i_1__1 
       (.I0(Qreg2[1]),
        .I1(Qreg1[1]),
        .I2(\Qreg2_reg[7]_0 [1]),
        .O(\Qreg1_reg[7]_0 [1]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg1[1]_i_1__2 
       (.I0(D_IBUF[1]),
        .I1(Qreg2[1]),
        .O(Qreg10[1]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[2]_i_1__1 
       (.I0(Qreg2[2]),
        .I1(Qreg1[2]),
        .I2(\Qreg2_reg[7]_0 [2]),
        .O(\Qreg1_reg[7]_0 [2]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg1[2]_i_1__2 
       (.I0(D_IBUF[2]),
        .I1(Qreg2[2]),
        .O(Qreg10[2]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[3]_i_1__1 
       (.I0(Qreg2[3]),
        .I1(Qreg1[3]),
        .I2(\Qreg2_reg[7]_0 [3]),
        .O(\Qreg1_reg[7]_0 [3]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg1[3]_i_1__2 
       (.I0(D_IBUF[3]),
        .I1(Qreg2[3]),
        .O(Qreg10[3]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[4]_i_1__1 
       (.I0(Qreg2[4]),
        .I1(Qreg1[4]),
        .I2(\Qreg2_reg[7]_0 [4]),
        .O(\Qreg1_reg[7]_0 [4]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg1[4]_i_1__2 
       (.I0(D_IBUF[4]),
        .I1(Qreg2[4]),
        .O(Qreg10[4]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[5]_i_1__1 
       (.I0(Qreg2[5]),
        .I1(Qreg1[5]),
        .I2(\Qreg2_reg[7]_0 [5]),
        .O(\Qreg1_reg[7]_0 [5]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg1[5]_i_1__2 
       (.I0(D_IBUF[5]),
        .I1(Qreg2[5]),
        .O(Qreg10[5]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[6]_i_1__1 
       (.I0(Qreg2[6]),
        .I1(Qreg1[6]),
        .I2(\Qreg2_reg[7]_0 [6]),
        .O(\Qreg1_reg[7]_0 [6]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg1[6]_i_1__2 
       (.I0(D_IBUF[6]),
        .I1(Qreg2[6]),
        .O(Qreg10[6]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[7]_i_1__1 
       (.I0(Qreg2[7]),
        .I1(Qreg1[7]),
        .I2(\Qreg2_reg[7]_0 [7]),
        .O(\Qreg1_reg[7]_0 [7]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg1[7]_i_1__2 
       (.I0(D_IBUF[7]),
        .I1(Qreg2[7]),
        .O(Qreg10[7]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[0] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg10[0]),
        .Q(Qreg1[0]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[1] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg10[1]),
        .Q(Qreg1[1]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[2] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg10[2]),
        .Q(Qreg1[2]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[3] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg10[3]),
        .Q(Qreg1[3]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[4] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg10[4]),
        .Q(Qreg1[4]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[5] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg10[5]),
        .Q(Qreg1[5]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[6] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg10[6]),
        .Q(Qreg1[6]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[7] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg10[7]),
        .Q(Qreg1[7]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[0]_i_1__1 
       (.I0(Qreg2[0]),
        .I1(Qreg1[0]),
        .I2(Q[0]),
        .O(D[0]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg2[0]_i_1__2 
       (.I0(D_IBUF[0]),
        .I1(Qreg1[0]),
        .O(Qreg20[0]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[1]_i_1__1 
       (.I0(Qreg2[1]),
        .I1(Qreg1[1]),
        .I2(Q[1]),
        .O(D[1]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg2[1]_i_1__2 
       (.I0(D_IBUF[1]),
        .I1(Qreg1[1]),
        .O(Qreg20[1]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[2]_i_1__1 
       (.I0(Qreg2[2]),
        .I1(Qreg1[2]),
        .I2(Q[2]),
        .O(D[2]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg2[2]_i_1__2 
       (.I0(D_IBUF[2]),
        .I1(Qreg1[2]),
        .O(Qreg20[2]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[3]_i_1__1 
       (.I0(Qreg2[3]),
        .I1(Qreg1[3]),
        .I2(Q[3]),
        .O(D[3]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg2[3]_i_1__2 
       (.I0(D_IBUF[3]),
        .I1(Qreg1[3]),
        .O(Qreg20[3]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[4]_i_1__1 
       (.I0(Qreg2[4]),
        .I1(Qreg1[4]),
        .I2(Q[4]),
        .O(D[4]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg2[4]_i_1__2 
       (.I0(D_IBUF[4]),
        .I1(Qreg1[4]),
        .O(Qreg20[4]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[5]_i_1__1 
       (.I0(Qreg2[5]),
        .I1(Qreg1[5]),
        .I2(Q[5]),
        .O(D[5]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg2[5]_i_1__2 
       (.I0(D_IBUF[5]),
        .I1(Qreg1[5]),
        .O(Qreg20[5]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[6]_i_1__1 
       (.I0(Qreg2[6]),
        .I1(Qreg1[6]),
        .I2(Q[6]),
        .O(D[6]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg2[6]_i_1__2 
       (.I0(D_IBUF[6]),
        .I1(Qreg1[6]),
        .O(Qreg20[6]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[7]_i_1__0 
       (.I0(Qreg2[7]),
        .I1(Qreg1[7]),
        .I2(Q[7]),
        .O(D[7]));
  LUT2 #(
    .INIT(4'h6)) 
    \Qreg2[7]_i_1__1 
       (.I0(D_IBUF[7]),
        .I1(Qreg1[7]),
        .O(Qreg20[7]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[0] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg20[0]),
        .Q(Qreg2[0]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[1] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg20[1]),
        .Q(Qreg2[1]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[2] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg20[2]),
        .Q(Qreg2[2]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[3] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg20[3]),
        .Q(Qreg2[3]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[4] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg20[4]),
        .Q(Qreg2[4]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[5] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg20[5]),
        .Q(Qreg2[5]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[6] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg20[6]),
        .Q(Qreg2[6]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[7] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(Qreg20[7]),
        .Q(Qreg2[7]));
  LUT6 #(
    .INIT(64'hEB8282828282EB82)) 
    i__carry_i_1
       (.I0(Q2[7]),
        .I1(Qreg2[7]),
        .I2(Qreg1[7]),
        .I3(Q2[6]),
        .I4(Qreg2[6]),
        .I5(Qreg1[6]),
        .O(DI[3]));
  LUT6 #(
    .INIT(64'hEB8282828282EB82)) 
    i__carry_i_2
       (.I0(Q2[5]),
        .I1(Qreg2[5]),
        .I2(Qreg1[5]),
        .I3(Q2[4]),
        .I4(Qreg2[4]),
        .I5(Qreg1[4]),
        .O(DI[2]));
  LUT6 #(
    .INIT(64'hEB8282828282EB82)) 
    i__carry_i_3
       (.I0(Q2[3]),
        .I1(Qreg2[3]),
        .I2(Qreg1[3]),
        .I3(Q2[2]),
        .I4(Qreg2[2]),
        .I5(Qreg1[2]),
        .O(DI[1]));
  LUT6 #(
    .INIT(64'hEB8282828282EB82)) 
    i__carry_i_4
       (.I0(Q2[1]),
        .I1(Qreg2[1]),
        .I2(Qreg1[1]),
        .I3(Q2[0]),
        .I4(Qreg2[0]),
        .I5(Qreg1[0]),
        .O(DI[0]));
  LUT6 #(
    .INIT(64'h0069690069000069)) 
    i__carry_i_5
       (.I0(Qreg2[7]),
        .I1(Qreg1[7]),
        .I2(Q2[7]),
        .I3(Qreg2[6]),
        .I4(Qreg1[6]),
        .I5(Q2[6]),
        .O(S[3]));
  LUT6 #(
    .INIT(64'h0069690069000069)) 
    i__carry_i_6
       (.I0(Qreg2[5]),
        .I1(Qreg1[5]),
        .I2(Q2[5]),
        .I3(Qreg2[4]),
        .I4(Qreg1[4]),
        .I5(Q2[4]),
        .O(S[2]));
  LUT6 #(
    .INIT(64'h0069690069000069)) 
    i__carry_i_7
       (.I0(Qreg2[3]),
        .I1(Qreg1[3]),
        .I2(Q2[3]),
        .I3(Qreg2[2]),
        .I4(Qreg1[2]),
        .I5(Q2[2]),
        .O(S[1]));
  LUT6 #(
    .INIT(64'h0069690069000069)) 
    i__carry_i_8
       (.I0(Qreg2[1]),
        .I1(Qreg1[1]),
        .I2(Q2[1]),
        .I3(Qreg2[0]),
        .I4(Qreg1[0]),
        .I5(Q2[0]),
        .O(S[0]));
endmodule

(* ORIG_REF_NAME = "DE_REG_SYNC" *) 
module DE_REG_SYNC_0
   (D,
    Q,
    \Qreg2_reg[7]_0 ,
    \Qreg1_reg[7]_0 ,
    Q2,
    \Qreg1_reg[7]_1 ,
    \Qreg2_reg[7]_1 ,
    E,
    \Qreg2_reg[7]_2 ,
    CLK,
    R_IBUF,
    \Qreg2_reg[7]_3 );
  output [7:0]D;
  output [7:0]Q;
  output [7:0]\Qreg2_reg[7]_0 ;
  output [7:0]\Qreg1_reg[7]_0 ;
  output [7:0]Q2;
  input [7:0]\Qreg1_reg[7]_1 ;
  input [7:0]\Qreg2_reg[7]_1 ;
  input [0:0]E;
  input [7:0]\Qreg2_reg[7]_2 ;
  input CLK;
  input R_IBUF;
  input [7:0]\Qreg2_reg[7]_3 ;

  wire CLK;
  wire [7:0]D;
  wire [0:0]E;
  wire [7:0]Q;
  wire [7:0]Q2;
  wire [7:0]\Qreg1_reg[7]_0 ;
  wire [7:0]\Qreg1_reg[7]_1 ;
  wire [7:0]\Qreg2_reg[7]_0 ;
  wire [7:0]\Qreg2_reg[7]_1 ;
  wire [7:0]\Qreg2_reg[7]_2 ;
  wire [7:0]\Qreg2_reg[7]_3 ;
  wire R_IBUF;

  LUT2 #(
    .INIT(4'h6)) 
    E3_carry_i_10
       (.I0(\Qreg2_reg[7]_0 [6]),
        .I1(Q[6]),
        .O(Q2[6]));
  LUT2 #(
    .INIT(4'h6)) 
    E3_carry_i_11
       (.I0(\Qreg2_reg[7]_0 [5]),
        .I1(Q[5]),
        .O(Q2[5]));
  LUT2 #(
    .INIT(4'h6)) 
    E3_carry_i_12
       (.I0(\Qreg2_reg[7]_0 [4]),
        .I1(Q[4]),
        .O(Q2[4]));
  LUT2 #(
    .INIT(4'h6)) 
    E3_carry_i_13
       (.I0(\Qreg2_reg[7]_0 [3]),
        .I1(Q[3]),
        .O(Q2[3]));
  LUT2 #(
    .INIT(4'h6)) 
    E3_carry_i_14
       (.I0(\Qreg2_reg[7]_0 [2]),
        .I1(Q[2]),
        .O(Q2[2]));
  LUT2 #(
    .INIT(4'h6)) 
    E3_carry_i_15
       (.I0(\Qreg2_reg[7]_0 [1]),
        .I1(Q[1]),
        .O(Q2[1]));
  LUT2 #(
    .INIT(4'h6)) 
    E3_carry_i_16
       (.I0(\Qreg2_reg[7]_0 [0]),
        .I1(Q[0]),
        .O(Q2[0]));
  LUT2 #(
    .INIT(4'h6)) 
    E3_carry_i_9
       (.I0(\Qreg2_reg[7]_0 [7]),
        .I1(Q[7]),
        .O(Q2[7]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[0]_i_1__0 
       (.I0(Q[0]),
        .I1(\Qreg2_reg[7]_0 [0]),
        .I2(\Qreg2_reg[7]_1 [0]),
        .O(\Qreg1_reg[7]_0 [0]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[1]_i_1__0 
       (.I0(Q[1]),
        .I1(\Qreg2_reg[7]_0 [1]),
        .I2(\Qreg2_reg[7]_1 [1]),
        .O(\Qreg1_reg[7]_0 [1]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[2]_i_1__0 
       (.I0(Q[2]),
        .I1(\Qreg2_reg[7]_0 [2]),
        .I2(\Qreg2_reg[7]_1 [2]),
        .O(\Qreg1_reg[7]_0 [2]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[3]_i_1__0 
       (.I0(Q[3]),
        .I1(\Qreg2_reg[7]_0 [3]),
        .I2(\Qreg2_reg[7]_1 [3]),
        .O(\Qreg1_reg[7]_0 [3]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[4]_i_1__0 
       (.I0(Q[4]),
        .I1(\Qreg2_reg[7]_0 [4]),
        .I2(\Qreg2_reg[7]_1 [4]),
        .O(\Qreg1_reg[7]_0 [4]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[5]_i_1__0 
       (.I0(Q[5]),
        .I1(\Qreg2_reg[7]_0 [5]),
        .I2(\Qreg2_reg[7]_1 [5]),
        .O(\Qreg1_reg[7]_0 [5]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[6]_i_1__0 
       (.I0(Q[6]),
        .I1(\Qreg2_reg[7]_0 [6]),
        .I2(\Qreg2_reg[7]_1 [6]),
        .O(\Qreg1_reg[7]_0 [6]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg1[7]_i_1__0 
       (.I0(Q[7]),
        .I1(\Qreg2_reg[7]_0 [7]),
        .I2(\Qreg2_reg[7]_1 [7]),
        .O(\Qreg1_reg[7]_0 [7]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[0] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_3 [0]),
        .Q(\Qreg2_reg[7]_0 [0]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[1] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_3 [1]),
        .Q(\Qreg2_reg[7]_0 [1]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[2] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_3 [2]),
        .Q(\Qreg2_reg[7]_0 [2]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[3] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_3 [3]),
        .Q(\Qreg2_reg[7]_0 [3]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[4] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_3 [4]),
        .Q(\Qreg2_reg[7]_0 [4]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[5] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_3 [5]),
        .Q(\Qreg2_reg[7]_0 [5]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[6] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_3 [6]),
        .Q(\Qreg2_reg[7]_0 [6]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[7] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_3 [7]),
        .Q(\Qreg2_reg[7]_0 [7]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[0]_i_1__0 
       (.I0(Q[0]),
        .I1(\Qreg2_reg[7]_0 [0]),
        .I2(\Qreg1_reg[7]_1 [0]),
        .O(D[0]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[1]_i_1__0 
       (.I0(Q[1]),
        .I1(\Qreg2_reg[7]_0 [1]),
        .I2(\Qreg1_reg[7]_1 [1]),
        .O(D[1]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[2]_i_1__0 
       (.I0(Q[2]),
        .I1(\Qreg2_reg[7]_0 [2]),
        .I2(\Qreg1_reg[7]_1 [2]),
        .O(D[2]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[3]_i_1__0 
       (.I0(Q[3]),
        .I1(\Qreg2_reg[7]_0 [3]),
        .I2(\Qreg1_reg[7]_1 [3]),
        .O(D[3]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[4]_i_1__0 
       (.I0(Q[4]),
        .I1(\Qreg2_reg[7]_0 [4]),
        .I2(\Qreg1_reg[7]_1 [4]),
        .O(D[4]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[5]_i_1__0 
       (.I0(Q[5]),
        .I1(\Qreg2_reg[7]_0 [5]),
        .I2(\Qreg1_reg[7]_1 [5]),
        .O(D[5]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[6]_i_1__0 
       (.I0(Q[6]),
        .I1(\Qreg2_reg[7]_0 [6]),
        .I2(\Qreg1_reg[7]_1 [6]),
        .O(D[6]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'h96)) 
    \Qreg2[7]_i_1 
       (.I0(Q[7]),
        .I1(\Qreg2_reg[7]_0 [7]),
        .I2(\Qreg1_reg[7]_1 [7]),
        .O(D[7]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[0] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [0]),
        .Q(Q[0]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[1] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [1]),
        .Q(Q[1]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[2] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [2]),
        .Q(Q[2]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[3] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [3]),
        .Q(Q[3]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[4] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [4]),
        .Q(Q[4]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[5] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [5]),
        .Q(Q[5]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[6] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [6]),
        .Q(Q[6]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[7] 
       (.C(CLK),
        .CE(E),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [7]),
        .Q(Q[7]));
endmodule

(* ORIG_REF_NAME = "DE_REG_SYNC" *) 
module DE_REG_SYNC_1
   (S,
    Q,
    \Qreg2_reg[7]_0 ,
    DI,
    E,
    Q2,
    CO,
    Qreg_reg,
    \Qreg2_reg[7]_1 ,
    E_0,
    D,
    CLK,
    R_IBUF,
    \Qreg2_reg[7]_2 );
  output [3:0]S;
  output [7:0]Q;
  output [7:0]\Qreg2_reg[7]_0 ;
  output [3:0]DI;
  output [0:0]E;
  input [7:0]Q2;
  input [0:0]CO;
  input [0:0]Qreg_reg;
  input [0:0]\Qreg2_reg[7]_1 ;
  input [0:0]E_0;
  input [7:0]D;
  input CLK;
  input R_IBUF;
  input [7:0]\Qreg2_reg[7]_2 ;

  wire CLK;
  wire [0:0]CO;
  wire [7:0]D;
  wire [3:0]DI;
  wire [0:0]E;
  wire [0:0]E_0;
  wire [7:0]Q;
  wire [7:0]Q2;
  wire [7:0]\Qreg2_reg[7]_0 ;
  wire [0:0]\Qreg2_reg[7]_1 ;
  wire [7:0]\Qreg2_reg[7]_2 ;
  wire [0:0]Qreg_reg;
  wire R_IBUF;
  wire [3:0]S;

  LUT6 #(
    .INIT(64'hEB8282828282EB82)) 
    E3_carry_i_1
       (.I0(Q2[7]),
        .I1(Q[7]),
        .I2(\Qreg2_reg[7]_0 [7]),
        .I3(Q2[6]),
        .I4(Q[6]),
        .I5(\Qreg2_reg[7]_0 [6]),
        .O(DI[3]));
  LUT6 #(
    .INIT(64'hEB8282828282EB82)) 
    E3_carry_i_2
       (.I0(Q2[5]),
        .I1(Q[5]),
        .I2(\Qreg2_reg[7]_0 [5]),
        .I3(Q2[4]),
        .I4(Q[4]),
        .I5(\Qreg2_reg[7]_0 [4]),
        .O(DI[2]));
  LUT6 #(
    .INIT(64'hEB8282828282EB82)) 
    E3_carry_i_3
       (.I0(Q2[3]),
        .I1(Q[3]),
        .I2(\Qreg2_reg[7]_0 [3]),
        .I3(Q2[2]),
        .I4(Q[2]),
        .I5(\Qreg2_reg[7]_0 [2]),
        .O(DI[1]));
  LUT6 #(
    .INIT(64'hEB8282828282EB82)) 
    E3_carry_i_4
       (.I0(Q2[1]),
        .I1(Q[1]),
        .I2(\Qreg2_reg[7]_0 [1]),
        .I3(Q2[0]),
        .I4(Q[0]),
        .I5(\Qreg2_reg[7]_0 [0]),
        .O(DI[0]));
  LUT6 #(
    .INIT(64'h0069690069000069)) 
    E3_carry_i_5
       (.I0(Q[7]),
        .I1(\Qreg2_reg[7]_0 [7]),
        .I2(Q2[7]),
        .I3(Q[6]),
        .I4(\Qreg2_reg[7]_0 [6]),
        .I5(Q2[6]),
        .O(S[3]));
  LUT6 #(
    .INIT(64'h0069690069000069)) 
    E3_carry_i_6
       (.I0(Q[5]),
        .I1(\Qreg2_reg[7]_0 [5]),
        .I2(Q2[5]),
        .I3(Q[4]),
        .I4(\Qreg2_reg[7]_0 [4]),
        .I5(Q2[4]),
        .O(S[2]));
  LUT6 #(
    .INIT(64'h0069690069000069)) 
    E3_carry_i_7
       (.I0(Q[3]),
        .I1(\Qreg2_reg[7]_0 [3]),
        .I2(Q2[3]),
        .I3(Q[2]),
        .I4(\Qreg2_reg[7]_0 [2]),
        .I5(Q2[2]),
        .O(S[1]));
  LUT6 #(
    .INIT(64'h0069690069000069)) 
    E3_carry_i_8
       (.I0(Q[1]),
        .I1(\Qreg2_reg[7]_0 [1]),
        .I2(Q2[1]),
        .I3(Q[0]),
        .I4(\Qreg2_reg[7]_0 [0]),
        .I5(Q2[0]),
        .O(S[0]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[0] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [0]),
        .Q(\Qreg2_reg[7]_0 [0]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[1] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [1]),
        .Q(\Qreg2_reg[7]_0 [1]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[2] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [2]),
        .Q(\Qreg2_reg[7]_0 [2]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[3] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [3]),
        .Q(\Qreg2_reg[7]_0 [3]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[4] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [4]),
        .Q(\Qreg2_reg[7]_0 [4]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[5] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [5]),
        .Q(\Qreg2_reg[7]_0 [5]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[6] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [6]),
        .Q(\Qreg2_reg[7]_0 [6]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[7] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(\Qreg2_reg[7]_2 [7]),
        .Q(\Qreg2_reg[7]_0 [7]));
  LUT4 #(
    .INIT(16'h8000)) 
    \Qreg2[7]_i_1__2 
       (.I0(CO),
        .I1(Qreg_reg),
        .I2(\Qreg2_reg[7]_1 ),
        .I3(E_0),
        .O(E));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[0] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(D[0]),
        .Q(Q[0]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[1] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(D[1]),
        .Q(Q[1]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[2] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(D[2]),
        .Q(Q[2]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[3] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(D[3]),
        .Q(Q[3]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[4] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(D[4]),
        .Q(Q[4]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[5] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(D[5]),
        .Q(Q[5]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[6] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(D[6]),
        .Q(Q[6]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[7] 
       (.C(CLK),
        .CE(E_0),
        .CLR(R_IBUF),
        .D(D[7]),
        .Q(Q[7]));
endmodule

(* ORIG_REF_NAME = "DE_REG_SYNC" *) 
module DE_REG_SYNC_2
   (S,
    M_OBUF,
    DI,
    L_IBUF,
    S_IBUF,
    V_IBUF,
    R_IBUF,
    \Qreg1_reg[7]_0 ,
    Q,
    Q2,
    E,
    CLK);
  output [3:0]S;
  output [7:0]M_OBUF;
  output [3:0]DI;
  input L_IBUF;
  input S_IBUF;
  input [7:0]V_IBUF;
  input R_IBUF;
  input [7:0]\Qreg1_reg[7]_0 ;
  input [7:0]Q;
  input [7:0]Q2;
  input [0:0]E;
  input CLK;

  wire CLK;
  wire [3:0]DI;
  wire [0:0]E;
  wire L_IBUF;
  wire [7:0]M_OBUF;
  wire [7:0]Q;
  wire [7:0]Q2;
  wire [7:0]Qreg1;
  wire [7:0]Qreg10;
  wire [7:0]\Qreg1_reg[7]_0 ;
  wire [7:0]Qreg2;
  wire [7:0]Qreg20;
  wire \Qreg2[7]_i_3_n_0 ;
  wire [6:0]Qrs;
  wire R_IBUF;
  wire [3:0]S;
  wire S_IBUF;
  wire [7:0]V_IBUF;

  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[0] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg10[0]),
        .Q(Qreg1[0]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[1] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg10[1]),
        .Q(Qreg1[1]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[2] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg10[2]),
        .Q(Qreg1[2]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[3] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg10[3]),
        .Q(Qreg1[3]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[4] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg10[4]),
        .Q(Qreg1[4]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[5] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg10[5]),
        .Q(Qreg1[5]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[6] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg10[6]),
        .Q(Qreg1[6]));
  FDCE #(
    .INIT(1'b0)) 
    \Qreg1_reg[7] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg10[7]),
        .Q(Qreg1[7]));
  LUT3 #(
    .INIT(8'hFE)) 
    \Qreg2[7]_i_3 
       (.I0(R_IBUF),
        .I1(S_IBUF),
        .I2(L_IBUF),
        .O(\Qreg2[7]_i_3_n_0 ));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[0] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg20[0]),
        .Q(Qreg2[0]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[1] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg20[1]),
        .Q(Qreg2[1]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[2] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg20[2]),
        .Q(Qreg2[2]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[3] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg20[3]),
        .Q(Qreg2[3]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[4] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg20[4]),
        .Q(Qreg2[4]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[5] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg20[5]),
        .Q(Qreg2[5]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[6] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg20[6]),
        .Q(Qreg2[6]));
  FDCE #(
    .INIT(1'b0),
    .IS_C_INVERTED(1'b1)) 
    \Qreg2_reg[7] 
       (.C(CLK),
        .CE(E),
        .CLR(\Qreg2[7]_i_3_n_0 ),
        .D(Qreg20[7]),
        .Q(Qreg2[7]));
  SR_SYNC \lp[0].rs 
       (.D(Qreg20[0]),
        .L_IBUF(L_IBUF),
        .M_OBUF(M_OBUF[0]),
        .Q(Q[0]),
        .\Qreg1_reg[0] (Qreg10[0]),
        .\Qreg1_reg[0]_0 (\Qreg1_reg[7]_0 [0]),
        .\Qreg1_reg[0]_1 (Qreg1[0]),
        .\Qreg2_reg[0] (Qreg2[0]),
        .Qrs(Qrs[0]),
        .R_IBUF(R_IBUF),
        .S_IBUF(S_IBUF),
        .V_IBUF(V_IBUF[0]));
  SR_SYNC_3 \lp[1].rs 
       (.D(Qreg20[1]),
        .DI(DI[0]),
        .L_IBUF(L_IBUF),
        .M_OBUF(M_OBUF[1]),
        .Q(Q[1]),
        .Q2(Q2[1:0]),
        .\Qreg1_reg[1] (Qreg10[1]),
        .\Qreg1_reg[1]_0 (\Qreg1_reg[7]_0 [1]),
        .\Qreg1_reg[1]_1 (Qreg1[1:0]),
        .\Qreg2_reg[1] (Qreg2[1:0]),
        .Qreg_reg_0(Qrs[0]),
        .R_IBUF(R_IBUF),
        .S(S[0]),
        .S_IBUF(S_IBUF),
        .V_IBUF(V_IBUF[1]));
  SR_SYNC_4 \lp[2].rs 
       (.D(Qreg20[2]),
        .L_IBUF(L_IBUF),
        .M_OBUF(M_OBUF[2]),
        .Q(Q[2]),
        .\Qreg1_reg[2] (Qreg10[2]),
        .\Qreg1_reg[2]_0 (\Qreg1_reg[7]_0 [2]),
        .\Qreg1_reg[2]_1 (Qreg1[2]),
        .\Qreg2_reg[2] (Qreg2[2]),
        .Qrs(Qrs[2]),
        .R_IBUF(R_IBUF),
        .S_IBUF(S_IBUF),
        .V_IBUF(V_IBUF[2]));
  SR_SYNC_5 \lp[3].rs 
       (.D(Qreg20[3]),
        .DI(DI[1]),
        .L_IBUF(L_IBUF),
        .M_OBUF(M_OBUF[3]),
        .Q(Q[3]),
        .Q2(Q2[3:2]),
        .\Qreg1_reg[3] (Qreg10[3]),
        .\Qreg1_reg[3]_0 (\Qreg1_reg[7]_0 [3]),
        .\Qreg1_reg[3]_1 (Qreg1[3:2]),
        .\Qreg2_reg[3] (Qreg2[3:2]),
        .Qreg_reg_0(Qrs[2]),
        .R_IBUF(R_IBUF),
        .S(S[1]),
        .S_IBUF(S_IBUF),
        .V_IBUF(V_IBUF[3]));
  SR_SYNC_6 \lp[4].rs 
       (.D(Qreg20[4]),
        .L_IBUF(L_IBUF),
        .M_OBUF(M_OBUF[4]),
        .Q(Q[4]),
        .\Qreg1_reg[4] (Qreg10[4]),
        .\Qreg1_reg[4]_0 (\Qreg1_reg[7]_0 [4]),
        .\Qreg1_reg[4]_1 (Qreg1[4]),
        .\Qreg2_reg[4] (Qreg2[4]),
        .Qrs(Qrs[4]),
        .R_IBUF(R_IBUF),
        .S_IBUF(S_IBUF),
        .V_IBUF(V_IBUF[4]));
  SR_SYNC_7 \lp[5].rs 
       (.D(Qreg20[5]),
        .DI(DI[2]),
        .L_IBUF(L_IBUF),
        .M_OBUF(M_OBUF[5]),
        .Q(Q[5]),
        .Q2(Q2[5:4]),
        .\Qreg1_reg[5] (Qreg10[5]),
        .\Qreg1_reg[5]_0 (\Qreg1_reg[7]_0 [5]),
        .\Qreg1_reg[5]_1 (Qreg1[5:4]),
        .\Qreg2_reg[5] (Qreg2[5:4]),
        .Qreg_reg_0(Qrs[4]),
        .R_IBUF(R_IBUF),
        .S(S[2]),
        .S_IBUF(S_IBUF),
        .V_IBUF(V_IBUF[5]));
  SR_SYNC_8 \lp[6].rs 
       (.D(Qreg20[6]),
        .L_IBUF(L_IBUF),
        .M_OBUF(M_OBUF[6]),
        .Q(Q[6]),
        .\Qreg1_reg[6] (Qreg10[6]),
        .\Qreg1_reg[6]_0 (\Qreg1_reg[7]_0 [6]),
        .\Qreg1_reg[6]_1 (Qreg1[6]),
        .\Qreg2_reg[6] (Qreg2[6]),
        .Qrs(Qrs[6]),
        .R_IBUF(R_IBUF),
        .S_IBUF(S_IBUF),
        .V_IBUF(V_IBUF[6]));
  SR_SYNC_9 \lp[7].rs 
       (.D(Qreg20[7]),
        .DI(DI[3]),
        .L_IBUF(L_IBUF),
        .M_OBUF(M_OBUF[7]),
        .Q(Q[7]),
        .Q2(Q2[7:6]),
        .\Qreg1_reg[7] (Qreg10[7]),
        .\Qreg1_reg[7]_0 (\Qreg1_reg[7]_0 [7]),
        .\Qreg1_reg[7]_1 (Qreg1[7:6]),
        .\Qreg2_reg[7] (Qreg2[7:6]),
        .Qreg_reg_0(Qrs[6]),
        .R_IBUF(R_IBUF),
        .S(S[3]),
        .S_IBUF(S_IBUF),
        .V_IBUF(V_IBUF[7]));
endmodule

module SR_SYNC
   (Qrs,
    D,
    \Qreg1_reg[0] ,
    M_OBUF,
    L_IBUF,
    S_IBUF,
    V_IBUF,
    R_IBUF,
    \Qreg1_reg[0]_0 ,
    Q,
    \Qreg1_reg[0]_1 ,
    \Qreg2_reg[0] );
  output [0:0]Qrs;
  output [0:0]D;
  output [0:0]\Qreg1_reg[0] ;
  output [0:0]M_OBUF;
  input L_IBUF;
  input S_IBUF;
  input [0:0]V_IBUF;
  input R_IBUF;
  input [0:0]\Qreg1_reg[0]_0 ;
  input [0:0]Q;
  input [0:0]\Qreg1_reg[0]_1 ;
  input [0:0]\Qreg2_reg[0] ;

  wire [0:0]D;
  wire L_IBUF;
  wire [0:0]M_OBUF;
  wire [0:0]Q;
  wire [0:0]\Qreg1_reg[0] ;
  wire [0:0]\Qreg1_reg[0]_0 ;
  wire [0:0]\Qreg1_reg[0]_1 ;
  wire [0:0]\Qreg2_reg[0] ;
  wire Qres;
  wire [0:0]Qrs;
  wire Qset;
  wire R_IBUF;
  wire S_IBUF;
  wire [0:0]V_IBUF;

  LUT3 #(
    .INIT(8'h96)) 
    \M_OBUF[0]_inst_i_1 
       (.I0(\Qreg1_reg[0]_1 ),
        .I1(\Qreg2_reg[0] ),
        .I2(Qrs),
        .O(M_OBUF));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg1[0]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[0]_0 ),
        .I2(Q),
        .I3(\Qreg2_reg[0] ),
        .O(\Qreg1_reg[0] ));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg2[0]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[0]_0 ),
        .I2(Q),
        .I3(\Qreg1_reg[0]_1 ),
        .O(D));
  LUT4 #(
    .INIT(16'h0F08)) 
    Qreg_i_1__6
       (.I0(V_IBUF),
        .I1(L_IBUF),
        .I2(R_IBUF),
        .I3(S_IBUF),
        .O(Qset));
  LUT5 #(
    .INIT(32'hFF000200)) 
    Qreg_i_2
       (.I0(L_IBUF),
        .I1(S_IBUF),
        .I2(V_IBUF),
        .I3(Qrs),
        .I4(R_IBUF),
        .O(Qres));
  FDCE #(
    .INIT(1'b0)) 
    Qreg_reg
       (.C(Qset),
        .CE(1'b1),
        .CLR(Qres),
        .D(1'b1),
        .Q(Qrs));
endmodule

(* ORIG_REF_NAME = "SR_SYNC" *) 
module SR_SYNC_3
   (D,
    \Qreg1_reg[1] ,
    S,
    M_OBUF,
    DI,
    Qreg_reg_0,
    L_IBUF,
    S_IBUF,
    V_IBUF,
    R_IBUF,
    \Qreg1_reg[1]_0 ,
    Q,
    \Qreg1_reg[1]_1 ,
    \Qreg2_reg[1] ,
    Q2);
  output [0:0]D;
  output [0:0]\Qreg1_reg[1] ;
  output [0:0]S;
  output [0:0]M_OBUF;
  output [0:0]DI;
  input [0:0]Qreg_reg_0;
  input L_IBUF;
  input S_IBUF;
  input [0:0]V_IBUF;
  input R_IBUF;
  input [0:0]\Qreg1_reg[1]_0 ;
  input [0:0]Q;
  input [1:0]\Qreg1_reg[1]_1 ;
  input [1:0]\Qreg2_reg[1] ;
  input [1:0]Q2;

  wire [0:0]D;
  wire [0:0]DI;
  wire L_IBUF;
  wire [0:0]M_OBUF;
  wire [0:0]Q;
  wire [1:0]Q2;
  wire [0:0]\Qreg1_reg[1] ;
  wire [0:0]\Qreg1_reg[1]_0 ;
  wire [1:0]\Qreg1_reg[1]_1 ;
  wire [1:0]\Qreg2_reg[1] ;
  wire [0:0]Qreg_reg_0;
  wire Qres;
  wire [1:1]Qrs;
  wire Qset;
  wire R_IBUF;
  wire [0:0]S;
  wire S_IBUF;
  wire [0:0]V_IBUF;

  LUT6 #(
    .INIT(64'h22B2B222B22222B2)) 
    E2_carry_i_4
       (.I0(Q2[1]),
        .I1(M_OBUF),
        .I2(Q2[0]),
        .I3(Qreg_reg_0),
        .I4(\Qreg2_reg[1] [0]),
        .I5(\Qreg1_reg[1]_1 [0]),
        .O(DI));
  LUT6 #(
    .INIT(64'h9009099009909009)) 
    E2_carry_i_8
       (.I0(M_OBUF),
        .I1(Q2[1]),
        .I2(Qreg_reg_0),
        .I3(\Qreg2_reg[1] [0]),
        .I4(\Qreg1_reg[1]_1 [0]),
        .I5(Q2[0]),
        .O(S));
  LUT3 #(
    .INIT(8'h96)) 
    \M_OBUF[1]_inst_i_1 
       (.I0(\Qreg1_reg[1]_1 [1]),
        .I1(\Qreg2_reg[1] [1]),
        .I2(Qrs),
        .O(M_OBUF));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg1[1]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[1]_0 ),
        .I2(Q),
        .I3(\Qreg2_reg[1] [1]),
        .O(\Qreg1_reg[1] ));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg2[1]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[1]_0 ),
        .I2(Q),
        .I3(\Qreg1_reg[1]_1 [1]),
        .O(D));
  LUT4 #(
    .INIT(16'h0F08)) 
    Qreg_i_1__5
       (.I0(V_IBUF),
        .I1(L_IBUF),
        .I2(R_IBUF),
        .I3(S_IBUF),
        .O(Qset));
  LUT5 #(
    .INIT(32'hFF000200)) 
    Qreg_i_2__6
       (.I0(L_IBUF),
        .I1(S_IBUF),
        .I2(V_IBUF),
        .I3(Qrs),
        .I4(R_IBUF),
        .O(Qres));
  FDCE #(
    .INIT(1'b0)) 
    Qreg_reg
       (.C(Qset),
        .CE(1'b1),
        .CLR(Qres),
        .D(1'b1),
        .Q(Qrs));
endmodule

(* ORIG_REF_NAME = "SR_SYNC" *) 
module SR_SYNC_4
   (Qrs,
    D,
    \Qreg1_reg[2] ,
    M_OBUF,
    L_IBUF,
    S_IBUF,
    V_IBUF,
    R_IBUF,
    \Qreg1_reg[2]_0 ,
    Q,
    \Qreg1_reg[2]_1 ,
    \Qreg2_reg[2] );
  output [0:0]Qrs;
  output [0:0]D;
  output [0:0]\Qreg1_reg[2] ;
  output [0:0]M_OBUF;
  input L_IBUF;
  input S_IBUF;
  input [0:0]V_IBUF;
  input R_IBUF;
  input [0:0]\Qreg1_reg[2]_0 ;
  input [0:0]Q;
  input [0:0]\Qreg1_reg[2]_1 ;
  input [0:0]\Qreg2_reg[2] ;

  wire [0:0]D;
  wire L_IBUF;
  wire [0:0]M_OBUF;
  wire [0:0]Q;
  wire [0:0]\Qreg1_reg[2] ;
  wire [0:0]\Qreg1_reg[2]_0 ;
  wire [0:0]\Qreg1_reg[2]_1 ;
  wire [0:0]\Qreg2_reg[2] ;
  wire Qres;
  wire [0:0]Qrs;
  wire Qset;
  wire R_IBUF;
  wire S_IBUF;
  wire [0:0]V_IBUF;

  LUT3 #(
    .INIT(8'h96)) 
    \M_OBUF[2]_inst_i_1 
       (.I0(\Qreg1_reg[2]_1 ),
        .I1(\Qreg2_reg[2] ),
        .I2(Qrs),
        .O(M_OBUF));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg1[2]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[2]_0 ),
        .I2(Q),
        .I3(\Qreg2_reg[2] ),
        .O(\Qreg1_reg[2] ));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg2[2]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[2]_0 ),
        .I2(Q),
        .I3(\Qreg1_reg[2]_1 ),
        .O(D));
  LUT4 #(
    .INIT(16'h0F08)) 
    Qreg_i_1__4
       (.I0(V_IBUF),
        .I1(L_IBUF),
        .I2(R_IBUF),
        .I3(S_IBUF),
        .O(Qset));
  LUT5 #(
    .INIT(32'hFF000200)) 
    Qreg_i_2__5
       (.I0(L_IBUF),
        .I1(S_IBUF),
        .I2(V_IBUF),
        .I3(Qrs),
        .I4(R_IBUF),
        .O(Qres));
  FDCE #(
    .INIT(1'b0)) 
    Qreg_reg
       (.C(Qset),
        .CE(1'b1),
        .CLR(Qres),
        .D(1'b1),
        .Q(Qrs));
endmodule

(* ORIG_REF_NAME = "SR_SYNC" *) 
module SR_SYNC_5
   (D,
    \Qreg1_reg[3] ,
    S,
    M_OBUF,
    DI,
    Qreg_reg_0,
    L_IBUF,
    S_IBUF,
    V_IBUF,
    R_IBUF,
    \Qreg1_reg[3]_0 ,
    Q,
    \Qreg1_reg[3]_1 ,
    \Qreg2_reg[3] ,
    Q2);
  output [0:0]D;
  output [0:0]\Qreg1_reg[3] ;
  output [0:0]S;
  output [0:0]M_OBUF;
  output [0:0]DI;
  input [0:0]Qreg_reg_0;
  input L_IBUF;
  input S_IBUF;
  input [0:0]V_IBUF;
  input R_IBUF;
  input [0:0]\Qreg1_reg[3]_0 ;
  input [0:0]Q;
  input [1:0]\Qreg1_reg[3]_1 ;
  input [1:0]\Qreg2_reg[3] ;
  input [1:0]Q2;

  wire [0:0]D;
  wire [0:0]DI;
  wire L_IBUF;
  wire [0:0]M_OBUF;
  wire [0:0]Q;
  wire [1:0]Q2;
  wire [0:0]\Qreg1_reg[3] ;
  wire [0:0]\Qreg1_reg[3]_0 ;
  wire [1:0]\Qreg1_reg[3]_1 ;
  wire [1:0]\Qreg2_reg[3] ;
  wire [0:0]Qreg_reg_0;
  wire Qres;
  wire [3:3]Qrs;
  wire Qset;
  wire R_IBUF;
  wire [0:0]S;
  wire S_IBUF;
  wire [0:0]V_IBUF;

  LUT6 #(
    .INIT(64'h22B2B222B22222B2)) 
    E2_carry_i_3
       (.I0(Q2[1]),
        .I1(M_OBUF),
        .I2(Q2[0]),
        .I3(Qreg_reg_0),
        .I4(\Qreg2_reg[3] [0]),
        .I5(\Qreg1_reg[3]_1 [0]),
        .O(DI));
  LUT6 #(
    .INIT(64'h9009099009909009)) 
    E2_carry_i_7
       (.I0(M_OBUF),
        .I1(Q2[1]),
        .I2(Qreg_reg_0),
        .I3(\Qreg2_reg[3] [0]),
        .I4(\Qreg1_reg[3]_1 [0]),
        .I5(Q2[0]),
        .O(S));
  LUT3 #(
    .INIT(8'h96)) 
    \M_OBUF[3]_inst_i_1 
       (.I0(\Qreg1_reg[3]_1 [1]),
        .I1(\Qreg2_reg[3] [1]),
        .I2(Qrs),
        .O(M_OBUF));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg1[3]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[3]_0 ),
        .I2(Q),
        .I3(\Qreg2_reg[3] [1]),
        .O(\Qreg1_reg[3] ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg2[3]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[3]_0 ),
        .I2(Q),
        .I3(\Qreg1_reg[3]_1 [1]),
        .O(D));
  LUT4 #(
    .INIT(16'h0F08)) 
    Qreg_i_1__3
       (.I0(V_IBUF),
        .I1(L_IBUF),
        .I2(R_IBUF),
        .I3(S_IBUF),
        .O(Qset));
  LUT5 #(
    .INIT(32'hFF000200)) 
    Qreg_i_2__4
       (.I0(L_IBUF),
        .I1(S_IBUF),
        .I2(V_IBUF),
        .I3(Qrs),
        .I4(R_IBUF),
        .O(Qres));
  FDCE #(
    .INIT(1'b0)) 
    Qreg_reg
       (.C(Qset),
        .CE(1'b1),
        .CLR(Qres),
        .D(1'b1),
        .Q(Qrs));
endmodule

(* ORIG_REF_NAME = "SR_SYNC" *) 
module SR_SYNC_6
   (Qrs,
    D,
    \Qreg1_reg[4] ,
    M_OBUF,
    L_IBUF,
    S_IBUF,
    V_IBUF,
    R_IBUF,
    \Qreg1_reg[4]_0 ,
    Q,
    \Qreg1_reg[4]_1 ,
    \Qreg2_reg[4] );
  output [0:0]Qrs;
  output [0:0]D;
  output [0:0]\Qreg1_reg[4] ;
  output [0:0]M_OBUF;
  input L_IBUF;
  input S_IBUF;
  input [0:0]V_IBUF;
  input R_IBUF;
  input [0:0]\Qreg1_reg[4]_0 ;
  input [0:0]Q;
  input [0:0]\Qreg1_reg[4]_1 ;
  input [0:0]\Qreg2_reg[4] ;

  wire [0:0]D;
  wire L_IBUF;
  wire [0:0]M_OBUF;
  wire [0:0]Q;
  wire [0:0]\Qreg1_reg[4] ;
  wire [0:0]\Qreg1_reg[4]_0 ;
  wire [0:0]\Qreg1_reg[4]_1 ;
  wire [0:0]\Qreg2_reg[4] ;
  wire Qres;
  wire [0:0]Qrs;
  wire Qset;
  wire R_IBUF;
  wire S_IBUF;
  wire [0:0]V_IBUF;

  LUT3 #(
    .INIT(8'h96)) 
    \M_OBUF[4]_inst_i_1 
       (.I0(\Qreg1_reg[4]_1 ),
        .I1(\Qreg2_reg[4] ),
        .I2(Qrs),
        .O(M_OBUF));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg1[4]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[4]_0 ),
        .I2(Q),
        .I3(\Qreg2_reg[4] ),
        .O(\Qreg1_reg[4] ));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg2[4]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[4]_0 ),
        .I2(Q),
        .I3(\Qreg1_reg[4]_1 ),
        .O(D));
  LUT4 #(
    .INIT(16'h0F08)) 
    Qreg_i_1__2
       (.I0(V_IBUF),
        .I1(L_IBUF),
        .I2(R_IBUF),
        .I3(S_IBUF),
        .O(Qset));
  LUT5 #(
    .INIT(32'hFF000200)) 
    Qreg_i_2__3
       (.I0(L_IBUF),
        .I1(S_IBUF),
        .I2(V_IBUF),
        .I3(Qrs),
        .I4(R_IBUF),
        .O(Qres));
  FDCE #(
    .INIT(1'b0)) 
    Qreg_reg
       (.C(Qset),
        .CE(1'b1),
        .CLR(Qres),
        .D(1'b1),
        .Q(Qrs));
endmodule

(* ORIG_REF_NAME = "SR_SYNC" *) 
module SR_SYNC_7
   (D,
    \Qreg1_reg[5] ,
    S,
    M_OBUF,
    DI,
    Qreg_reg_0,
    L_IBUF,
    S_IBUF,
    V_IBUF,
    R_IBUF,
    \Qreg1_reg[5]_0 ,
    Q,
    \Qreg1_reg[5]_1 ,
    \Qreg2_reg[5] ,
    Q2);
  output [0:0]D;
  output [0:0]\Qreg1_reg[5] ;
  output [0:0]S;
  output [0:0]M_OBUF;
  output [0:0]DI;
  input [0:0]Qreg_reg_0;
  input L_IBUF;
  input S_IBUF;
  input [0:0]V_IBUF;
  input R_IBUF;
  input [0:0]\Qreg1_reg[5]_0 ;
  input [0:0]Q;
  input [1:0]\Qreg1_reg[5]_1 ;
  input [1:0]\Qreg2_reg[5] ;
  input [1:0]Q2;

  wire [0:0]D;
  wire [0:0]DI;
  wire L_IBUF;
  wire [0:0]M_OBUF;
  wire [0:0]Q;
  wire [1:0]Q2;
  wire [0:0]\Qreg1_reg[5] ;
  wire [0:0]\Qreg1_reg[5]_0 ;
  wire [1:0]\Qreg1_reg[5]_1 ;
  wire [1:0]\Qreg2_reg[5] ;
  wire [0:0]Qreg_reg_0;
  wire Qres;
  wire [5:5]Qrs;
  wire Qset;
  wire R_IBUF;
  wire [0:0]S;
  wire S_IBUF;
  wire [0:0]V_IBUF;

  LUT6 #(
    .INIT(64'h22B2B222B22222B2)) 
    E2_carry_i_2
       (.I0(Q2[1]),
        .I1(M_OBUF),
        .I2(Q2[0]),
        .I3(Qreg_reg_0),
        .I4(\Qreg2_reg[5] [0]),
        .I5(\Qreg1_reg[5]_1 [0]),
        .O(DI));
  LUT6 #(
    .INIT(64'h9009099009909009)) 
    E2_carry_i_6
       (.I0(M_OBUF),
        .I1(Q2[1]),
        .I2(Qreg_reg_0),
        .I3(\Qreg2_reg[5] [0]),
        .I4(\Qreg1_reg[5]_1 [0]),
        .I5(Q2[0]),
        .O(S));
  LUT3 #(
    .INIT(8'h96)) 
    \M_OBUF[5]_inst_i_1 
       (.I0(\Qreg1_reg[5]_1 [1]),
        .I1(\Qreg2_reg[5] [1]),
        .I2(Qrs),
        .O(M_OBUF));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg1[5]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[5]_0 ),
        .I2(Q),
        .I3(\Qreg2_reg[5] [1]),
        .O(\Qreg1_reg[5] ));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg2[5]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[5]_0 ),
        .I2(Q),
        .I3(\Qreg1_reg[5]_1 [1]),
        .O(D));
  LUT4 #(
    .INIT(16'h0F08)) 
    Qreg_i_1__1
       (.I0(V_IBUF),
        .I1(L_IBUF),
        .I2(R_IBUF),
        .I3(S_IBUF),
        .O(Qset));
  LUT5 #(
    .INIT(32'hFF000200)) 
    Qreg_i_2__2
       (.I0(L_IBUF),
        .I1(S_IBUF),
        .I2(V_IBUF),
        .I3(Qrs),
        .I4(R_IBUF),
        .O(Qres));
  FDCE #(
    .INIT(1'b0)) 
    Qreg_reg
       (.C(Qset),
        .CE(1'b1),
        .CLR(Qres),
        .D(1'b1),
        .Q(Qrs));
endmodule

(* ORIG_REF_NAME = "SR_SYNC" *) 
module SR_SYNC_8
   (Qrs,
    D,
    \Qreg1_reg[6] ,
    M_OBUF,
    L_IBUF,
    S_IBUF,
    V_IBUF,
    R_IBUF,
    \Qreg1_reg[6]_0 ,
    Q,
    \Qreg1_reg[6]_1 ,
    \Qreg2_reg[6] );
  output [0:0]Qrs;
  output [0:0]D;
  output [0:0]\Qreg1_reg[6] ;
  output [0:0]M_OBUF;
  input L_IBUF;
  input S_IBUF;
  input [0:0]V_IBUF;
  input R_IBUF;
  input [0:0]\Qreg1_reg[6]_0 ;
  input [0:0]Q;
  input [0:0]\Qreg1_reg[6]_1 ;
  input [0:0]\Qreg2_reg[6] ;

  wire [0:0]D;
  wire L_IBUF;
  wire [0:0]M_OBUF;
  wire [0:0]Q;
  wire [0:0]\Qreg1_reg[6] ;
  wire [0:0]\Qreg1_reg[6]_0 ;
  wire [0:0]\Qreg1_reg[6]_1 ;
  wire [0:0]\Qreg2_reg[6] ;
  wire Qres;
  wire [0:0]Qrs;
  wire Qset;
  wire R_IBUF;
  wire S_IBUF;
  wire [0:0]V_IBUF;

  LUT3 #(
    .INIT(8'h96)) 
    \M_OBUF[6]_inst_i_1 
       (.I0(\Qreg1_reg[6]_1 ),
        .I1(\Qreg2_reg[6] ),
        .I2(Qrs),
        .O(M_OBUF));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg1[6]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[6]_0 ),
        .I2(Q),
        .I3(\Qreg2_reg[6] ),
        .O(\Qreg1_reg[6] ));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg2[6]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[6]_0 ),
        .I2(Q),
        .I3(\Qreg1_reg[6]_1 ),
        .O(D));
  LUT4 #(
    .INIT(16'h0F08)) 
    Qreg_i_1__0
       (.I0(V_IBUF),
        .I1(L_IBUF),
        .I2(R_IBUF),
        .I3(S_IBUF),
        .O(Qset));
  LUT5 #(
    .INIT(32'hFF000200)) 
    Qreg_i_2__1
       (.I0(L_IBUF),
        .I1(S_IBUF),
        .I2(V_IBUF),
        .I3(Qrs),
        .I4(R_IBUF),
        .O(Qres));
  FDCE #(
    .INIT(1'b0)) 
    Qreg_reg
       (.C(Qset),
        .CE(1'b1),
        .CLR(Qres),
        .D(1'b1),
        .Q(Qrs));
endmodule

(* ORIG_REF_NAME = "SR_SYNC" *) 
module SR_SYNC_9
   (D,
    \Qreg1_reg[7] ,
    S,
    M_OBUF,
    DI,
    Qreg_reg_0,
    L_IBUF,
    S_IBUF,
    V_IBUF,
    R_IBUF,
    \Qreg1_reg[7]_0 ,
    Q,
    \Qreg1_reg[7]_1 ,
    \Qreg2_reg[7] ,
    Q2);
  output [0:0]D;
  output [0:0]\Qreg1_reg[7] ;
  output [0:0]S;
  output [0:0]M_OBUF;
  output [0:0]DI;
  input [0:0]Qreg_reg_0;
  input L_IBUF;
  input S_IBUF;
  input [0:0]V_IBUF;
  input R_IBUF;
  input [0:0]\Qreg1_reg[7]_0 ;
  input [0:0]Q;
  input [1:0]\Qreg1_reg[7]_1 ;
  input [1:0]\Qreg2_reg[7] ;
  input [1:0]Q2;

  wire [0:0]D;
  wire [0:0]DI;
  wire L_IBUF;
  wire [0:0]M_OBUF;
  wire [0:0]Q;
  wire [1:0]Q2;
  wire [0:0]\Qreg1_reg[7] ;
  wire [0:0]\Qreg1_reg[7]_0 ;
  wire [1:0]\Qreg1_reg[7]_1 ;
  wire [1:0]\Qreg2_reg[7] ;
  wire [0:0]Qreg_reg_0;
  wire Qres;
  wire [7:7]Qrs;
  wire Qset;
  wire R_IBUF;
  wire [0:0]S;
  wire S_IBUF;
  wire [0:0]V_IBUF;

  LUT6 #(
    .INIT(64'h22B2B222B22222B2)) 
    E2_carry_i_1
       (.I0(Q2[1]),
        .I1(M_OBUF),
        .I2(Q2[0]),
        .I3(Qreg_reg_0),
        .I4(\Qreg2_reg[7] [0]),
        .I5(\Qreg1_reg[7]_1 [0]),
        .O(DI));
  LUT6 #(
    .INIT(64'h9009099009909009)) 
    E2_carry_i_5
       (.I0(M_OBUF),
        .I1(Q2[1]),
        .I2(Qreg_reg_0),
        .I3(\Qreg2_reg[7] [0]),
        .I4(\Qreg1_reg[7]_1 [0]),
        .I5(Q2[0]),
        .O(S));
  LUT3 #(
    .INIT(8'h96)) 
    \M_OBUF[7]_inst_i_1 
       (.I0(\Qreg1_reg[7]_1 [1]),
        .I1(\Qreg2_reg[7] [1]),
        .I2(Qrs),
        .O(M_OBUF));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg1[7]_i_1 
       (.I0(Qrs),
        .I1(\Qreg1_reg[7]_0 ),
        .I2(Q),
        .I3(\Qreg2_reg[7] [1]),
        .O(\Qreg1_reg[7] ));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    \Qreg2[7]_i_2 
       (.I0(Qrs),
        .I1(\Qreg1_reg[7]_0 ),
        .I2(Q),
        .I3(\Qreg1_reg[7]_1 [1]),
        .O(D));
  LUT4 #(
    .INIT(16'h0F08)) 
    Qreg_i_1
       (.I0(V_IBUF),
        .I1(L_IBUF),
        .I2(R_IBUF),
        .I3(S_IBUF),
        .O(Qset));
  LUT5 #(
    .INIT(32'hFF000200)) 
    Qreg_i_2__0
       (.I0(L_IBUF),
        .I1(S_IBUF),
        .I2(V_IBUF),
        .I3(Qrs),
        .I4(R_IBUF),
        .O(Qres));
  FDCE #(
    .INIT(1'b0)) 
    Qreg_reg
       (.C(Qset),
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
