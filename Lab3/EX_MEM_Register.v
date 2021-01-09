`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:47:54 12/22/2020 
// Design Name: 
// Module Name:    EX_MEM_Register 
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
module EX_MEM_Register(
    input clk,
	 input reset,
	 input EX_equal,
	 input [31:0] EX_alu_output,
	 input [31:0] EX_data_holderA,
	 input [31:0] EX_ir,
	 input [31:0] EX_pc,
	 output MEM_pc_select_enable,
	 output [31:0] MEM_alu_output,
	 output [31:0] MEM_data_holderA,
	 output [31:0] MEM_ir,
	 output [31:0] MEM_pc
    );
	
	wire const_enable;
	assign const_enable = 1'b1;
	
	wire [5:0]  EX_op;
	wire MEM_pc_select_enable_temp;
	
	parameter [5:0] BEQ = 6'b000100;
	parameter [5:0] JMP = 6'b000101;
	
	assign EX_op = EX_ir[31:26];
	
	assign MEM_pc_select_enable_temp = ((EX_op == JMP) || (EX_op == BEQ && EX_equal == 1'b1))? 1'b1 : 1'b0;
	
	Equal_cond_holder equal_cond(.in(MEM_pc_select_enable_temp), .clk(clk), .out(MEM_pc_select_enable));
	ALU_output alu_output(.input_data(EX_alu_output), .clk(clk), .output_data(MEM_alu_output));
	Data_holder reg_holder_A(.in(EX_data_holderA), .out(MEM_data_holderA), .clk(clk));
	IR ir(.input_instruction(EX_ir), .ir_enable(const_enable), .clk(clk), .reset(reset), .output_instruction(MEM_ir));
	Data_holder pc_holder(.in(EX_pc), .out(MEM_pc), .clk(clk));
	
endmodule
