`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:24:30 08/10/2020 
// Design Name: 
// Module Name:    controller 
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
module controller(
      input clk,
      input reset,
		input [5:0] OPcode, // OPcode
		input [5:0] Fun, // Function
		input MIO_ready, // CPU Wait
		input zero,
		
		output reg PCEN,
		output reg [1:0] RegDst,//寄存器写地址选择 置0选择RT 置1选择RS
		output reg ALUSrc_B, //ALU端口B输入选择 置0选择寄存器数据 置1选择立即数扩展
		output reg [1:0] DatatoReg,
		output reg [1:0] Branch,//管理下一个PC值 00时PC = PC+4
		output reg RegWrite,
		output reg ALE,
		output reg WR,
		output reg [2:0] ALU_Control,//000-111 3位ALU控制
		output reg CPU_MIO
		);

    parameter AND=3'b000, OR=3'b001, ADD=3'b010, SUB=3'b110, NOR=3'b100, SLT=3'b111,
		      XOR=3'b011, SRL=3'b101;
    parameter INST_R = 6'b000000, INST_ADDI = 6'b001000, INST_ANDI = 6'b001100,
              INST_ORI = 6'b001101, INST_XORI = 6'b001110, INST_SLTI = 6'b001010,
              INST_LUI = 6'b001111, INST_LW = 6'b100011, INST_SW = 6'b101011, 
              INST_BEQ = 6'b000100, INST_BNE = 6'b000101, INST_J = 6'b000010,
				  INST_JAL = 6'b000011, INST_SLTI_WRONG = 6'b011000;
    reg isWaiting,mem_w;

    always @(negedge clk)begin
        WR<=0;
	    ALE<=1;
        if(CPU_MIO)
		    case(isWaiting)
		    1'b0:begin ALE <=1;
                    WR <= mem_w;
                    isWaiting <=1;
                    PCEN <=0;
                    end
		    1'b1:begin ALE <=0;
                    WR <= 0;
                    PCEN <=1;
                    isWaiting <=0;
                    end
		endcase
		else begin isWaiting<=0;PCEN <= 1;end
    end

    always@(*) begin
        RegDst = 2'b00;
		ALUSrc_B = 0;
		DatatoReg = 2'b00;
		RegWrite = 0;
		Branch = 2'b00;
		mem_w = 0;
		CPU_MIO = 0;
		case(OPcode)
			INST_R:begin RegDst = 2'b01;RegWrite = 1;
                    case(Fun)
                        6'b100000:ALU_Control = ADD;
                        6'b100010:ALU_Control = SUB;
                        6'b100100:ALU_Control = AND;
                        6'b100101:ALU_Control = OR;
                        6'b101010:ALU_Control = SLT;
                        6'b100111:ALU_Control = NOR;
                        6'b000010:ALU_Control = SRL;
                        6'b010110:ALU_Control = XOR;
                        6'b001000:Branch = 2'b11;
                        default: ALU_Control = ADD;
                    endcase
			    end
			INST_LW: begin ALU_Control = ADD; ALUSrc_B = 1; DatatoReg = 2'b01; RegWrite = 1; CPU_MIO = 1; end
			INST_SW:begin ALU_Control = ADD; ALUSrc_B = 1; mem_w = 1; CPU_MIO = 1; end
			INST_BEQ:begin ALU_Control = SUB; Branch = {1'b0,zero}; end
			INST_J: Branch = 2'b10;
			INST_BNE: begin ALU_Control = SUB;Branch = {1'b0,~zero}; end
			INST_SLTI:begin ALU_Control = SLT; ALUSrc_B = 1; RegWrite = 1; end
			//INST_SLTI_WRONG:begin ALU_Control = SLT; ALUSrc_B = 1; RegWrite = 1; end
			INST_ADDI:begin ALU_Control = ADD; ALUSrc_B = 1; RegWrite = 1; end
			INST_ANDI:begin ALU_Control = AND; ALUSrc_B = 1; RegWrite = 1; end
			INST_ORI:begin ALU_Control = OR; ALUSrc_B = 1; RegWrite = 1; end
			INST_JAL:begin RegDst = 2'b10; Branch = 2'b10; DatatoReg = 2'b11; RegWrite = 1; end
			INST_LUI:begin DatatoReg = 2'b10; RegWrite = 1; end
			default:ALU_Control = ADD;
			endcase
    end


endmodule
