`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:04:02 11/12/2020 
// Design Name: 
// Module Name:    Extender 
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
module Extender(
    input [5:0] opcode,
    input [25:0] input_26bimm,
    output [31:0] output_32bimm
    );
	 
	parameter[5:0] JMP = 6'b000101;
	
	assign output_32bimm[31:0] = (opcode==JMP)? { {6{input_26bimm[25]}}, input_26bimm[25:0]}
										: { {16{input_26bimm[15]}}, input_26bimm[15:0]};
	
endmodule
