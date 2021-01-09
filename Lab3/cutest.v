`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:20:39 11/23/2020
// Design Name:   CU
// Module Name:   D:/Hardware/CPU/cutest.v
// Project Name:  CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: CU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cutest;

	// Inputs
	reg [5:0] opcode;
	reg [10:0] ALUfunc;
	reg clk;
	reg reset;
	reg equal;

	// Outputs
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

	// Instantiate the Unit Under Test (UUT)
	CU uut (
		.opcode(opcode), 
		.ALUfunc(ALUfunc), 
		.clk(clk), 
		.reset(reset), 
		.equal(equal), 
		.pc_enable(pc_enable), 
		.pc_select_enable(pc_select_enable), 
		.npc_enable(npc_enable), 
		.ir_enable(ir_enable), 
		.reg_write_enable(reg_write_enable), 
		.writeback_select_enable(writeback_select_enable), 
		.mux1_select_enable(mux1_select_enable), 
		.mux2_select_enable(mux2_select_enable), 
		.alu_op(alu_op), 
		.mem_write_enable(mem_write_enable), 
		.mem_data_select_enable(mem_data_select_enable)
	);

	initial begin
		clk = 0;
		reset = 1;
		opcode = 6'b000001;
		ALUfunc = 11'b00000000001;
		equal = 1;
		#15;
		reset = 0;
		#100
      reset = 1;
	end
      
	always begin
		#10 clk = ~clk;
	end
      
endmodule

