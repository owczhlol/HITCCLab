`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:33:08 11/11/2020 
// Design Name: 
// Module Name:    Register_set 
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
module Register_set(
    input  [ 4:0] RS_1,
    input  [ 4:0] RS_2,    
	 input  [ 4:0] writeback_address,   
	 input  [31:0] writeback_data,
    input         clk,
    input         write_enable,
    input         reset,
	 output reg    reg_reset_led,
    output [31:0] output_data_1,
    output [31:0] output_data_2
    );
	 
	reg [31:0] memory [0:31];
	
	assign output_data_1 = memory[RS_1];
	assign output_data_2 = memory[RS_2];
	
	initial begin
		$readmemb("D:/Hardware/CPU/regdata.txt", memory);
	end
	
	always@(posedge clk) begin
		if(reset == 0) begin
			reg_reset_led = 1'b1;
		end
		else 
			begin
				reg_reset_led = 1'b0;
				if(write_enable == 1) begin
					memory[writeback_address] <= writeback_data;
				end
			end
	end
endmodule
