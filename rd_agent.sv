/*-----------------------------------------------------------------------------------------------*/
// Filename: rd_agent.sv
// Class Name: rd_agent
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 12/10/2023
//------------------------------------------------------------------------------------------------
//  -> rd_agent is extended form uvm_agent
//  -> handles for driver, monitor and sequencer are defined
//  -> in build_phase, created all the driver components
//  -> since the agent is active, all the components are created
//  -> in the connect_phase, the connection between driver port and sequencer export is done
/*-----------------------------------------------------------------------------------------------*/
class rd_agent extends uvm_agent;
  
  rd_driver drv;
  rd_sequencer rseqr;
  rd_monitor mon;

  
  `uvm_component_utils(rd_agent)
  
  //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(get_is_active == UVM_ACTIVE) begin
      drv = rd_driver::type_id::create("drv", this);
      rseqr = rd_sequencer::type_id::create("rseqr",this);
    end
   
    mon = rd_monitor::type_id::create("mon",this);
    
  endfunction
  
  //conect phase
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(rseqr.seq_item_export);
    end
  endfunction
  
endclass