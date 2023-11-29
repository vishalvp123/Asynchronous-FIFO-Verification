/*-----------------------------------------------------------------------------------------------*/
// Filename: wr_seq_item.sv
// Class Name: wr_seq_item
// Author: Vishal P
// Creation Date: 11/10/2023
// Completion Date: 11/10/2023
//------------------------------------------------------------------------------------------------
//  -> wr_seq_item is extended from uvm_sequence_item
//  -> Fields are declared as rand and randc which are to be randomized 
//  -> and other fields are defined as bit which are not randomized 
/*-----------------------------------------------------------------------------------------------*/
class wr_seq_item extends uvm_sequence_item;
  
  rand bit [7:0] din;
  rand bit wrEn;
  bit fifoFull;
  
  `uvm_object_utils(wr_seq_item) 
  
  function new(string name = "wr_seq_item");
    super.new(name);
  endfunction
  
  //constraints
  
endclass