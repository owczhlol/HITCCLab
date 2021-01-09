`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:09:52 11/12/2020 
// Design Name: 
// Module Name:    CU 
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
module CU(
    input [5:0] opcode,
    input [10:0] ALUfunc,
    input clk,
    input reset,
	 input equal,
	 output reg pc_enable,
	 output reg pc_select_enable,
	 output reg npc_enable,
	 output reg ir_enable,
	 output reg reg_write_enable,
	 output reg writeback_select_enable,
	 output reg mux1_select_enable,
	 output reg mux2_select_enable,
	 output reg [2:0] alu_op,
	 output reg mem_write_enable,
	 output reg mem_data_select_enable
    );
	 

	parameter [5:0] ALU = 6'b000001;
	parameter [5:0] SW  = 6'b000010;
	parameter [5:0] LW  = 6'b000011;
	parameter [5:0] BEQ = 6'b000100;
	parameter [5:0] JMP = 6'b000101;
	
	parameter [4:0] STATE_IF  = 5'b00001;
	parameter [4:0] STATE_ID  = 5'b00010;
	parameter [4:0] STATE_EX  = 5'b00100;
	parameter [4:0] STATE_MEM = 5'b01000;
	parameter [4:0] STATE_WB  = 5'b10000;
	
	reg [4:0] STATE;
	reg [4:0] NEXT_STATE;
	
	always@(negedge clk) begin
		if(reset == 0) begin
			pc_enable <= 0;
			pc_select_enable <= 0;
			npc_enable <= 1;
			ir_enable <= 0;
			reg_write_enable <= 0;
			writeback_select_enable <= 0;
			mux1_select_enable <= 0;
			mux2_select_enable <= 0;
			mem_write_enable <= 0;
			mem_data_select_enable <= 0;
			STATE <= STATE_WB;
			NEXT_STATE <= STATE_IF;
		end
		
		else begin
			STATE <= NEXT_STATE;
			case(opcode)
				ALU : alu_op <= ALUfunc[2:0];
				BEQ : alu_op <= 3'b000;
				JMP : alu_op <= 3'b111;
				default: alu_op <= 3'b001;
			endcase
			
			case (NEXT_STATE)
				STATE_IF : NEXT_STATE <= STATE_ID;
				STATE_ID : NEXT_STATE <= STATE_EX;
				STATE_EX : NEXT_STATE <= STATE_MEM;
				STATE_MEM: NEXT_STATE <= STATE_WB;
				STATE_WB : NEXT_STATE <= STATE_IF;
			endcase	
			
			//pc_enable <= (STATE == STATE_WB)? 1'b1 : 1'b0;//整个IF阶段都为1
			//ir_enable <= (STATE == STATE_WB)? 1'b1 : 1'b0;//整个IF阶段都为1
			//mem_write_enable <= (STATE == STATE_EX && opcode == SW)? 1'b1 : 1'b0;//整个MEM阶段都为1，前提是指令为SW
			//reg_write_enable <= (STATE == STATE_MEM && (opcode == ALU || opcode == LW))? 1'b1 : 1'b0;//整个WB阶段都为1，前提是指令合规
			//pc_select_enable <= (STATE == STATE_WB && (opcode == JMP || (opcode == BEQ && equal == 1)))? 1'b1 : 1'b0;//整个IF阶段,指令合规,为1
			
			//writeback_select_enable <= (opcode == LW)? 1'b1 : 1'b0;//选择写回的位置LW就写到RS1，ALU就写道Rd
			mux1_select_enable <= (opcode == JMP || opcode == BEQ || opcode == LW || opcode == SW)? 1'b0 : 1'b1;
			mux2_select_enable <= (opcode == JMP || opcode == BEQ)? 1'b1 : 1'b0;
			mem_data_select_enable <= (opcode == LW)? 1'b0 : 1'b1;//选择写回的数据，是LW的结果还是ALU运算的结果
		end	
	end
	
	/*always@(STATE) begin
		case(opcode)
			ALU : alu_op = ALUfunc[2:0];
			BEQ : alu_op = 3'b000;
			JMP : alu_op = 3'b111;
			default: alu_op = 3'b001;
		endcase	
	end*/
	
endmodule
