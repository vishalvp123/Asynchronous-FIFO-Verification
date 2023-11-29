/*-----------------------------------------------------------------------------------------------*/
// Filename: wr_driver.sv
// Class Name: wr_driver
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 13/10/2023
//--------------------------------------------------------------------------------------------------
//  -> wr_driver is written by extending uvm_driver
//  -> Instance of interface is written as virtual 
//  -> In build_phase, using uvm_config_db get method to get the interface handle which is set in top
//  -> In run_phase, the logic for driving the signals to DUT is written.
//  -> Two tasks are written, one is reset and other one is drive task.
/*-----------------------------------------------------------------------------------------------*/
class wr_driver extends uvm_driver #(wr_seq_item);
  `uvm_component_utils(wr_driver)
  
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
    
      @(vif.wr_drv_cb)

    if(vif.rst==1) 
      //@(vif.wr_drv_cb)
      begin
        `uvm_info(get_type_name(), $sformatf("RESET"), UVM_MEDIUM)
        
        vif.wr_drv_cb.wrEn <= 0;
        vif.wr_drv_cb.din  <= 0;
        
    end
  endtask
  
  task drive(wr_seq_item req); 
    
    wait(!vif.rst) //waiting for reset to go low before driving          
    @(vif.wr_drv_cb)
    vif.wr_drv_cb.wrEn <= req.wrEn;
    if(req.wrEn==1)//checking for wrEn 
      wait(!vif.fifoFull) //waiting for fifoFull to go low before driving 
      begin
          vif.wr_drv_cb.din <= req.din;
         @(vif.wr_drv_cb);
         `uvm_info(get_type_name(), $sformatf("After wrEn=%0d\t din = %0h",req.wrEn,req.din), UVM_MEDIUM)
         vif.wr_drv_cb.wrEn <= 0;
                   
       end
    
  endtask
  
endclass
