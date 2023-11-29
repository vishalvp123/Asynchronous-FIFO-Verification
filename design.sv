// Code your design here
module async_fifo #(parameter
  WR_DATA_WIDTH_MUL = 1 ,// WR_DATA_WIDTH = WR_DATA_WIDTH_MUL * DATA_WIDTH
  RD_DATA_WIDTH_MUL = 1 ,// RD_DATA_WIDTH = RD_DATA_WIDTH_MUL * DATA_WIDTH
  DATA_WIDTH        = 8, 
  ADDRESS_WIDTH     = 4,
  WR_DATA_WIDTH     = WR_DATA_WIDTH_MUL * DATA_WIDTH,
  RD_DATA_WIDTH     = RD_DATA_WIDTH_MUL * DATA_WIDTH,
  FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
  (
     //Write port
     input wire                          wrClk,
     input wire                          wrEn,
     input wire  [WR_DATA_WIDTH-1:0]     din,  
     output                              fifoFull,

    // Reading port
     input wire                          rdClk,        
     output                              fifoEmpty,
     input wire                          rdEn,
     input                               rst,
    `ifndef NO_LAT
     output reg  [RD_DATA_WIDTH-1:0]     dout
    `else
     output  [RD_DATA_WIDTH-1:0]     dout
    `endif
  );
  reg   [DATA_WIDTH-1:0]  Mem [FIFO_DEPTH-1:0];
  reg   [ADDRESS_WIDTH:0] wrPtr;
  reg   [ADDRESS_WIDTH:0] rdPtr;

 
  genvar i;
  generate
    for (i = 0; i < WR_DATA_WIDTH_MUL; i = i + 1) begin
       always @ (posedge wrClk)begin 
         if(wrEn & !fifoFull)begin
          Mem[wrPtr+i] <= din[i*DATA_WIDTH+:DATA_WIDTH];
         // Mem[wrPtr+i] <= din[i*DATA_WIDTH+DATA_WIDTH-1:i*DATA_WIDTH];
        end
      end
   end
  endgenerate


  always @ (posedge wrClk or posedge rst)begin
    if(rst)begin
      wrPtr <= 0;
    end else begin
      if(wrEn & !fifoFull)begin
        wrPtr <= wrPtr + WR_DATA_WIDTH_MUL;
      end
    end
  end

  always @ (posedge rdClk or posedge rst)begin
    if(rst)begin
      rdPtr <= 0;
    end else begin
      if (rdEn &  !fifoEmpty)begin
        rdPtr <= rdPtr + RD_DATA_WIDTH_MUL;
      end
    end
  end

`ifndef NO_LAT
  generate 
    for (i = 0 ; i <RD_DATA_WIDTH_MUL ; i = i + 1) begin 
      always @(posedge rdClk)begin  
          dout[i*DATA_WIDTH+:DATA_WIDTH] <= Mem[rdPtr+i];
       end
    end
  endgenerate
 
  `else
  generate 
    for (i = 0 ; i <RD_DATA_WIDTH_MUL ; i = i + 1) begin 
      //always@(posedge rdClk)begin  
      assign dout[i*DATA_WIDTH+:DATA_WIDTH] = Mem[rdPtr+i];
       //end
    end
  endgenerate
  
 `endif


 wire [ADDRESS_WIDTH:0] rdPtrGray;

  bin2Gray #(.COUNTER_WIDTH(ADDRESS_WIDTH+1))bin2Gray_rdPtr (
    .din  (rdPtr), 
    .dout (rdPtrGray)
  );

  reg  [ADDRESS_WIDTH:0] rdPtrGray_rdClk;
  always@(posedge rdClk or posedge rst)begin
    if(rst)begin
      rdPtrGray_rdClk <= 0;
    end else begin
      rdPtrGray_rdClk <= rdPtrGray;
    end
  end


  reg [ADDRESS_WIDTH:0] rdPtrGray_wrClk_Q1, rdPtrGray_wrClk_Q2;

  always@(posedge wrClk or posedge rst)begin
    if(rst)begin
      rdPtrGray_wrClk_Q1 <= 0;
      rdPtrGray_wrClk_Q2 <= 0;
    end else begin
      rdPtrGray_wrClk_Q1 <= rdPtrGray_rdClk;
      rdPtrGray_wrClk_Q2 <= rdPtrGray_wrClk_Q1;
    end
  end

  wire [ADDRESS_WIDTH:0] rdPtrBin_wrClk;

  gray2Bin #(.COUNTER_WIDTH(ADDRESS_WIDTH+1))gray2Bin_rdPtr(
    .din  (rdPtrGray_wrClk_Q2), 
    .dout (rdPtrBin_wrClk)
  );   

  parameter WR_DATA_WIDTH_RATIO = WR_DATA_WIDTH_MUL/RD_DATA_WIDTH_MUL;
  generate  
    if(WR_DATA_WIDTH_MUL > RD_DATA_WIDTH_MUL)
     begin
      if(WR_DATA_WIDTH_RATIO == 2)
        assign fifoFull = (wrPtr[ADDRESS_WIDTH] != rdPtrBin_wrClk[ADDRESS_WIDTH]) & (wrPtr[ADDRESS_WIDTH-1:0] == rdPtrBin_wrClk[ADDRESS_WIDTH-1:0]);
      else if(WR_DATA_WIDTH_RATIO == 4)
        assign fifoFull = (wrPtr[ADDRESS_WIDTH] != rdPtrBin_wrClk[ADDRESS_WIDTH]) & (wrPtr[ADDRESS_WIDTH-1:2] == rdPtrBin_wrClk[ADDRESS_WIDTH-1:1]);
      else if(WR_DATA_WIDTH_RATIO == 8)
        assign fifoFull = (wrPtr[ADDRESS_WIDTH] != rdPtrBin_wrClk[ADDRESS_WIDTH]) & (wrPtr[ADDRESS_WIDTH-1:3] == rdPtrBin_wrClk[ADDRESS_WIDTH-1:2]);
      else if(WR_DATA_WIDTH_RATIO == 16)
        assign fifoFull = (wrPtr[ADDRESS_WIDTH] != rdPtrBin_wrClk[ADDRESS_WIDTH]) & (wrPtr[ADDRESS_WIDTH-1:4] == rdPtrBin_wrClk[ADDRESS_WIDTH-1:3]);
      else if(WR_DATA_WIDTH_RATIO == 32)
        assign fifoFull = (wrPtr[ADDRESS_WIDTH] != rdPtrBin_wrClk[ADDRESS_WIDTH]) & (wrPtr[ADDRESS_WIDTH-1:5] == rdPtrBin_wrClk[ADDRESS_WIDTH-1:4]);
    end
    else begin
      assign fifoFull = (wrPtr[ADDRESS_WIDTH] != rdPtrBin_wrClk[ADDRESS_WIDTH]) & (wrPtr[ADDRESS_WIDTH-1:0] == rdPtrBin_wrClk[ADDRESS_WIDTH-1:0]);
    end
  endgenerate 

wire [ADDRESS_WIDTH:0] wrPtrGray;
  bin2Gray #(.COUNTER_WIDTH(ADDRESS_WIDTH+1)) bin2Gray_wrPtr (
    .din  (wrPtr), 
    .dout (wrPtrGray)
  );
  reg [ADDRESS_WIDTH:0] wrPtrGray_wrClk;
  always@(posedge wrClk or posedge rst)begin
    if(rst)begin
      wrPtrGray_wrClk <= 0;
    end else begin
      wrPtrGray_wrClk <= wrPtrGray;
    end
  end

  reg  [ADDRESS_WIDTH:0] wrPtrGray_rdClk_Q1, wrPtrGray_rdClk_Q2;
  always@(posedge rdClk or posedge rst)begin
    if(rst)begin
      wrPtrGray_rdClk_Q1 <= 0;
      wrPtrGray_rdClk_Q2 <= 0;
    end else begin
      wrPtrGray_rdClk_Q1 <= wrPtrGray_wrClk;
      wrPtrGray_rdClk_Q2 <= wrPtrGray_rdClk_Q1;
    end
  end

  wire [ADDRESS_WIDTH:0] wrPtrBin_rdClk;
  gray2Bin #(.COUNTER_WIDTH(ADDRESS_WIDTH+1))gray2Bin_wrPtr2(
    .din  (wrPtrGray_rdClk_Q2), 
    .dout (wrPtrBin_rdClk)
  );


  parameter RD_DATA_WIDTH_RATIO = RD_DATA_WIDTH_MUL /WR_DATA_WIDTH_MUL;
  generate 
    if(RD_DATA_WIDTH_MUL > WR_DATA_WIDTH_MUL)
     begin
      if(RD_DATA_WIDTH_RATIO == 2)
        assign fifoEmpty = (rdPtr[ADDRESS_WIDTH] == wrPtrBin_rdClk[ADDRESS_WIDTH]) & (rdPtr[ADDRESS_WIDTH-1:0] == wrPtrBin_rdClk[ADDRESS_WIDTH-1:0]);
      else if(RD_DATA_WIDTH_RATIO == 4)
        assign fifoEmpty = (rdPtr[ADDRESS_WIDTH] == wrPtrBin_rdClk[ADDRESS_WIDTH]) & (rdPtr[ADDRESS_WIDTH-1:1] == wrPtrBin_rdClk[ADDRESS_WIDTH-1:1]);
      else if(RD_DATA_WIDTH_RATIO == 8)
        assign fifoEmpty = (rdPtr[ADDRESS_WIDTH] == wrPtrBin_rdClk[ADDRESS_WIDTH]) & (rdPtr[ADDRESS_WIDTH-1:2] == wrPtrBin_rdClk[ADDRESS_WIDTH-1:2]);
      else if(RD_DATA_WIDTH_RATIO == 16)
        assign fifoEmpty = (rdPtr[ADDRESS_WIDTH] == wrPtrBin_rdClk[ADDRESS_WIDTH]) & (rdPtr[ADDRESS_WIDTH-1:3] == wrPtrBin_rdClk[ADDRESS_WIDTH-1:3]);
      else if(RD_DATA_WIDTH_RATIO == 32)
        assign fifoEmpty = (rdPtr[ADDRESS_WIDTH] == wrPtrBin_rdClk[ADDRESS_WIDTH]) & (rdPtr[ADDRESS_WIDTH-1:4] == wrPtrBin_rdClk[ADDRESS_WIDTH-1:4]);
    end
    else begin
      assign fifoEmpty = (rdPtr[ADDRESS_WIDTH] == wrPtrBin_rdClk[ADDRESS_WIDTH]) & (rdPtr[ADDRESS_WIDTH-1:0] == wrPtrBin_rdClk[ADDRESS_WIDTH-1:0]);
   end
  endgenerate
endmodule



module bin2Gray #(parameter COUNTER_WIDTH = 4)(
  input      [COUNTER_WIDTH-1:0] din,
  output  [COUNTER_WIDTH-1:0] dout
);
//wire [COUNTER_WIDTH-1:0] dout;
  genvar i;
  generate
    for (i = 0; i < (COUNTER_WIDTH-1) ; i = i + 1) begin
      assign dout[i] = din[i+1] ^ din[i];
    end
  endgenerate
     assign dout[COUNTER_WIDTH-1]= din[COUNTER_WIDTH-1];
endmodule



module gray2Bin #(parameter COUNTER_WIDTH = 4)(
  input      [COUNTER_WIDTH-1:0] din,
  output  [COUNTER_WIDTH-1:0] dout
  );
//wire  [COUNTER_WIDTH-1:0] dout;
  assign dout[COUNTER_WIDTH-1] = din[COUNTER_WIDTH-1];
  genvar i;
  generate
    for (i = (COUNTER_WIDTH-2); i >= 0 ; i = i - 1) begin
      assign dout[i] = dout[i+1] ^ din[i];
    end
  endgenerate

endmodule

