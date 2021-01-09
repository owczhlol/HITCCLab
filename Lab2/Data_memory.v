`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:21:06 11/13/2020 
// Design Name: 
// Module Name:    Data_memory 
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
module Data_memory(
    input [31:0]  alu_address,
    input [31:0]  data,
    input         write_enable,
    input         clk,
    input         reset,
	 output  reg   data_reset_led,
    output [31:0] out
    );

	reg [31:0] memory [0:255];
	
	initial begin
		$readmemb("D:/Hardware/CPU/datamem.txt" ,memory);
	end
	
	assign out = memory[alu_address];
		
	
	always@(posedge clk) begin
		if(reset == 0) begin
			data_reset_led = 1'b1;
		end
		else begin
			data_reset_led = 1'b0;
			if(write_enable == 1) begin
				memory[alu_address] <= data;
			end	
		end
	end

endmodule
