`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:22:26 11/13/2020 
// Design Name: 
// Module Name:    Writeback_Select 
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
module Writeback_Select(
    input        select,
    input  [4:0] rs1_address,
    input  [4:0] rd_address,
    output [4:0] writeback_address
    );
	
	assign writeback_address = (select == 1)? rs1_address : rd_address;

endmodule
