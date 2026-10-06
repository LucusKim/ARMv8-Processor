module NextPClogic(NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch); 
   input [63:0] CurrentPC, SignExtImm64; 
   input Branch, ALUZero, Uncondbranch; 
   output reg [63:0] NextPC; 

   /* write your code here */
	//assign SignExtImm64=SignExtImm64<<2; //shift immediate by 2	
	always@(*) begin
		//SignExtImm64=SignExtImm64<<2; //shift immediate by 2
		if(Uncondbranch) begin //if uncond jump
			NextPC = CurrentPC + (SignExtImm64 << 2);
		end
		else if(Branch) begin //if cond
			if(ALUZero) begin //if aluzero
				NextPC = CurrentPC + (SignExtImm64 << 2);
			end
			else begin //else add pc + 4
				NextPC = CurrentPC + 4;
			end
		end
		else begin //else add pc + 4
			NextPC = CurrentPC + 4;
		end
	end

endmodule
