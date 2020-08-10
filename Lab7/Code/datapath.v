`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:42:32 08/10/2020 
// Design Name: 
// Module Name:    datapath 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module datapath(input ALUSrc_A, 
                input ALUSrc_B, 
                input [2:0] ALU_Control, 
                input [1:0] Branch, 
                input clk, 
                input [1:0] DatatoReg, 
                input [31:0] Data_in, 
                input [25:0] inst_field, 
                input PCEN, 
                input [1:0] RegDst, 
                input RegWrite, 
                input rst, 
                output [31:0] ALU_out, 
                output [31:0] Data_out, 
                output [31:0] PC_out, 
                output zero);
   
   wire [31:0] Imm;
   wire N0;
   wire [31:0] pc_4;
   wire V5;
   wire [31:0] PC_OFFSET;
   wire [31:0] PC_FINAL;
   wire [31:0] ALU_B;
   wire [4:0] Wt_addr;
   wire [31:0] Wt_data;
   wire [31:0] rdata_A;
   wire [31:0] ALU_A;

   REG32  PC (.CE(PCEN), 
             .clk(clk), 
             .D(PC_FINAL), 
             .rst(rst), 
             .Q(PC_out));
   VCC  V_SDP (.P(V5));
   GND  G_SDP (.G(N0));
    assign pc_4 = PC_out + 4;
    assign PC_OFFSET = pc_4+(Imm[29:0] << 2);

   alu ALU (.A(ALU_A), 
            .ALU_Op(ALU_Control), 
            .B(ALU_B), 
            .overflow(), 
            .res(ALU_out),
            .zero(zero));
   Regs  U2 (.clk(clk), 
                 .L_S(RegWrite), 
                 .rst(rst), 
                 .R_addr_A(inst_field[25:21]), 
                 .R_addr_B(inst_field[20:16]), 
                 .Wt_addr(Wt_addr), 
                 .Wt_data(Wt_data), 
                 .rdata_A(rdata_A), 
                 .rdata_B(Data_out));
   MUX2T1_32  MUX1 (.I0(Data_out), 
                      .I1(Imm), 
                      .s(ALUSrc_B), 
                      .o(ALU_B));
   Ext_32  Extend (.imm_16(inst_field[15:0]), 
                   .Imm_32(Imm));
   MUX4T1_32  MUX2 (.I0(pc_4), 
                      .I1(PC_OFFSET), 
                      .I2({pc_4[31:28], inst_field[25:0], N0, N0}), 
                      .I3(rdata_A), 
                      .s(Branch), 
                      .o(PC_FINAL));
   MUX2T1_32  MUX3 (.I0(rdata_A), 
                      .I1({{27{N0}},inst_field[10:6]}), 
                      .s(ALUSrc_A), 
                      .o(ALU_A));
   MUX4T1_5  MUX4 (.I0(inst_field[20:16]), 
                     .I1(inst_field[15:11]), 
                     .I2({5{V5}}), 
                     .I3({5{V5}}), 
                     .s(RegDst[1:0]), 
                     .o(Wt_addr[4:0]));
   MUX4T1_32  MUX5 (.I0(ALU_out), 
                      .I1(Data_in), 
                      .I2({inst_field[15:0],{16{N0}}}), 
                      .I3(pc_4), 
                      .s(DatatoReg), 
                      .o(Wt_data));
endmodule

