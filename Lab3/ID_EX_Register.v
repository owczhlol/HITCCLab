`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:47:53 12/21/2020 
// Design Name: 
// Module Name:    ID_EX_Register 
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
module ID_EX_Register(
	 input [31:0] ID_data_holderA,
	 input [31:0] ID_data_holderB,
	 input [31:0] ID_imm,
	 input [31:0] ID_npc,
	 input [31:0] ID_ir,
	 input [31:0] ID_pc,
	 input clk,
	 input reset,
	 input ID_EX_enable,
	 output [31:0] EX_data_holderA,
	 output [31:0] EX_data_holderB,
	 output [31:0] EX_imm,
	 output [31:0] EX_npc,
	 output [31:0] EX_ir,
	 output [31:0] EX_pc
    );
	 
	wire const_enable;
	assign const_enable = 1'b1;
	
	wire [31:0] EX_data_holderA_temp;
	wire [31:0] EX_data_holderB_temp;
	wire [31:0] EX_ir_temp;
	
	Data_holder reg_holder_A(.in(ID_data_holderA), .out(EX_data_holderA_temp), .clk(clk));
	Data_holder reg_holder_B(.in(ID_data_holderB), .out(EX_data_holderB_temp), .clk(clk));
	Data_holder imm_holder(.in(ID_imm), .out(EX_imm), .clk(clk));
	NPC npc(.input_address(ID_npc), .clk(clk), .npc_enable(const_enable), .output_address(EX_npc));
	IR ir(.input_instruction(ID_ir), .ir_enable(const_enable), .clk(clk), .reset(reset), .output_instruction(EX_ir_temp));
	Data_holder pc_holder(.in(ID_pc), .out(EX_pc), .clk(clk));
	
	assign EX_data_holderA = (ID_EX_enable == 1)? EX_data_holderA_temp : 32'h00000000;
	assign EX_data_holderB = (ID_EX_enable == 1)? EX_data_holderB_temp : 32'h00000000;
	assign EX_ir = (ID_EX_enable == 1)? EX_ir_temp : 32'h00000000;
	
endmodule
