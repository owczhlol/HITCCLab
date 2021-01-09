`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:07:18 11/23/2020
// Design Name:   CPU
// Module Name:   D:/Hardware/CPU/CPUtest.v
// Project Name:  CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CPU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module CPUtest;

	// Inputs
	reg clk;
	reg reset;

	wire cpu_out;
	
	// Instantiate the Unit Under Test (UUT)
	CPU uut (
		.clk(clk), 
		.reset(reset),
		.cpu_out(cpu_out)
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
		#5 clk = ~clk;
	end

endmodule

