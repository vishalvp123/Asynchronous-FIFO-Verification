/*-----------------------------------------------------------------------------------------------*/
// Filename: rd_sequence.sv
// Class Name: fifo_read_sequence
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 12/10/2023
//------------------------------------------------------------------------------------------------
//  -> Sequence generates the stimulus and sends to driver via sequencer
//  -> fifo_read_sequence is written by extending the uvm_sequence
//  -> Logic to generate and send the sequence_item is added inside the body() method
/*-----------------------------------------------------------------------------------------------*/

class fifo_read_sequence extends uvm_sequence #(rd_seq_item);
  
  `uvm_object_utils(fifo_read_sequence)
  
  //constructor
  function new(string name ="fifo_read_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.rdEn==1;})
    `uvm_info(get_type_name(), $sformatf("rdEn=%0d dout=%0h", req.rdEn,req.dout), UVM_MEDIUM)
  endtask
  
endclass

