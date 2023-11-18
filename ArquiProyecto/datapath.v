`include "mux2.v"
`include "flopr.v"
`include "adder.v"
`include "regfile.v"
`include "extend.v"
`include "alu.v"

module datapath (
	clk,
	reset,
	RegSrc,
	RegWrite,
	ImmSrc,
	ALUSrc,
	ALUControl,
	MemtoReg,
	PCSrc,
	ALUFlags,
	PC,
	Instr,
	ALUResult,
	WriteData,
	ReadData,
	wireCMP //Cambio
);
	input wire clk;
	input wire reset;
	input wire [1:0] RegSrc;
	input wire RegWrite;
	input wire [1:0] ImmSrc;
	input wire ALUSrc;
	input wire [1:0] ALUControl;
	input wire MemtoReg;
	input wire PCSrc;
	output wire [3:0] ALUFlags;
	output wire [31:0] PC;
	input wire [31:0] Instr;
	output wire [31:0] ALUResult;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	wire [31:0] PCNext;
	wire [31:0] PCPlus4;
	wire [31:0] PCPlus8;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [3:0] RA1;
	wire [3:0] RA2;

    input wire wireCMP; //Cambio
	reg [31:0] Result1;


	mux2 #(32) pcmux(
		.d0(PCPlus4),
		.d1(Result1),//Cambio
		.s(PCSrc),
		.y(PCNext)
	);
	flopr #(32) pcreg(
		.clk(clk),
		.reset(reset),
		.d(PCNext),
		.q(PC)
	);
	adder #(32) pcadd1(
		.a(PC),
		.b(32'b100),
		.y(PCPlus4)
	);
	adder #(32) pcadd2(
		.a(PCPlus4),
		.b(32'b100),
		.y(PCPlus8)
	);
	mux2 #(4) ra1mux(
		.d0(Instr[19:16]),
		.d1(4'b1111),
		.s(RegSrc[0]),
		.y(RA1)
	);
	mux2 #(4) ra2mux(
		.d0(Instr[3:0]),
		.d1(Instr[15:12]),
		.s(RegSrc[1]),
		.y(RA2)
	);
	regfile rf(
		.clk(clk),
		.we3(RegWrite),
		.ra1(RA1),
		.ra2(RA2),
		.wa3(Instr[15:12]),
		.wd3(Result1), //Cambio
		.r15(PCPlus8),
		.rd1(SrcA),
		.rd2(WriteData)
	);
	mux2 #(32) resmux(
		.d0(ALUResult),
		.d1(ReadData),
		.s(MemtoReg),
		.y(Result)
	);
	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	);
	mux2 #(32) srcbmux(
		.d0(WriteData),
		.d1(ExtImm),
		.s(ALUSrc),
		.y(SrcB)
	);
	alu alu(
		SrcA,
		SrcB,
		ALUControl,
		ALUResult,
		ALUFlags
	);


	always @(*) begin
        // Si wireCMP es 1 es CMP u otra instruccion, si es 0 es SLT(i)
        if (wireCMP == 1'b0)
            if (ALUFlags[1] == 1'b0)
                Result1 = 32'b00000000000000000000000000000001;
            else
                Result1 = 32'b00000000000000000000000000000000;
        else
            Result1 = Result;
    end // Cambio
	
endmodule