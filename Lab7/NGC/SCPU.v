`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:38:43 08/10/2020 
// Design Name: 
// Module Name:    single_cycle_Cpu_9 
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
module SCPU(	input clk,			//
                input reset,
                input MIO_ready,
                input INT,
                input [31:0]inst_in,
                input [31:0]Data_in,	
                                
                output WR,
                output[31:0]PC_out,
                output[31:0]Addr_out,
                output[31:0]Data_out, 
                output CPU_MIO,
                output ALE
				);

    wire ALUSrc_B, ALUSrc_A, zero, PCEN, RegWrite;
    wire [1:0] RegDst, DatatoReg, Branch;
    wire [2:0] ALU_Control;
	 GND  SGND (.G(ALUSrc_A));
    datapath  SDP (.ALUSrc_A(ALUSrc_A), 
                .ALUSrc_B(ALUSrc_B), 
                .ALU_Control(ALU_Control), 
                .Branch(Branch), 
                .clk(clk), 
                .DatatoReg(DatatoReg), 
                .Data_in(Data_in), 
                .inst_field(inst_in[25:0]), 
                .PCEN(PCEN), 
                .RegDst(RegDst), 
                .RegWrite(RegWrite), 
                .rst(reset), 
                .ALU_out(Addr_out), 
                .Data_out(Data_out), 
                .PC_out(PC_out), 
                .zero(zero));

    controller  SCTRL (.clk(clk), 
                    .Fun(inst_in[5:0]), 
                    .MIO_ready(MIO_ready), 
                    .OPcode(inst_in[31:26]), 
                    .reset(reset), 
                    .zero(zero), 
                    .ALE(ALE), 
                    .ALUSrc_B(ALUSrc_B), 
                    .ALU_Control(ALU_Control), 
                    .Branch(Branch), 
                    .CPU_MIO(CPU_MIO), 
                    .DatatoReg(DatatoReg), 
                    .PCEN(PCEN), 
                    .RegDst(RegDst), 
                    .RegWrite(RegWrite), 
                    .WR(WR));

endmodule
