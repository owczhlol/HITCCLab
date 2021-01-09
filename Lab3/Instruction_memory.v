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
    (*keep = "true"*)output [31:0] output_instruction
    );
	 
	reg [31:0] data [0:255];
	
	wire [29:0] meaningful_address;
	wire [31:0] fixed_address;
	
	assign meaningful_address = address[31:2];
	assign fixed_address = {2'b00, meaningful_address};
	
	
	initial begin
		$readmemb("D:/Hardware/instructionmem.txt", data);
	end
	
	assign output_instruction = data[fixed_address];
	
endmodule
