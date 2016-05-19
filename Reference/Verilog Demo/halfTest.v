 //  `timescale 1ns / 1ps
//time scale tell scale of time and here it is in ns and precision level is in pico seconds

//other module which calls our original module (halfadder)
//this module does n't take any input arguments
    module test;

///********************************Input & Output Declaration**************************************************************

    	// Inputs   local variable declaration //  these are input and outputs to our half adder module// 
    	reg input1;//reg is data type // it can store values till it gets next assignment
    	reg input2;//
    	// Outputs
    	wire sum1; //wire is another datatype 
	wire carry1; 

///**************************************************************************************************************************



//********************************** YOUr circuit Code goes here ************************************************************

    	// Instantiate the Unit Under Test (UUT)
	//creating our half adder module instance here     	
	halfadder uut (
    		.a (input1), //matching original arguments to passing values
    		.b (input2), 
    		.sum (sum1),
		.carry (carry1)
    	); //you can give with out matching also but order should be in the same order like c funcitons
		//but if you use matching then order is not important
     
//***************************************************************************************************************************


//Intial Block begins here // it starts execution when code is in simulation // something like main funciton 
    	initial begin 
	$dumpfile("test.vcd"); //these are for Graphical view of Data //wave forms
	 $dumpvars(0,test);    
		// Initialize Inputs
	//execution starts here at time = 0;
    	a = 0;
    	b = 0;
	     
    	#20 a = 1;//at time =20 a is changing at this time code/halfadder takes a values changes carry and sum
    	#20 b = 1;//time =40; b is changing
    	#20 a = 0;	
    	#20 b = 1;	  
    	#40;
        end  //block ends here
     
    	initial begin // one more  intial block;  these two initial blocks begins at same time ,and executed parallally 
    		 $monitor("time = %d,a=%d,b=%d,sum=%d ,carry =%d\n",$time,a,b,sum,carry);//print the values at above time intervals
    	end
     
    endmodule //end module
     
     


