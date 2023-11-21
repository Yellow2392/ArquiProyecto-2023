`include "decode.v"
`include "condlogic.v"

module controller (
	clk,
	reset,
	Instr,
	ALUFlags,
	RegSrc,
	RegWrite,
	ImmSrc,
	ALUSrc,
	ALUControl,
	MemWrite,
	MemtoReg,
	PCSrc,
	wireSLT //Cambio
);
	input wire clk;
	input wire reset;
	input wire [31:12] Instr;
	input wire [3:0] ALUFlags;
	output wire [1:0] RegSrc;
	output wire RegWrite;
	output wire [1:0] ImmSrc;
	output wire ALUSrc;
	output wire [1:0] ALUControl;
	output wire MemWrite;
	output wire MemtoReg;
	output wire PCSrc;

	output wire wireSLT;//Cambio

	wire [1:0] FlagW;
	wire NoWrite;
	wire PCS;
	wire RegW;
	wire MemW;

	//assign wireCMP = (Instr[24:21] == 4'b1010) & Instr[20]; //Cambio

	decode dec(
		.Op(Instr[27:26]),
		.Funct(Instr[25:20]),
		.Rd(Instr[15:12]),
		.FlagW(FlagW),
		.PCS(PCS),
		.RegW(RegW),
		.MemW(MemW),
		.MemtoReg(MemtoReg),
		.ALUSrc(ALUSrc),
		.ImmSrc(ImmSrc),
		.RegSrc(RegSrc),
		.ALUControl(ALUControl),
		.NoWrite(NoWrite),
		.wireSLT(wireSLT)
	);
	condlogic cl(
		.clk(clk),
		.reset(reset),
		.Cond(Instr[31:28]),
		.ALUFlags(ALUFlags),
		.FlagW(FlagW),
		.PCS(PCS),
		.RegW(RegW),
		.MemW(MemW),
		.PCSrc(PCSrc),
		.RegWrite(RegWrite),
		.MemWrite(MemWrite),
		.NoWrite(NoWrite)
	);

endmodule