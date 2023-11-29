/*-----------------------------------------------------------------------------------------------*/
// Filename: test.sv
// Class Name: base_test
// Author: Vishal P
// Creation Date: 11/10/2023
// Completion Date: 
//------------------------------------------------------------------------------------------------
//  -> Declaration of environment, sequence handles is done
//  -> Printing the topology in the end_of_elaboration_phase
//  -> In report phase, checking for test pass or fail
//  -> Extending the base test, different test cases are written.
//  -> In run_phase of each test case, the sequences created are started on particular sequencer
/*-----------------------------------------------------------------------------------------------*/
class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  fifo_env env;
  
  function new(string name = "base_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);
  endfunction
  
  //end of elaboration phase
  virtual function void end_of_elaboration();
    
    print();
    
  endfunction
  
  //report phase
  function void report_phase(uvm_phase phase);
   uvm_report_server svr;
   super.report_phase(phase);
   
   svr = uvm_report_server::get_server();
   if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
    else begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
  endfunction
  
 
endclass


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     sanity
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class sanity extends base_test;
  `uvm_component_utils(sanity)
  fifo_write_sequence wr_seq;
  fifo_read_sequence  rd_seq;
  
  function new(string name = "sanity", uvm_component parent);
    super.new(name,parent);
  endfunction
  
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_seq = fifo_write_sequence::type_id::create("wr_seq",this);
    rd_seq = fifo_read_sequence::type_id::create("rd_seq",this);
   endfunction
 
  
   task run_phase (uvm_phase phase);
    phase.raise_objection(this);
     
     repeat(2) begin
       
       wr_seq.start(env.wr_agt.wseqr);
       `uvm_info(get_type_name(), $sformatf("WRITE SEQUENCE DONE"),UVM_MEDIUM);
     //end
     //repeat(2) begin
     
       rd_seq.start(env.rd_agt.rseqr);
       `uvm_info(get_type_name(), $sformatf("READ SEQUENCE DONE"),UVM_MEDIUM);
     end
     
     phase.drop_objection(this);
     phase.phase_done.set_drain_time(this, 100);
  
   endtask

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     async_fifo_reset_test
//By applying reset to fifo, checking if all the signals are in default state. Reset is taken 
//from the top and from the reset sequence it is passed onto DUT. 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class async_fifo_reset_test extends base_test;
  `uvm_component_utils(async_fifo_reset_test)
  fifo_write_sequence wr_seq;
  fifo_read_sequence  rd_seq;
  
  fifo_reset_sequence rst_seq;
  
  function new(string name = "async_fifo_reset_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
   //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_seq = fifo_write_sequence::type_id::create("wr_seq",this);
    rd_seq = fifo_read_sequence::type_id::create("rd_seq",this);
    rst_seq = fifo_reset_sequence::type_id::create("rst_seq",this);

  endfunction  
  
  
   task run_phase (uvm_phase phase);
    phase.raise_objection(this);
     
     //#60; 
     repeat(2)
       wr_seq.start(env.wr_agt.wseqr);
     #60; 
     
     rst_seq.start(env.wr_agt.wseqr);
       
     phase.drop_objection(this);
     phase.phase_done.set_drain_time(this, 100);
  
   endtask

endclass


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     async_fifo_write_and_read_test                           
//
//	By writing completely into the fifo and reading from it, four things can be observed:       
//		1) Writing into fifo and checking if the write operation is happening                   
//		2) Writing into all the locations of fifo, checking for fifoFull signal asserted or not 
//		3) Reading from fifo and checking if the same data is read from fifo which was written  
//		4) Reading from all the locations of fifo, checking for fifoEmpty signal asserted or not

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class async_fifo_write_and_read_test extends base_test;
  `uvm_component_utils(async_fifo_write_and_read_test)
  fifo_write_sequence wr_seq;
  fifo_read_sequence  rd_seq;
    
  function new(string name = "async_fifo_write_and_read_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_seq = fifo_write_sequence::type_id::create("wr_seq",this);
    rd_seq = fifo_read_sequence::type_id::create("rd_seq",this);
   endfunction
 
  
   task run_phase (uvm_phase phase);
    phase.raise_objection(this);
     
     //repeat(top.FIFO.FIFO_DEPTH) begin //FIFO_DEPTH is defined in the DUT as a parameter
     repeat(16) begin
       
       wr_seq.start(env.wr_agt.wseqr);
       `uvm_info(get_type_name(), $sformatf("WRITE SEQUENCE DONE"),UVM_MEDIUM);
     end
     //repeat(top.FIFO.FIFO_DEPTH) begin //FIFO_DEPTH is defined in the DUT as a parameter
       repeat(16) begin
       rd_seq.start(env.rd_agt.rseqr);
       `uvm_info(get_type_name(), $sformatf("READ SEQUENCE DONE"),UVM_MEDIUM);
     end
     
     phase.drop_objection(this);
     phase.phase_done.set_drain_time(this, 100);
  
   endtask

endclass



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     async_fifo_simultaneous_write_and_read_test
//By simultaneously writing into fifo and reading from fifo n-number times, checking if the 
//data is written into fifo and read from fifo matches or not. 
//Checking if the write and read are happening independently as per the specification.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class async_fifo_simultaneous_write_and_read_test extends base_test;
  `uvm_component_utils(async_fifo_simultaneous_write_and_read_test)
   fifo_write_sequence wr_seq;
   fifo_read_sequence  rd_seq;
  
  
  function new(string name = "async_fifo_simultaneous_write_and_read_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_seq = fifo_write_sequence::type_id::create("wr_seq",this);
    rd_seq = fifo_read_sequence::type_id::create("rd_seq",this);
   endfunction
 
  
   task run_phase (uvm_phase phase);
    phase.raise_objection(this);
     repeat(2) begin
     wr_seq.start(env.wr_agt.wseqr);
     end
     repeat(14) begin
       fork 
           wr_seq.start(env.wr_agt.wseqr);
           rd_seq.start(env.rd_agt.rseqr);
       join
       
     end
     //repeat(2) begin
       //rd_seq.start(env.rd_agt.rseqr);
       //end
     
     phase.drop_objection(this);
     phase.phase_done.set_drain_time(this, 100);
  
   endtask

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     async_fifo_connectivity_test
//By sending a particular or fixed value (like din=100) for din from testbench to dut, checking if the data sent 
//and received are same. With the dut instance the din is tapped and matched with the din sent from testbench.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class async_fifo_connectivity_test extends base_test;
  `uvm_component_utils(async_fifo_connectivity_test)
   connectivity_sequence con_seq;
  
  
  function new(string name = "async_fifo_connectivity_test", uvm_component parent);
    super.new(name,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    con_seq = connectivity_sequence::type_id::create("con_seq",this);
   endfunction
 
  
   task run_phase (uvm_phase phase);
    phase.raise_objection(this);
     
     repeat(1) begin
       con_seq.start(env.wr_agt.wseqr);
     end
     
     phase.drop_objection(this);
     phase.phase_done.set_drain_time(this, 100);
  
   endtask

endclass
