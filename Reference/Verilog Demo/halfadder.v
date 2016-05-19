//Venu Gopal V

//module name halfadder
//inputs a,b and output sum and carry;
module halfadder(
	input a,
	input b,
	output sum,
	output carry
);
//Module Starts here
wire XOR;//wire variable XOR like int val
wire AND;//one more variable 


//Two ways to write the code 
// 1.Gate level logic literally putting your circuit
// 2. Behavioral logic where you write code like c and assign just final boolean expression to output


//**********************************Gate Level logic*********************************************************//
xor(XOR,a,b);//using inbuilt/provided  modules
//xor(output,input1,input2,....,inputN) calling convection; //N input xor gate

and(AND,a,b);//using inbuilt module and
//and(output,input1,input2......inputN)

and(sum,XOR,XOR);

and(carry,AND,AND);
//*******************************************************************************************************//

//***********************************Behavioral Level Logic**********************************************//
//assign sum=a&~b|~a&b;
//assign carry=a&b;
//uncomment Behavioral and comment out Gate level logic and run 
//******************************************************************************************************//

endmodule
//full adder from above half adder /gate level logic 
module fulladder(
input  input1,
input  input2,
input  carryin,
output  sum,
output  carryout);
//internal connections
wire sumOne;
wire carryOne;
wire carrySecond;

halfadder a(input1,input2,sumMiddle,carryMiddle);
halfadder b(sumMiddle,carryin,sum,carrySecond);
or(carryout,carrySecond,carryMiddle);



end module


