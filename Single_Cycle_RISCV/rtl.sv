module single_cycle_riscv (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,   // from instruction memory (addressed by `address`)
    input  logic [31:0] mem_out,       // from data memory
    output logic [31:0] rs2_data,      // store data
    output logic [31:0] alu_out,       // data memory address
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,           // load / store width
    output logic [6:0]  opcode,
    output logic [31:0] address        // PC
);

    // IF stage signals
    logic [31:0] pc_new;

    // ID stage signals
    logic [31:0] rs1_data_id;
    logic [31:0] rs2_data_id;
    logic [31:0] imm_out_id;
    logic [6:0]  opcode_id;
    logic [6:0]  imm11_5_id;
    logic [2:0]  fn3_id;
    logic        fn7_5_id;
    logic [2:0]  aluop_id;
    logic [1:0]  memtoreg_id;
    logic        branch_id;
    logic        mem_write_id;
    logic        mem_read_id;
    logic        alu_src_id;
    logic        mux_inp_id;

    // EX stage signals
    logic        and_out_ex;
    logic [31:0] alu_out_ex;
    logic [31:0] pc_ex_out;

    // WB stage signals
    logic [31:0] wb_data;

    // 1. IF Stage
    if_stage u_if_stage (
        .clk              (clk),
        .reset            (reset),
        .stall            (stall),
        .and_out          (and_out_ex),
        .pc_signed_offset (pc_ex_out),
        .address          (address),
        .pc_new           (pc_new)
    );

    // 2. ID Stage
    id_stage u_id_stage (
        .clk          (clk),
        .reset        (reset),
        .stall        (stall),
        .instruction  (instruction),
        .wb_data      (wb_data),
        .rs1_data     (rs1_data_id),
        .rs2_data     (rs2_data_id),
        .imm_out      (imm_out_id),
        .opcode_out_d (opcode_id),
        .imm11_5      (imm11_5_id),
        .fn3_out_d    (fn3_id),
        .fn7_5        (fn7_5_id),
        .aluop        (aluop_id),
        .memtoreg     (memtoreg_id),
        .branch       (branch_id),
        .mem_write    (mem_write_id),
        .mem_read     (mem_read_id),
        .alu_src      (alu_src_id),
        .mux_inp      (mux_inp_id)
    );

    // 3. EX Stage
    ex_stage u_ex_stage (
        .rs1_data   (rs1_data_id),
        .rs2_data   (rs2_data_id),
        .imm_out    (imm_out_id),
        .address    (address),
        .branch     (branch_id),
        .alu_src    (alu_src_id),
        .fn7_5      (fn7_5_id),
        .mux_inp    (mux_inp_id),
        .fn3        (fn3_id),
        .imm11_5    (imm11_5_id),
        .aluop      (aluop_id),
        .opcode     (opcode_id),
        .and_out_ex (and_out_ex),
        .alu_out    (alu_out_ex),
        .pc_ex_out  (pc_ex_out)
    );

    // 4. WB Stage
    wb_stage u_wb_stage (
        .mem_out          (mem_out),
        .alu_out          (alu_out_ex),
        .return_addr      (pc_new),
        .imm_out          (imm_out_id),
        .pc_signed_offset (pc_ex_out),
        .memtoreg         (memtoreg_id),
        .opcode_out_d     (opcode_id),
        .wb_data          (wb_data)
    );

    // Core outputs
    assign rs2_data  = rs2_data_id;
    assign alu_out   = alu_out_ex;
    assign mem_write = mem_write_id;
    assign mem_read  = mem_read_id;
    assign fn3       = fn3_id;
    assign opcode    = opcode_id;

endmodule

