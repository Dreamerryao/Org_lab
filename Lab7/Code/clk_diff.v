`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:15:33 09/21/2020 
// Design Name: 
// Module Name:    clk_diff 
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
/**
 * differential clock to signel ended clock
 * Frank Shaw	 <xiaoqingzhe@gmail.com>
 */
module clk_diff(
	input clk200P,clk200N,
	output clk200MHz
	);

	IBUFGDS #(
		.DIFF_TERM("FALSE"), // Differential Termination
		.IBUF_LOW_PWR("TRUE"), // Low power="TRUE", Highest performance="FALSE"
		.IOSTANDARD("DEFAULT") // Specifies the I/O standard for this buffer
	) IBUFGDS_inst (
		.O(clk200MHz),  // Clock buffer output
		.I(clk200P),  // Diff_p clock buffer input
		.IB(clk200N) // Diff_n clock buffer input
	);
endmodule
