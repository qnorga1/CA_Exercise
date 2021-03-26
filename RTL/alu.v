//Module: ALU
//Function: The ALU is a combinational circuit that executes the arithmetic or logical operation taking into account the control signals and input operands.
//Inputs:
//alu_in_0 (16 bits):  First operand
//alu_in_1 (16 bits): Second operand
//alu_ctrl (4 bits): Signal generated by the control unit to select one of the artihmetic or logical operations.
//shf_amnt (5 bits): Number of bits to shift for a shift instruction.
//Outputs:
//alu_out (16 bits): Result of the arithmetic or logical operation.
//zero_flag: If the result of the ALU is zero this signal is asserted.


module alu #(
   parameter integer DATA_W = 16
   )(
		input   wire signed [DATA_W-1:0] alu_in_0,
      input   wire signed [DATA_W-1:0] alu_in_1,
      input   wire        [       3:0] alu_ctrl,
      input   wire        [       4:0] shft_amnt,
		output  reg  signed [DATA_W-1:0] alu_out,
		output  reg		                  zero_flag,
      output  reg                      overflow
   );

   //The alu control codes can be found
   //in chapter 4.4 of the book.
   //PARAMETER DECLARATION
   
   parameter [3:0] AND_OP = 4'd0;
   parameter [3:0]  OR_OP = 4'd1;
   parameter [3:0] ADD_OP = 4'd2;
   parameter [3:0] SLL_OP = 4'd3;
   parameter [3:0] SRL_OP = 4'd4;
   parameter [3:0] SUB_OP = 4'd5;
   parameter [3:0] SLT_OP = 4'd7;
   parameter [3:0] NOR_OP = 4'd12;
   parameter [3:0] MULT_OP = 4'd12; //TODO


   //REG AND WIRE DECLARATION
   reg signed [DATA_W-1:0] sub_out,add_out,and_out,or_out,
                           nor_out,slt_out, sll_out, srl_out, mult_out;
	reg 		               overflow_add,overflow_sub,
                           msb_equal_flag;
   
   
   
   //ZERO FLAG 
   //
   //Statements like this can be written in a more
   //compact way in Verilog:
   //always@(*) zero_flag = (data_out=='b0);
   //They are written here in a more verbose way for clarity.

   always@(*)begin
      if(alu_out == 'b0) begin
         zero_flag = 1'b1;
      end else begin
         zero_flag = 1'b0;
      end
   end

   //ARITHMETIC and LOGIC OPERATIONS
   always@(*)begin
      add_out  =   alu_in_0 + alu_in_1;
      sll_out  =   alu_in_1 << shft_amnt;
      srl_out  =   alu_in_1 >> shft_amnt;
      sub_out  =   alu_in_0 - alu_in_1;
      and_out  =   alu_in_0 & alu_in_1;
      or_out   =   alu_in_0 | alu_in_1;
      nor_out  = ~(alu_in_0 | alu_in_1);
      slt_out  =  (alu_in_0 < alu_in_1) ? 1:0;        //Zero extend the 1 bit slt flag to a DATA_W bit value  
      mult_out = alu_in_0 * alu_in_1;   
   end

   //This block will translate into a multiplexer, where alu_ctrl
   //will act as the selection signal between the different hardware sub
   //blocks described above
	always @(*) begin
		case (alu_ctrl)
			AND_OP:  alu_out = and_out;
			OR_OP:   alu_out =  or_out;
			NOR_OP:  alu_out = nor_out;
			ADD_OP:  alu_out = add_out;			
			SUB_OP:  alu_out = sub_out;
			SLT_OP:  alu_out = slt_out;
			SLL_OP:  alu_out = sll_out;
			SRL_OP:  alu_out = srl_out;
			MULT_OP:  alu_out = mult_out;
			default: alu_out =     'd0;
		endcase
	end



   // OVERFLOW DETECTION
   always@(*)begin
      if(alu_in_0[DATA_W-1] == alu_in_1[DATA_W-1]) begin
         msb_equal_flag = 1'b1;
      end else begin
         msb_equal_flag = 1'b0;
      end
   end
   
   always@(*)begin
      if((msb_equal_flag == 1'b1) && (add_out[DATA_W-1] != alu_in_0[DATA_W-1]))begin
         overflow_add = 1'b1;
      end else begin
         overflow_add = 1'b0;
      end
   end

//   assign overflow_sub = (alu_in_0[DATA_W-1] == alu_in_1[DATA_W-1] && sub_out[DATA_W-1] != alu_in_0[DATA_W-1]) ? 1 : 0;

   always@(*)begin
      if((msb_equal_flag == 1'b1) && (sub_out[DATA_W-1] != alu_in_0[DATA_W-1]))begin
         overflow_sub = 1'b1;
      end else begin
         overflow_sub = 1'b0;
      end
   end



   always@(*)begin
      if(alu_ctrl == ADD_OP)
         overflow = overflow_add;
      else
         overflow = overflow_sub;
  end 


endmodule



