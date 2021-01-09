`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:44:49 11/23/2020
// Design Name:   PC
// Module Name:   D:/Hardware/CPU/pctest.v
// Project Name:  CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PC
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module pctest;

	// Inputs
	reg [31:0] new_address;
	reg clk;
	reg reset;
	reg pc_enable;

	// Outputs
	wire [31:0] output_address;

	// Instantiate the Unit Under Test (UUT)
	PC uut (
		.new_address(new_address), 
		.clk(clk), 
		.reset(reset), 
		.pc_enable(pc_enable), 
		.output_address(output_address)
	);

	initial begin
		// Initialize Inputs
		new_address = 32'b1;
		clk = 0;
		reset = 0;
		pc_enable = 1;

		// Wait 100 ns for global reset to finish
      #100 reset = 1'b1;
		// Add stimulus here
	end
   always begin
		#10 clk = ~clk;
	end   
endmodule

