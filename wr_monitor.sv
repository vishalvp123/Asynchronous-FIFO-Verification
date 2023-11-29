/*-----------------------------------------------------------------------------------------------*/
// Filename: wr_monitor.sv
// Class Name: wr_monitor
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 13/10/2023
//------------------------------------------------------------------------------------------------
//  -> wr_monitor is extended form uvm_monitor
//  -> Instance of interface is written as virtual 
//  -> In build_phase, using uvm_config_db get method to get the interface handle which is set in top
//  -> uvm_analysis_port is used to define analysis port
//  -> A handle is defined of type wr_seq_item to capture transaction information from interface
//  -> In the run_phase the logic to sample the signals is written
/*-----------------------------------------------------------------------------------------------*/
class wr_monitor extends uvm_monitor;
  
  virtual intf vif;
  uvm_analysis_port #(wr_seq_item) item_collect_port;  
  
  //to capture transaction info
  wr_seq_item trans_collected;
  
  `uvm_component_utils(wr_monitor)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans_collected=new();
    item_collect_port = new("item_collect_port", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual intf)::get(this, "", "vif", vif))
      `uvm_fatal("No_Virtual_Interface",{"VIRTUAL INTERFACE MUST BE SET FOR :",get_full_name(),".intf"});
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    trans_collected = wr_seq_item::type_id::create("trans_collected");
    
    forever
      begin
        //trans_collected.wrEn = 0;
        //trans_collected.din  = 0;
        
        @(vif.wr_mon_cb)
        
        if(vif.rst)
          begin 
            `uvm_info(get_type_name(), $sformatf("RESET"), UVM_MEDIUM)
            trans_collected.wrEn = 0;
            trans_collected.din  = 0;
	        
            reset_checker();
            //item_collect_port.write(trans_collected);
          end
        
            
        else  if(vif.wr_mon_cb.wrEn)
       begin 
         
         trans_collected.wrEn = vif.wr_mon_cb.wrEn;
         trans_collected.din  = vif.wr_mon_cb.din;
         `uvm_info(get_type_name(), $sformatf("wrEn=%0d\t din= %0h ",vif.wr_mon_cb.wrEn,vif.wr_mon_cb.din), UVM_MEDIUM)
         item_collect_port.write(trans_collected);
       end
      
    
        
      end
      
  endtask 
  
  //Reset test checker
  task reset_checker();
  	if(top.rst==1)
	  begin
        if(top.FIFO.fifoFull==0 && top.FIFO.fifoEmpty==1 && top.FIFO.dout=='h5d) begin  
          `uvm_info(get_type_name(), $sformatf("RESET IS HIGH rst=%0d",top.rst), UVM_MEDIUM)
	  end
      end
	else begin
	  `uvm_info(get_type_name(), $sformatf("RESET IS LOW rst=%0d",top.rst), UVM_MEDIUM)
	  end
   endtask

  
endclass

