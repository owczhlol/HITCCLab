`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:17:48 12/22/2020 
// Design Name: 
// Module Name:    MUX3241 
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
module MUX3241(
    input [31:0] input_data0,
    input [31:0] input_data1,
    input [31:0] input_data2,
    input [31:0] input_data3,
    input [1:0] select,
    (* KEEP = "TRUE" *)output [31:0] output_data
    );
	
	assign output_data = (select[1] == 1'b0)? (select[0] == 1'b0)? input_data0 : input_data1
														 : (select[0] == 1'b0)? input_data2 : input_data3;
														 

endmodule
