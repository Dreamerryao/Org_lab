`timescale 1ns / 1ps
module     MDpath(input clk,
					   input reset,
					  
					   input MIO_ready,		//=1
					   input IorD,
					   input IRWrite,
					   input[1:0] RegDst,
					   input RegWrite,
					   input[1:0]MemtoReg,
					   input[1:0]ALUSrcA,
			
					   input[2:0]ALUSrcB,
					   input[1:0]PCSource,
					   input PCWrite,
					   input PCWriteCond,	
					   input Branch,
					   input[2:0]ALU_operation,
					  
					   output[31:0]PC_Current,
					   input[31:0]data2CPU,
					   output[31:0]Inst,
					   output[31:0]data_out,
					   output[31:0]M_addr,
					  
					   output zero,
					   output overflow
					  );	

assign data_out = Data_B;

wire [31:0]MDR_Data;
wire [4:0]WriteAddress;
wire [31:0]WriteData;
wire [31:0]Data_A;
wire [31:0]Data_B;
wire [31:0]ALU_Out;
wire [31:0]Imm_32;
wire [31:0]ALU_A;
wire [31:0]ALU_B;
wire [31:0]res;
wire [31:0]PC_Next;
wire CE;

assign CE = MIO_ready && (PCWrite || (PCWriteCond && zero && Branch) || (PCWriteCond && ~zero && ~Branch));
//assign CE = MIO_ready && (PCWrite || (PCWriteCond && zero && Branch) );

REG32 IR(.clk(clk),
			.rst(reset),
			.CE(IRWrite),
			.D(data2CPU[31:0]),
			.Q(Inst[31:0])
			);
			
REG32 MDR(.clk(clk),
			 .rst(1'b0),
			 .CE(1'b1),
			 .D(data2CPU[31:0]),
			 .Q(MDR_Data[31:0])
			 );

MUX4T1_5 MUX1(.s(RegDst[1:0]),
				  .I0(Inst[20:16]),
				  .I1(Inst[15:11]),
				  .I2(5'b11111),
				  .I3(5'b00000),
				  .o(WriteAddress[4:0])
				  );				  
				
MUX4T1_32 MUX2(.s(MemtoReg[1:0]),
				  .I0(ALU_Out[31:0]),
				  .I1(MDR_Data[31:0]),
				  .I2( {Inst[15:0], 16'h0000} ),
				  .I3( PC_Current[31:0] ),
				  .o(WriteData[31:0])
				  );	

Regs U2(.L_S(RegWrite),
		  .clk(clk),
		  .rst(reset),
		  .R_addr_A(Inst[25:21]),
		  .R_addr_B(Inst[20:16]),
		  .Wt_addr(WriteAddress[4:0]),
		  .Wt_data(WriteData[31:0]),
		  .rdata_A(Data_A[31:0]),
		  .rdata_B(Data_B[31:0])
		  );


Ext_32 Ext(.imm_16(Inst[15:0]),
			  .Imm_32(Imm_32[31:0])
			  );				  
							
MUX8T1_32 MUX3(.s(ALUSrcB[2:0]),
				  .I0(Data_B[31:0]),
				  .I1(32'h4),
				  .I2(Imm_32[31:0]),
				  .I3( {Imm_32[29:0],1'b0,1'b0} ),
				  .I4( {16'h0000, Inst[15:0]} ),
				  .I5( {32'h0} ),
				  .I6( {32'h0} ),
				  .I7( {32'h0} ),
				  .o(ALU_B[31:0])
				  );						  

MUX4T1_32 MUX4(.s(ALUSrcA[1:0]),
				   .I0(PC_Current[31:0]),
					.I1(Data_A[31:0]),
					.I2( {27'b0, Inst[10:6]} ),
					.I3( {32'h00000000} ),
					.o(ALU_A[31:0])
					);		  

alu U1(.A(ALU_A[31:0]),
		 .B(ALU_B[31:0]),
		 .ALU_operation(ALU_operation[2:0]),
		 .zero(zero),
		 .res(res[31:0]),
		 .overflow(overflow)
		 );					  
					  
REG32 ALUOut(.clk(clk),
				 .rst(1'b0),
				 .CE(1'b1),
				 .D(res[31:0]),
				 .Q(ALU_Out[31:0])
				 );				  
					  
MUX2T1_32 MUX5(.s(IorD),
				   .I0(PC_Current[31:0]),
					.I1(ALU_Out[31:0]),
					.o(M_addr[31:0])
					);
					  
MUX4T1_32 MUX6(.s(PCSource[1:0]),
			      .I0(res[31:0]),
					.I1(ALU_Out[31:0]),
					.I2( {PC_Current[31:28], Inst[25:0], 1'b0, 1'b0} ),
					.I3(Data_A[31:0]),  // jr
					.o(PC_Next[31:0])
					);					  
REG32 PC(.clk(clk),
			.rst(reset),
			.CE(CE),
			.D(PC_Next[31:0]),
			.Q(PC_Current[31:0])
			);					  
					  
					  
					  
					  
					  
					  
					  
					  
					  
					  
					  
					  
					  
					  	 
endmodule
