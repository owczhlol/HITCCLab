`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:32:21 12/22/2020
// Design Name:   MUX3241
// Module Name:   D:/Hardware/CPU_v2/mux3241_test.v
// Project Name:  CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: MUX3241
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mux3241_test;

	// Inputs
	reg [31:0] input_data0;
	reg [31:0] input_data1;
	reg [31:0] input_data2;
	reg [31:0] input_data3;
	reg [1:0] select;

	// Outputs
	wire [31:0] output_data;

	// Instantiate the Unit Under Test (UUT)
	MUX3241 uut (
		.input_data0(input_data0), 
		.input_data1(input_data1), 
		.input_data2(input_data2), 
		.input_data3(input_data3), 
		.select(select), 
		.output_data(output_data)
	);

	initial begin
		// Initialize Inputs
		input_data0 = 32'h00000000;
		input_data1 = 32'h00000001;
		input_data2 = 32'h00000002;
		input_data3 = 32'h00000003;
		select = 2'b00;
		// Wait 100 ns for global reset to finish
		#10
      select = 2'b01;
		#10
      select = 2'b10;
		#10
      select = 2'b11;
		// Add stimulus here

	end
      
endmodule

