/*-----------------------------------------------------------------------------------------------*/
// Filename: rd_monitor.sv
// Class Name: rd_monitor
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 13/10/2023
//------------------------------------------------------------------------------------------------
//  -> rd_monitor is extended form uvm_monitor
//  -> Instance of interface is written as virtual 
//  -> In build_phase, using uvm_config_db get method to get the interface handle which is set in top
//  -> uvm_analysis_port is used to define analysis port
//  -> A handle is defined of type rd_seq_item to capture transaction information from interface
//  -> In the run_phase the logic to sample the signals is written
/*-----------------------------------------------------------------------------------------------*/
class rd_monitor extends uvm_monitor;
  
  virtual intf vif;
  uvm_analysis_port #(rd_seq_item) item_collect_port1;  
  
  //to capture transaction info
  rd_seq_item trans_collected1;
  
  `uvm_component_utils(rd_monitor)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans_collected1=new();
    item_collect_port1 = new("item_collect_port1", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual intf)::get(this, "", "vif", vif))
      `uvm_fatal("No_Virtual_Interface",{"VIRTUAL INTERFACE MUST BE SET FOR :",get_full_name(),".intf"});
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    trans_collected1 = rd_seq_item::type_id::create("trans_collected1");
    
    forever
      begin
       
      @(vif.rd_mon_cb)
      
        if(vif.rst)
          begin 
            //`uvm_info(get_type_name(), $sformatf("RESET"), UVM_MEDIUM)
            trans_collected1.rdEn = 0;
            trans_collected1.dout  = 0;
            //item_collect_port1.write(trans_collected1);
          end
        else if(vif.rd_mon_cb.rdEn)  
       begin
         
         trans_collected1.rdEn = vif.rd_mon_cb.rdEn;
         `uvm_info(get_type_name() , $sformatf("rdEn=%0d\t dout= %0h ",vif.rd_mon_cb.rdEn,vif.rd_mon_cb.dout), UVM_MEDIUM)
         @(vif.rd_mon_cb)
         trans_collected1.dout = vif.rd_mon_cb.dout;
         
         item_collect_port1.write(trans_collected1);
       end
     
    end
  endtask  
endclass
