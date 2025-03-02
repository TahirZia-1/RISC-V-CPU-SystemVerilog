// Hazard Detection Unit
module hazard_detection(
    input logic [4:0] rs1_addr_decode,
    input logic [4:0] rs2_addr_decode,
    input logic [4:0] rd_addr_execute,
    input logic mem_read_execute,
    input logic branch_taken,
    output logic stall,
    output logic flush
);
    // Load-use hazard detection
    always_comb begin
        // Stall if we're trying to use a register that will be loaded in the next cycle
        if (mem_read_execute && 
            ((rs1_addr_decode == rd_addr_execute) || 
             (rs2_addr_decode == rd_addr_execute)) &&
            (rd_addr_execute != 5'b0)) begin
            stall = 1'b1;
        end else begin
            stall = 1'b0;
        end
        
        // Flush the pipeline on branch taken
        flush = branch_taken;
    end
endmodule