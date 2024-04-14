//Project 2: Superscalar & Out-of-Order
//Max Destil
//RIN: 662032859

//Memory Unit

module memory_unit(
    input logic clk,
    input logic reset,
    input logic [31:0] memory_address, // Address for read/write
    input logic start_memory_read, // Enable signal for read operations
    input logic start_memory_write, // Enable signal for write operations
    input logic [31:0] memory_write_data, // Data to write for store operations
    input logic [4:0] rd, 
    input logic memory_reset_write_enable_flag,
    input logic reset_read_memory_operation_complete, reset_write_memory_operation_complete,
    
    output logic reset_instruction_in_progress_memory_read,
    output logic reset_instruction_in_progress_memory_write,
    output logic [31:0] memory_read_data, // Data output for load operations
    output logic load_busy,
    output logic store_busy,
    output logic [4:0] memory_write_dest, 
    output logic memory_write_enable,
    output logic read_memory_operation_started,
    output logic write_memory_operation_started,
    output logic read_memory_operation_complete, // Signal when the read operation is complete
    output logic write_memory_operation_complete, // Signal when the write operation is complete
    output logic read_memory_reset_operation_complete,
    output logic write_memory_reset_operation_complete,
    output logic reset_enable_flag3
);

    localparam MEM_SIZE = 1024; 
    logic [31:0] memory[MEM_SIZE-1:0];

    // Volatile variables
    logic [1:0] cycle_counter; // Counter to track the 2-cycle latency
    logic load_operation_in_progress; // Flag to indicate operation is ongoing
    logic store_operation_in_progress; // Flag to indicate operation is ongoing
    logic read_memory_enable_flag, write_memory_enable_flag;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset logic including memory_operation_complete
            cycle_counter <= 3'd0;
            load_operation_in_progress <= 0;
            store_operation_in_progress <= 0;
            reset_instruction_in_progress_memory_read <= 0;
            reset_instruction_in_progress_memory_write <= 0;
            memory_read_data <= 32'b0;
            load_busy <= 0;
            memory_write_dest <= 5'b0;
            memory_write_enable <= 0;
            store_busy <= 0;
            read_memory_operation_started <= 0;
            write_memory_operation_started <= 0;
            read_memory_operation_complete <= 0;
            write_memory_operation_complete <= 0;
            read_memory_reset_operation_complete <= 0;
            write_memory_reset_operation_complete <= 0;
            reset_enable_flag3 <= 0;
            read_memory_enable_flag <= 0;
            write_memory_enable_flag <= 0;
            for (int i = 0; i < 1024; i++) begin
                memory[i] <= 32'b0; // Set unused registers to 0 
            end
            memory[6] <= 32'hFEEDBEEF; //pre-set value to initiate the initial load instruction
        end else begin
            // From dispatch unit to memory 
            if (start_memory_read && !load_busy && !read_memory_enable_flag) begin
                read_memory_enable_flag <= 1;
                load_operation_in_progress <= 1;
                reset_instruction_in_progress_memory_read <= 1;
                load_busy <= 1;
                memory_read_data <= memory[memory_address];
                memory_write_dest <= rd; // Set the destination register for the result
                read_memory_reset_operation_complete <= 0;
                reset_enable_flag3 <= 0;
                cycle_counter <= 3'd2; // Set the cycle count for the operation
            end else if (start_memory_write && !store_busy && !write_memory_enable_flag) begin
                write_memory_enable_flag <= 1;
                store_operation_in_progress <= 1;
                reset_instruction_in_progress_memory_write <= 1;
                store_busy <= 1;
                memory[memory_address] <= memory_write_data;
                write_memory_reset_operation_complete <= 0;
                cycle_counter <= 3'd2; // Set the cycle count for the operation
            end else if(load_operation_in_progress) begin
                read_memory_operation_started <= 1;
                // Decrement the cycle counter each clock cycle
                if (cycle_counter > 1) begin
                    cycle_counter <= cycle_counter - 1;
                end else begin
                    // Operation completes after 2 cycles
                    load_operation_in_progress <= 0;
                    reset_instruction_in_progress_memory_read <= 0;
                    load_busy <= 0; 
                    memory_write_enable <= 1;
                    read_memory_operation_complete <= 1; // Indicate operation complete
                end
            end else if(store_operation_in_progress) begin
                write_memory_operation_started <= 1;
                // Decrement the cycle counter each clock cycle
                if (cycle_counter > 1) begin
                    cycle_counter <= cycle_counter - 1;
                end else begin
                    // Operation completes after 2 cycles
                    store_operation_in_progress <= 0;
                    reset_instruction_in_progress_memory_write <= 0;
                    store_busy <= 0; 
                    write_memory_operation_complete <= 1; // Indicate operation complete
                end
            end else if(memory_reset_write_enable_flag) begin
                memory_write_enable <= 0;
                reset_enable_flag3 <= 1;
            end else if(reset_read_memory_operation_complete) begin
                read_memory_enable_flag <= 0;
                read_memory_operation_started <= 0;
                read_memory_operation_complete <= 0;
                read_memory_reset_operation_complete <= 1;
            end else if(reset_write_memory_operation_complete) begin
                write_memory_enable_flag <= 0;
                write_memory_operation_started <= 0;
                write_memory_operation_complete <= 0;
                write_memory_reset_operation_complete <= 1;
            end
        end
    end
endmodule