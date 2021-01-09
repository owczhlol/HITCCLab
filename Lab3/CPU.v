`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:08:04 11/12/2020 
// Design Name: 
// Module Name:    CPU 
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
module CPU(
	 input clk,
    input reset,
	 output cpu_out,
	 output result_zero,
	 output cmd_reset_led,
    output data_reset_led,
	 output reg_reset_led
	 );
	 
	//数据线组
	wire [31:0] new_address;
	wire [31:0] pc_output_address;
	wire [31:0] pc_adder_output;
	wire [31:0] npc_output;
	wire [31:0] imem_ir;
	wire [31:0] current_instruction;
	wire [31:0] writeback_data;
	wire [4:0] writeback_address;
	wire [31:0] reg_output1;
	wire [31:0] reg_output2; 
	wire [31:0] holderA;
	wire [31:0] holderB;
	wire [31:0] imm32b;
	wire [31:0] holderImm;
	wire [31:0] alu_dataA; 
	wire [31:0] alu_dataB;
	wire zero;
	wire [31:0] alu_temp;
	wire [31:0] alu_result;
	wire [31:0] mem_data_temp;
	wire [31:0] mem_data;
	
	//指令组
	wire [5:0] opcode;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rrd;
	wire [10:0] alu_func;
	wire [25:0] imm26b;
	
	//指令绑定
	assign opcode = current_instruction[31:26];
	assign rs1 = current_instruction[25:21];
	assign rs2 = current_instruction[20:16];
	assign rrd = current_instruction[15:11];
	assign alu_func = current_instruction[10:0];
	assign imm26b = current_instruction[25:0];
	
	//CU控制使能
	wire pc_enable;
	wire pc_select_enable;
	wire npc_enable;
	wire ir_enable;
	wire reg_write_enable;
	wire writeback_select_enable;
	wire mux1_select_enable;
	wire mux2_select_enable;
	wire [2:0] alu_op;
	wire mem_write_enable;
	wire mem_data_select_enable;


	//Out
	assign cpu_out = equal;
	assign result_zero = zero;
	
	//CU输入
	wire equal;
	
	
	//IF阶段元件声明
	PC pc(.new_address(new_address), .clk(clk), .pc_enable(pc_enable), .reset(reset), .output_address(pc_output_address));
	PC_adder pc_adder(.input_address(pc_output_address), .output_address(pc_adder_output));
	PC_select pc_select(.JMP_address(alu_temp), .PC_address(pc_adder_output), .pc_select(pc_select_enable), .next_address(new_address));
	Instruction_memory instruction_memory(.address(pc_output_address), .reset(reset), .clk(clk), .output_instruction(imem_ir), .cmd_reset_led(cmd_reset_led));
	
	//TODO
	NPC npc(.input_address(new_address), .clk(clk), .npc_enable(npc_enable), .output_address(npc_output));
	IR ir(.input_instruction(imem_ir), .ir_enable(ir_enable), .clk(clk), .reset(reset), .output_instruction(current_instruction));
	
	//ID阶段元件声明
	Register_set register_set(.RS_1(rs1), .RS_2(rs2), .writeback_address(writeback_address), .writeback_data(writeback_data),
										.clk(clk), .write_enable(reg_write_enable), .reset(reset), .output_data_1(reg_output1), 
										.output_data_2(reg_output2), .reg_reset_led(reg_reset_led));							
	Data_holder reg_holder_A(.in(reg_output1), .out(holderA), .clk(clk));
	Data_holder reg_holder_B(.in(reg_output2), .out(holderB), .clk(clk));
	Extender extender(.opcode(opcode), .input_26bimm(imm26b), .output_32bimm(imm32b));
	Data_holder imm_holder(.in(imm32b), .out(holderImm), .clk(clk));
	Writeback_Select writeback_select(.select(writeback_select_enable), .rs1_address(rs1), .rd_address(rrd), .writeback_address(writeback_address));

	//EX阶段元件声明
	equal_control eqcontrol(.data_A(holderA), .data_B(holderB), .clk(clk), .reset(reset), .equal(equal) );		
	MUX32 mux1(.input_data0(holderImm), .input_data1(holderA), .select(mux1_select_enable), .output_data(alu_dataA));
	MUX32 mux2(.input_data0(holderB), .input_data1(npc_output), .select(mux2_select_enable), .output_data(alu_dataB));
	ALU alu(.alu_op(alu_op), .input_data1(alu_dataA), .input_data2(alu_dataB), 
				.clk(clk), /*.equal(equal),*/ .output_result(alu_temp), .reset(reset), .zero(zero));
	ALU_output alu_output(.input_data(alu_temp), .clk(clk), .output_data(alu_result));
	
	//MEM阶段元件声明
	Data_memory data_memory(.alu_address(alu_result), .data(holderA), .write_enable(mem_write_enable), 
									.clk(clk), .reset(reset), .out(mem_data_temp), .data_reset_led(data_reset_led));
	Data_holder mem_holder(.in(mem_data_temp), .out(mem_data), .clk(clk));
	
	//WB阶段元件声明
	MUX32 mux3(.input_data0(mem_data), .input_data1(alu_result), .select(mem_data_select_enable), .output_data(writeback_data));
	 
	//CU声明
	CU cu(.opcode(opcode), .ALUfunc(alu_func), .clk(clk), .reset(reset), .equal(equal), .pc_enable(pc_enable), .pc_select_enable(pc_select_enable),
			.npc_enable(npc_enable), .ir_enable(ir_enable), .reg_write_enable(reg_write_enable), .writeback_select_enable(writeback_select_enable),
			.mux1_select_enable(mux1_select_enable), .mux2_select_enable(mux2_select_enable), .alu_op(alu_op), .mem_write_enable(mem_write_enable),
			.mem_data_select_enable(mem_data_select_enable));
	 
endmodule

