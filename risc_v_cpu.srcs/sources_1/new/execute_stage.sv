module execute_stage(
    input logic [31:0] pc,
    input logic [31:0] rs1_data,
    input logic [31:0] rs2_data,
    input logic [31:0] imm,
    input logic [3:0] alu_op,
    input logic alu_src,
    input logic branch,
    input logic jump,
    input logic [1:0] forward_a,
    input logic [1:0] forward_b,
    input logic [31:0] alu_result_mem,
    input logic [31:0] write_data_wb,
    output logic [31:0] alu_result,
    output logic [31:0] branch_target,
    output logic branch_taken
);
    logic [31:0] alu_input1, alu_input2, forwarded_rs2;
    logic zero, less_than;
    
    // Forwarding MUX for ALU input 1
    always_comb begin
        case (forward_a)
            2'b00: alu_input1 = rs1_data;
            2'b01: alu_input1 = write_data_wb;
            2'b10: alu_input1 = alu_result_mem;
            default: alu_input1 = rs1_data;
        endcase
    end
    
    // Forwarding MUX for rs2
    always_comb begin
        case (forward_b)
            2'b00: forwarded_rs2 = rs2_data;
            2'b01: forwarded_rs2 = write_data_wb;
            2'b10: forwarded_rs2 = alu_result_mem;
            default: forwarded_rs2 = rs2_data;
        endcase
    end
    
    // ALU source MUX
    assign alu_input2 = alu_src ? imm : forwarded_rs2;
    
    // ALU
    alu alu_unit (
        .alu_op(alu_op),
        .operand1(alu_input1),
        .operand2(alu_input2),
        .result(alu_result),
        .zero(zero),
        .less_than(less_than)
    );
    
    // Branch target calculation
    assign branch_target = pc + imm;
    
    // Branch decision
    always_comb begin
        if (jump) begin
            branch_taken = 1'b1;
        end else if (branch) begin
            case (alu_op)
                4'b0101: branch_taken = zero;     // BEQ
                4'b0110: branch_taken = ~zero;    // BNE
                4'b0111: branch_taken = less_than; // BLT
                4'b1000: branch_taken = ~less_than; // BGE
                default: branch_taken = 1'b0;
            endcase
        end else begin
            branch_taken = 1'b0;
        end
    end
endmodule

// ALU Module
module alu(
    input logic [3:0] alu_op,
    input logic [31:0] operand1,
    input logic [31:0] operand2,
    output logic [31:0] result,
    output logic zero,
    output logic less_than
);
    always_comb begin
        case (alu_op)
            4'b0000: result = operand1 - operand2;                  // SUB
            4'b0001: result = operand2;                            // Pass through operand2 (LUI)
            4'b0010: result = operand1 + operand2;                 // AUIPC
            4'b0011: result = operand1 + 4;                        // JAL (PC+4)
            4'b0100: result = operand1 + operand2;                 // JALR
            4'b0101: result = operand1 - operand2;                 // Branch comparison
            4'b0110: result = operand1 + operand2;                 // Load/Store address
            4'b0111: result = operand1 + operand2;                 // ADD/ADDI
            4'b1000: result = $signed(operand1) < $signed(operand2) ? 32'h1 : 32'h0; // SLT/SLTI
            4'b1001: result = operand1 < operand2 ? 32'h1 : 32'h0;                   // SLTU/SLTIU
            4'b1010: result = operand1 ^ operand2;                 // XOR/XORI
            4'b1011: result = operand1 | operand2;                 // OR/ORI
            4'b1100: result = operand1 & operand2;                 // AND/ANDI
            4'b1101: result = operand1 << operand2[4:0];           // SLL/SLLI
            4'b1110: result = $signed(operand1) >>> operand2[4:0]; // SRA/SRAI
            4'b1111: result = operand1 >> operand2[4:0];           // SRL/SRLI
            default: result = 32'h0;
        endcase
    end
    
    // Zero flag and less than flag
    assign zero = (result == 32'h0);
    assign less_than = (alu_op == 4'b1000) ? $signed(operand1) < $signed(operand2) : 
                       (alu_op == 4'b1001) ? operand1 < operand2 : 1'b0;
endmodule