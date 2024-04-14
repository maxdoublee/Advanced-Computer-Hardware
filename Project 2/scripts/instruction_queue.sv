//Project 2: Superscalar & Out-of-Order
//Max Destil
//RIN: 662032859

//Instruction Queue

module instruction_queue(
    input logic clk,
    input logic reset,
    input logic queue_advance, // Signal to advance the instruction queue from testbench

    output logic [31:0] instruction_out1, // First instruction output per cycle
    output logic [31:0] instruction_out2, // Second instruction output per cycle
    output logic valid_out1, // Valid flag for the first instruction
    output logic valid_out2, // Valid flag for the second instruction
    output logic queue_empty // Flag to indicate instructions have ran out
);

    // Pre-stored instructions array for simulation
    logic [31:0] instruction_memory[0:19]; 

    // Internal pointer to manage queue progression
    logic [18:0] read_pointer;

    // Pre-stored Instructions

    initial begin
        // Encoding format (Starting LSB): opcode | rd | funct3 | rs1 | rs2 | funct7
        instruction_memory[0] = 32'b0000000_00010_00001_000_00011_0110011; // ADD instruction
        instruction_memory[1] = 32'b0000001_00100_00010_000_00100_0110011; // MUL instruction
        instruction_memory[2] = 32'b0000000_00010_00001_000_00011_0110011; // ADD instruction
        instruction_memory[3] = 32'b000000000000_00000_000_00000_0010011; // NOP instruction
        instruction_memory[4] = 32'b0000001_00100_00010_000_00100_0110011; // MUL instruction
        instruction_memory[5] = 32'b000000000000_00000_000_00000_0010011; // NOP instruction
        instruction_memory[6] = 32'b0000000_00010_00001_000_00011_0110011; // ADD instruction
        instruction_memory[7] = 32'b0000001_00100_00010_000_00100_0110011; // MUL instruction
        instruction_memory[8] = 32'b000000000100_00101_010_01010_0000011; // LOAD instruction
        instruction_memory[9] = 32'b000000000000_00000_000_00000_0010011; // NOP instruction
        instruction_memory[10] = 32'b0000000_01010_00101_010_00000_0100011; // STORE instruction
        instruction_memory[11] = 32'b000000000000_00000_000_00000_0010011; // NOP instruction
        instruction_memory[12] = 32'b000000000100_00101_010_01010_0000011; // LOAD instruction
        instruction_memory[13] = 32'b0000000_01010_00101_010_00000_0100011; // STORE instruction
        instruction_memory[14] = 32'b0000000_01010_00101_010_00000_0100011; // STORE instruction
        instruction_memory[15] = 32'b000000000100_00101_010_01010_0000011; // LOAD instruction
        instruction_memory[16] = 32'b0000000_01010_00101_010_00000_0100011; // STORE instruction
        instruction_memory[17] = 32'b0000000_01010_00101_010_00000_0100011; // STORE instruction
        instruction_memory[18] = 32'b000000000000_00000_000_00000_0010011; // NOP instruction
        instruction_memory[19] = 32'b000000000000_00000_000_00000_0010011; // NOP instruction
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction_out1 <= 32'b0;
            instruction_out2 <= 32'b0;
            valid_out1 <= 0;
            valid_out1 <= 0;
            read_pointer <= 0;
            queue_empty <= 0;
        end else begin
            // Only proceed if we are advancing the queue
            if (queue_advance) begin 
                // On each clock cycle, output two instructions
                if (read_pointer < 20) begin 
                    instruction_out1 <= instruction_memory[read_pointer]; 
                    instruction_out2 <= instruction_memory[read_pointer + 1]; 
                    valid_out1 <= 1;
                    valid_out2 <= 1;
                    read_pointer <= read_pointer + 2; // Advance the read pointer
                end else begin // No instructions left
                    valid_out1 <= 0;
                    valid_out2 <= 0;
                    queue_empty <= 1; //Simulation ends because instructions ran out
                end
            end 
        end
    end
endmodule