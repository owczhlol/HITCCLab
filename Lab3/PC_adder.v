`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:33:24 11/11/2020 
// Design Name: 
// Module Name:    PC_adder 
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
module PC_adder(
    input  [31:0] input_address,
    output [31:0] output_address
    );
	
	assign output_address = input_address + 4;

endmodule
