
// module: Forwarding
// Function: Generates the forwarding signals for each one of the datapath resources

module forwarding_unit(
      input  wire [4:0] IF_IDregisterRs,
      input  wire [4:0] IF_IDregisterRt, 
      input  wire [4:0] EX_MEMregisterRd,
      input  wire [4:0] MEM_WBregisterRd,
      input  wire       EX_MEMregWrite,
      input  wire       MEM_WBregWrite,
      output reg  [1:0] forwardA,
      output reg  [1:0] forwardB
   );
   
   always@(*) begin
   
         if (EX_MEMregWrite && EX_MEMregisterRd != 5'd0 && EX_MEMregisterRd == ID_EXregisterRs) begin
          forwardA = 2'b10;
      end
      else begin
            forwardA = 2'b00;
      end
         if (EX_MEMregWrite && EX_MEMregisterRd != 5'd0 && EX_MEMregisterRd == ID_EXregisterRt) begin
          forwardB = 2'b10;
      end
      else begin
            forwardB = 2'b00;
      end
      
         if(MEM_WBregWrite && MEM_WBregisterRd != 5'd0 && !(EX_MEMregWrite && (EX_MEMregisterRd != 5'd0) && (EX_MEMregisterRd != ID_EXregisterRs)) && MEM_WBregisterRd == ID_EXregisterRs) begin
          forwardA = 2'b01;
      end
      else begin
            forwardA = 2'b00;
      end
         
         if(MEM_WBregWrite && MEM_WBregisterRd != 5'd0 && !(EX_MEMregWrite && (EX_MEMregisterRd != 5'd0) && (EX_MEMregisterRd != ID_EXregisterRt)) && MEM_WBregisterRd == ID_EXregisterRt) begin
          forwardB = 2'b01;
      end
      else begin
            forwardB = 2'b00;
      end
  end
endmodule
 