`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:01:44 12/21/2020 
// Design Name: 
// Module Name:    CPU_top 
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
module CPU_top(
    input clk,
    input reset,
	 output [31:0] debug_wb_pc,
	 output 		  debug_wb_rf_wen,
	 output [4 :0] debug_wb_rf_addr,
    output [31:0] debug_wb_rf_wdata
    );
	 
	//IF
	wire [31:0] IF_ir;
	wire [31:0] IF_npc;
	wire [31:0] pc_output_address;
	wire [31:0] pc_adder_output;
	
	//ID
	wire [31:0] ID_ir;
	wire [31:0] ID_npc;
	wire [31:0] ID_pc;
	wire [31:0] ID_data_holderA;
	wire [31:0] ID_data_holderB;
	wire [31:0] ID_imm;
	
	//EX
	wire [31:0] EX_ir;
	wire [31:0] EX_pc;
	wire [31:0] EX_npc;
	wire [31:0] EX_data_holderA;
	wire [31:0] EX_data_holderB; 
	wire [31:0] EX_imm;
	wire [31:0] EX_alu_output;
	wire [31:0] alu_dataA;
	wire [31:0] alu_dataB;
	wire EX_equal;
	
	//MEM
	(*keep = "true"*)wire [31:0] MEM_ir;
	wire [31:0] MEM_pc;
	wire [31:0] MEM_data_holderA;
	wire [31:0] MEM_alu_output;
	wire MEM_pc_select_enable;	//是否跳转cond
	wire [31:0] MEM_mem_data_holder;
	
	//WB
	wire [31:0] WB_ir;
	wire [31:0] WB_pc;
	wire [31:0] WB_mem_data_holder;
	wire [31:0] WB_alu_output;
	wire [31:0] WB_result;
	wire WB_mux_select;
	
	//Conflict_Control_Unit
	wire IF_pc_enable;	//pc使能
	wire IF_ID_enable;	//IFID寄存器使能
	wire ID_EX_enable;	//IDEX寄存器使能
	wire [1:0] EX_mux1_select_enable;
	wire [1:0] EX_mux2_select_enable;
	
	//OUTPUT
	assign debug_wb_pc = WB_pc;
   assign debug_wb_rf_wdata = WB_result;
	
	//IF
	PC pc(.new_address(IF_npc), .clk(clk), .pc_enable(IF_pc_enable), .reset(reset), .output_address(pc_output_address));
	PC_adder pc_adder(.input_address(pc_output_address), .output_address(pc_adder_output));
	PC_select pc_select(.JMP_address(MEM_alu_output), .PC_address(pc_adder_output), .pc_select(MEM_pc_select_enable), .next_address(IF_npc));
	Instruction_memory instruction_memory(.address(pc_output_address), .output_instruction(IF_ir));
	IF_ID_Register IF_ID_reg(.IF_npc(IF_npc), .IF_ir(IF_ir), .clk(clk), .IF_ID_enable(IF_ID_enable), .IF_pc(pc_output_address), 
		.reset(reset), .ID_npc(ID_npc), .ID_ir(ID_ir), .ID_pc(ID_pc));
	
	//ID
	Register_set register_set(.RS_1(ID_ir[25:21]), .RS_2(ID_ir[20:16]), .WB_ir(WB_ir), .writeback_data(WB_result),
										.clk(clk), .reset(reset), .output_data_1(ID_data_holderA), .output_data_2(ID_data_holderB),
										.write_enable(debug_wb_rf_wen), .writeback_address(debug_wb_rf_addr));	
	Extender extender(.opcode(ID_ir[31:26]), .input_26bimm(ID_ir[25:0]), .output_32bimm(ID_imm));
	ID_EX_Register ID_EX_reg(.ID_data_holderA(ID_data_holderA), .ID_data_holderB(ID_data_holderB), .ID_imm(ID_imm), .ID_npc(ID_npc), .ID_ir(ID_ir), .ID_pc(ID_pc),
		.clk(clk), .reset(reset), .ID_EX_enable(ID_EX_enable), 
		.EX_data_holderA(EX_data_holderA), .EX_data_holderB(EX_data_holderB), .EX_imm(EX_imm), .EX_npc(EX_npc), .EX_ir(EX_ir), .EX_pc(EX_pc));
	
	//EX
	equal_control eqcontrol(.data_A(EX_data_holderA), .data_B(EX_data_holderB), .clk(clk), .reset(reset), .equal(EX_equal));
	MUX3241 mux41_1(.input_data0(EX_imm), .input_data1(EX_data_holderA), .input_data2(MEM_alu_output), .input_data3(WB_result), 
		.select(EX_mux1_select_enable), .output_data(alu_dataA));
	MUX3241 mux41_2(.input_data0(EX_data_holderB), .input_data1(EX_npc), .input_data2(MEM_alu_output), .input_data3(WB_result), 
		.select(EX_mux2_select_enable), .output_data(alu_dataB));
	ALU alu(.instruction(EX_ir), .input_data1(alu_dataA), .input_data2(alu_dataB), .clk(clk), .reset(reset), .output_result(EX_alu_output));
	EX_MEM_Register EX_MEM_reg(.clk(clk), .reset(reset), .EX_equal(EX_equal), .EX_alu_output(EX_alu_output), .EX_data_holderA(EX_data_holderA), .EX_pc(EX_pc),
		.EX_ir(EX_ir), .MEM_pc_select_enable(MEM_pc_select_enable), .MEM_alu_output(MEM_alu_output), .MEM_data_holderA(MEM_data_holderA), .MEM_ir(MEM_ir), .MEM_pc(MEM_pc));
	
	//MEM
	Data_memory data_memory(.alu_address(MEM_alu_output), .data(MEM_data_holderA), .MEM_ir(MEM_ir), .clk(clk), .reset(reset), .out(MEM_mem_data_holder));
	MEM_WB_Register MEM_WB_reg(.clk(clk), .reset(reset), .MEM_mem_data_holder(MEM_mem_data_holder), .MEM_ir(MEM_ir), .MEM_alu_output(MEM_alu_output), .MEM_pc(MEM_pc),
		.WB_mem_data_holder(WB_mem_data_holder), .WB_ir(WB_ir), .WB_alu_output(WB_alu_output), .WB_pc(WB_pc));

	//WB
	assign WB_mux_select = (WB_ir[31:26] == 6'b000011)? 1'b0 : 1'b1;
	MUX32 WB_mux(.input_data0(WB_mem_data_holder), .input_data1(WB_alu_output), .select(WB_mux_select), .output_data(WB_result));
   
	//Conflict_Control_Unit
	Conflict_Control_Unit ccu(.ID_ir(ID_ir), .EX_ir(EX_ir), .MEM_ir(MEM_ir), .WB_ir(WB_ir),
		.IF_pc_enable(IF_pc_enable), .IF_ID_enable(IF_ID_enable), .ID_EX_enable(ID_EX_enable),
		.EX_mux1_select_enable(EX_mux1_select_enable), .EX_mux2_select_enable(EX_mux2_select_enable));

	
endmodule
