/*
Cheat Sheet:
	supply0  	-  	GND
	supply1  	-  	VCC

	4'b1001  	-  	4-bit binary val 1001

	Vector/Bus 	- 	wire [3:0] data
	Array      	- 	reg bit [1:8]		//Notice Numbering
	Array of Bus
			   	- 	reg [3:0] mem [1:8]

	Operators:
		! 	   	- 	Not
		&	   	- 	And
		|		- 	Or
		^		-	Xor
		^~		- 	Xnor
		<<		-	Left Shift
		>>		-	Right Shift

	initial and always

	Seq block: begin end
	//  block: fork join
*/

module OneBitFullAdder(s,cout, a,b,cin);
	input a,b,cin;
	output s,cout;

	xor(s, a,b,cin);
	and(temp1, a,b);
	and(temp2, b,cin);
	and(temp3, cin,a);
	or(cout, temp1,temp2,temp3);
endmodule

module generatePropagate(g,p, x,y);
	input x,y;
	output g,p;

	and(g, x,y);
	or(p, x,y);
endmodule

module op(p,g ,p1,g1,p0,g0);
	input p1,g1,p0,g0;
	output p,g;

	and(temp1, p1,p0);
	and(temp2, p1,g0);
	or(p, g1, temp1);
	or(g, g1, temp1);
endmodule

module CLAdder(loperand, roperand, sum);
	input[31:0] loperand ,roperand;
	output[31:0] sum;

	wire[31:0] g,p;

	genvar i;
	for(i=0;i<32;i=i+1)
	begin
		generatePropagate gp1(g[i],p[i], loperand[i],roperand[i]);
	end

	// pg is the i/p for recursive ckt
	// 00 x+y = 0, x.y = 0 	kill
	// 01 x+y = 0, x.y = 1	X, not possible
	// 10 x+y = 1, x.y = 0	propagate
	// 11 x+y = 1, x.y = 1	generate

	//pif = gi + pi.pi-1
	//gif = gi + pi.gi-1
	//defined in module op

	genvar j;
	wire[31:0] gStages[0:5], pStages[0:5];

	// Getting first layer or recursive doubling
	for( j=0; j<32 ; j=j+1 )
	begin
		if( j-1 >= 0 )
		begin
			op layer1(pStages[0][j],gStages[0][j], p[j],g[j], p[j-1], g[j-1]);
		end
	end

	//Getting second layer of recursive doubling
	for( j=0; j<32 ; j=j+1 )
	begin
		if( j-2 >= 0 )
		begin
			op layer2(pStages[1][j],gStages[1][j], p[0][j],g[0][j], p[0][j-2], g[0][j-2]);
		end
	end

	//Getting third layer of recursive doubling
	for( j=0; j<32 ; j=j+1 )
	begin
		if( j-4 >= 0 )
		begin
			op layer3(pStages[2][j],gStages[2][j], p[1][j],g[1][j], p[1][j-4], g[1][j-4]);
		end
	end

	//Getting fourth layer of recursive doubling
	for( j=0; j<32 ; j=j+1 )
	begin
		if( j-8 >= 0 )
		begin
			op layer4(pStages[3][j],gStages[3][j], p[2][j],g[2][j], p[2][j-8], g[2][j-8]);
		end
	end

	//Getting fifth layer of recursive doubling
	for( j=0; j<32 ; j=j+1 )
	begin
		if( j-16 >= 0 )
		begin
			op layer5(pStages[4][j],gStages[4][j], p[3][j],g[3][j], p[3][j-16], g[3][j-16]);
		end
	end

	//Getting sixth layer of recursive doubling
	for( j=0; j<32 ; j=j+1 )
	begin
		if( j-32 >= 0 )
		begin
			op layer6(pStages[5][j],gStages[5][j], p[4][j],g[4][j], p[4][j-32], g[4][j-32]);
		end
	end

/*
	integer k = 1;
	for(i=1;i<6;i=i+1)
	begin
		for(j=0;j<32;j=j+1)
		begin
			if( j-k>=0 )
			begin
				op layerNext(p[i][j],g[i][j], pStages[i-1][j], gStages[i-1][j], pStages[i-1][j-k], gStages[i-1][j-k]);
			end
		end
		k = k + k;
	end
*/
	wand dontCare;
	for(i=1;i<32;i=i+1)
	begin
		OneBitFullAdder finalAdd(sum[i],dontCare, loperand[i], roperand[i], pStages[5][i]);
	end
endmodule