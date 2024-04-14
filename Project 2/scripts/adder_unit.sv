//Project 2: Superscalar & Out-of-Order
//Max Destil
//RIN: 662032859

//Adder Functional Unit

module adder_unit(
    input logic clk,
    input logic reset,
    input logic start,
    input logic [4:0] rd, 
    input logic [31:0] operand_a, operand_b,
    input logic adder_reset_write_enable_flag,
    input logic reset_adder_complete,
    
    output logic [31:0] adder_result,
    output logic reset_instruction_in_progress_adder,
    output logic [4:0] adder_write_dest, 
    output logic adder_write_enable, 
    output logic adder_started, 
    output logic adder_complete, 
    output logic adder_busy,
    output logic adder_reset_operation_complete,
    output logic reset_enable_flag1
);

    // Internal signals
    logic [2:0] cycle_counter; // Counter to track the 4-cycle latency
    logic operation_in_progress; // Flag to indicate operation is ongoing
    logic adder_enable_flag;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset internal states
            cycle_counter <= 3'd0;
            operation_in_progress <= 0;
            adder_result <= 32'b0;
            reset_instruction_in_progress_adder <= 0;
            adder_write_dest <= 5'b0;
            adder_write_enable <= 0;
            adder_started <= 0;
            adder_complete <= 0;
            adder_busy <= 0;
            adder_reset_operation_complete <= 0;
            reset_enable_flag1 <= 0;
            adder_enable_flag <= 0;
        end else if (start && !adder_busy && !adder_enable_flag) begin
            // Start of a new addition operation
            adder_enable_flag <= 1;
            operation_in_progress <= 1;
            reset_instruction_in_progress_adder <= 1;
            adder_busy <= 1;
            adder_result <= operand_a + operand_b; // Perform the addition
            adder_write_dest <= rd; // Set the destination register for the result
            adder_reset_operation_complete <= 0;
            reset_enable_flag1 <= 0;
            cycle_counter <= 3'd4; // Set the cycle count for the operation
        end else if (operation_in_progress) begin
            adder_started <= 1;
            // Decrement the cycle counter each clock cycle
            if (cycle_counter > 1) begin
                cycle_counter <= cycle_counter - 1;
            end else begin
                // Operation completes after 4 cycles
                operation_in_progress <= 0;
                reset_instruction_in_progress_adder <= 0;
                adder_busy <= 0; // Clear the adder_busy flag on completion
                adder_write_enable <= 1; // Signal to write back the result
                adder_complete <= 1;
            end
        end else if(adder_reset_write_enable_flag) begin
            adder_write_enable <= 0;
            reset_enable_flag1 <= 1;
        end else if(reset_adder_complete) begin
            adder_enable_flag <= 0;
            adder_started <= 0;
            adder_complete <= 0;
            adder_reset_operation_complete <= 1;
        end
    end
endmodule