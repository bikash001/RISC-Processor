#ISA for RISC Processor

## Gen Description

32-bit Processor with integer op support
Float Pt not supported

Load-Store Architecture
38-bit instr len

32-bit len for mem addr in ld, st

06-bit len for instr == 2**6 == 64 instructions supported

##Instructions

#### Arithmetic Ops:

1. add

 sub is implemented via macro
2. negative
3. mul
4. div

#### Memory Access
1. ld
2. st

#### NOP

#### Control transfer instruction
1. JCC (multiple types JZ(or JE), JNZ(or JNE), JGE, JG, JLE, JL)
2. JMP
	
	no call instruction

#### Stack Ops
1. push
2. pop

#### Boolean Ops
1. and
2. or
3. not
4. xor

#### Shift Ops
1. shl
2. shr

Total Op Count: 22