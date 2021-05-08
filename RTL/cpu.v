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

wire              zero_flag;
wire [      31:0] branch_pc,updated_pc,current_pc,jump_pc,
                  instruction;
wire [       1:0] alu_op;
wire [       3:0] alu_control;
wire              reg_dst,branch,mem_read,mem_2_reg,
                  mem_write,alu_src, reg_write, jump;
wire [       4:0] regfile_waddr;
wire [      31:0] regfile_wdata, dram_data,alu_out,
                  regfile_data_1,regfile_data_2,
                  alu_operand_2;

wire signed [31:0] immediate_extended;

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
   .branch_pc (branch_pc ),
   .jump_pc   (jump_pc   ),
   .zero_flag (zero_flag ),
   .branch    (branch    ),
   .jump      (jump      ),
   .current_pc(current_pc),
   .enable    (enable    ),
   .updated_pc(updated_pc)
);

// IF/ID upadated PC
reg_arstn_en #(.DATA_W(32)) updated_pc_pipe_IF_ID(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (updated_pc),
      .en    (enable    ),
      .dout  (updated_pc_IF_ID)
);

// ID/EX upadated PC
reg_arstn_en #(.DATA_W(32)) updated_pc_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (updated_pc_IF_ID),
      .en    (enable    ),
      .dout  (updated_pc_ID_EX)
);


/////////////////////
// INSTRUCTION     //
/////////////////////

// IF/ID instruction
reg_arstn_en #(.DATA_W(32)) instruction_pipe_IF_ID(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (instruction),
      .en    (enable    ),
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
//TODO

control_unit control_unit(
   .opcode   (instruction[31:26]),
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
	
	reg_arstn_en #(.DATA_W(1)) register_regWrite_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
	.din   (updated_reg_write),
      .en    (enable    ),
	.dout  (reg_write_ID_EX)
);	

	reg_arstn_en #(.DATA_W(1)) register_regWrite_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
		.din   (reg_write_ID_EX),
      .en    (enable    ),
		.dout  (reg_write_EX_MEM)
);
	
	reg_arstn_en #(.DATA_W(1)) register_regWrite_pipe_MEM_WB(
      .clk   (clk       ),
      .arst_n(arst_n    ),
		.din   (reg_write_EX_MEM),
      .en    (enable    ),
		.dout  (reg_write_MEM_WB)
);
	reg_arstn_en #(.DATA_W(1)) register_memWrite_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
		.din   (updated_mem_write),
      .en    (enable    ),
		.dout  (mem_write_ID_EX)
);	

	reg_arstn_en #(.DATA_W(1)) register_memWrite_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
		.din   (mem_write_ID_EX),
      .en    (enable    ),
		.dout  (mem_write_EX_MEM)
);
	
	reg_arstn_en #(.DATA_W(1)) register_memWrite_pipe_MEM_WB(
      .clk   (clk       ),
      .arst_n(arst_n    ),
		.din   (mem_write_EX_MEM),
      .en    (enable    ),
		.dout  (mem_write_MEM_WB)
);
	
///////////////////////////////
// FORWARDING UNIT 	//////
//////////////////////////////
reg [1:0] forwardA;
reg [1:0] forwardB;
	
forwarding_unit forwarding_unit(
	.IF_IDregisterRs(instruction_ID_EX[25:21],
	.IF_IDregisterRt(instruction_ID_EX[20:16]),
	.EX_MEMregisterRd(regfile_waddr_EX_MEM),
	.MEM_WBregisterRd(regfile_waddr_MEM_WB),
	.EX_MEMregWrite(reg_write_EX_MEM),
	.MEM_WBregWrite(reg_write_MEM_WB),
	.forwardA(forwardA),
	.forwardB(forwardB)
);

///////////////////////////////
// HAZARD DETECTION 	//////
//////////////////////////////
wire hazardDetected, IF_IDWrite, PCWrite, updated_mem_write, updated_reg_write;

hazard_detection hazard_detection(
	.IF_IDregisterRt(instruction_ID_EX[25:21],
	.IF_IDregisterRs(instruction_ID_EX[20:16]),
	.ID_EXregisterRt(regfile_waddr_EX_MEM),
	.ID_EXMemRead(regfile_waddr_MEM_WB),
	.PCWrite(PCWrite),
	.IF_IDWrite(IF_IDWrite),
	.hazardDetected(hazardDetected)
);

mux_2 #(
	.DATA_W(1)
) hazard_detected_REGWRITE_mux (
	.input_a (1b'0),
	.input_b (reg_write),
	.select_a(hazardDetected          ),
	.mux_out (updated_reg_write    )
);
	
mux_2 #(
	.DATA_W(1)
) hazard_detected_MEMWRITE_mux (
	.input_a (1b'0),
	.input_b (mem_write),
	.select_a(hazardDetected          ),
	.mux_out (updated_mem_write     )
);
/////////////////////
// REGISTERS       //
/////////////////////

mux_2 #(
   .DATA_W(5)
) regfile_dest_mux (
	.input_a (instruction_ID_EX[15:11]),
	.input_b (instruction_ID_EX[20:16]),
   .select_a(reg_dst          ),
   .mux_out (regfile_waddr     )
);

register_file #(
   .DATA_W(32)
) register_file(
   .clk      (clk               ),
   .arst_n   (arst_n            ),
   .reg_write(reg_write         ),
   .raddr_1  (instruction_IF_ID[25:21]),
   .raddr_2  (instruction_IF_ID[20:16]),
   .waddr    (regfile_waddr     ),
   .wdata    (regfile_wdata     ),
   .rdata_1  (regfile_data_1    ),
   .rdata_2  (regfile_data_2    )
);

// ID/EX register read data
reg_arstn_en #(.DATA_W(16)) register_data1_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_data_1),
      .en    (enable    ),
      .dout  (regfile_data_1_ID_EX)
);

reg_arstn_en #(.DATA_W(16)) register_data2_pipe_ID_EX(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_data_2),
      .en    (enable    ),
      .dout  (regfile_data_2_ID_EX)
);

reg_arstn_en #(.DATA_W(16)) register_data2_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_data_2_ID_EX),
      .en    (enable    ),
      .dout  (regfile_data_2_EX_MEM)
);
		
reg_arstn_en #(.DATA_W(16)) register_waddr_pipe_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (regfile_waddr),
      .en    (enable    ),
      .dout  (regfile_waddr_EX_MEM)
);
			 
reg_arstn_en #(.DATA_W(16)) register_waddr_pipe_MEM_WB(
      .clk   (clk       ),
      .arst_n(arst_n    ),
	.din   (regfile_waddr_EX_MEM),
      .en    (enable    ),
	.dout  (regfile_waddr_MEM_WB)
);
				 
				 
				 
				 


/////////////////////
// ALU             //
/////////////////////

alu_control alu_ctrl(
	.function_field (instruction_ID_EX_extended[5:0]),
   .alu_op         (alu_op          ),
   .alu_control    (alu_control     )
);
	
// 2 MUX's to select 1st ALU operand
mux_2 #(
   .DATA_W(32)
) alu_operand_mux (
	.input_a (regfile_data_1_ID_EX),
	.input_b (regfile_wdata    ),
	.select_a(forwardA[0]           ),
	.mux_out (mux1_out     )
);
mux_2 #(
   .DATA_W(32)
) alu_operand_mux (
	.input_a (mux1_out),
	.input_b (alu_result_EX_MEM    ),
	.select_a(forwardA[1]           ),
	.mux_out (alu_operand_1     )
);

// 3 MUX's to choose 2nd alu operand	
mux_2 #(
   .DATA_W(32)
) alu_operand_mux (
	.input_a (regfile_data_2_ID_EX),
	.input_b (regfile_wdata    ),
	.select_a(forwardB[0]           ),
	.mux_out (mux2_out     )
);
mux_2 #(
   .DATA_W(32)
) alu_operand_mux (
	.input_a (mux2_out),
	.input_b (alu_result_EX_MEM    ),
	.select_a(forwardA[1]           ),
	.mux_out (alu_operand_1     )
);	
mux_2 #(
   .DATA_W(32)
) alu_operand_mux (
	.input_a (mux_3_out),
	.input_b (instruction_ID_EX_extended),
   .select_a(alu_src           ),
   .mux_out (alu_operand_2     )
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

reg_arstn_en #(.DATA_W(32)) alu_result_EX_MEM(
      .clk   (clk       ),
      .arst_n(arst_n    ),
      .din   (alu_out),
      .en    (enable    ),
      .dout  (alu_result_EX_MEM)
);

reg_arstn_en #(.DATA_W(32)) alu_result_MEM_WB(
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
   .wen      (mem_write     ),
   .ren      (mem_read      ),
   .wdata    (regfile_data_2_EX_MEM),
   .rdata    (dram_data     ),   
   .addr_ext (addr_ext_2    ),
   .wen_ext  (wen_ext_2     ),
   .ren_ext  (ren_ext_2     ),
   .wdata_ext(wdata_ext_2   ),
   .rdata_ext(rdata_ext_2   )
);

// MEM WB dram data
reg_arstn_en #(.DATA_W(32)) dram_data_MEM_WB(
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
   .select_a (mem_2_reg     ),
   .mux_out  (regfile_wdata)
);


/////////////////////
// BRANCH          //
/////////////////////
//TODO

branch_unit#(
   .DATA_W(32)
)branch_unit(
   .updated_pc   (updated_pc        ),
   .instruction  (instruction       ),
   .branch_offset(immediate_extended),
   .branch_pc    (branch_pc         ),
   .jump_pc      (jump_pc         )
);


endmodule


