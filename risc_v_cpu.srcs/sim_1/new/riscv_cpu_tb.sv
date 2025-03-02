module riscv_cpu_tb();
    // Testbench signals
    logic clk;
    logic rst_n;
    logic [31:0] pc_current;
    
    // Instantiate the RISC-V CPU
    riscv_cpu dut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_current(pc_current)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Test sequence
    initial begin
        // Reset the CPU
        rst_n = 0;
        #20;
        rst_n = 1;
        
        // Run the simulation for 100 cycles
        repeat(100) @(posedge clk);
        
        $display("Simulation completed");
        $finish;
    end
    
    // Monitor important signals
    initial begin
        $monitor("Time=%0t, PC=%h, Instruction=%h", 
                 $time, pc_current, dut.instruction_fetch);
    end
endmodule