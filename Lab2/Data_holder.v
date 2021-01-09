`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:38:11 11/11/2020 
// Design Name: 
// Module Name:    Data_holder 
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
module Data_holder(
    input [31:0] in,
    input        clk,
    (* KEEP = "TRUE" *)output reg [31:0] out
    );
	
	always@(negedge clk) begin
		out <= in;
	end
	
endmodule
