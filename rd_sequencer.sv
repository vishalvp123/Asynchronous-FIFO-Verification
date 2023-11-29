/*---------------------------------------------------------------------------------------------------------*/
// Filename: rd_sequencer.sv
// Class Name: rd_sequencer
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 12/10/2023
//----------------------------------------------------------------------------------------------------------
//  -> rd_sequencer is written by extending uvm_sequencer
//  -> uvm_sequencer and uvm_driver base classes have seq_item_export and seq_item_port defined respectively
//  -> The connection between driver port and sequencer export is done in the rd_agent
/*---------------------------------------------------------------------------------------------------------*/
class rd_sequencer extends uvm_sequencer#(rd_seq_item);
  
  `uvm_component_utils(rd_sequencer)
  
  //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass