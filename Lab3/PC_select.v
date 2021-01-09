`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:05:39 11/11/2020 
// Design Name: 
// Module Name:    PC_select 
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
module PC_select(
    input [31:0] JMP_address,
    input [31:0] PC_address,
    input pc_select,
    output [31:0] next_address
    );
	 
	assign next_address = (pc_select == 1)? JMP_address : PC_address;

endmodule
