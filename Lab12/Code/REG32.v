`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:33:44 04/02/2019 
// Design Name: 
// Module Name:    REG32 
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
module REG32(input clk,
				 input rst,
				 input CE,
				 input [31:0] D,
				 output reg[31:0] Q
    );
	 always @(posedge clk or posedge rst)
		if(rst==1) Q<=0;
		else if (CE==1) Q<=D;


endmodule
