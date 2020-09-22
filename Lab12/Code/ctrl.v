`timescale 1ns / 1ps
`define Datapath_signals {PCWrite, PCWriteCond, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource, ALUSrcA, ALUSrcB, RegWrite, RegDst, Branch, CPU_MIO}

module   ctrl(input  clk,
					input  reset,
					input  [31:0] Inst_in,
					input  zero,
					input  overflow,
					input  MIO_ready,
					output reg MemRead,
					output reg MemWrite,
					output reg[2:0]ALU_operation,
					output [4:0]state_out,
					
					output reg CPU_MIO,
					output reg IorD,
					output reg IRWrite,
					output reg [1:0]RegDst,
					output reg RegWrite,
					output reg [1:0]MemtoReg,
					output reg [1:0]ALUSrcA,
					output reg [2:0]ALUSrcB,
					output reg [1:0]PCSource,
					output reg PCWrite,
					output reg PCWriteCond,
					output reg Branch
					);

parameter value0 = 20'b1001_0100_00_00001_00000;
parameter value1 = 20'b0001_0000_00_00011_00000;
parameter value2 = 20'b0000_0000_00_01010_00000;
parameter value3 = 20'b0011_0000_00_00000_00001;
parameter value4 = 20'b0000_0001_00_00000_10000;
parameter value5 = 20'b0010_1000_00_00000_00001;
parameter value6 = 20'b0000_0000_00_01000_00000;
parameter value7 = 20'b0000_0000_00_00000_10100;
parameter value8 = 20'b0100_0000_01_01000_00010;
parameter value9 = 20'b1000_0000_10_00001_00000;

parameter IF = 5'b00000, ID = 5'b00001, Exe_Mem = 5'b00010, Mem_RD = 5'b00011;
parameter LW_WB = 5'b00100, Mem_W = 5'b00101, Exe_R = 5'b00110, R_WB = 5'b00111;
parameter Exe_Beq = 5'b01000, J = 5'b01001, Error = 5'b11111, Exe_Bne = 5'b01110;
parameter Jal = 5'b01010, Jr = 5'b01011, I_WB = 5'b01100, Exe_I = 5'b01101;
parameter Exe_Lui = 5'b01111;

parameter AND = 3'b000, OR = 3'b001, ADD = 3'b010;
parameter SUB = 3'b110, NOR = 3'b100, SLT = 3'b111;
parameter XOR = 3'b011, SRL = 3'b101;

reg [4:0]state;
assign state_out = state;

always @ (posedge clk or posedge reset) begin
	if(reset==1) state <= IF;
	else
		case(state)
			IF:		if(MIO_ready) state <= ID;
						else          state <= IF;
			ID:		case(Inst_in[31:26])
							6'b000000: begin 
												if(Inst_in[5:0]==6'h9 || Inst_in[5:0]==6'h8)
													state <= Jr;	// Jalr, Jr
												else
													state <= Exe_R;		// R-type OP
											end
							6'b100011: state <= Exe_Mem;   // Lw
							6'b101011: state <= Exe_Mem;	// Sw
							6'b000100: state <= Exe_Beq;	// Beq
							6'b000101: state <= Exe_Bne;  // Bne
							6'hA, 6'h8, 6'hC, 6'hD, 6'hE:	state <= Exe_I; //I-type
							6'hF:	state <= Exe_Lui;        //lui
							6'h3:	state <= Jal;				// Jal
							6'h2: state <= J;			      // J
							default:   state <= Error;
						endcase
			Exe_Mem:  case(Inst_in[31:26])
							6'b100011: state <= Mem_RD;   // Lw
							6'b101011: state <= Mem_W;	// Sw
						endcase
			Mem_RD:  state <= LW_WB;
			LW_WB:   state <= IF;
			Mem_W:   state <= IF;
			Exe_R:	state <= R_WB;
			R_WB:    state <= IF;
			Exe_I:	state <= I_WB;
			I_WB:		state <= IF;
			Exe_Lui: state <= IF;
			Exe_Beq: state <= IF;
			Exe_Bne: state <= IF;
			Jal:     state <= IF;
			Jr:		state <= IF;	// Jalr, Jr
			J:       state <= IF;
			Error:   state <= Error;
			default: state <= Error;
		endcase
end

always @ * begin
	case(state)
		IF:		begin `Datapath_signals = 20'b1001_0100_00_00001_00000; ALU_operation = 3'b010; end
		ID:      begin `Datapath_signals = 20'b0001_0000_00_00011_00000; ALU_operation = 3'b010; end
		Exe_Mem: begin `Datapath_signals = value2; ALU_operation = 3'b010; end
		Mem_RD:  begin `Datapath_signals = value3; ALU_operation = 3'b010; end
		LW_WB:   begin `Datapath_signals = value4; ALU_operation = 3'b010; end
		Mem_W:   begin `Datapath_signals = value5; ALU_operation = 3'b010; end
		Exe_R:   begin 
						case(Inst_in[5:0])
							6'b100000: begin `Datapath_signals = 20'b0000_0000_00_01000_00000; ALU_operation = ADD; end
							6'b100010: begin `Datapath_signals = 20'b0000_0000_00_01000_00000; ALU_operation = SUB; end
							6'b100100: begin `Datapath_signals = 20'b0000_0000_00_01000_00000; ALU_operation = AND; end
							6'b100101: begin `Datapath_signals = 20'b0000_0000_00_01000_00000; ALU_operation = OR;  end
							6'b100111: begin `Datapath_signals = 20'b0000_0000_00_01000_00000; ALU_operation = NOR; end
							6'b101010: begin `Datapath_signals = 20'b0000_0000_00_01000_00000; ALU_operation = SLT; end
							6'b000010: begin `Datapath_signals = 20'b0000_0000_00_10000_00000; ALU_operation = SRL; end
							6'b000000: begin `Datapath_signals = 20'b0000_0000_00_01000_00000; ALU_operation = XOR; end
							default:   begin `Datapath_signals = 20'b0000_0000_00_01000_00000; ALU_operation = ADD; end
						endcase
					end
		R_WB:    begin `Datapath_signals = 20'b0000_0000_00_00000_10100; ALU_operation = 3'b010; end		
		Exe_I:   begin
						case(Inst_in[31:26])
							6'b001000: begin `Datapath_signals = 20'b0000_0000_00_01010_00000; ALU_operation = ADD; end // addi
							6'b001100: begin `Datapath_signals = 20'b0000_0000_00_01100_00000; ALU_operation = AND; end // andi
							6'b001101: begin `Datapath_signals = 20'b0000_0000_00_01100_00000; ALU_operation = OR;  end // ori
							6'b001110: begin `Datapath_signals = 20'b0000_0000_00_01100_00000; ALU_operation = XOR; end // xori
							6'b001010: begin `Datapath_signals = 20'b0000_0000_00_01010_00000; ALU_operation = SLT; end // slti
							default:   begin `Datapath_signals = 20'b0000_0000_00_01010_00000; ALU_operation = ADD; end
						endcase
					end
		I_WB:		begin `Datapath_signals = 20'b0000_0000_00_00000_10000;; ALU_operation = 3'b010; end
		Exe_Lui: begin `Datapath_signals = 20'b0000_0010_00_00000_10000; ALU_operation = 3'b010; end		
		Exe_Beq: begin `Datapath_signals = 20'b0100_0000_01_01000_00010; ALU_operation = 3'b110; end
		Exe_Bne: begin `Datapath_signals = 20'b0100_0000_01_01000_00000; ALU_operation = 3'b110; end		
		Jal:     begin `Datapath_signals = 20'b1000_0011_10_00001_11000; ALU_operation = 3'b010; end
		Jr:      begin 
						if(Inst_in[5:0]==6'h8) begin // jr
							`Datapath_signals = 20'b1000_0000_11_01000_00000; ALU_operation = 3'b010; end
						else begin // jalr
							`Datapath_signals = 20'b1000_0011_01_00000_10100; ALU_operation = 3'b010; end 
					end
		J:       begin `Datapath_signals = 20'b1000_0000_10_00000_00000;; ALU_operation = 3'b010; end	
		default: begin `Datapath_signals = value0; ALU_operation = 3'b010; end
	endcase
end
				
endmodule
