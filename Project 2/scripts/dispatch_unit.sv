//Project 2: Superscalar & Out-of-Order
//Max Destil
//RIN: 662032859

//Dispatch Unit

module dispatch_unit (
    input logic clk,
    input logic reset,
    input logic [4:0] rs1_1, rs2_1, 
    input logic [4:0] rs1_2, rs2_2, 
    input logic [31:0] read_data1_1, read_data2_1, 
    input logic [31:0] read_data1_2, read_data2_2, 
    input logic type_add1, type_mul1, type_load1, type_store1, type_nop1,
    input logic type_add2, type_mul2, type_load2, type_store2, type_nop2,
    input logic adder_busy1, multiplier_busy1, load_busy1, store_busy1, 
    input logic adder_busy2, multiplier_busy2, load_busy2, store_busy2, 
    input logic reset_instruction_in_progress_adder1, reset_instruction_in_progress_adder2,
    input logic reset_instruction_in_progress_multiplier1, reset_instruction_in_progress_multiplier2,
    input logic reset_instruction_in_progress_memory_read1, reset_instruction_in_progress_memory_read2,
    input logic reset_instruction_in_progress_memory_write1, reset_instruction_in_progress_memory_write2,
    input logic [31:0] immediate1, 
    input logic [31:0] immediate2, 
    input logic confirm_rs_flag1,
    input logic confirm_rs_flag2,
    input logic adder_complete1, multiplier_complete1,
    input logic adder_complete2, multiplier_complete2,
    input logic read_memory_operation_complete1,
    input logic read_memory_operation_complete2,
    input logic write_memory_operation_complete1,
    input logic write_memory_operation_complete2,
    input logic data_hazard,
    input logic adder_write_enable1, multiplier_write_enable1,
    input logic adder_write_enable2, multiplier_write_enable2,
    input logic adder_reset_operation_complete1, adder_reset_operation_complete2,
    input logic multiplier_reset_operation_complete1, multiplier_reset_operation_complete2,
    input logic read_memory_reset_operation_complete1, read_memory_reset_operation_complete2,
    input logic write_memory_reset_operation_complete1, write_memory_reset_operation_complete2,

    output logic start_adder1, start_adder2,
    output logic start_multiplier1, start_multiplier2,
    output logic reset_adder_complete1, reset_adder_complete2,
    output logic reset_multiplier_complete1, reset_multiplier_complete2,
    output logic reset_read_memory_operation_complete1, reset_read_memory_operation_complete2,
    output logic reset_write_memory_operation_complete1, reset_write_memory_operation_complete2,
    output logic request_rs_flag1,
    output logic request_rs_flag2,
    output logic [4:0] request_rs1_1, request_rs2_1,
    output logic [4:0] request_rs1_2, request_rs2_2, 
    output logic [31:0] operand_a, operand_b,
    output logic [31:0] memory_address1,
    output logic [31:0] memory_address2,
    output logic start_memory_read1,
    output logic start_memory_read2,
    output logic start_memory_write1,
    output logic start_memory_write2,
    output logic [31:0] memory_write_data1,
    output logic [31:0] memory_write_data2,
    output logic no_operation_instruction1,
    output logic no_operation_instruction2,
    output logic notify_tb_of_data_hazard
);

    logic first_entry_type_add1;
    logic first_entry_type_add2;
    logic first_entry_type_mul1;
    logic first_entry_type_mul2;
    logic first_entry_type_load1;
    logic first_entry_type_load2;
    logic first_entry_type_store1;
    logic first_entry_type_store2;
    logic first_entry_type_nop1;
    logic first_entry_type_nop2;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            start_adder1 <= 0;
            start_adder2 <= 0;
            start_multiplier1 <= 0;
            start_multiplier2 <= 0;
            reset_adder_complete1 <= 0;
            reset_adder_complete2 <= 0;
            reset_multiplier_complete1 <= 0;
            reset_multiplier_complete2 <= 0;
            reset_read_memory_operation_complete1 <= 0;
            reset_read_memory_operation_complete2 <= 0;
            reset_write_memory_operation_complete1 <= 0;
            reset_write_memory_operation_complete2 <= 0;
            request_rs_flag1 <= 0;
            request_rs_flag2 <= 0;
            request_rs1_1 <= 5'b0;
            request_rs2_1 <= 5'b0;
            request_rs1_2 <= 5'b0;
            request_rs2_2 <= 5'b0;
            operand_a <= 32'b0;
            operand_b <= 32'b0;
            memory_address1 <= 32'b0;
            memory_address2 <= 32'b0;
            start_memory_read1 <= 0;
            start_memory_read2 <= 0;
            start_memory_write1 <= 0;
            start_memory_write2 <= 0;
            memory_write_data1 <= 32'b0;
            memory_write_data2 <= 32'b0;
            no_operation_instruction1 <= 0;
            no_operation_instruction2 <= 0;
            first_entry_type_add1 <= 0;
            first_entry_type_add2 <= 0;
            first_entry_type_mul1 <= 0;
            first_entry_type_mul2 <= 0;
            first_entry_type_load1 <= 0;
            first_entry_type_load2 <= 0;
            first_entry_type_store1 <= 0;
            first_entry_type_store2 <= 0;
            first_entry_type_nop1 <= 0;
            first_entry_type_nop2 <= 0;
            notify_tb_of_data_hazard <= 0;
        end else begin
            // Dispatch logic for first instruction
            if (type_add1 && !first_entry_type_add1) begin
                // Request operands through source registers
                request_rs_flag1 <= 1;
                request_rs1_1 <= rs1_1;
                request_rs2_1 <= rs2_1;
                if(confirm_rs_flag1 && !adder_busy1) begin //start of operation
                    first_entry_type_add1 <= 1;
                    request_rs_flag1 <= 0;
                    operand_a <= read_data1_1;
                    operand_b <= read_data2_1;
                    start_adder1 <= 1;
                end 
            end else if (type_mul1 && !first_entry_type_mul1) begin
                // Request operands through source registers
                request_rs_flag1 <= 1;
                request_rs1_1 <= rs1_1;
                request_rs2_1 <= rs2_1;
                if(confirm_rs_flag1 && !multiplier_busy1) begin
                    first_entry_type_mul1 <= 1;
                    request_rs_flag1 <= 0;
                    operand_a <= read_data1_1;
                    operand_b <= read_data2_1;
                    start_multiplier1 <= 1;
                end 
            end else if (type_load1 && !first_entry_type_load1) begin
                // Request operands through source registers
                request_rs_flag1 <= 1;
                request_rs1_1 <= rs1_1;
                request_rs2_1 <= rs2_1;
                if(confirm_rs_flag1 && !load_busy1) begin 
                    first_entry_type_load1 <= 1;
                    request_rs_flag1 <= 0;
                    memory_address1 = immediate1 + read_data1_1;
                    start_memory_read1 <= 1;
                end 
            end else if (type_store1 && !first_entry_type_store1) begin 
                // Request operands through source registers
                request_rs_flag1 <= 1;
                request_rs1_1 <= rs1_1;
                request_rs2_1 <= rs2_1;
                if(confirm_rs_flag1 && !store_busy1) begin 
                    first_entry_type_store1 <= 1;
                    request_rs_flag1 <= 0;
                    memory_address1 <= immediate1 + read_data1_1; 
                    memory_write_data1 <= read_data2_1; 
                    start_memory_write1 <= 1;
                end 
            end else if(type_nop1 && !first_entry_type_nop1) begin
                first_entry_type_nop1 <= 1;
                // No operation instruction was received by dispatch unit 
                no_operation_instruction1 <= 1;
            end

            // Dispatch logic for second instruction
            // First added conditional statement to ensure in-order instruction dispatch, with stalling of the second dispatch unit if the first stalls
            if(!data_hazard) begin
                notify_tb_of_data_hazard <= 0;
                if (type_add2 && !first_entry_type_add2) begin
                    // Request operands through source registers
                    request_rs_flag2 <= 1;
                    request_rs1_2 <= rs1_2;
                    request_rs2_2 <= rs2_2;
                    if(confirm_rs_flag2 && !adder_busy2) begin 
                        first_entry_type_add2 <= 1;
                        request_rs_flag2 <= 0;
                        operand_a <= read_data1_2;
                        operand_b <= read_data2_2;
                        start_adder2 <= 1;
                    end
                end else if (type_mul2 && !first_entry_type_mul2) begin
                    // Request operands through source registers
                    request_rs_flag2 <= 1;
                    request_rs1_2 <= rs1_2;
                    request_rs2_2 <= rs2_2;
                    if(confirm_rs_flag2 && !multiplier_busy2) begin 
                        first_entry_type_mul2 <= 1;
                        request_rs_flag2 <= 0;
                        operand_a <= read_data1_2;
                        operand_b <= read_data2_2;
                        start_multiplier2 <= 1;
                    end 
                end else if (type_load2&& !first_entry_type_load2) begin
                    // Request operands through source registers
                    request_rs_flag2 <= 1;
                    request_rs1_2 <= rs1_2;
                    request_rs2_2 <= rs2_2;
                    if(confirm_rs_flag2 && !load_busy2) begin 
                        first_entry_type_load2 <= 1;
                        request_rs_flag2 <= 0;
                        memory_address2 <= immediate2 + read_data1_2;
                        start_memory_read2 <= 1;
                    end 
                end else if (type_store2 && !first_entry_type_store2) begin 
                    // Request operands through source registers
                    request_rs_flag2 <= 1;
                    request_rs1_2 <= rs1_2;
                    request_rs2_2 <= rs2_2;
                    if(confirm_rs_flag2 && !store_busy2) begin 
                        first_entry_type_store2 <= 1;
                        request_rs_flag2 <= 0;
                        memory_address2 <= immediate2 + read_data1_2; 
                        memory_write_data2 <= read_data2_2; 
                        start_memory_write2 <= 1;
                    end 
                end else if(type_nop2 && !first_entry_type_nop2) begin
                    first_entry_type_nop2 <= 1;
                    // No operation instruction was received by dispatch unit 
                    no_operation_instruction2 <= 1;
                end

                // Check if adder/multiplier reset instruction is in progress from functional units
                if(reset_instruction_in_progress_adder1) begin 
                    start_adder1 <= 0;
                end else if(reset_instruction_in_progress_adder2) begin
                    start_adder2 <= 0;
                end else if(reset_instruction_in_progress_multiplier1) begin
                    start_multiplier1 <= 0;
                end else if(reset_instruction_in_progress_multiplier2) begin
                    start_multiplier2 <= 0;
                end 

                // Check if load/store reset instruction is in progress from functional units
                if(reset_instruction_in_progress_memory_read1) begin 
                    start_memory_read1 <= 0;
                end else if(reset_instruction_in_progress_memory_read2) begin
                    start_memory_read2 <= 0;
                end else if(reset_instruction_in_progress_memory_write1) begin
                    start_memory_write1 <= 0;
                end else if(reset_instruction_in_progress_memory_write2) begin
                    start_memory_write2 <= 0;
                end 

                // Logic to manage completed instructions
                if((adder_complete1 && adder_complete2) || (multiplier_complete1 && multiplier_complete2) || (adder_complete1 && multiplier_complete2) || (multiplier_complete1 && adder_complete2) || (adder_complete1 && no_operation_instruction2) || (multiplier_complete1 && no_operation_instruction2) || (read_memory_operation_complete1 && no_operation_instruction2) || (write_memory_operation_complete1 && no_operation_instruction2) || (read_memory_operation_complete1 && write_memory_operation_complete2) || (write_memory_operation_complete1 && read_memory_operation_complete2) || (write_memory_operation_complete1 && write_memory_operation_complete2)) begin 
                    reset_adder_complete1 <= 1;
                    reset_adder_complete2 <= 1;
                    reset_multiplier_complete1 <= 1;
                    reset_multiplier_complete2 <= 1;
                    reset_read_memory_operation_complete1 <= 1;
                    reset_read_memory_operation_complete2 <= 1;
                    reset_write_memory_operation_complete1 <= 1;
                    reset_write_memory_operation_complete2 <= 1;
                    first_entry_type_add1 <= 0;
                    first_entry_type_add2 <= 0;
                    first_entry_type_mul1 <= 0;
                    first_entry_type_mul2 <= 0;
                    first_entry_type_load1 <= 0;
                    first_entry_type_load2 <= 0;
                    first_entry_type_store1 <= 0;
                    first_entry_type_store2 <= 0;
                    first_entry_type_nop1 <= 0;
                    first_entry_type_nop2 <= 0;
                end else begin 
                    reset_adder_complete1 <= 0;
                    reset_adder_complete2 <= 0;
                    reset_multiplier_complete1 <= 0;
                    reset_multiplier_complete2 <= 0;
                    reset_read_memory_operation_complete1 <= 0;
                    reset_read_memory_operation_complete2 <= 0;
                    reset_write_memory_operation_complete1 <= 0;
                    reset_write_memory_operation_complete2 <= 0;
                end
            end else begin
                notify_tb_of_data_hazard <= 1;
            end
        end
    end
endmodule