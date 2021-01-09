`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:52:55 11/24/2020 
// Design Name: 
// Module Name:    equal_control 
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
module equal_control(
    input [31:0] data_A,
    input [31:0] data_B,
    input        clk,
    input        reset,
    output reg   equal
    );
	always@(posedge clk) begin
		if(reset == 0) begin
			equal = 1'b0;
		end
		else begin
			equal = (data_A == data_B)? 1'b1 : 1'b0;
		end
	end

endmodule
