// Forwarding Unit
module forwarding_unit(
    input logic [4:0] rs1_addr_execute,
    input logic [4:0] rs2_addr_execute,
    input logic [4:0] rd_addr_memory,
    input logic [4:0] rd_addr_writeback,
    input logic reg_write_memory,
    input logic reg_write_writeback,
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);
    // Forward from MEM stage for rs1
    always_comb begin
        if (reg_write_memory && (rd_addr_memory != 5'b0) && 
            (rd_addr_memory == rs1_addr_execute)) begin
            forward_a = 2'b10; // Forward from MEM stage
        end else if (reg_write_writeback && (rd_addr_writeback != 5'b0) && 
                    (rd_addr_writeback == rs1_addr_execute)) begin
            forward_a = 2'b01; // Forward from WB stage
        end else begin
            forward_a = 2'b00; // No forwarding
        end
    end
    
    // Forward from MEM stage for rs2
    always_comb begin
        if (reg_write_memory && (rd_addr_memory != 5'b0) && 
            (rd_addr_memory == rs2_addr_execute)) begin
            forward_b = 2'b10; // Forward from MEM stage
        end else if (reg_write_writeback && (rd_addr_writeback != 5'b0) && 
                    (rd_addr_writeback == rs2_addr_execute)) begin
            forward_b = 2'b01; // Forward from WB stage
        end else begin
            forward_b = 2'b00; // No forwarding
        end
    end
endmodule