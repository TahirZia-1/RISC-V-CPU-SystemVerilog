module fetch_stage(
    input logic clk,
    input logic rst_n,
    input logic stall,
    input logic [31:0] pc_next,
    input logic branch_taken,
    input logic [31:0] branch_target,
    output logic [31:0] pc,
    output logic [31:0] pc_plus4,
    output logic [31:0] instruction
);
    // Program Counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0;
        end else if (!stall) begin
            if (branch_taken) begin
                pc <= branch_target;
            end else begin
                pc <= pc_plus4;
            end
        end
    end
    
    // PC + 4 adder
    assign pc_plus4 = pc + 32'd4;
    
    // Instruction Memory
    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );
    
endmodule

// Instruction Memory Module
module instruction_memory(
    input logic [31:0] address,
    output logic [31:0] instruction
);
    // ROM memory for instructions
    logic [31:0] mem [0:1023]; // 4KB instruction memory
    
    initial begin
        // Load program into instruction memory
        // This is where you would load your assembly program
        // For example:
        mem[0] = 32'h00500113; // addi x2, x0, 5
        mem[1] = 32'h00300193; // addi x3, x0, 3
        mem[2] = 32'h002081b3; // add x3, x1, x2
        mem[3] = 32'h40308233; // sub x4, x1, x3
        mem[4] = 32'h0041a023; // sw x4, 0(x3)
        // Add more instructions as needed
        
        // Fill the rest with NOPs
        for (int i = 5; i < 1024; i++) begin
            mem[i] = 32'h00000013; // NOP (addi x0, x0, 0)
        end
    end
    
    // Word-aligned memory access
    assign instruction = mem[address[31:2]];
    
endmodule