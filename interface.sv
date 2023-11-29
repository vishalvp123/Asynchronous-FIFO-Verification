/*-----------------------------------------------------------------------------------------------*/
// Filename: interface.sv
// Class Name: intf
// Author: Vishal P
// Creation Date: 11/10/2023
// Completion Date: 11/10/2023
//------------------------------------------------------------------------------------------------
//  -> All the DUT signals are defined inside the interface class
//  -> clocking blocks are defined for write_driver, read_driver, write_monitor and read_monitor
//  -> modports are written to define direaction of signals
/*-----------------------------------------------------------------------------------------------*/
interface intf(input bit wrClk, rdClk,rst);
  //logic wrClk;
  //logic rdClk;
  //logic rst;
  logic wrEn=0;
  logic rdEn=0;
  logic fifoFull;
  logic fifoEmpty;
  logic [7:0]din=0;
  logic [7:0]dout;
  
  clocking wr_drv_cb @(posedge wrClk);
    default input #1 output #0;
    output din;
    output wrEn;
    //output rdEn;
    input rst;
    //output dout;
    input fifoFull;
    input fifoEmpty;
  endclocking
  
  clocking rd_drv_cb @(posedge rdClk);
    default input #1 output #0;
    //output din;
    //output wrEn;
    output rdEn;
    input rst;
    input dout;
    //input fifoFull;
    input fifoEmpty;
  endclocking
 
  // monitor clocking bolck
  clocking wr_mon_cb @(posedge wrClk);
    default input #1 output #0;
    input din;
    //input dout;
    input wrEn;
    //input rdEn;
    //input rst;
    input fifoFull;
    input fifoEmpty;
  endclocking
  
  
  clocking rd_mon_cb @(posedge rdClk);
    default input #1 output #0;
    input dout;
    input rdEn;
    //input rst;
    input fifoFull;
    input fifoEmpty;
  endclocking
  
 
  modport wr_drv_mp (clocking wr_drv_cb, input wrClk, rdClk,rst);
  modport rd_drv_mp (clocking rd_drv_cb, input wrClk, rdClk,rst);
  modport wr_mon_mp (clocking wr_mon_cb, input wrClk, rdClk,rst);
  modport rd_mon_mp (clocking rd_mon_cb, input wrClk, rdClk,rst);
    
endinterface