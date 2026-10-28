module alu #(
    parameter int DATA_WIDTH = 32
)(
    input  logic [4:0]            alu_control,
    input  logic [DATA_WIDTH-1:0] rs1_data,
    input  logic [DATA_WIDTH-1:0] rs2_data,
    output logic [DATA_WIDTH-1:0] alu_out,
    output logic                  zero          // branch condition true
);

    always_comb begin
        alu_out = '0;
        zero    = 1'b0;

        case (alu_control)
            5'd0: begin // ADD
                alu_out = rs1_data + rs2_data;
                zero    = 1'b0;
            end

            5'd1: begin // SUB
                alu_out = rs1_data - rs2_data;
                zero    = 1'b0;
            end

            5'd2: begin // XOR
                alu_out = rs1_data ^ rs2_data;
                zero    = 1'b0;
            end

            5'd3: begin // OR
                alu_out = rs1_data | rs2_data;
                zero    = 1'b0;
            end

            5'd4: begin // AND
                alu_out = rs1_data & rs2_data;
                zero    = 1'b0;
            end

            5'd5: begin // SLL
                alu_out = rs1_data << rs2_data[4:0];
                zero    = 1'b0;
            end

            5'd6: begin // SRL
                alu_out = rs1_data >> rs2_data[4:0];
                zero    = 1'b0;
            end

            5'd7: begin // SRA
                alu_out = signed'(rs1_data) >>> rs2_data[4:0];
                zero    = 1'b0;
            end

            5'd8: begin // SLT
                alu_out = (signed'(rs1_data) < signed'(rs2_data)) ? {{(DATA_WIDTH-1){1'b0}}, 1'b1} : '0;
                zero    = 1'b0;
            end

            5'd9: begin // SLTU
                alu_out = (rs1_data < rs2_data) ? {{(DATA_WIDTH-1){1'b0}}, 1'b1} : '0;
                zero    = 1'b0;
            end

            5'd10: begin // BEQ
                alu_out = '0;
                zero    = (rs1_data == rs2_data);
            end

            5'd11: begin // BNE
                alu_out = '0;
                zero    = (rs1_data != rs2_data);
            end

            5'd12: begin // BLT
                alu_out = '0;
                zero    = (signed'(rs1_data) < signed'(rs2_data));
            end

            5'd13: begin // BGE
                alu_out = '0;
                zero    = (signed'(rs1_data) >= signed'(rs2_data));
            end

            5'd14: begin // BLTU
                alu_out = '0;
                zero    = (rs1_data < rs2_data);
            end

            5'd15: begin // BGEU
                alu_out = '0;
                zero    = (rs1_data >= rs2_data);
            end

            default: begin
                alu_out = '0;
                zero    = 1'b0;
            end
        endcase
    end

endmodule

