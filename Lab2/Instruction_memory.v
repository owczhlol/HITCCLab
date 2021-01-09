`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:39:33 11/11/2020 
// Design Name: 
// Module Name:    Instruction_memory 
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
module Instruction_memory(
    input [31:0] address,
	 input        reset,
	 input        clk,
	 output reg   cmd_reset_led,
    (*keep = "true"*)output [31:0] output_instruction
    );
	 
	reg [31:0] data [0:255];
	
	initial begin
		$readmemb("D:/Hardware/CPU/instructionmem.txt", data);
	end
	
	always@(posedge clk) begin
		if(reset == 0) begin
			cmd_reset_led = 1'b1;
		end
		else begin
			cmd_reset_led = 1'b0;
		end
	end
	
	assign output_instruction = data[address];
	
endmodule
