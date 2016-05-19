module full_add(cout,sum,a,b,cin);

	input a,b,cin;
	output cout,sum;

	wire c1,c2,c3;

	//carry-bit
	and(c1,a,b);
	and(c2,b,cin);
	and(c3,cin,a);
	or(cout,c1,c2,c3);

	//sum bit
	xor(sum,a,b,cin);

	//assign cout = a&b | b&cin | cin&a;
	//assign sum = a^b^cin;
endmodule

module cs_add8(cout,sum,a,b,cin);

	input[7:0] a,b,cin;
	output[7:0] cout,sum;

	genvar i;

	for(i=0; i<8; i=i+1)
	begin
		full_add fa1(cout[i],sum[i],a[i],b[i],cin[i]);	
	end
endmodule

module cs_add16(cout,sum,a,b,cin);

	input[15:0] a,b,cin;
	output[15:0] cout,sum;

	genvar i;

	for(i=0; i<16; i=i+1)
	begin
		full_add fa2(cout[i],sum[i],a[i],b[i],cin[i]);	
	end
endmodule

module shift_left(out,in);
	
	input[15:0] in;
	output[15:0] out;

	genvar i;
	
	//shift 1 bit left
	assign out[0] = 1'b0;
	for(i=1;i<=15;i = i+1)
	begin
		assign out[i] = in[i-1];
	end
endmodule

module mult8(res,ain,bin);
	output[15:0] res;
	input[7:0] ain,bin;

	genvar i,j;
	wor[15:0] dc;
	supply0[15:0] inp0;
	
	wire[7:0] btemp[0:7];
	wire[15:0] prod[0:7];

	//create B0B0...	
	for(i=0;i<8;i=i+1)
	begin
		assign btemp[0][i] = bin[0];
	end
	//create first product
	cs_add8 a1(prod[0][7:0],dc[7:0],ain[7:0],btemp[0],inp0[7:0]);
	assign prod[0][15:8] = 8'b0;
	
	for(i=1; i<8; i = i+1)
	begin
		//generate BiBiBi..
		
		//assign btemp[i][7:0] = 8'b(b[i]);
		for(j=0;j<8;j=j+1)
		begin		
			assign btemp[i][j] = bin[i];
		end
		//generate ith product term in 8 bits with position shift
		cs_add8 a2(prod[i][i+7:i],dc[7:0],ain[7:0],btemp[i],inp0[7:0]);
		//remaining bits are 0			
		for(j=0;j<i;j=j+1)
		begin
			assign prod[i][j]	= 1'b0;	
		end		
		for(j = i+8;j<=15;j= j+1)
		begin
			assign prod[i][j]  = 1'b0;
		end
	end

	//add the 3 sums and 3 products
	wire[15:0] sum[0:2],carry[0:2];
	cs_add16 a3(carry[0],sum[0],prod[0],prod[1],prod[2]);
	cs_add16 a4(carry[1],sum[1],prod[3],prod[4],prod[5]);
	cs_add16 a5(carry[2],sum[2],prod[6],prod[7],inp0);

	wire[15:0] fssum;
	wire[16:0] fscarry,fcsum;
	wire[17:0] fccarry;
	assign fscarry[0] = 1'b0;
	assign fcsum[0] = 1'b0;
	assign fccarry[1:0] = 2'b0;
	cs_add16 a6(fscarry[16:1],fssum,sum[0],sum[1],sum[2]);
	cs_add16 a7(fccarry[17:2],fcsum[16:1],carry[0],carry[1],carry[2]);
	
	wire[15:0] newcarry;
	wire[16:0] newcarrycarry;
	assign newcarrycarry[0] = 1'b0;
	cs_add16 a8(newcarrycarry[16:1],newcarry,fcsum[15:0],fscarry[15:0],fccarry[15:0]);
	
	wire[15:0] finalsum;
	wire[16:0] finalcarry;
	assign finalcarry[0] = 1'b0;
	cs_add16 a9(finalcarry[16:1],finalsum,newcarrycarry[15:0],newcarry,fssum);
	
	wire[16:0] carryover;
	cs_add16 a10(carryover[16:1],res,finalsum,finalcarry[15:0],carryover[15:0]);
	
	/*
	wire[15:0] stagesum[0:15];
	wire[15:0] stagecarry[0:30];
	
	assign stagecarry[0] =  finalcarry;
	assign stagesum[0] = finalsum;
	for(i=0;i<15;i=i+1)
	begin
		shift_left b1(stagecarry[16+i],stagecarry[i]);
		cs_add16 a10(stagecarry[i+1],stagesum[i+1],stagesum[i],stagecarry[16+i],inp0);
	end
	
	assign res = stagesum[15];
	*/ 
endmodule
