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
    input [31:0] alu_address,
    input [31:0] data,
	 input [31:0] MEM_ir,
    input clk,
    input reset,
    output [31:0] out
    );

	reg [31:0] memory [0:255];

	wire write_enable;
	wire [5:0] MEM_op;
	
	assign MEM_op = MEM_ir[31:26];
	assign write_enable = (MEM_op == 6'b000010)? 1'b1 : 1'b0;
	
	assign out = memory[alu_address];
	
	initial begin
		$readmemb("D:/Hardware/datamem.txt" ,memory);
	end
		
	always@(posedge clk) begin
		if(reset == 1'b0) begin
			//$readmemb("D:/Hardware/CPU/datamem.txt" ,memory);
		end
		else begin
			if(write_enable == 1'b1) begin
				memory[alu_address] <= data;
			end	
		end
	end
endmodule
