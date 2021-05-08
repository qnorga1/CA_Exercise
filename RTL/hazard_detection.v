module hazard_detection(
      input  wire [4:0] IF_IDregisterRt,
      input  wire [4:0] IF_IDregisterRs,
      input  wire [4:0] ID_EXregisterRt,
      input  wire       ID_EXMemRead,
      output reg  PCWrite,
      output reg  IF_IDWrite,
      output reg  hazardDetected
   );
  
  always@(*) begin
    //Load instruction
    if (ID_EXMemRead && ((ID_EXregisterRt == IF_IDregisterRs) || (ID_EXregisterRt == IF_IDregisterRt)) ) begin
          hazardDetected = 1'b1;
          PCWrite = ; //TODO
          IF_IDWrite = ; //TODO
      end
      else begin
          hazardDetected = 1'b0;
           PCWrite = ; //TODO
          IF_IDWrite = ; //TODO
      end
    
  end
endmodule
