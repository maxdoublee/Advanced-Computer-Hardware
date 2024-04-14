//Project 2: Superscalar & Out-of-Order
//Max Destil
//RIN: 662032859

//Multiplier Functional Unit

module multiplier_unit(
    input logic clk,
    input logic reset,
    input logic start,
    input logic [4:0] rd, 
    input logic [31:0] operand_a, operand_b,
    input logic multiplier_reset_write_enable_flag,
    input logic reset_multiplier_complete,
    
    output logic [31:0] multiplier_result,
    output logic reset_instruction_in_progress_multiplier,
    output logic [4:0] multiplier_write_dest,
    output logic multiplier_write_enable, 
    output logic multiplier_started,
    output logic multiplier_complete, 
    output logic multiplier_busy,
    output logic multiplier_reset_operation_complete,
    output logic reset_enable_flag2
);

    // Internal signals
    logic [2:0] cycle_counter; // Counter to track the 6-cycle latency
    logic operation_in_progress; // Flag to indicate operation is ongoing
    logic multiplier_enable_flag;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset internal states
            cycle_counter <= 3'd0;
            operation_in_progress <= 0;
            multiplier_result <= 32'd0;
            reset_instruction_in_progress_multiplier = 0;
            multiplier_write_dest <= 5'b0;
            multiplier_write_enable <= 0;
            multiplier_started <= 0;
            multiplier_complete <= 0;
            multiplier_busy <= 0;
            multiplier_reset_operation_complete <= 0;
            reset_enable_flag2 <= 0;
            multiplier_enable_flag <= 0;
        end else if (start && !multiplier_busy && !multiplier_enable_flag) begin
            // Start of a new multiplication operation
            multiplier_enable_flag <= 1;
            operation_in_progress <= 1;
            reset_instruction_in_progress_multiplier <= 1;
            multiplier_busy <= 1;
            multiplier_result <= operand_a * operand_b; // Perform the multiplication
            multiplier_write_dest <= rd; // Set the destination register for the result
            multiplier_reset_operation_complete <= 0;
            reset_enable_flag2 <= 0;
            cycle_counter <= 3'd6; // Set the cycle count for the operation
        end else if (operation_in_progress) begin
            multiplier_started <= 1;
            // Decrement the cycle counter each clock cycle
            if (cycle_counter > 1) begin
                cycle_counter <= cycle_counter - 1;
            end else begin
                // Operation completes after 6 cycles
                operation_in_progress <= 0;
                reset_instruction_in_progress_multiplier <= 0;
                multiplier_busy <= 0; // Clear the multiplier_busy flag on completion
                multiplier_write_enable <= 1; // Signal to write back the result
                multiplier_complete <= 1;
            end
        end else if(multiplier_reset_write_enable_flag) begin
            multiplier_write_enable <= 0;
            reset_enable_flag2 <= 1;
        end else if(reset_multiplier_complete) begin
            multiplier_enable_flag <= 0;
            multiplier_started <= 0;
            multiplier_complete <= 0;
            multiplier_reset_operation_complete <= 1;
        end
    end
endmodule