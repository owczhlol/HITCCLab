`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:37:42 12/23/2020
// Design Name:   CPU_top
// Module Name:   D:/Hardware/CPU_v2/CPU_top_test.v
// Project Name:  CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CPU_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CPU_top_test;

	// Inputs
	reg clk;
	reg reset;

	// Outputs
	wire [31:0] debug_wb_pc;
	wire debug_wb_rf_wen;
	wire [4:0] debug_wb_rf_addr;
	wire [31:0] debug_wb_rf_wdata;

	// Instantiate the Unit Under Test (UUT)
	CPU_top uut (
		.clk(clk), 
		.reset(reset), 
		.debug_wb_pc(debug_wb_pc), 
		.debug_wb_rf_wen(debug_wb_rf_wen), 
		.debug_wb_rf_addr(debug_wb_rf_addr), 
		.debug_wb_rf_wdata(debug_wb_rf_wdata)
	);

	initial begin
		clk = 0;
		reset = 1;
		
		#10;
		reset = 0;
		#100
      reset = 1;
			
	end
      
	always begin
		#2 clk = ~clk;
	end
      
endmodule

