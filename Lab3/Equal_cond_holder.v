`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:54:43 12/23/2020 
// Design Name: 
// Module Name:    Equal_cond_holder 
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
module Equal_cond_holder(
    input in,
    input clk,
    output reg out
    );
	
	always@(negedge clk) begin
		out <= in;
	end
endmodule
