module RISCuva1 ( clk, reset,
 				  progAddress, progData, progReset,
 				  dataIn, dataOut,
				  portAddress, portRead, portWrite,
 				  intReq, intAck );

	// Inputs and outputs:
	input 	clk, reset; 		// Clock and Reset
	
	output [9:0] progAddress; 	// Up to 1K instructions (10 bits)
	input [13:0] progData; 		// Current instruction code
	output progReset; 			// Reset of Program Memory
	
	input [7:0] dataIn; 		// Data input (from an I/O port)
	output [7:0] dataOut; 		// Data output (through a port)
	
	output [7:0] portAddress; 	// Addressed I/O Port (0..255)
	output portRead; 			// Read signal
	output portWrite; 			// Write signal
	input intReq; 				// Interrupt request
	output intAck; 				// Interrupt Acknowledge
	
	// Instruction decoding from the instruction code:
	wire [13:0] opCode = progData; 	// Instruction code
	
	wire [1:0] opA = opCode[13:12]; // 1st operation code
	wire [1:0] opB = opCode[11:10]; // 2nd operation code
	wire [1:0] opC = opCode[ 9: 8]; // 3rd operation code
	wire [3:0] rM = opCode[ 7: 4]; 	// Source register
	wire [3:0] rN = opCode[ 3: 0]; 	// Destination register
	
	wire [9:0] immAddr = opCode[ 9:0]; // Address for jumps
	wire [7:0] immData = opCode[11:4]; // Immediate data
	wire [4:0] immPort = opCode[ 8:4]; // For direct access
	
	wire MISC = (opA == 2'b00);
	wire JP = (opA == 2'b01);
	wire LOAD = (opA == 2'b10);
	wire ALU = (opA == 2'b11);
	
	wire CALL = (opB == 2'b00);
	wire GOTO = (opB == 2'b01);
	wire RETS = (opB == 2'b10);
	wire MOVOUT = (opB == 2'b11);
	
	wire RET = (opC == 2'b00);
	wire RETI = (opC == 2'b01);
	wire DI = (opC == 2'b10);
	wire EI = (opC == 2'b11);
	
	wire FLAG_Z = (opB == 2'b00);
	wire FLAG_NZ = (opB == 2'b01);
	wire FLAG_C = (opB == 2'b10);
	wire FLAG_NC = (opB == 2'b11);
	
	wire LOGIC = (opB == 2'b00);
	wire ARITH = (opB == 2'b01);
	wire SHIFT = (opB == 2'b10);
	wire MOVIN = (opB == 2'b11);
	
	wire MOV = (opC == 2'b00);
	wire XNOR = (opC == 2'b01);
	wire OR = (opC == 2'b10);
	wire AND = (opC == 2'b11);
	
	wire ADD = (opC == 2'b00);
	wire ADC = (opC == 2'b01);
	wire SUB = (opC == 2'b10);
	wire SBC = (opC == 2'b11);
	
	wire ASR = (opC == 2'b00);
	wire RRC = (opC == 2'b01);
	wire ROR = (opC == 2'b10);
	wire ROL = (opC == 2'b11);
	
	wire IND = (opC == 2'b00);
	wire SEQ = (opC == 2'b01);
	wire DIR = (opC >= 2'b10); 
	
	// General Resources:
	reg zeroFlag, carryFlag; 				// DFFs used by flags
	wire [7:0] dataBus; 					// Data bus for all operations
	wire [2+9:0] stackValue; 				// Internal stack output
	
	// Register file (r0-r15) and operand buses: 
	reg [7:0] registerFile[0:15]; 			// 16x8 dual-port memory
	always@(posedge clk)
	begin
		if (LOAD | ALU)
			registerFile[rN] <= dataBus; 	// Synchronous write
	end
	wire [7:0] busN = registerFile[rN]; 	// Async. read of rN
	wire [7:0] busM = registerFile[rM]; 	// Async. read of rM
	
	// Port signals for direct, indirect and sequential accesses: 
	reg [7:0] nextPort;
	always@(posedge clk)
	begin
		if (portRead | portWrite)
			nextPort <= portAddress + 1; 	// For sequential use
	end
	assign dataOut = busN; 					// Output from rN
	assign portRead = ALU & MOVIN; 			// Read signal
	assign portWrite = MISC & MOVOUT; 		// Write signal
	assign portAddress = IND ? busM : 		// Indirect
						 SEQ ? nextPort :	// Sequent.
							   {3'b111,immPort}; // Direct
	
	// Logic ALU: AND, OR, XNOR and MOV.
	wire logicCarry = AND ? 1'b1 : OR ? 1'b0 : carryFlag;
	wire [7:0] logicALU = AND ? busN & busM :
						  OR ?  busN | busM :
						  XNOR ? busN ~^ busM :
									 	 busM ; 

	// Arithmetic ALU: ADD, ADC, SUB and SBC.
	wire [7:0] arithALU, altM;
	wire arithCarry, x, y, z;
	assign x = ADD ? 1'b0 : ADC ? carryFlag :
			   SUB ? 1'b1 : ~carryFlag;
	assign altM = (SUB | SBC) ? ~busM : busM;
	assign {z, arithALU, y} = {busN, 1'b1} + {altM, x};
	assign arithCarry = (SUB | SBC) ? ~z : z; 
	
	// Shifter: ASR, RRC, ROR and ROL. 
	wire [7:0] shiftALU;
	wire shiftCarry;
	assign {shiftALU, shiftCarry} =
						ASR ? {busN[7], busN} :
						RRC ? {carryFlag, busN} :
						ROR ? {busN[0], busN} :
							  {busN[6:0], busN[7], busN[7]};
	
	// This data bus collects results from all sources:
	assign dataBus = (LOAD | MISC)		? immData : 8'bz;
	assign dataBus = (ALU | JP) & LOGIC ? logicALU : 8'bz;
	assign dataBus = (ALU | JP) & ARITH ? arithALU : 8'bz;
	assign dataBus = (ALU | JP) & SHIFT ? shiftALU : 8'bz;
	assign dataBus = (ALU | JP) & MOVIN ? dataIn : 8'bz; 
	
	// Interrupt Controller:
	reg userEI, callingIRQ, intAck;
	wire mayIRQ = ! (MISC & RETS
				  | MISC & MOVOUT
				  | ALU & MOVIN);
	wire validIRQ = intReq & ~intAck & userEI & mayIRQ;
	wire [9:0] destIRQ = callingIRQ ? 10'h001 : 10'h000;
	always@(posedge clk or posedge reset)
	begin
		if (reset) 					 userEI <= 0;
		else if (MISC & RETS & DI)   userEI <= 0;
		else if (MISC & RETS & EI)   userEI <= 1;
		
		if (reset) 					 intAck <= 0;
		else if (validIRQ) 			 intAck <= 1;
		else if (MISC & RETS & RETI) intAck <= 0;
		
		if (reset) 					 callingIRQ <= 0;
		else 						 callingIRQ <= validIRQ;
	end

	// Flag DFFs:
	always@(posedge clk)
	begin
		if (MISC & RETS & RETI) 	// Flags recovery when ‘reti’
			{carryFlag,zeroFlag} <= stackValue[11:10];
		else begin
			if (LOAD | ALU) // 'Z' changes with registers
				zeroFlag <= (dataBus == 8'h00);
			if (ALU & ~MOVIN) // but 'C' only with ALU ops
				carryFlag <= LOGIC ? logicCarry :
							 SHIFT ? shiftCarry :
									 arithCarry ;
		end
	end

	// 'validFlag' evaluates one of four conditions for jumps.
	wire validFlag = FLAG_Z ?   zeroFlag :
				 	 FLAG_NZ ? ~zeroFlag :
					 FLAG_C ?  carryFlag :
							  ~carryFlag ; 
	
	// Program Counter (PC): the address of current instruction.
	reg [9:0] PC;
	wire [9:0] nextPC, incrPC;
	wire onRet = MISC & RETS & (RETN | RETI);
	wire onJump = MISC & (GOTO | CALL) | JP & validFlag;
	assign incrPC = PC + (callingIRQ ? 0 : 1);
	assign nextPC = onRet ? stackValue[9:0] : 10'bz;
	assign nextPC = onJump ? immAddr | destIRQ : 10'bz;
	assign nextPC = !(onRet | onJump) ? incrPC : 10'bz;
	always@(posedge clk)
	begin
		PC <= nextPC;
	end

	// When using Xilinx BlockRAM as program memory:
	assign progAddress = nextPC;
	assign progReset = reset | validIRQ; 

	// Internal stack for returning addresses (16 levels):
	reg [3:0] SP; // Stack Pointer register
	always@(posedge clk or posedge reset)
	begin
		if (reset) 							SP <= 0;
		else if (MISC & CALL) 				SP <= SP + 1;
		else if (MISC & RETS & (RETN|RETI)) SP <= SP – 1;
	end
	wire [3:0] mySP = (CALL | GOTO) ? SP : SP – 1;

	reg [2+9:0] stackMem[0:15]; 		// Stack 16x12 memory
	always@(posedge clk)
	begin
		if (MISC & CALL) // Keep returning address and flags
			stackMem [mySP] <= {carryFlag, zeroFlag, incrPC};
	end

	assign stackValue = stackMem[mySP]; 
endmodule 	/// RISCuva1 (all in one file!)