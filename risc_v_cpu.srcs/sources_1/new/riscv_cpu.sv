module riscv_cpu(
    input logic clk,
    input logic rst_n,
    output logic [31:0] pc_current
);
    // Pipeline stage signals
    logic [31:0] pc_fetch, pc_plus4_fetch;
    logic [31:0] instruction_fetch;
    
    // IF/ID pipeline registers
    logic [31:0] pc_decode, pc_plus4_decode;
    logic [31:0] instruction_decode;
    
    // ID stage signals
    logic [4:0] rs1_addr, rs2_addr, rd_addr_decode;
    logic [31:0] rs1_data, rs2_data;
    logic [31:0] imm_decode;
    logic [3:0] alu_op_decode;
    logic alu_src_decode, mem_to_reg_decode, reg_write_decode;
    logic mem_read_decode, mem_write_decode;
    logic branch_decode, jump_decode;
    
    // ID/EX pipeline registers
    logic [31:0] pc_execute, pc_plus4_execute;
    logic [31:0] rs1_data_execute, rs2_data_execute;
    logic [31:0] imm_execute;
    logic [4:0] rs1_addr_execute, rs2_addr_execute, rd_addr_execute;
    logic [3:0] alu_op_execute;
    logic alu_src_execute, mem_to_reg_execute, reg_write_execute;
    logic mem_read_execute, mem_write_execute;
    logic branch_execute, jump_execute;
    
    // EX stage signals
    logic [31:0] alu_result_execute;
    logic [31:0] branch_target_execute;
    logic branch_taken_execute;
    logic [31:0] alu_operand2_mux;
    
    // EX/MEM pipeline registers
    logic [31:0] pc_plus4_memory;
    logic [31:0] alu_result_memory;
    logic [31:0] rs2_data_memory;
    logic [4:0] rd_addr_memory;
    logic mem_to_reg_memory, reg_write_memory;
    logic mem_read_memory, mem_write_memory;
    
    // MEM stage signals
    logic [31:0] memory_read_data;
    
    // MEM/WB pipeline registers
    logic [31:0] pc_plus4_writeback;
    logic [31:0] alu_result_writeback;
    logic [31:0] memory_read_data_writeback;
    logic [4:0] rd_addr_writeback;
    logic mem_to_reg_writeback, reg_write_writeback;
    
    // WB stage signals
    logic [31:0] write_data_writeback;
    
    // Hazard detection and forwarding units
    logic stall, flush;
    logic [1:0] forward_a, forward_b;
    
    // PC update for branch/jump
    logic [31:0] pc_next;
    
    // Output current PC
    assign pc_current = pc_fetch;
    
    // Instantiate the pipeline stages and components
    
    // Fetch Stage
    fetch_stage fetch (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .pc_next(pc_next),
        .branch_taken(branch_taken_execute),
        .branch_target(branch_target_execute),
        .pc(pc_fetch),
        .pc_plus4(pc_plus4_fetch),
        .instruction(instruction_fetch)
    );
    
    // IF/ID Pipeline Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_decode <= 32'h0;
            pc_plus4_decode <= 32'h0;
            instruction_decode <= 32'h0;
        end else if (flush) begin
            pc_decode <= 32'h0;
            pc_plus4_decode <= 32'h0;
            instruction_decode <= 32'h0;
        end else if (!stall) begin
            pc_decode <= pc_fetch;
            pc_plus4_decode <= pc_plus4_fetch;
            instruction_decode <= instruction_fetch;
        end
    end
    
    // Decode Stage
    decode_stage decode (
        .clk(clk),
        .rst_n(rst_n),
        .instruction(instruction_decode),
        .write_data(write_data_writeback),
        .rd_addr_wb(rd_addr_writeback),
        .reg_write_wb(reg_write_writeback),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr_decode),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm(imm_decode),
        .alu_op(alu_op_decode),
        .alu_src(alu_src_decode),
        .mem_to_reg(mem_to_reg_decode),
        .reg_write(reg_write_decode),
        .mem_read(mem_read_decode),
        .mem_write(mem_write_decode),
        .branch(branch_decode),
        .jump(jump_decode)
    );
    
    // ID/EX Pipeline Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_execute <= 32'h0;
            pc_plus4_execute <= 32'h0;
            rs1_data_execute <= 32'h0;
            rs2_data_execute <= 32'h0;
            imm_execute <= 32'h0;
            rs1_addr_execute <= 5'h0;
            rs2_addr_execute <= 5'h0;
            rd_addr_execute <= 5'h0;
            alu_op_execute <= 4'h0;
            alu_src_execute <= 1'b0;
            mem_to_reg_execute <= 1'b0;
            reg_write_execute <= 1'b0;
            mem_read_execute <= 1'b0;
            mem_write_execute <= 1'b0;
            branch_execute <= 1'b0;
            jump_execute <= 1'b0;
        end else begin
            pc_execute <= pc_decode;
            pc_plus4_execute <= pc_plus4_decode;
            rs1_data_execute <= rs1_data;
            rs2_data_execute <= rs2_data;
            imm_execute <= imm_decode;
            rs1_addr_execute <= rs1_addr;
            rs2_addr_execute <= rs2_addr;
            rd_addr_execute <= rd_addr_decode;
            alu_op_execute <= alu_op_decode;
            alu_src_execute <= alu_src_decode;
            mem_to_reg_execute <= mem_to_reg_decode;
            reg_write_execute <= reg_write_decode;
            mem_read_execute <= mem_read_decode;
            mem_write_execute <= mem_write_decode;
            branch_execute <= branch_decode;
            jump_execute <= jump_decode;
        end
    end
    
    // Execute Stage
    execute_stage execute (
        .pc(pc_execute),
        .rs1_data(rs1_data_execute),
        .rs2_data(rs2_data_execute),
        .imm(imm_execute),
        .alu_op(alu_op_execute),
        .alu_src(alu_src_execute),
        .branch(branch_execute),
        .jump(jump_execute),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .alu_result_mem(alu_result_memory),
        .write_data_wb(write_data_writeback),
        .alu_result(alu_result_execute),
        .branch_target(branch_target_execute),
        .branch_taken(branch_taken_execute)
    );
    
    // EX/MEM Pipeline Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_plus4_memory <= 32'h0;
            alu_result_memory <= 32'h0;
            rs2_data_memory <= 32'h0;
            rd_addr_memory <= 5'h0;
            mem_to_reg_memory <= 1'b0;
            reg_write_memory <= 1'b0;
            mem_read_memory <= 1'b0;
            mem_write_memory <= 1'b0;
        end else begin
            pc_plus4_memory <= pc_plus4_execute;
            alu_result_memory <= alu_result_execute;
            rs2_data_memory <= rs2_data_execute;
            rd_addr_memory <= rd_addr_execute;
            mem_to_reg_memory <= mem_to_reg_execute;
            reg_write_memory <= reg_write_execute;
            mem_read_memory <= mem_read_execute;
            mem_write_memory <= mem_write_execute;
        end
    end
    
    // Memory Stage
    memory_stage memory (
        .clk(clk),
        .rst_n(rst_n),
        .address(alu_result_memory),
        .write_data(rs2_data_memory),
        .mem_read(mem_read_memory),
        .mem_write(mem_write_memory),
        .read_data(memory_read_data)
    );
    
    // MEM/WB Pipeline Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_plus4_writeback <= 32'h0;
            alu_result_writeback <= 32'h0;
            memory_read_data_writeback <= 32'h0;
            rd_addr_writeback <= 5'h0;
            mem_to_reg_writeback <= 1'b0;
            reg_write_writeback <= 1'b0;
        end else begin
            pc_plus4_writeback <= pc_plus4_memory;
            alu_result_writeback <= alu_result_memory;
            memory_read_data_writeback <= memory_read_data;
            rd_addr_writeback <= rd_addr_memory;
            mem_to_reg_writeback <= mem_to_reg_memory;
            reg_write_writeback <= reg_write_memory;
        end
    end
    
    // Writeback Stage
    writeback_stage writeback (
        .alu_result(alu_result_writeback),
        .memory_data(memory_read_data_writeback),
        .pc_plus4(pc_plus4_writeback),
        .mem_to_reg(mem_to_reg_writeback),
        .write_data(write_data_writeback)
    );
    
    // Hazard Detection Unit
    hazard_detection hazard (
        .rs1_addr_decode(rs1_addr),
        .rs2_addr_decode(rs2_addr),
        .rd_addr_execute(rd_addr_execute),
        .mem_read_execute(mem_read_execute),
        .branch_taken(branch_taken_execute),
        .stall(stall),
        .flush(flush)
    );
    
    // Forwarding Unit
    forwarding_unit forwarding (
        .rs1_addr_execute(rs1_addr_execute),
        .rs2_addr_execute(rs2_addr_execute),
        .rd_addr_memory(rd_addr_memory),
        .rd_addr_writeback(rd_addr_writeback),
        .reg_write_memory(reg_write_memory),
        .reg_write_writeback(reg_write_writeback),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );
    
endmodule