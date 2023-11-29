/*---------------------------------------------------------------------------------------------------------*/
// Filename: wr_sequencer.sv
// Class Name: wr_sequencer
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 12/10/2023
//----------------------------------------------------------------------------------------------------------
//  -> wr_sequencer is written by extending uvm_sequencer
//  -> uvm_sequencer and uvm_driver base classes have seq_item_export and seq_item_port defined respectively
//  -> The connection between driver port and sequencer export is done in the wr_agent
/*---------------------------------------------------------------------------------------------------------*/
class wr_sequencer extends uvm_sequencer#(wr_seq_item);
  
  `uvm_component_utils(wr_sequencer)
  
  //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass