module alu_control (
    input  logic [2:0] alu_op,        // operation class from main_control
    input  logic [2:0] fn3,
    input  logic [6:0] imm11_5,       // instruction[31:25]: shift qualifier (I-type)
    input  logic       fn7_5,         // instruction[30]: SUB / SRA qualifier (R-type)
    output logic [4:0] control_out
);

    always_comb begin
        case (alu_op)
            3'b000: begin // R-type
                case (fn3)
                    3'b000:  control_out = fn7_5 ? 5'd1 : 5'd0; // SUB / ADD
                    3'b001:  control_out = 5'd5;                // SLL
                    3'b010:  control_out = 5'd8;                // SLT
                    3'b011:  control_out = 5'd9;                // SLTU
                    3'b100:  control_out = 5'd2;                // XOR
                    3'b101:  control_out = fn7_5 ? 5'd7 : 5'd6; // SRA / SRL
                    3'b110:  control_out = 5'd3;                // OR
                    3'b111:  control_out = 5'd4;                // AND
                    default: control_out = 5'd0;
                endcase
            end

            3'b001: begin // I-type ALU
                case (fn3)
                    3'b000:  control_out = 5'd0;                // ADDI
                    3'b001:  control_out = 5'd5;                // SLLI
                    3'b010:  control_out = 5'd8;                // SLTI
                    3'b011:  control_out = 5'd9;                // SLTIU
                    3'b100:  control_out = 5'd2;                // XORI
                    3'b101:  control_out = (imm11_5 == 7'h20) ? 5'd7 : 5'd6; // SRAI / SRLI
                    3'b110:  control_out = 5'd3;                // ORI
                    3'b111:  control_out = 5'd4;                // ANDI
                    default: control_out = 5'd0;
                endcase
            end

            3'b010: control_out = 5'd0; // Load -> ADD
            3'b011: control_out = 5'd0; // Store -> ADD

            3'b100: begin // Branch
                case (fn3)
                    3'b000:  control_out = 5'd10; // BEQ
                    3'b001:  control_out = 5'd11; // BNE
                    3'b100:  control_out = 5'd12; // BLT
                    3'b101:  control_out = 5'd13; // BGE
                    3'b110:  control_out = 5'd14; // BLTU
                    3'b111:  control_out = 5'd15; // BGEU
                    default: control_out = 5'd0;  // other fn3: ADD
                endcase
            end

            3'b110: control_out = 5'd0; // JAL / LUI -> ADD

            default: control_out = 5'd0; // other -> ADD
        endcase
    end

endmodule

