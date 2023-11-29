/*-----------------------------------------------------------------------------------------------*/
// Filename: env.sv
// Class Name: env
// Author: Vishal P
// Creation Date: 11/10/2023
// Completion Date: 11/10/2023
//------------------------------------------------------------------------------------------------
//  -> env is extended from uvm_env
//  -> handles for agent and scoreboard are written
//  -> in build_phase agent and scoreboard components are created
//  -> connection between analysis ports from agent(monitor) to scoreboard is done in connect_phase
/*-----------------------------------------------------------------------------------------------*/

class fifo_env extends uvm_env;

  `uvm_component_utils(fifo_env)
  wr_agent wr_agt;
  rd_agent rd_agt;
  
  fifo_scoreboard scb;
  coverage cov;
  
   //constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_agt = wr_agent::type_id::create("wr_agent",this);
    rd_agt = rd_agent::type_id::create("rd_agt",this);
    scb = fifo_scoreboard::type_id::create("scb",this);
    cov = coverage::type_id::create("cov",this);    
  endfunction
    
  function void connect_phase(uvm_phase phase);
    
    wr_agt.mon.item_collect_port.connect(scb.item_collect_port);
    rd_agt.mon.item_collect_port1.connect(scb.item_collect_port1);
    wr_agt.mon.item_collect_port.connect(cov.wr_item_collected_export);
    rd_agt.mon.item_collect_port1.connect(cov.rd_item_collected_export);
        
  endfunction

endclass
