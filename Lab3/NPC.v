`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:25:49 11/11/2020 
// Design Name: 
// Module Name:    NPC 
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
module NPC(
    input [31:0] input_address,
    input clk,
	 input npc_enable,
	 output reg[31:0] output_address
    );

	always@(negedge clk) begin
		output_address = (npc_enable==1)? input_address : 32'h00000000;
	end
	
endmodule
