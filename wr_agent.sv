/*-----------------------------------------------------------------------------------------------*/
// Filename: wr_agent.sv
// Class Name: wr_agent
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 12/10/2023
//------------------------------------------------------------------------------------------------
//  -> wr_agent is extended form uvm_agent
//  -> handles for driver, monitor and sequencer are defined
//  -> in build_phase, created all the driver components
//  -> since the agent is active, all the components are created
//  -> in the connect_phase, the connection between driver port and sequencer export is done
/*-----------------------------------------------------------------------------------------------*/
class wr_agent extends uvm_agent;
  
  wr_driver drv;
  wr_sequencer wseqr;
  wr_monitor mon;

  
  `uvm_component_utils(wr_agent)
  
  //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(get_is_active == UVM_ACTIVE) begin
      drv = wr_driver::type_id::create("drv", this);
      wseqr = wr_sequencer::type_id::create("wseqr",this);
    end
   
    mon = wr_monitor::type_id::create("mon",this);
    
  endfunction
  
  //conect phase
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(wseqr.seq_item_export);
    end
  endfunction
  
endclass