`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:45:30 11/12/2020 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
	 input [2:0] alu_op,
    (* KEEP = "TRUE" *)input [31:0] input_data1,
    (* KEEP = "TRUE" *)input [31:0] input_data2,
	 input       clk,
	 input       reset,
	 output      zero,
    (* KEEP = "TRUE" *)output reg [31:0] output_result
    );
	
	reg [31:0] temp;
	assign zero = (output_result == 32'b0)? 1'b1 :1'b0;

	always@(posedge clk) begin		
		if(reset == 0) begin
			output_result = 32'b0;
			temp = 32'b0;
		end
		
		else begin
			case(alu_op)
				3'b000 : output_result = (input_data1 << 2) + input_data2 - 1;//BEQ
				3'b001 : output_result = input_data1 + input_data2;
				3'b010 : output_result = input_data1 - input_data2;
				3'b011 : output_result = input_data1 & input_data2;
				3'b100 : output_result = input_data1 | input_data2;
				3'b101 : output_result = input_data1 ^ input_data2;
				3'b110 : output_result = (input_data1 < input_data2)? 32'h000000001 : 32'h00000000;
				3'b111 : begin
								//JMP
								temp = input_data1 << 2;
								output_result = {input_data2[31:26], temp[25:0]};
							end
				default:
					begin
						output_result = input_data1 + input_data2;
					end
			endcase
		end	
	end

endmodule
