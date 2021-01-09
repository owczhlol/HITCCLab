`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:55:00 11/11/2020 
// Design Name: 
// Module Name:    PC 
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
module PC(
    input [31:0] new_address,
    input        clk,
    input		  reset,
    input 		  pc_enable,
    (* KEEP = "TRUE" *)output reg[31:0] output_address
    );
	 
	always@(posedge clk) begin
		if(reset == 1'b0) 
			output_address <= 32'b0;
		else 
			output_address <= (pc_enable == 1)? new_address : output_address;
	end
	
endmodule
