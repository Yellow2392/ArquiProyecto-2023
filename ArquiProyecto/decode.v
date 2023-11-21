module decode (
	Op,
	Funct,
	Rd,
	FlagW,
	PCS,
	RegW,
	MemW,
	MemtoReg,
	ALUSrc,
	ImmSrc,
	RegSrc,
	ALUControl,
	NoWrite,
	wireSLT
);
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	output reg [1:0] FlagW;
	output wire PCS;
	output wire RegW;
	output wire MemW;
	output wire MemtoReg;
	output wire ALUSrc;
	output wire [1:0] ImmSrc;
	output wire [1:0] RegSrc;
	output reg [1:0] ALUControl;
	output reg NoWrite;
	reg [9:0] controls;
	wire Branch;
	wire ALUOp;
	output wire wireSLT; //Cambio

	always @(*)
		casex (Op)
			2'b00:
				if (Funct[5])
					if (Funct[4:1] == 4'b1010 & Funct[0] == 1'b0) //cmd debe ser CMP y bit-S debe ser 0
						controls = 11'b00001010011;
					else
						controls = 11'b00001010010;
				else
					controls = 11'b00000010010;
			2'b01:
				if (Funct[0])
					controls = 11'b00011110000;
				else
					controls = 11'b10011101000;
			2'b10: controls = 11'b01101000100;
			//if (10) branch normal
			// controls = 10'b0110100010;
			//else if (10) branch nuevo (blez)
			// controls = 10
			//Branch = 1   Funct[5] Funct[4]
			default: controls = 11'bxxxxxxxxxxx;
		endcase
	assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp, wireSLT} = controls; //agregar wireSLT
	always @(*)
		if (ALUOp) begin
			case (Funct[4:1])
				4'b0100: 
					ALUControl = 2'b00; //ADD
				4'b0010:  
					ALUControl = 2'b01; //SUB
				4'b0000:  
					ALUControl = 2'b10; //AND
				4'b1100: 
					ALUControl = 2'b11; //ORR
				4'b1010: 
					ALUControl = 2'b01; //CMP
				default: 
					ALUControl = 2'bxx;
			endcase
			FlagW[1] = Funct[0];
			FlagW[0] = ( (Funct[4:1] == 4'b1010) | Funct[0]) & ((ALUControl == 2'b00) | (ALUControl == 2'b01));
			NoWrite = (Funct[4:1] == 4'b1010) & Funct[0];
			//wireCMP = (Funct[4:1] == 4'b1010) & Funct[0]; cambiar
		end
		else begin
			ALUControl = 2'b00;
			FlagW = 2'b00;
		end
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch;
endmodule