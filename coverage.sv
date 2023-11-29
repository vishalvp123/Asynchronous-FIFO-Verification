/*-----------------------------------------------------------------------------------------------*/
// Filename: coverage.sv
// Class Name: coverage
// Author: Vishal P
// Creation Date: 
// Completion Date: 
//------------------------------------------------------------------------------------------------
//  -> 
//  -> 
//  -> 
//  -> 
//  -> 
//  -> 
/*-----------------------------------------------------------------------------------------------*/

`uvm_analysis_imp_decl(_wr_port) 
`uvm_analysis_imp_decl(_rd_port)

class coverage extends uvm_component;
  `uvm_component_utils(coverage) 
  
  uvm_analysis_imp_wr_port #(wr_seq_item, coverage) wr_item_collected_export;
  uvm_analysis_imp_rd_port #(rd_seq_item, coverage) rd_item_collected_export;
  
  wr_seq_item wr;
  rd_seq_item rd;
  
  //interface handle 
  virtual intf vif;
  
  //cover group for write enable
  covergroup write_cg;
    
    cp1: coverpoint wr.wrEn{
      				   bins b1 = {1};// for wrEn=1
                       //ignore_bins b5 = {0}; //for wrEn=0
                       }

  endgroup

  //cover gorup for read enable
  covergroup read_cg;
    
    cp2: coverpoint rd.rdEn{
                       bins b2 = {1}; // for rdEn=1
                       //ignore_bins b6 = {0};// for rdEn=0
                      }
  endgroup
  
  //constructor
  function new(string name="coverage", uvm_component parent=null);
    super.new(name, parent);
    write_cg = new();
    read_cg = new();
  endfunction
  
  //build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wr_item_collected_export = new("wr_item_collected_export", this);
    rd_item_collected_export = new("rd_item_collected_export", this);
    
    wr = wr_seq_item :: type_id::create("wr");
    rd = rd_seq_item :: type_id::create("rd");
    
    //get interface from top
    if(!uvm_config_db#(virtual intf)::get(this, "", "vif", vif))
       `uvm_fatal("No_Virtual_Interface",{"VIRTUAL INTERFACE MUST BE SET FOR :", get_full_name(),".intf"});
  
  endfunction
  
  

  //write method to sample write
  virtual function void write_wr_port(wr_seq_item wr);
    this.wr = wr;
    write_cg.sample(); //sample
    //`uvm_info(get_type_name(), $sformatf("IN COVERAGE WRITE METHOD FOR SAMPLING wrEn=%0d",wr.wrEn),UVM_MEDIUM);
  endfunction
  
  //write method to sample read
  virtual function void write_rd_port(rd_seq_item rd);
    this.rd = rd;
    read_cg.sample(); //sample
    //`uvm_info(get_type_name(), $sformatf("IN COVERAGE WRITE METHOD FOR SAMPLING rdEn=%0d",rd.rdEn),UVM_MEDIUM);
  endfunction

  //extract phase
  virtual function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    $display("----------------------------------------------------------------------");
    $display("OVERALL COVERAGE = %f", $get_coverage());
    $display("coverage of covergroup write_cg = %f", write_cg.get_coverage());
    $display("coverage of covergroup read_cg = %f", read_cg.get_coverage());
    $display("----------------------------------------------------------------------");
  endfunction
  
endclass