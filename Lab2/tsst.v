`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:56:54 11/11/2020 
// Design Name: 
// Module Name:    test 
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
module reg_file(clk, reset, write, read_address_a, read_address_b, write_address, write_data, read_out_a, read_out_b);
	input clk, reset, write;
	input [4:0] read_address_a, read_address_b, write_address;
	input [31:0] write_data;
	output [31:0] read_out_a, read_out_b;
	
	reg [31:0] data [0:31];
	
	
	assign read_out_a = (read_address_a == 5'b0) ? 32'b0 : data[read_address_a];
	assign read_out_b = (read_address_b == 5'b0) ? 32'b0 : data[read_address_b];
	
	always @(negedge clk or negedge reset) begin
		if(reset == 0) begin
      end
		else if(write == 1'b1 && write_address != 5'b0) data[write_address] <= write_data;
	end

endmodule