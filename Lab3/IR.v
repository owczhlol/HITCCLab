`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:48:50 11/11/2020 
// Design Name: 
// Module Name:    IR 
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
module IR(
    input [31:0] input_instruction,
    input ir_enable,
    input clk,
	 input reset,
    (* KEEP = "TRUE" *)output reg[31:0] output_instruction
    );

	always@(negedge clk) begin
		if (reset == 0) begin
			output_instruction <= 32'h00000000;
		end
		else begin
			output_instruction <= (ir_enable == 1)? input_instruction : 32'h00000000;
		end
	end
	
endmodule
