module memory_stage(
    input logic clk,
    input logic rst_n,
    input logic [31:0] address,
    input logic [31:0] write_data,
    input logic mem_read,
    input logic mem_write,
    output logic [31:0] read_data
);
    // Data Memory
    data_memory dmem (
        .clk(clk),
        .rst_n(rst_n),
        .address(address),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(read_data)
    );
endmodule

// Data Memory Module
module data_memory(
    input logic clk,
    input logic rst_n,
    input logic [31:0] address,
    input logic [31:0] write_data,
    input logic mem_read,
    input logic mem_write,
    output logic [31:0] read_data
);
    // 4KB data memory
    logic [31:0] mem [0:1023];
    
    // Initialize memory
    initial begin
        for (int i = 0; i < 1024; i++) begin
            mem[i] = 32'h0;
        end
    end
    
    // Memory read (asynchronous read)
    assign read_data = mem_read ? mem[address[31:2]] : 32'h0;
    
    // Memory write (synchronous write)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 1024; i++) begin
                mem[i] <= 32'h0;
            end
        end else if (mem_write) begin
            mem[address[31:2]] <= write_data;
        end
    end
endmodule
