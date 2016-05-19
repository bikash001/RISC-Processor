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

module OneBitFullAdder(a,b,cin,s,cout)
	input a,b,cin;
	output s,cout;

	xor(s, a, b, cin)
	cout = ()

endmodule


module CLAdder(loperand, roperand, sum)
	input[31:0] loperand , roperand;
	output[31:0] sum;


endmodule