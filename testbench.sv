/*-----------------------------------------------------------------------------------------------*/
// Filename: top.sv
// Class Name: top
// Author: Vishal P
// Creation Date: 11/10/2023
// Completion Date: 11/10/2023
//------------------------------------------------------------------------------------------------
//  -> Declaration of clock and reset signals is done in top
//  -> Clocks are generated based on the frequency given
//  -> The instance of interface and DUT is written and DUT I/O ports are connected to interface
//  -> Using uvm_config_db set method, the interface is set in top
//  -> run_test is written to start particular test. Test name can be passed as an argument in
//  -> command line or can be given as an argument to run_test("test_name")
/*-----------------------------------------------------------------------------------------------*/

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "package.sv"
module top;
    
	//clock and reset signals declaration
	bit wrClk;
	bit rdClk;
	bit rst;
	
	//clock generation
	initial forever #5  wrClk = ~wrClk;	//		frequency = 100MHz		time period = 10ns
	initial forever #10 rdClk = ~rdClk;	//		frequency = 50MHz		time period = 20ns
	
	//reset generation
	
    initial begin
      repeat(5)
        @(posedge wrClk) rst=1;
      rst=0;
      
	end
		
	//interface instance
  intf intf(wrClk,rdClk,rst);
	
	//DUT instance
	async_fifo FIFO(
		.wrClk(intf.wrClk),
		.wrEn(intf.wrEn),
		.din(intf.din),
		.fifoFull(intf.fifoFull),
		.rdClk(intf.rdClk),
		.fifoEmpty(intf.fifoEmpty),
		.rdEn(intf.rdEn),
		.rst(intf.rst),
		.dout(intf.dout)
		);
		
		
	
  initial begin
    
    //setting interface with config_db set method
    uvm_config_db #(virtual intf)::set(null, "*", "vif", intf);
    
    //to open waveform
    $dumpfile("dump.vcd");
    $dumpvars();
  
  end
	
  initial begin
    
    //run_test("sanity");
    
    //run_test("async_fifo_reset_test");
           
    run_test("async_fifo_write_and_read_test");
    
    //run_test("async_fifo_simultaneous_write_and_read_test");
    
    //run_test("async_fifo_connectivity_test");
        
  end
  
endmodule
	