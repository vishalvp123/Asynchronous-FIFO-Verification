/*-----------------------------------------------------------------------------------------------*/
// Filename: scoreboard.sv
// Class Name: scoreboard
// Author: Vishal P
// Creation Date: 12/10/2023
// Completion Date: 
//-----------------------------------------------------------------------------------------------
//  -> Declared TLM analysis export to receive transactions from monitor
//  -> in build_phase create a TLM analysis export instance.
//  -> Implementd two write methods to receive the transactions from the monitor.
//  -> in run_phase, the logic for comparision is written 
/*-----------------------------------------------------------------------------------------------*/
`uvm_analysis_imp_decl(_item_collect_port) 
`uvm_analysis_imp_decl(_item_collect_port1)

class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)
  
  uvm_analysis_imp_item_collect_port#(wr_seq_item, fifo_scoreboard) item_collect_port;
  uvm_analysis_imp_item_collect_port1#(rd_seq_item, fifo_scoreboard) item_collect_port1; 
  
  virtual intf vif;
  
  bit [7:0] q1[$]; //queue to collect din  in write method
  bit [7:0] q2[$]; //queue to collect dout in write method

  wr_seq_item a1; 
  rd_seq_item a2;
  
  
  bit [7:0] mem_wr[50];
  bit [7:0] mem_rd[50];
  
  //variables
  int j=0;
  int k=0;
  int s=0;
  int r=0;
  int x=0;
  int y=0;
  
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collect_port  = new("item_collect_port", this);
    item_collect_port1 = new("item_collect_port1", this);
  endfunction
  
  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a1=wr_seq_item::type_id::create("a1",this);
    a2=rd_seq_item::type_id::create("a2",this);
    
    //getting interface from top
    if(!uvm_config_db#(virtual intf)::get(this, "", "vif", vif))
       `uvm_fatal("No_Virtual_Interface",{"VIRTUAL INTERFACE MUST BE SET FOR :", get_full_name(),".intf"});
  endfunction
  
  //write method to collect din data
  virtual function void write_item_collect_port(wr_seq_item a1);
    if(a1.wrEn) 
    begin
      q1.push_front(a1.din);
      `uvm_info(get_type_name(), $sformatf("-------AFTER  PUSHING TO q1-------q1_size = %0d wrEn=%0d din=%h q1[%0d]=%h", q1.size(),a1.wrEn,a1.din,r,q1[r]),UVM_MEDIUM);
    end
    
    //checker for fifoFull
    /*if(vif.fifoFull) begin
      `uvm_info(get_type_name(), $sformatf("-------FIFO FULL FLAG ASSERTED-------fifoFull=%0d",vif.fifoFull),UVM_MEDIUM);
    end*/
    
    //checker for fifoFull
    if(top.FIFO.wrPtr==16) begin
      `uvm_info(get_type_name(), $sformatf("-------FIFO FULL FLAG ASSERTED-------fifoFull=%0d wrPtr=%0d",vif.fifoFull,top.FIFO.wrPtr),UVM_MEDIUM);
    end
    
    //connectivity test checker
    if(vif.din==top.FIFO.din) begin
       `uvm_info(get_type_name(), $sformatf("-------DATA SENT TO DUT AND READ FROM DUT INPUT DIN MATCHES-------vif.din=%h top.FIFO.din=%h",vif.din, top.FIFO.din),UVM_MEDIUM);
    end
  endfunction
  
  //write method to collect dout data
  virtual function void write_item_collect_port1(rd_seq_item a2);
    if(a2.rdEn)
      begin
        q2.push_front(a2.dout);
        `uvm_info(get_type_name(), $sformatf("-------AFTER  PUSHING TO q2-------q2_size = %0d rdEn=%0d dout=%h q2[%0d]=%h", q2.size(),a2.rdEn,a2.dout,s,q2[s]),UVM_MEDIUM);
      end
   
    //checking for fifoEmpty
    /*if(vif.fifoEmpty) begin
      `uvm_info(get_type_name(), $sformatf("-------FIFOEMPTY FLAG ASSERTED-------fifoEmpty=%0d",vif.fifoEmpty),UVM_MEDIUM);
    end  */
    
    //checking for fifompty
    if(top.FIFO.fifoEmpty==1) begin
      `uvm_info(get_type_name(), $sformatf("-------FIFOEMPTY FLAG ASSERTED-------fifoEmpty=%0d rdPtr=%0d",vif.fifoEmpty,top.FIFO.rdPtr),UVM_MEDIUM);
    end 
    
    
  endfunction
  
  //run phase
  virtual task run_phase(uvm_phase phase);
    forever
      begin
        
        wait(q1.size() > 0) 
        begin
          mem_wr[x]=q1.pop_back();
          `uvm_info(get_type_name(), $sformatf("-------mem_wr-------mem_wr[%0d]=%h\n\n", x,mem_wr[x]),UVM_MEDIUM);
          x=x+1;
        end
                
        wait(q2.size() > 0)
        begin
          mem_rd[j]=q2.pop_back();
          `uvm_info(get_type_name(), $sformatf("-------mem_rd-------mem_rd[%0d]=%h\n\n", j,mem_rd[j]),UVM_MEDIUM);
          j=j+1;
        end
        
        //comparinf if din==dout
        if(mem_wr[k]== mem_rd[y])
          begin
            `uvm_info(get_type_name(), $sformatf("~~~~~~~~~~~~~DATA MATCHED~~~~~~~~~~~~~~~~~  :  din = %h dout = %h", mem_wr[k],mem_rd[y]), UVM_MEDIUM)
             //`uvm_info(get_type_name(), $sformatf("------------------------------------------------------------------------------------------------------------------------\n\n "), UVM_MEDIUM)
             k=k+1;
             y=y+1;
          end
        
        else
          begin
            `uvm_info(get_type_name(), $sformatf("~~~~~~~~~~~~~DATA MISMATCH~~~~~~~~~~~~~~~~~ :  din = %h dout = %h", mem_wr[k],mem_rd[y]), UVM_MEDIUM)
            `uvm_error(get_type_name(),"~~~~~~~~~~~~~DATA MISMATCH~~~~~~~~~~~~~~~~~")
            //`uvm_info(get_type_name(), $sformatf("------------------------------------------------------------------------------------------------------------------------\n\n "), UVM_MEDIUM)
            k=k+1;
            y=y+1;
          end
	end
    
    
  endtask
  
endclass
