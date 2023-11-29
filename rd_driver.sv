/*-----------------------------------------------------------------------------------------------*/
// Filename: rd_driver.sv
// Class Name: rd_driver
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 13/10/2023
//--------------------------------------------------------------------------------------------------
//  -> rd_driver is written by extending uvm_driver
//  -> Instance of interface is written as virtual 
//  -> In build_phase, using uvm_config_db get method to get the interface handle which is set in top
//  -> In run_phase, the logic for driving the signals to DUT is written.
//  -> Two tasks are written, one is reset and other one is drive task.
/*-----------------------------------------------------------------------------------------------*/
class rd_driver extends uvm_driver #(rd_seq_item);
  `uvm_component_utils(rd_driver)
  
  virtual intf vif;
  
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual intf)::get(this, "", "vif", vif))
       `uvm_fatal("No_Virtual_Interface",{"VIRTUAL INTERFACE MUST BE SET FOR :", get_full_name(),".intf"});
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      
      seq_item_port.get_next_item(req);
      
      rst_task();
      
      drive(req);
      
      seq_item_port.item_done();
      
    end
  endtask    
  
  task rst_task();
    @(vif.rd_drv_cb)

    if(vif.rst==1) 
     // @(vif.rd_drv_cb)
      begin
        `uvm_info(get_type_name(), $sformatf("RESET"), UVM_MEDIUM)
        vif.rd_drv_cb.rdEn <= 0;
        
    end
    
  endtask
  
  task drive(rd_seq_item req);
   
    wait(!vif.rst)
    @(vif.rd_drv_cb)
    vif.rd_drv_cb.rdEn <= req.rdEn;
    
    if(req.rdEn==1)//checking for rdEn 
      wait(!vif.fifoEmpty) // waiting for fifoEmpty signal to go low. works commented or uncommented
      begin
        @(vif.rd_drv_cb)
        req.dout      <= vif.dout;
        req.fifoEmpty <= vif.fifoEmpty;
        
        `uvm_info(get_type_name(), $sformatf("rdEn=%0d\t dout = %0h\t fifoEmpty=%0d",req.rdEn,vif.dout,vif.fifoEmpty), UVM_MEDIUM)
        
        //@(vif.rd_drv_cb);
        
        vif.rd_drv_cb.rdEn <= 0;
       end
     
  endtask
  
endclass
