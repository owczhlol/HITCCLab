`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:30:37 12/22/2020 
// Design Name: 
// Module Name:    Conflict_Control_Unit 
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
module Conflict_Control_Unit(
    input [31:0] ID_ir,
    input [31:0] EX_ir,
    input [31:0] MEM_ir,
    input [31:0] WB_ir,
	 output IF_pc_enable,
	 output IF_ID_enable,	
    output ID_EX_enable,
    output [1:0] EX_mux1_select_enable,
    output [1:0] EX_mux2_select_enable
    );
	 
	parameter [5:0] ALU = 6'b000001;
	parameter [5:0] SW  = 6'b000010;
	parameter [5:0] LW  = 6'b000011;
	parameter [5:0] BEQ = 6'b000100;
	parameter [5:0] JMP = 6'b000101;
	
	parameter [31:0] NUL = 32'h00000000;
	
	wire [5:0] EX_op;
	wire [4:0] EX_rs1;
	wire [4:0] EX_rs2;
	wire [5:0] MEM_op;
	wire [4:0] MEM_rrd;
	wire [4:0] MEM_lwd;
	wire [5:0] WB_op;		
	wire [4:0] WB_rrd;
	wire [4:0] WB_lwd;
	
	assign EX_op  = EX_ir[31:26];
	assign EX_rs1 = EX_ir[25:21];
	assign EX_rs2 = EX_ir[20:16];
	assign MEM_op = MEM_ir[31:26];
	assign MEM_lwd = MEM_ir[25:21];
	assign MEM_rrd = MEM_ir[15:11];
	assign WB_op  = WB_ir[31:26];
	assign WB_lwd = WB_ir[25:21];
	assign WB_rrd = WB_ir[15:11];
	
	//两个ALU指令，间隔为1，检测段ID/EX和EX/MEM--此时等于10
	//WB_ir 为LW指令，EX_ir为ALU/BEQ	etc, == 11
	assign EX_mux1_select_enable = (EX_op == ALU && MEM_op == ALU && EX_rs1 == MEM_rrd)? 2'b10 :
	                           	((EX_op == ALU && WB_op == LW  && EX_rs1 == WB_lwd) 
	                            || (EX_op == ALU && WB_op == ALU && EX_rs1 == WB_rrd))? 2'b11:
		                            (EX_op == JMP || EX_op == BEQ || EX_op == LW || EX_op == SW)? 2'b00 : 2'b01;
											 
	//mux2 考虑ALU紧接着LW
	assign EX_mux2_select_enable = ((EX_op == ALU || EX_op == LW) && MEM_op == ALU && EX_rs2 == MEM_rrd)? 2'b10 :
											 ((EX_op == ALU && WB_op == LW  && EX_rs2 == WB_lwd)
										  || (EX_op == ALU && WB_op == ALU && EX_rs2 == WB_rrd)
									     || (EX_op == LW  && WB_op == ALU && EX_rs2 == WB_rrd)
										  || (EX_op == LW  && WB_op == LW  && EX_rs2 == WB_lwd))? 2'b11:
											  (EX_op == JMP || EX_op == BEQ)? 2'b01 : 2'b00;
		
	assign IF_pc_enable = ID_EX_enable;
							  
	assign IF_ID_enable = ID_EX_enable;
	
	assign ID_EX_enable = ((EX_op == ALU && MEM_op == LW && (EX_rs1 == MEM_lwd || EX_rs2 == MEM_lwd))
	                    || (EX_op == LW  && MEM_op == LW &&  EX_rs2 == MEM_lwd)
	                    || (EX_ir == NUL && MEM_op == LW))? 1'b0 : 1'b1;
	
endmodule
