`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:25:44 12/21/2020 
// Design Name: 
// Module Name:    IF_ID_Register 
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
module IF_ID_Register(
    input [31:0] IF_npc,
	 input [31:0] IF_ir,
	 input [31:0] IF_pc,
	 input clk,
	 input IF_ID_enable,
	 input reset,
	 output [31:0] ID_npc,
	 output [31:0] ID_ir,
	 output [31:0] ID_pc
    );
	
	wire const_enable;
	assign const_enable = 1'b1;
	
	reg [31:0] old_ir;
	reg [31:0] old_npc;
	reg [31:0] old_pc;
	 
	wire [31:0] ID_npc_temp;
	wire [31:0] ID_ir_temp;
	wire [31:0] ID_pc_temp;
	wire [31:0] unfixed_ID_pc;
	
	NPC npc(.input_address(IF_npc), .clk(clk), .npc_enable(const_enable), .output_address(ID_npc_temp));
	IR ir(.input_instruction(IF_ir), .ir_enable(const_enable), .clk(clk), .reset(reset), .output_instruction(ID_ir_temp));
	Data_holder pc_holder(.in(IF_pc), .out(ID_pc_temp), .clk(clk));
	
	assign ID_npc = (IF_ID_enable == 1)? ID_npc_temp : old_npc;
	assign ID_ir  = (IF_ID_enable == 1)? ID_ir_temp  : old_ir;
	assign unfixed_ID_pc =  (IF_ID_enable == 1'b1)? ID_pc_temp  : old_pc;
	assign ID_pc = (unfixed_ID_pc == 32'h00000000)? 32'h00000000 : (unfixed_ID_pc - 4);
	
	always@(negedge clk) begin
		old_ir <= ID_ir;
		old_npc <= ID_npc;
		old_pc <= unfixed_ID_pc;
	end
	
endmodule
