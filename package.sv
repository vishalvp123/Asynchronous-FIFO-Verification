/*-----------------------------------------------------------------------------------------------*/
// Filename: package.sv
// Author: Vishal P
// Creation Date: 11/10/2023
// Completion Date: 11/10/2023
//------------------------------------------------------------------------------------------------
//  -> All the components adn objects created are put in the package.sv file
//  -> The files are included in an order in which they have to be compiled 
/*-----------------------------------------------------------------------------------------------*/
`include "interface.sv"

`include "wr_seq_item.sv"
`include "rd_seq_item.sv"

`include "wr_sequence.sv"
`include "wr_sequencer.sv"

`include "rd_sequence.sv"
`include "rd_sequencer.sv"


`include "wr_driver.sv"
`include "rd_driver.sv"

`include "wr_monitor.sv"
`include "rd_monitor.sv"

`include "wr_agent.sv"
`include "rd_agent.sv"

`include "coverage.sv"
`include "scoreboard.sv"

`include "env.sv"
`include "test.sv"