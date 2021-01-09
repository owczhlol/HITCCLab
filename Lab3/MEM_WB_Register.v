`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:27:40 12/22/2020 
// Design Name: 
// Module Name:    MEM_WB_Register 
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
module MEM_WB_Register(
    input clk,
    input reset,
	 input [31:0] MEM_mem_data_holder,
	 input [31:0] MEM_ir,
	 input [31:0] MEM_alu_output,
	 input [31:0] MEM_pc,
	 output [31:0] WB_mem_data_holder,
	 output [31:0] WB_ir,
	 output [31:0] WB_alu_output,
	 output [31:0] WB_pc
    );
	 
	wire const_enable;
	assign const_enable = 1'b1;
	
	
	Data_holder mem_holder(.in(MEM_mem_data_holder), .out(WB_mem_data_holder), .clk(clk));
	ALU_output alu_output(.input_data(MEM_alu_output), .clk(clk), .output_data(WB_alu_output));
	IR ir(.input_instruction(MEM_ir), .ir_enable(const_enable), .clk(clk), .reset(reset), .output_instruction(WB_ir));
	Data_holder pc_holder(.in(MEM_pc), .out(WB_pc), .clk(clk));
	
endmodule
