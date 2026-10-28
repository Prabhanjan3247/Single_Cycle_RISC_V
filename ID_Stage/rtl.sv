module id_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] wb_data,        // data to write back (from the WB stage)
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] imm_out,
    output logic [6:0]  opcode_out_d,
    output logic [6:0]  imm11_5,
    output logic [2:0]  fn3_out_d,
    output logic        fn7_5,
    output logic [2:0]  aluop,
    output logic [1:0]  memtoreg,
    output logic        branch,
    output logic        mem_write,
    output logic        mem_read,
    output logic        alu_src,
    output logic        mux_inp
);

    logic [4:0]  dec_rs1;
    logic [4:0]  dec_rs2;
    logic [4:0]  dec_rd;
    logic [6:0]  dec_opcode;
    logic [6:0]  dec_imm11_5;
    logic [2:0]  dec_fn3;
    logic [11:0] dec_imm;
    logic [19:0] dec_imm_uj;
    logic        dec_fn7_5;
    logic        mc_reg_write;
    logic        rf_reg_write;

    decoder u_decoder (
        .instruction (instruction),
        .rs1         (dec_rs1),
        .rs2         (dec_rs2),
        .rd          (dec_rd),
        .opcode      (dec_opcode),
        .imm11_5     (dec_imm11_5),
        .fn3         (dec_fn3),
        .imm         (dec_imm),
        .imm_uj      (dec_imm_uj),
        .fn7_5       (dec_fn7_5)
    );

    imm_generator u_imm_generator (
        .imm_input    (dec_imm),
        .fn3          (dec_fn3),
        .opcode       (dec_opcode),
        .imm_input_uj (dec_imm_uj),
        .imm_output   (imm_out)
    );

    main_control u_main_control (
        .opcode    (dec_opcode),
        .fn3       (dec_fn3),
        .memtoreg  (memtoreg),
        .branch    (branch),
        .mux_inp   (mux_inp),
        .memread   (mem_read),
        .memwrite  (mem_write),
        .alusrc    (alu_src),
        .reg_write (mc_reg_write),
        .aluop     (aluop)
    );

    assign rf_reg_write = mc_reg_write && (!stall);

    register_file u_register_file (
        .rs1_sel   (dec_rs1),
        .rs2_sel   (dec_rs2),
        .reg_write (rf_reg_write),
        .clk       (clk),
        .reset     (reset),
        .wb_data   (wb_data),
        .rd_sel    (dec_rd),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );

    assign opcode_out_d = dec_opcode;
    assign imm11_5      = dec_imm11_5;
    assign fn3_out_d    = dec_fn3;
    assign fn7_5        = dec_fn7_5;

endmodule

