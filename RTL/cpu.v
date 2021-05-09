//Module: CPU
//Function: CPU is the top design of the processor
//Inputs:
//	clk: main clock
//	arst_n: reset 
// 	enable: Starts the execution
//	addr_ext: Address for reading/writing content to Instruction Memory
//	wen_ext: Write enable for Instruction Memory
// 	ren_ext: Read enable for Instruction Memory
//	wdata_ext: Write word for Instruction Memory
//	addr_ext_2: Address for reading/writing content to Data Memory
//	wen_ext_2: Write enable for Data Memory
// 	ren_ext_2: Read enable for Data Memory
//	wdata_ext_2: Write word for Data Memory
//Outputs:
//	rdata_ext: Read data from Instruction Memory
//	rdata_ext_2: Read data from Data Memory



module cpu(
		input  wire			  clk,
		input  wire         arst_n,
		input  wire         enable,
		input  wire	[31:0]  addr_ext,
		input  wire         wen_ext,
		input  wire         ren_ext,
		input  wire [31:0]  wdata_ext,
		input  wire	[31:0]  addr_ext_2,
		input  wire         wen_ext_2,
		input  wire         ren_ext_2,
		input  wire [31:0]  wdata_ext_2,
		
		output wire	[31:0]  rdata_ext,
		output wire	[31:0]  rdata_ext_2

   );

wire              zero_flag, alu_zero_EX_MEM;
wire [      31:0] branch_pc,current_pc,jump_pc,
                  updated_pc_IF_ID, updated_pc_ID_EX, updated_pc_EX_MEM, updated_jump_pc_EX_MEM, updated_pc, instruction;
wire [       1:0] alu_op, alu_op_ID_EX;
wire [       3:0] alu_control;
wire              reg_dst,branch,mem_read,mem_2_reg,
                  mem_write,alu_src, reg_write, reg_write_MEM_WB, jump, alu_src_ID_EX, jump_EX_MEM, branch_EX_MEM, reg_write_ID_EX, mem_2_reg_ID_EX, branch_ID_EX, jump_ID_EX, mem_read_ID_EX, mem_write_ID_EX, reg_dst_ID_EX, reg_write_EX_MEM , mem_2_reg_EX_MEM, mem_read_EX_MEM, mem_write_EX_MEM, mem_2_reg_MEM_WB;
wire [       4:0] regfile_waddr, instruction1620_ID_EX,instruction1115_ID_EX,	 regfile_waddr_EX_MEM, regfile_waddr_MEM_WB;
wire [      31:0] regfile_wdata, dram_data,alu_out, dram_data_MEM_WB,
                  regfile_data_1,regfile_data_2,
                  alu_operand_2, alu_result_EX_MEM, alu_result_MEM_WB;
wire [      31:0] instruction_IF_ID, instruction_ID_EX, instruction_ID_EX_extended;
wire [      31:0] regfile_data_1_ID_EX, regfile_data_2_ID_EX, regfile_data_2_EX_MEM;
wire signed [31:0] immediate_extended;
wire [1:0] forwardA;
wire [1:0] forwardB;
wire [31:0] mux1_out, alu_operand_1, mux2_out, mux_3_out;
wire hazardDetected,  PCWrite, updated_mem_write, updated_reg_write;
wire IF_IDWrite;

// extends IF/ID instruction
assign immediate_extended = $signed(instruction_IF_ID[15:0]);

/////////////////////
// PROGRAM COUNTER //
/////////////////////
pc #(
   .DATA_W(32)
) program_counter (
   .clk       (clk       ),
   .arst_n    (arst_n    ),
   .branch_pc (updated_pc_EX_MEM ),
   .jump_pc   (updated_jump_pc_EX_MEM   ),
   .zero_flag (alu_zero_EX_MEM ),
   .branch    (branch_EX_MEM    ),
   .jump      (jump_EX_MEM      ),
   .current_pc(current_pc),
   .enable    (enable ),
   .updated_pc(updated_pc),
	.PCWrite(PCWrite)
);


// IF/ID updated PC
reg_arstn_en #(.DATA_W(32)) updated_pc_pipe_IF_ID(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (updated_pc),
      .en    (IF_IDWrite    ),
      .dout  (updated_pc_IF_ID)
);

// ID/EX updated PC
reg_arstn_en #(.DATA_W(32)) updated_pc_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (updated_pc_IF_ID),
      .en    (enable    ),
      .dout  (updated_pc_ID_EX)
);

// ID/EX updated BRANCH PC
reg_arstn_en #(.DATA_W(32)) updated_pc_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (branch_pc),
      .en    (enable    ),
      .dout  (updated_pc_EX_MEM)
);

// ID/EX updated JUMP PC
reg_arstn_en #(.DATA_W(32)) updated_jump_pc_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (jump_pc),
      .en    (enable    ),
      .dout  (updated_jump_pc_EX_MEM)
);


/////////////////////
// INSTRUCTION     //
/////////////////////

// IF/ID instruction
reg_arstn_en #(.DATA_W(32)) instruction_pipe_IF_ID(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (instruction),
      .en    (IF_IDWrite   ),
      .dout  (instruction_IF_ID)
);

// ID/EX instruction extended
reg_arstn_en #(.DATA_W(32)) instruction_extended_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (immediate_extended),
      .en    (enable    ),
      .dout  (instruction_ID_EX_extended)
);

// ID/EX instruction
reg_arstn_en #(.DATA_W(32)) instruction_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (instruction_IF_ID),
      .en    (enable    ),
      .dout  (instruction_ID_EX)
);
	
reg_arstn_en #(.DATA_W(5)) instruction1115_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (instruction_IF_ID[15:11]),
      .en    (enable    ),
      .dout  (instruction1115_ID_EX)
);
	
reg_arstn_en #(.DATA_W(5)) instruction1620_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (instruction_IF_ID[20:16]),
      .en    (enable    ),
      .dout  (instruction1620_ID_EX)
);


	
//reg_arstn_en #(.DATA_W(5)) control_ALU_Src_pipe_ID_EX(
 //     .clk   (clk       ),
//      .arst_n(arst_n    ),
 //     .din   (alu_src),
//      .en    (enable    ),
//      .dout  (alu_src_ID_EX)
//);
// instruction memory
sram #(
   .ADDR_W(9 ),
   .DATA_W(32)
) instruction_memory(
   .clk      (clk           ),
   .addr     (current_pc    ),
   .wen      (1'b0          ),
   .ren      (1'b1          ),
   .wdata    (32'b0         ),
   .rdata    (instruction   ),   
   .addr_ext (addr_ext      ),
   .wen_ext  (wen_ext       ), 
   .ren_ext  (ren_ext       ),
   .wdata_ext(wdata_ext     ),
   .rdata_ext(rdata_ext     )
);



/////////////////////
// CONTROL         //
/////////////////////

control_unit control_unit(
   .opcode   (instruction_IF_ID[31:26]),
   .reg_dst  (reg_dst           ),
   .branch   (branch            ),
   .mem_read (mem_read          ),
   .mem_2_reg(mem_2_reg         ),
   .alu_op   (alu_op            ),
   .mem_write(mem_write         ),
   .alu_src  (alu_src           ),
   .reg_write(reg_write         ),
   .jump     (jump              )
);

// ID/EX control
reg_arstn_en #(.DATA_W(1)) control_RegWrite_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (updated_reg_write),
      .en    (enable    ),
      .dout  (reg_write_ID_EX)
);	

reg_arstn_en #(.DATA_W(1)) control_Mem2Reg_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (mem_2_reg),
      .en    (enable    ),
      .dout  (mem_2_reg_ID_EX)
);

reg_arstn_en #(.DATA_W(1)) control_Branch_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (branch),
      .en    (enable    ),
      .dout  (branch_ID_EX)
);

reg_arstn_en #(.DATA_W(1)) control_Jump_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (jump),
      .en    (enable    ),
      .dout  (jump_ID_EX)
);

reg_arstn_en #(.DATA_W(1)) control_MemRead_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (mem_read),
      .en    (enable    ),
      .dout  (mem_read_ID_EX)
);

reg_arstn_en #(.DATA_W(1)) control_MemWrite_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (updated_mem_write),
      .en    (enable    ),
      .dout  (mem_write_ID_EX)
);

reg_arstn_en #(.DATA_W(1)) control_RegDst_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (reg_dst),
      .en    (enable    ),
      .dout  (reg_dst_ID_EX)
);

reg_arstn_en #(.DATA_W(2)) control_ALU_Op_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (alu_op),
      .en    (enable    ),
      .dout  (alu_op_ID_EX)
);

reg_arstn_en #(.DATA_W(1)) control_ALU_Src_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (alu_src),
      .en    (enable    ),
      .dout  (alu_src_ID_EX)
);

//reg_arstn_en #(.DATA_W(1)) control_ALU_Src_pipe_ID_EX(
//      .clk   (clk       ),
 //     .arst_n(arst_n    ),
 //     .din   (alu_src),
//      .en    (enable    ),
//      .dout  (alu_src_ID_EX)
//);

// EX/MEM control
reg_arstn_en #(.DATA_W(1)) control_RegWrite_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (reg_write_ID_EX),
      .en    (enable    ),
      .dout  (reg_write_EX_MEM)
);

reg_arstn_en #(.DATA_W(1)) control_Mem2Reg_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (mem_2_reg_ID_EX),
      .en    (enable    ),
      .dout  (mem_2_reg_EX_MEM)
);

reg_arstn_en #(.DATA_W(1)) control_Branch_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (branch_ID_EX),
      .en    (enable    ),
      .dout  (branch_EX_MEM)
);

reg_arstn_en #(.DATA_W(1)) control_Jump_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (jump_ID_EX),
      .en    (enable    ),
      .dout  (jump_EX_MEM)
);

reg_arstn_en #(.DATA_W(1)) control_MemRead_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (mem_read_ID_EX),
      .en    (enable    ),
      .dout  (mem_read_EX_MEM)
);

reg_arstn_en #(.DATA_W(1)) control_MemWrite_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (mem_write_ID_EX),
      .en    (enable    ),
      .dout  (mem_write_EX_MEM)
);
// MEM_WB control
reg_arstn_en #(.DATA_W(1)) control_RegWrite_pipe_MEM_WB(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (reg_write_EX_MEM),
      .en    (enable    ),
      .dout  (reg_write_MEM_WB)
);

reg_arstn_en #(.DATA_W(1)) control_Mem2Reg_pipe_MEM_WB(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (mem_2_reg_EX_MEM),
      .en    (enable    ),
      .dout  (mem_2_reg_MEM_WB)
);





/////////////////////
// REGISTERS       //
/////////////////////

mux_2 #(
   .DATA_W(5)
) regfile_dest_mux (
   .input_a (instruction1115_ID_EX[4:0]),
   .input_b (instruction1620_ID_EX[4:0]),
   .select_a(reg_dst_ID_EX          ),
   .mux_out (regfile_waddr     )
);

register_file #(
   .DATA_W(32)
) register_file(
   .clk      (clk               ),
   .arst_n   (arst_n            ),
   .reg_write(reg_write_MEM_WB         ),
   .raddr_1  (instruction_IF_ID[25:21]),
   .raddr_2  (instruction_IF_ID[20:16]),
   .waddr    (regfile_waddr_MEM_WB     ),
   .wdata    (regfile_wdata     ),
   .rdata_1  (regfile_data_1    ),
   .rdata_2  (regfile_data_2    )
);

reg_arstn_en #(.DATA_W(5)) register_destmux_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_waddr),
      .en    (enable    ),
      .dout  (regfile_waddr_EX_MEM)
);

reg_arstn_en #(.DATA_W(5)) register_destmux_pipe_MEM_WB(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_waddr_EX_MEM),
      .en    (enable    ),
      .dout  (regfile_waddr_MEM_WB)
);

// ID/EX register read data
reg_arstn_en #(.DATA_W(32)) register_data1_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_data_1),
      .en    (enable    ),
      .dout  (regfile_data_1_ID_EX)
);

reg_arstn_en #(.DATA_W(32)) register_data2_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_data_2),
      .en    (enable    ),
      .dout  (regfile_data_2_ID_EX)
);

reg_arstn_en #(.DATA_W(32)) register_data2_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (mux_3_out),
      .en    (enable    ),
      .dout  (regfile_data_2_EX_MEM)
);


/////////////////////
// ALU             //
/////////////////////

alu_control alu_ctrl(
   .function_field (instruction_ID_EX_extended[5:0]),
   .alu_op         (alu_op_ID_EX[1:0]          ),
   .alu_control    (alu_control     )
);



alu#(
   .DATA_W(32)
) alu(
   .alu_in_0 (alu_operand_1),
   .alu_in_1 (alu_operand_2 ),
   .alu_ctrl (alu_control   ),
   .alu_out  (alu_out       ),
   .shft_amnt(instruction_ID_EX_extended[10:6]),
   .zero_flag(zero_flag     ),
   .overflow (              )
);

reg_arstn_en #(.DATA_W(1)) alu_zero_reg_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (zero_flag),
      .en    (enable    ),
      .dout  (alu_zero_EX_MEM)
);

reg_arstn_en #(.DATA_W(32)) alu_result_reg_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (alu_out),
      .en    (enable    ),
      .dout  (alu_result_EX_MEM)
);

reg_arstn_en #(.DATA_W(32)) alu_result_reg_MEM_WB(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (alu_result_EX_MEM),
      .en    (enable    ),
      .dout  (alu_result_MEM_WB)
);

/////////////////////
// DATA MEMORY     //
/////////////////////

sram #(
   .ADDR_W(10),
   .DATA_W(32)
) data_memory(
   .clk      (clk           ),
   .addr     (alu_result_EX_MEM       ),
   .wen      (mem_write_EX_MEM     ),
   .ren      (mem_read_EX_MEM      ),
   .wdata    (regfile_data_2_EX_MEM),
   .rdata    (dram_data     ),   
   .addr_ext (addr_ext_2    ),
   .wen_ext  (wen_ext_2     ),
   .ren_ext  (ren_ext_2     ),
   .wdata_ext(wdata_ext_2   ),
   .rdata_ext(rdata_ext_2   )
);

// MEM WB dram data
reg_arstn_en #(.DATA_W(32)) dram_data_reg_MEM_WB(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (dram_data),
      .en    (enable    ),
      .dout  (dram_data_MEM_WB)
);


/////////////////////
// WRITE BACK MUX  //
/////////////////////

mux_2 #(
   .DATA_W(32)
) regfile_data_mux (
   .input_a  (dram_data_MEM_WB    ),
   .input_b  (alu_result_MEM_WB      ),
   .select_a (mem_2_reg_MEM_WB     ),
   .mux_out  (regfile_wdata)
);


/////////////////////
// BRANCH          //
/////////////////////

branch_unit#(
   .DATA_W(32)
)branch_unit(
   .updated_pc   (updated_pc_ID_EX        ),
   .instruction  (instruction_IF_ID       ),
   .branch_offset(instruction_ID_EX_extended),
   .branch_pc    (branch_pc         ),
   .jump_pc      (jump_pc         )
);


///////////////////////////////
// FORWARDING UNIT 	//////
//////////////////////////////


forwarding_unit forwarding_unit(
	.ID_EXregisterRs(instruction_ID_EX[25:21]),
	.ID_EXregisterRt(instruction_ID_EX[20:16]),
	.EX_MEMregisterRd(regfile_waddr_EX_MEM),
	.MEM_WBregisterRd(regfile_waddr_MEM_WB),
	.EX_MEMregWrite(reg_write_EX_MEM),
	.MEM_WBregWrite(reg_write_MEM_WB),
	.forwardA(forwardA),
	.forwardB(forwardB)
);

// 2 MUX's to select 1st ALU operand
mux_2 #(
   .DATA_W(32)
) alu_operand_mux11 (
	.input_a (regfile_data_1_ID_EX),
	.input_b (regfile_wdata    ),
	.select_a(forwardA[0]           ),
	.mux_out (mux1_out     )
);
mux_2 #(
   .DATA_W(32)
) alu_operand_mux12 (
	.input_a (mux1_out),
	.input_b (alu_result_EX_MEM    ),
	.select_a(forwardA[1]           ),
	.mux_out (alu_operand_1     )
);

// 3 MUX's to choose 2nd alu operand	
mux_2 #(
   .DATA_W(32)
) alu_operand_mux21 (
	.input_a (regfile_data_2_ID_EX),
	.input_b (regfile_wdata    ),
	.select_a(forwardB[0]           ),
	.mux_out (mux2_out     )
);
mux_2 #(
   .DATA_W(32)
) alu_operand_mux22 (
	.input_a (mux2_out),
	.input_b (alu_result_EX_MEM    ),
	.select_a(forwardB[1]           ),
	.mux_out (mux_3_out     )
);	

// EX instruction (ALU) MUX
mux_2 #(
   .DATA_W(32)
) alu_operand_mux (
   .input_a (instruction_ID_EX_extended), 
   .input_b (mux_3_out    ),
   .select_a(alu_src_ID_EX           ),
   .mux_out (alu_operand_2     )
);

///////////////////////////////
// HAZARD DETECTION 	//////
//////////////////////////////


hazard_detection hazard_detection(
	.IF_IDregisterRs(instruction_IF_ID[25:21]),
	.IF_IDregisterRt(instruction_IF_ID[20:16]),
	.ID_EXregisterRt(instruction_ID_EX[20:16]),
	.ID_EXMemRead(regfile_waddr_MEM_WB),
	.PCWrite(PCWrite),
	.IF_IDWrite(IF_IDWrite),
	.hazardDetected(hazardDetected)
);

mux_2 #(
	.DATA_W(1)
) hazard_detected_REGWRITE_mux (
	.input_a (1'b0),
	.input_b (reg_write),
	.select_a(hazardDetected          ),
	.mux_out (updated_reg_write    )
);

mux_2 #(
	.DATA_W(1)
) hazard_detected_MEMWRITE_mux (
	.input_a (1'b0),
	.input_b (mem_write),
	.select_a(hazardDetected          ),
	.mux_out (updated_mem_write     )
);

endmodule
