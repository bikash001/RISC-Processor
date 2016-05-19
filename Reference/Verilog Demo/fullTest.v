 //  `timescale 1ns / 1ps
//time scale tell scale of time and here it is in ns and precision level is in pico seconds

//other module which calls our original module (halfadder)
//this module does n't take any input arguments
    module testFull;

///********************************Input & Output Declaration**************************************************************

    	// Inputs   local variable declaration //  these are input and outputs to our half adder module// 

	//YOUR CODE
///**************************************************************************************************************************



//********************************** YOUr circuit Code goes here ************************************************************

    	// Instantiate the Unit Under Test (UUT)
	fulladder uut (
//YOUR CODE		 	
	); //you can give with out matching also but order should be in the same order like c funcitons
		//but if you use matching then order is not important
     
//***************************************************************************************************************************


//Intial Block begins here // it starts execution when code is in simulation // something like main funciton 
    	initial begin 
	$dumpfile("test.vcd"); //these are for Graphical view of Data //wave forms
	 $dumpvars(0,testFull);    
	
	//YOUR CODE		

	end  //block ends here
     
    	initial begin // one more  intial block;  these two initial blocks begins at same time ,and executed parallally 
    		 $monitor("time = %d,a=%d,b=%d,sum=%d ,carry =%d\n",$time,a,b,sum,carry);//print the values at above time intervals
    	end
     
    endmodule //end module
     
     


