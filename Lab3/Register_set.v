`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:33:08 11/11/2020 
// Design Name: 
// Module Name:    Register_set 
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
module Register_set(
    input [4:0] RS_1,
    input [4:0] RS_2,    
	 input [31:0] WB_ir,   
	 (* KEEP = "TRUE" *)input [31:0] writeback_data,
    input clk,
    input reset,
    output [31:0] output_data_1,
    output [31:0] output_data_2,
	 output write_enable,
	 output [4:0] writeback_address
    );
	 
	reg [31:0] memory [0:31];
	
	wire [4:0] writeback_address1; 
	wire [4:0] writeback_address2; 
	
	wire [5:0] WB_op;
	
	assign writeback_address1 = WB_ir[15:11];	//ALUops
	assign writeback_address2 = WB_ir[25:21];	//LW
	assign WB_op = WB_ir[31:26];
	
	assign write_enable = (WB_op == 6'b000001 || WB_op == 6'b000011)? 1'b1 : 1'b0;
	assign writeback_address = (WB_op == 6'b000001)? writeback_address1 : writeback_address2;
	
	assign output_data_1 = memory[RS_1];
	assign output_data_2 = memory[RS_2];
	
	initial begin
		$readmemb("D:/Hardware/regdata.txt", memory);
	end
	
	always@(posedge clk) begin
		if(reset == 0) begin
			//$readmemb("D:/Hardware/CPU/regdata.txt", memory);
		end
		else begin
			if(write_enable == 1) begin
				memory[writeback_address] <= writeback_data;
			end
		end
	end
endmodule
