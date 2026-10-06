module SignExtender(BusImm, Imm26, Ctrl); 
   output reg [63:0] BusImm; 
   input [25:0]  Imm26; 
   input [2:0]	 Ctrl; 
   // 00 to I format
   // 01 to D format
   // 10 to B format
   // 11 to CBZ format
   // 100 to movz
   
   reg extBit; 
   always@(*) //trigger when in changes
   begin
   	case(Ctrl)
		3'b000: 
			begin
				extBit = Imm26[21]; //I type has 10 bit opcode
				BusImm = {{52{extBit}}, Imm26[21:10]};
			end
		3'b001:
			begin
				extBit = Imm26[20]; //D type has 11 bit opcode
				BusImm = {{55{extBit}}, Imm26[20:12]};
			end

		3'b010:
			begin
				extBit = Imm26[25]; //B type has 6 bit opcode
				BusImm = {{38{extBit}}, Imm26[25:0]};
			end
		3'b011:
			begin
				extBit = Imm26[23]; //CBZ type has 8 bit opcode
				BusImm = {{45{extBit}}, Imm26[23:5]};
			end
		3'b100:
			begin
				BusImm = Imm26[20:5]<<(Imm26[22:21] * 16);
			end
	endcase
   end
   
endmodule
