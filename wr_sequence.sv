/*-----------------------------------------------------------------------------------------------*/
// Filename: wr_sequence.sv
// Class Name: fifo_write_sequence
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 12/10/2023
//------------------------------------------------------------------------------------------------
//  -> Sequence generates the stimulus and sends to driver via sequencer
//  -> fifo_write_sequence is written by extending the uvm_sequence
//  -> Logic to generate and send the sequence_item is added inside the body() method
/*-----------------------------------------------------------------------------------------------*/

  
class fifo_write_sequence extends uvm_sequence #(wr_seq_item);
  
  `uvm_object_utils(fifo_write_sequence)
  
  //constructor
  function new(string name ="fifo_write_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.wrEn==1;})
    `uvm_info(get_type_name(), $sformatf("wrEn=%0d din=%0h", req.wrEn,req.din), UVM_MEDIUM)   
  endtask
  
endclass

class fifo_reset_sequence extends uvm_sequence #(wr_seq_item);
  
  `uvm_object_utils(fifo_reset_sequence)
  
  //constructor
  function new(string name ="fifo_reset_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
   // repeat(5)
    //#100;
      top.rst=1'b1;
  endtask
  
endclass


class connectivity_sequence extends uvm_sequence #(wr_seq_item);
  
  `uvm_object_utils(connectivity_sequence)
  
  //constructor
  function new(string name ="connectivity_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.wrEn==1; req.din=='h80;})
    `uvm_info(get_type_name(), $sformatf("wrEn=%0d din=%0h", req.wrEn,req.din), UVM_MEDIUM)   
  endtask
  
endclass
