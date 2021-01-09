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
	 input  clk,
    input  reset,
	 output cpu_out,
	 output result_zero,
	 output cmd_reset_led,
    output data_reset_led,
	 output reg_reset_led
	 );
	 
	//data wire
	wire [31:0] new_address;
	wire [31:0] pc_output_address;
	wire [31:0] pc_adder_output;
	wire [31:0] npc_output;
	wire [31:0] imem_ir;
	wire [31:0] current_instruction;
	wire [31:0] writeback_data;
	wire [ 4:0]  writeback_address;
	wire [31:0] reg_output1;
	wire [31:0] reg_output2; 
	wire [31:0] holderA;
	wire [31:0] holderB;
	wire [31:0] imm32b;
	wire [31:0] holderImm;
	wire [31:0] alu_dataA; 
	wire [31:0] alu_dataB;
	wire        zero;
	wire [31:0] alu_temp;
	wire [31:0] alu_result;
	wire [31:0] mem_data_temp;
	wire [31:0] mem_data;
	
	//command wire
	wire [ 5:0] opcode;
	wire [ 4:0] rs1;
	wire [ 4:0] rs2;
	wire [ 4:0] rrd;
	wire [10:0] alu_func;
	wire [25:0] imm26b;
	
	//command bind
	assign opcode   = current_instruction[31:26];
	assign rs1      = current_instruction[25:21];
	assign rs2      = current_instruction[20:16];
	assign rrd      = current_instruction[15:11];
	assign alu_func = current_instruction[10: 0];
	assign imm26b   = current_instruction[25: 0];
	
	//CU enable
	wire 		  pc_enable;
	wire 		  pc_select_enable;
	wire 		  npc_enable;
	wire 		  ir_enable;
	wire 		  reg_write_enable;
	wire 		  writeback_select_enable;
	wire 		  mux1_select_enable;
	wire       mux2_select_enable;
	wire [2:0] alu_op;
	wire       mem_write_enable;
	wire       mem_data_select_enable;
	
	//CU input
	wire equal;
	
	//cpu output
	assign cpu_out     = equal;
	assign result_zero = zero;
	
	//IF state
	PC pc(
		.clk           (clk              ), 		
		.reset         (reset            ), 
		.new_address   (new_address      ), 
		.pc_enable     (pc_enable        ), 
		.output_address(pc_output_address)
	);
	
	PC_adder pc_adder(
		.input_address (pc_output_address), 
		.output_address(pc_adder_output  )
	);
	
	PC_select pc_select(
		.JMP_address (alu_temp        ), 
		.PC_address  (pc_adder_output ), 
		.pc_select   (pc_select_enable), 
		.next_address(new_address     )
	);
	
	NPC npc(
		.clk           (clk        ), 
		.input_address (new_address), 
		.npc_enable    (npc_enable ),
		.output_address(npc_output )
	);
	
	Instruction_memory instruction_memory(
		.clk                (clk              ), 
		.reset              (reset            ), 
		.address            (pc_output_address), 
		.output_instruction (imem_ir          ),
		.cmd_reset_led      (cmd_reset_led    )
	);
	
	IR ir(
		.clk               (clk                ), 
		.reset             (reset              ), 
		.input_instruction (imem_ir            ), 
		.ir_enable         (ir_enable          ), 
		.output_instruction(current_instruction)
	);
	
	//ID state
	Register_set register_set(
		.clk              (clk              ), 	
		.reset            (reset            ), 		
		.RS_1             (rs1              ), 
		.RS_2             (rs2              ), 
		.writeback_address(writeback_address),
		.writeback_data   (writeback_data   ),
		.write_enable     (reg_write_enable ), 
		.output_data_1    (reg_output1      ), 
		.output_data_2    (reg_output2      ), 
		.reg_reset_led    (reg_reset_led    )
	);			
	
	Data_holder reg_holder_A(
		.clk(clk        ),
		.in (reg_output1),
		.out(holderA    )
	);
	
	Data_holder reg_holder_B(
		.clk(clk        ),
		.in (reg_output2), 
		.out(holderB    )
	);
	
	Extender extender(
		.opcode       (opcode), 
		.input_26bimm (imm26b), 
		.output_32bimm(imm32b)
	);
	
	Data_holder imm_holder(
		.clk(clk      ),
		.in (imm32b   ), 
		.out(holderImm)
	);
	
	Writeback_Select writeback_select(
		.select           (writeback_select_enable), 
		.rs1_address      (rs1                    ), 
		.rd_address       (rrd                    ), 
		.writeback_address(writeback_address      )
	);

	//EX state
	equal_control eqcontrol(
		.clk   (clk    ), 
		.reset (reset  ), 
		.data_A(holderA), 
		.data_B(holderB), 
		.equal (equal  )
	);		
	
	MUX32 mux1(
		.input_data0(holderImm         ),
		.input_data1(holderA           ), 
		.select     (mux1_select_enable), 
		.output_data(alu_dataA         )
	);
	
	MUX32 mux2(
		.input_data0(holderB           ), 
		.input_data1(npc_output        ), 
		.select     (mux2_select_enable), 
		.output_data(alu_dataB         )
	);
	
	ALU alu( 
		.clk          (clk      ), 
		.zero         (zero     ),
		.reset        (reset    ), 
		.alu_op       (alu_op   ),
		.input_data1  (alu_dataA),
		.input_data2  (alu_dataB), 
		.output_result(alu_temp )
	);
	
	ALU_output alu_output(
		.clk        (clk       ), 
		.input_data (alu_temp  ), 
		.output_data(alu_result)
	);
	
	//MEM state
	Data_memory data_memory(
		.clk           (clk             ), 
		.reset         (reset           ),
		.alu_address   (alu_result      ), 
		.data          (holderA         ), 
		.write_enable  (mem_write_enable), 
		.out           (mem_data_temp   ), 
		.data_reset_led(data_reset_led  )
	);
	
	Data_holder mem_holder(
		.clk(clk          ),
		.in (mem_data_temp),
		.out(mem_data     )
	);
	
	//WB state
	MUX32 mux3(
		.input_data0(mem_data              ), 
		.input_data1(alu_result            ), 
		.select		(mem_data_select_enable), 
		.output_data(writeback_data        )
	);
	 
	//CU
	CU cu(
		.clk                    (clk							), 
		.reset                  (reset						), 
		.opcode                 (opcode						),
		.ALUfunc                (alu_func					), 
		.equal                  (equal						),
		.pc_enable              (pc_enable					),
		.pc_select_enable       (pc_select_enable			),
		.npc_enable             (npc_enable					), 
		.ir_enable              (ir_enable					),
		.reg_write_enable       (reg_write_enable       ),
		.writeback_select_enable(writeback_select_enable),
		.mux1_select_enable     (mux1_select_enable     ),
		.mux2_select_enable     (mux2_select_enable     ), 
		.alu_op						(alu_op						), 
		.mem_write_enable       (mem_write_enable			),
		.mem_data_select_enable (mem_data_select_enable )
	);
	 
endmodule

