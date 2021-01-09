`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:49:01 10/24/2020
// Design Name:   ALU
// Module Name:   D:/Hardware/last/test.v
// Project Name:  last
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

module test;

	// Inputs
	reg [31:0] A;
	reg [31:0] B;
	reg Cin;
	reg [4:0] Card;

	// Outputs
	wire [31:0] F;
	wire Cout;
	wire Zero;

	// Instantiate the Unit Under Test (UUT)
	ALU uut (
		.A(A), 
		.B(B), 
		.Cin(Cin), 
		.Card(Card), 
		.F(F), 
		.Cout(Cout), 
		.Zero(Zero)
	);
	reg clk ;
	parameter clk_period=10;
	
	
	initial begin
		A = 32'h FFFFFFFF;
		B = 32'h 00000001;
		Card = 5'b11111;
		Cin = 1;
		clk=10;
		#100; 
	end
	
   always #(clk_period/2)clk=~clk;
	
	always@(posedge clk)begin
		Card=(Card==5'b01111)? 5'b00000:Card+1'b1;
	end
   
endmodule