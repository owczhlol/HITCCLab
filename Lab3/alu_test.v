`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:00:32 12/22/2020
// Design Name:   ALU
// Module Name:   D:/Hardware/CPU_v2/alu_test.v
// Project Name:  CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ALU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alu_test;

	// Inputs
	reg [31:0] instruction;
	reg [31:0] input_data1;
	reg [31:0] input_data2;
	reg clk;
	reg reset;

	// Outputs
	wire [31:0] output_result;

	// Instantiate the Unit Under Test (UUT)
	ALU uut (
		.instruction(instruction), 
		.input_data1(input_data1), 
		.input_data2(input_data2), 
		.clk(clk), 
		.reset(reset), 
		.output_result(output_result)
	);

	initial begin
		// Initialize Inputs
		instruction = 32'h00000000;
		input_data1 = 32'h00000001;
		input_data2 = 32'h00000002;
		clk = 0;
		reset = 1;	
		#10
		reset = 0;
		#100
		reset = 1;
		#120
		instruction = 32'b00000100001000100100000000000010;
		#140
		instruction = 32'b00000100001000100100000000000001;
		#160
		instruction = 32'b00010100000000000000000000000001;
		#180
		instruction = 32'b00001000001000010000000000001010;
	end
	
   always begin
		#5 clk = ~clk;   
	end
	
endmodule

