`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:05:59 09/21/2020 
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
module top(	input clk200P,
				input clk200N,
				input RSTN,
				input [3:0] K_COL,
				output [4:0] K_ROW,
				input [15:0] SW,
				output seg_clk,
				output seg_do,
				output seg_pen,
				output led_clk,
				output led_pen,
				output led_do,
				output [7:0] SEGMENT,
				output [3:0] AN,
				output [7:0] LED,
				output CR, RDY, readn
				);
//some defines
wire rst, Clk_CPU, IO_clk, GPIOF0;
wire mem_w, V5, N0;
wire counter0_out, counter1_out, counter2_out, counter_we, GPIOe0000000_we, data_ram_we, vram_we;
wire [1:0] counter_ch;
wire [3:0] Pulse, BTN_OK;
wire [4:0] Key_out, State;
wire [7:0] blink, LE_out, point_out;
wire [8:0] row;
wire [9:0] PS2_key, col;
wire [12:0] ram_addr;
wire [11:0] vga_data, vram_data_in, vram_data_out,start_data,maze_data;
wire [15:0] SW_OK, LED_out;
wire [17:0] start_addr;
wire [16:0] maze_addr;
wire [17:0] vram_r_addr, vram_w_addr;
wire [31:0] Div, Ai, Bi, Disp_num, inst, CPU2IO, PC, Addr_out, Data_in, Data_out, Counter_out, ram_data_in, ram_data_out;
wire [31:0] location;


clk_diff  Q1(
	.clk200P(clk200P),
	.clk200N(clk200N),
	.clk200MHz(clk_100mhz)
	);
SAnti_jitter U9	(.RSTN(RSTN), .clk(clk_100mhz), .Key_y(K_COL), .Key_x(K_ROW), .SW(SW), .readn(readn),
						.CR(CR), .Key_out(Key_out), .Key_ready(RDY), .pulse_out(Pulse), .BTN_OK(BTN_OK), 
						.SW_OK(SW_OK), .rst(rst));

clk_div U8			(.clk(clk_100mhz), .rst(rst), .SW2(SW_OK[2]), .clkdiv(Div), .Clk_CPU(Clk_CPU));

VCC  v_13 (.P(V5));
GND  g_14 (.G(N0));
assign IO_clk = ~Clk_CPU;

SEnter_2_32 M4		(.clk(clk_100mhz), .Din(Key_out), .D_ready(RDY), .BTN(BTN_OK[2:0]), .Ctrl({SW_OK[7:5],SW_OK[15],SW_OK[0]}),
						.readn(readn), .Ai(Ai), .Bi(Bi), .blink(blink));

 SSeg7_Dev  U6 (.clk(clk_100mhz), 
                 .flash(Div[25]), 
                 .Hexs(Disp_num), 
                 .LES(LE_out), 
                 .point(point_out), 
                 .rst(rst), 
                 .Start(Div[20]), 
                 .SW0(SW_OK[0]), 
                 .seg_clk(seg_clk), 
                 .seg_clrn(), 
                 .SEG_PEN(seg_pen), 
                 .seg_sout(seg_do));					

MCPU U1				(.clk(Clk_CPU), .reset(rst), .inst_out(inst), .INT(counter0_out), .PC_out(PC), .mem_w(mem_w), 
						.Addr_out(Addr_out), .Data_in(Data_in), .Data_out(Data_out), .state(State), .MIO_ready(V5));

RAM_B U3				(.addra(ram_addr), .wea(data_ram_we), .dina(ram_data_in), .clka(clk_100mhz), .douta(ram_data_out));

Counter U10			(.clk(IO_clk), .rst(rst), .clk0(Div[6]), .clk1(Div[9]), .clk2(Div[11]), .counter_we(counter_we), 
						.counter_val(CPU2IO), .counter_ch(counter_ch), .counter0_OUT(counter0_out), .counter1_OUT(counter1_out), 
						.counter2_OUT(counter2_out), .counter_out(Counter_out));
						
Multi_8CH32 U5		(.clk(IO_clk), .rst(rst), .EN(GPIOe0000000_we), .Test(SW_OK[7:5]), .point_in({Div,Div}), .LES({64{1'b0}}), 
						.Data0(CPU2IO), .data1({N0,N0,PC[31:2]}), .data2(inst), .data3(Counter_out), .data4(Addr_out), .data5(Data_out), 
						.data6(Data_in), .data7({{22{N0}},PS2_key}), .Disp_num(Disp_num), .point_out(point_out), .LE_out(LE_out));
						
GPIO U7				(.clk(IO_clk), .rst(rst), .EN(GPIOF0), .Start(Div[20]), .P_Data(CPU2IO), .counter_set(counter_ch), 
						.LED_out(LED_out), .GPIOf0(), .ledclk(led_clk), .ledsout(led_do), .LEDEN(led_pen), .ledclrn());


Seg7_Dev U61		(.Scan({SW_OK[1],Div[19:18]}), .SW0(SW_OK[0]), .flash(Div[25]), .Hexs(Disp_num), .point(point_out), 
						.LES(LE_out),.SEGMENT(SEGMENT), .AN(AN));

PIO U71				(.clk(IO_clk), .rst(rst), .EN(GPIOF0), .PData_in(CPU2IO), .LED_out(LED));
//防止出错,这些模块都调用的MCPU实验中提供的核


MIO_BUS U4			(.clk(clk_100mhz), .rst(rst), .BTN(BTN_OK), .SW(SW_OK), .mem_w(mem_w), .addr_bus(Addr_out), 
						.Cpu_data4bus(Data_in), .Cpu_data2bus(Data_out), .ram_data_in(ram_data_in), .data_ram_we(data_ram_we), 
						.ram_addr(ram_addr), .ram_data_out(ram_data_out), .Peripheral_in(CPU2IO), .GPIOe0000000_we(GPIOe0000000_we), 
						.GPIOf0000000_we(GPIOF0), .led_out(LED_out), .counter_out(Counter_out), .counter2_out(counter2_out), 
						.counter1_out(counter1_out), .counter0_out(counter0_out), .counter_we(counter_we)
						);

endmodule