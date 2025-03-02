module writeback_stage(
    input logic [31:0] alu_result,
    input logic [31:0] memory_data,
    input logic [31:0] pc_plus4,
    input logic mem_to_reg,
    output logic [31:0] write_data
);
    // Writeback MUX
    assign write_data = mem_to_reg ? memory_data : alu_result;
endmodule
