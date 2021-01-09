`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:28:38 10/23/2020 
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
    input [31:0] A,
    input [31:0] B,
    input Cin,
    input [4:0] Card,
    output [31:0] F,
    output Cout,
    output Zero
    );
	reg [32:0] temp_result;
	reg [31:0] ALU_output;
	reg 		  Zero_output;
	
	assign F    = ALU_output;
	assign Zero = Zero_output;

	assign Cout = temp_result[32];
	
	always@(*)
	begin
		case(Card)
		//add
		5'b00000:
		begin 
			ALU_output= A + B;
			temp_result = {1'b0,A} + {1'b0,B};
		end
		
		//add with cin
		5'b00001:
		begin 
			ALU_output= A + B + {31'b0,Cin};
			temp_result = {1'b0,A} + {1'b0,B} + {32'b0,Cin};
		end
		
		//sub
		5'b00010:
		begin 
			ALU_output= A - B;
			temp_result = {1'b0,A} - {1'b0,B};
		end
		
		//sub with cin
		5'b00011:
		begin 
			ALU_output= A - B - {31'b0,Cin};
			temp_result = {1'b0,A} - {1'b0,B} - {32'b0,Cin};
		end
		
		//sub
		5'b00100:
		begin 
			ALU_output= B - A;
			temp_result = {1'b0,B} - {1'b0,A};
		end
		
		//sub with cin
		5'b00101:
		begin 
			ALU_output= B - A - {31'b0,Cin};
			temp_result = {1'b0,B} - {1'b0,A} - {32'b0,Cin};
		end
		
		//keep A
		5'b00110:ALU_output= A;
		//keep B
		5'b00111:ALU_output= B;
		//~A
		5'b01000:ALU_output= ~A;
		//~B
		5'b01001:ALU_output= ~B;
		//A or B
		5'b01010:ALU_output= A | B;
		//A and B
		5'b01011:ALU_output= A & B;
		//A sor B
		5'b01100:ALU_output= ~(A ^ B);
		//A nor B
		5'b01101:ALU_output= A ^ B;
		//~&
		5'b01110:ALU_output= ~(A & B);
		//all zero
		5'b01111:ALU_output= 32'b0;
		//add
		default: ALU_output = A + B;
		endcase
		//if result is zero, set 1
		Zero_output = (ALU_output==32'b0)?1'b1:1'b0;
	end
endmodule