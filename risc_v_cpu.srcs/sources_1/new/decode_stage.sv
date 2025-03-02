module decode_stage(
    input logic clk,
    input logic rst_n,
    input logic [31:0] instruction,
    input logic [31:0] write_data,
    input logic [4:0] rd_addr_wb,
    input logic reg_write_wb,
    output logic [4:0] rs1_addr,
    output logic [4:0] rs2_addr,
    output logic [4:0] rd_addr,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] imm,
    output logic [3:0] alu_op,
    output logic alu_src,
    output logic mem_to_reg,
    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic branch,
    output logic jump
);
    // Instruction fields
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    // Extract instruction fields
    assign opcode = instruction[6:0];
    assign rd_addr = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign funct7 = instruction[31:25];
    
    // Register File
    register_file regfile (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr_wb),
        .write_data(write_data),
        .reg_write(reg_write_wb),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // Control Unit
    control_unit control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump)
    );
    
    // Immediate Generator
    immediate_gen immgen (
        .instruction(instruction),
        .imm(imm)
    );
    
endmodule

// Register File Module
module register_file(
    input logic clk,
    input logic rst_n,
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    input logic [4:0] rd_addr,
    input logic [31:0] write_data,
    input logic reg_write,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);
    // Register file with 32 32-bit registers
    logic [31:0] registers [0:31];
    
    // Read ports (asynchronous)
    assign rs1_data = (rs1_addr == 0) ? 32'h0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 0) ? 32'h0 : registers[rs2_addr];
    
    // Write port (synchronous)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'h0;
            end
        end else if (reg_write && rd_addr != 0) begin
            registers[rd_addr] <= write_data;
        end
    end
endmodule

// Control Unit Module
module control_unit(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    output logic [3:0] alu_op,
    output logic alu_src,
    output logic mem_to_reg,
    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic branch,
    output logic jump
);
    // RISC-V opcodes
    localparam LUI_OPCODE     = 7'b0110111;
    localparam AUIPC_OPCODE   = 7'b0010111;
    localparam JAL_OPCODE     = 7'b1101111;
    localparam JALR_OPCODE    = 7'b1100111;
    localparam BRANCH_OPCODE  = 7'b1100011;
    localparam LOAD_OPCODE    = 7'b0000011;
    localparam STORE_OPCODE   = 7'b0100011;
    localparam ARITHI_OPCODE  = 7'b0010011;
    localparam ARITH_OPCODE   = 7'b0110011;
    
    // Control signals based on opcode
    always_comb begin
        // Default values
        alu_op = 4'b0000;
        alu_src = 1'b0;
        mem_to_reg = 1'b0;
        reg_write = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        
        case (opcode)
            LUI_OPCODE: begin
                reg_write = 1'b1;
                alu_op = 4'b0001; // Pass immediate through ALU
                alu_src = 1'b1;
            end
            
            AUIPC_OPCODE: begin
                reg_write = 1'b1;
                alu_op = 4'b0010; // Add PC to immediate
                alu_src = 1'b1;
            end
            
            JAL_OPCODE: begin
                reg_write = 1'b1;
                jump = 1'b1;
                alu_op = 4'b0011; // PC+4
            end
            
            JALR_OPCODE: begin
                reg_write = 1'b1;
                jump = 1'b1;
                alu_src = 1'b1;
                alu_op = 4'b0100; // PC+4 and rs1+imm
            end
            
            BRANCH_OPCODE: begin
                branch = 1'b1;
                alu_op = 4'b0101; // Branch ALU op
            end
            
            LOAD_OPCODE: begin
                alu_src = 1'b1;
                mem_to_reg = 1'b1;
                reg_write = 1'b1;
                mem_read = 1'b1;
                alu_op = 4'b0110; // Address calculation
            end
            
            STORE_OPCODE: begin
                alu_src = 1'b1;
                mem_write = 1'b1;
                alu_op = 4'b0110; // Address calculation
            end
            
            ARITHI_OPCODE: begin
                alu_src = 1'b1;
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_op = 4'b0111; // ADDI
                    3'b010: alu_op = 4'b1000; // SLTI
                    3'b011: alu_op = 4'b1001; // SLTIU
                    3'b100: alu_op = 4'b1010; // XORI
                    3'b110: alu_op = 4'b1011; // ORI
                    3'b111: alu_op = 4'b1100; // ANDI
                    3'b001: alu_op = 4'b1101; // SLLI
                    3'b101: alu_op = (funct7[5]) ? 4'b1110 : 4'b1111; // SRAI or SRLI
                    default: alu_op = 4'b0000;
                endcase
            end
            
            ARITH_OPCODE: begin
                reg_write = 1'b1;
                case ({funct7[5], funct3})
                    4'b0000: alu_op = 4'b0111; // ADD
                    4'b1000: alu_op = 4'b0000; // SUB
                    4'b0001: alu_op = 4'b1101; // SLL
                    4'b0010: alu_op = 4'b1000; // SLT
                    4'b0011: alu_op = 4'b1001; // SLTU
                    4'b0100: alu_op = 4'b1010; // XOR
                    4'b0101: alu_op = 4'b1111; // SRL
                    4'b1101: alu_op = 4'b1110; // SRA
                    4'b0110: alu_op = 4'b1011; // OR
                    4'b0111: alu_op = 4'b1100; // AND
                    default: alu_op = 4'b0000;
                endcase
            end
            
            default: begin
                // Default values for other opcodes
                alu_op = 4'b0000;
                alu_src = 1'b0;
                mem_to_reg = 1'b0;
                reg_write = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                branch = 1'b0;
                jump = 1'b0;
            end
        endcase
    end
endmodule

// Immediate Generator Module
module immediate_gen(
    input logic [31:0] instruction,
    output logic [31:0] imm
);
    logic [6:0] opcode;
    
    assign opcode = instruction[6:0];
    
    always_comb begin
        case (opcode)
            // I-type instructions (JALR, LOAD, ARITHI)
            7'b1100111, 7'b0000011, 7'b0010011: 
                imm = {{20{instruction[31]}}, instruction[31:20]};
            
            // S-type instructions (STORE)
            7'b0100011: 
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            
            // B-type instructions (BRANCH)
            7'b1100011: 
                imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            
            // U-type instructions (LUI, AUIPC)
            7'b0110111, 7'b0010111: 
                imm = {instruction[31:12], 12'b0};
            
            // J-type instructions (JAL)
            7'b1101111: 
                imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            
            default: 
                imm = 32'h0;
        endcase
    end
endmodule