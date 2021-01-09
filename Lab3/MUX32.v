`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:39:28 11/12/2020 
// Design Name: 
// Module Name:    MUX32 
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
module MUX32(
    input [31:0] input_data0,
    input [31:0] input_data1,
    input select,
    (* KEEP = "TRUE" *)output [31:0] output_data
    );
	assign output_data = (select == 1'b0)? input_data0 : input_data1;

endmodule
