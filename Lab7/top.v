`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:03:26 08/09/2020 
// Design Name: 
// Module Name:    top 
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
module top(
		input [3:0] BTN_y,
		input clk200P,
		input clk200N,
		input RSTN,
		input [15:0] SW,
		output [4:0] BTN_x,
		output [3:0] AN,
		output CR,
		output [7:0] LED,
		output led_clk,
		output led_pen,
		output led_do,
		output RDY,
		output readn,
		output [7:0] SEGMENT,
		output seg_clk,
		output seg_do,
		output seg_pen
		);
	 
   wire [31:0] Ai,Bi;
   wire [7:0] blink;
   wire [3:0] BTN_OK;
   wire [31:0] Counter_out,Addr_out,CPU2IO,Data_in,Data_out,Disp_num,Div,inst,PC,douta,dina;
   wire EN,N0,V5,Clk_CPU,IO_clk,GPIOF0,rst;
   wire [15:0] LED_out,SW_OK;
   wire [7:0] LE_out,point_out;
   wire [3:0] Pulse;
   wire [4:0] Key_out;
   wire [9:0] addr_a;
	wire clka;
   wire  wea,WR,counter_we,INT,counter1_out,counter2_out;
   wire [1:0] counter_ch;
	wire clk_100mhz;
	
	clk_diff  Q1(
	.clk200P(clk200P),
	.clk200N(clk200N),
	.clk200MHz(clk_100mhz)
	);
   VCC  v_11 (.P(V5));
   GND  g_12 (.G(N0));
   assign IO_clk = ~Clk_CPU;
	assign clka = ~clk_100mhz;
   SEnter_2_32  M4 (.BTN(BTN_OK[2:0]), 
                   .clk(clk_100mhz), 
                   .Ctrl({SW_OK[7:5], SW_OK[15], SW_OK[0]}), 
                   .Din(Key_out), 
                   .D_ready(RDY), 
                   .Ai(Ai), 
                   .Bi(Bi), 
                   .blink(blink), 
                   .readn(readn));
   ROM_D  U2 (.a(PC[11:2]), 
             .spo(inst));
   Multi_8CH32  U5 (.clk(IO_clk), 
                   .Data0(CPU2IO), 
                   .data1({N0, N0, PC[31:2]}), 
                   .data2(inst), 
                   .data3(Counter_out), 
                   .data4(Addr_out), 
                   .data5(Data_out), 
                   .data6(Data_in), 
                   .data7(PC), 
                   .EN(EN), 
                   .LES({64{1'b0}}), 
                   .point_in({Div, Div}), 
                   .rst(rst), 
                   .Test(SW_OK[7:5]), 
                   .Disp_num(Disp_num), 
                   .LE_out(LE_out), 
                   .point_out(point_out));
   clk_div  U8 (.clk(clk_100mhz), 
               .rst(rst), 
               .SW2(SW_OK[2]), 
               .clkdiv(Div), 
               .Clk_CPU(Clk_CPU));
   SAnti_jitter  U9 (.clk(clk_100mhz), 
                    .Key_y(BTN_y), 
                    .readn(readn), 
                    .RSTN(RSTN), 
                    .SW(SW), 
                    .BTN_OK(BTN_OK[3:0]), 
                    .CR(CR), 
                    .Key_out(Key_out), 
                    .Key_ready(RDY), 
                    .Key_x(BTN_x), 
                    .pulse_out(Pulse[3:0]), 
                    .rst(rst), 
                    .SW_OK(SW_OK));
   Seg7_Dev  U61 (.flash(Div[25]), 
                 .Hexs(Disp_num[31:0]), 
                 .LES(LE_out), 
                 .point(point_out), 
                 .Scan({SW_OK[1], Div[19:18]}), 
                 .SW0(SW_OK[0]), 
                 .AN(AN), 
                 .SEGMENT(SEGMENT));

   RAM_B  U3 (.addra(addr_a), 
                  .clka(clka), 
                  .dina(dina), 
                  .wea(wea), 
                  .douta(douta));
   SCPU  U1 (.clk(Clk_CPU), 
                 .Data_in(Data_in), 
                 .inst_in(inst), 
                 .INT(INT), 
                 .MIO_ready(), 
                 .reset(rst), 
                 .Addr_out(Addr_out), 
                 .ALE(), 
                 .CPU_MIO(), 
                 .Data_out(Data_out), 
                 .PC_out(PC), 
                 .WR(WR));
   MIO_BUS  U4 (.addr_bus(Addr_out), 
                    .BTN(BTN_OK[3:0]), 
                    .clk(clk_100mhz), 
                    .counter_out(Counter_out), 
                    .counter0_out(INT), 
                    .counter1_out(counter1_out), 
                    .counter2_out(counter2_out), 
                    .Cpu_data2bus(Data_out), 
                    .led_out(LED_out), 
                    .mem_w(WR), 
                    .ram_data_out(douta), 
                    .rst(rst), 
                    .SW(SW_OK), 
                    .counter_we(counter_we), 
                    .Cpu_data4bus(Data_in), 
                    .data_ram_we(wea), 
                    .GPIOe0000000_we(EN), 
                    .GPIOf0000000_we(GPIOF0), 
                    .Peripheral_in(CPU2IO), 
                    .ram_addr(addr_a), 
                    .ram_data_in(dina));
   Counter  U10 (.clk(IO_clk), 
                    .clk0(Div[6]), 
                    .clk1(Div[9]), 
                    .clk2(Div[11]), 
                    .counter_ch(counter_ch), 
                    .counter_val(CPU2IO), 
                    .counter_we(counter_we), 
                    .rst(rst), 
                    .counter_out(Counter_out), 
                    .counter0_OUT(INT), 
                    .counter1_OUT(counter1_out), 
                    .counter2_OUT(counter2_out));
   Display  U6 (.clk(clk_100mhz), 
                    .flash(Div[25]), 
                    .Hexs(Disp_num), 
                    .LES(LE_out), 
                    .point(point_out), 
                    .rst(rst), 
                    .Start(Div[20]), 
                    .Text(SW_OK[0]), 
                    .segclk(seg_clk), 
                    .segclrn(), 
                    .SEGEN(seg_pen), 
                    .segsout(seg_do));
   GPIO  U7 (.clk(IO_clk), 
                 .EN(GPIOF0), 
                 .P_Data(CPU2IO), 
                 .rst(rst), 
                 .Start(Div[20]), 
                 .counter_set(counter_ch), 
                 .GPIOf0(), 
                 .ledclk(led_clk), 
                 .ledclrn(), 
                 .LEDEN(led_pen), 
                 .ledsout(led_do), 
                 .LED_out(LED_out));
   PIO  U71 (.clk(IO_clk), 
                .EN(GPIOF0), 
                .PData_in(CPU2IO), 
                .rst(rst), 
                .counter_set(), 
                .GPIOf0(), 
                .LED_out(LED));

endmodule
