//Module: hazard detection

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
        hazardDetected = 1'b0;
    //Load instruction
    if (ID_EXMemRead && ((ID_EXregisterRt == IF_IDregisterRs) || (ID_EXregisterRt == IF_IDregisterRt)) ) begin
          hazardDetected = 1'b1;
          PCWrite = 1'b0; 
          IF_IDWrite = 1'b0; 
      end
      else begin
          hazardDetected = 1'b0;
           PCWrite = 1'b1; 
          IF_IDWrite = 1'b1; 
      end
    
  end
endmodule


