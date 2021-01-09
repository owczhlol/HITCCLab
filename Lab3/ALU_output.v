`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:45:25 11/13/2020 
// Design Name: 
// Module Name:    ALU_output 
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
module ALU_output(
    input [31:0] input_data,
    input clk,
    output reg[31:0] output_data
    );

	always@(negedge clk) begin
		output_data = input_data;
	end
	
endmodule
