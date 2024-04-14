//Project 2: Superscalar & Out-of-Order
//Max Destil
//RIN: 662032859

//testbench

module testbench(
    input logic queue_empty, // Signal to indicate the end of simulation

    output logic data_hazard,
    output logic queue_advance //advances queue for testing purposes
);
    logic clk;
    logic reset;
    logic [31:0] expected_addition_result;
    logic [31:0] expected_multiplication_result;
    logic [31:0] expected_memory_read_data;
    logic [31:0] expected_memory_address;
    logic [31:0] expected_memory_write_data;
    logic expected_no_operation_instruction;
    logic [31:0] instruction_out1;
    logic [31:0] instruction_out2; 
    logic valid_out1;
    logic valid_out2;
    logic reset_adder_complete1;
    logic reset_adder_complete2;
    logic reset_multiplier_complete1;
    logic reset_multiplier_complete2;
    logic [6:0] opcode1;
    logic [6:0] opcode2;
    logic [4:0] rd1;
    logic [4:0] rd2;
    logic [4:0] rs1_1;
    logic [4:0] rs1_2;
    logic [4:0] rs2_1;
    logic [4:0] rs2_2;
    logic [2:0] funct3_1;
    logic [2:0] funct3_2;
    logic [6:0] funct7_1;
    logic [6:0] funct7_2;
    logic type_add1;
    logic type_add2;
    logic type_mul1;
    logic type_mul2;
    logic type_load1;
    logic type_load2;
    logic type_store1;
    logic type_store2;
    logic type_nop1;
    logic type_nop2;
    logic [31:0] immediate1;
    logic [31:0] immediate2;
    logic unrecognized_instruction;
    logic [31:0] read_data1_1;
    logic [31:0] read_data1_2;
    logic [31:0] read_data2_1;
    logic [31:0] read_data2_2;
    logic adder_started1;
    logic adder_started2;
    logic adder_complete1;
    logic adder_complete2;
    logic multiplier_started1;
    logic multiplier_started2;
    logic multiplier_complete1;
    logic multiplier_complete2;
    logic read_memory_operation_started1;
    logic read_memory_operation_started2;
    logic write_memory_operation_started1;
    logic write_memory_operation_started2;
    logic read_memory_operation_complete1;
    logic read_memory_operation_complete2;
    logic write_memory_operation_complete1;
    logic write_memory_operation_complete2;
    logic adder_busy1;
    logic adder_busy2;
    logic multiplier_busy1;
    logic multiplier_busy2;
    logic adder_reset_operation_complete1;
    logic adder_reset_operation_complete2;
    logic multiplier_reset_operation_complete1;
    logic multiplier_reset_operation_complete2;
    logic read_memory_reset_operation_complete1;
    logic read_memory_reset_operation_complete2;
    logic write_memory_reset_operation_complete1;
    logic write_memory_reset_operation_complete2;
    logic load_busy1;
    logic load_busy2;
    logic store_busy1;
    logic store_busy2;
    logic reset_instruction_in_progress_adder1;
    logic reset_instruction_in_progress_adder2;
    logic reset_instruction_in_progress_multiplier1;
    logic reset_instruction_in_progress_multiplier2;
    logic confirm_rs_flag1;
    logic confirm_rs_flag2;
    logic reset_instruction_in_progress_memory_read1;
    logic reset_instruction_in_progress_memory_read2;
    logic reset_instruction_in_progress_memory_write1;
    logic reset_instruction_in_progress_memory_write2;
    logic start_adder1;
    logic start_adder2;
    logic start_multiplier1;
    logic start_multiplier2;
    logic request_rs_flag1;
    logic request_rs_flag2;
    logic [4:0] request_rs1_1;
    logic [4:0] request_rs1_2;
    logic [4:0] request_rs2_1;
    logic [4:0] request_rs2_2;
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [31:0] memory_address1;
    logic [31:0] memory_address2;
    logic start_memory_read1;
    logic start_memory_read2;
    logic start_memory_write1;
    logic start_memory_write2;
    logic [31:0] memory_write_data1;
    logic [31:0] memory_write_data2;
    logic no_operation_instruction1;
    logic no_operation_instruction2;
    logic notify_tb_of_data_hazard;
    logic [4:0] adder_write_dest1;
    logic [4:0] adder_write_dest2;
    logic [4:0] multiplier_write_dest1;
    logic [4:0] multiplier_write_dest2;
    logic [4:0] memory_write_dest1;
    logic [4:0] memory_write_dest2;
    logic [31:0] adder_result1;
    logic [31:0] adder_result2;
    logic [31:0] multiplier_result1;
    logic [31:0] multiplier_result2;
    logic [31:0] memory_read_data1;
    logic [31:0] memory_read_data2;
    logic adder_write_enable1;
    logic adder_write_enable2;
    logic multiplier_write_enable1;
    logic multiplier_write_enable2;
    logic memory_write_enable1;
    logic memory_write_enable2;
    logic adder_reset_write_enable_flag1;
    logic adder_reset_write_enable_flag2;
    logic multiplier_reset_write_enable_flag1;
    logic multiplier_reset_write_enable_flag2;
    logic memory_reset_write_enable_flag1;
    logic memory_reset_write_enable_flag2;
    logic reset_enable_flag1;
    logic reset_enable_flag2;
    logic reset_enable_flag3;
    logic reset_read_memory_operation_complete1;
    logic reset_read_memory_operation_complete2;
    logic reset_write_memory_operation_complete1;
    logic reset_write_memory_operation_complete2;

    // Instantiate the Instruction Queue 
    instruction_queue top_instruction_queue (
        .clk(clk),
        .reset(reset),
        .queue_advance(queue_advance),
        .instruction_out1(instruction_out1),
        .instruction_out2(instruction_out2),
        .valid_out1(valid_out1),
        .valid_out2(valid_out2),
        .queue_empty(queue_empty)
    );

    instruction_decoder decoder1 (
        .clk(clk),
        .reset(reset),
        .instruction(instruction_out1), 
        .opcode(opcode1),
        .rd(rd1),
        .rs1(rs1_1),
        .rs2(rs2_1),
        .funct3(funct3_1),
        .funct7(funct7_1),
        .type_add(type_add1),
        .type_mul(type_mul1),
        .type_load(type_load1),
        .type_store(type_store1),
        .type_nop(type_nop1),
        .immediate(immediate1),
        .unrecognized_instruction(unrecognized_instruction1)
    );

    // Instantiate the Second Instruction Decoder
    instruction_decoder decoder2 (
        .clk(clk),
        .reset(reset),
        .instruction(instruction_out2), 
        .opcode(opcode2),
        .rd(rd2),
        .rs1(rs1_2),
        .rs2(rs2_2),
        .funct3(funct3_2),
        .funct7(funct7_2),
        .type_add(type_add2),
        .type_mul(type_mul2),
        .type_load(type_load2),
        .type_store(type_store2),
        .type_nop(type_nop2),
        .immediate(immediate2),
        .unrecognized_instruction(unrecognized_instruction2)
    );

    // Instantiate the First Register File
    register_file top_register_file1 (
        .clk(clk),
        .reset(reset),
        .request_rs_flag(request_rs_flag1),
        .adder_write_dest(adder_write_dest1),
        .multiplier_write_dest(multiplier_write_dest1),
        .memory_write_dest(memory_write_dest1),
        .request_rs1(request_rs1_1), 
        .request_rs2(request_rs2_1), 
        .adder_result(adder_result1),
        .multiplier_result(multiplier_result1),
        .memory_read_data(memory_read_data1),
        .adder_write_enable(adder_write_enable1),
        .multiplier_write_enable(multiplier_write_enable1),
        .memory_write_enable(memory_write_enable1),
        .reset_enable_flag1(reset_enable_flag1_1),
        .reset_enable_flag2(reset_enable_flag2_1),
        .reset_enable_flag3(reset_enable_flag3_1),
        .read_data1(read_data1_1), 
        .read_data2(read_data2_1),
        .confirm_rs_flag(confirm_rs_flag1),  
        .adder_reset_write_enable_flag(adder_reset_write_enable_flag1),  
        .multiplier_reset_write_enable_flag(multiplier_reset_write_enable_flag1),
        .memory_reset_write_enable_flag(memory_reset_write_enable_flag1)
    );

    // Instantiate the Second Register File
    register_file top_register_file2 (
        .clk(clk),
        .reset(reset),
        .request_rs_flag(request_rs_flag2),
        .adder_write_dest(adder_write_dest2),
        .multiplier_write_dest(multiplier_write_dest2),
        .memory_write_dest(memory_write_dest2),
        .request_rs1(request_rs1_2), 
        .request_rs2(request_rs2_2), 
        .adder_result(adder_result2),
        .multiplier_result(multiplier_result2),
        .memory_read_data(memory_read_data2),
        .adder_write_enable(adder_write_enable2),
        .multiplier_write_enable(multiplier_write_enable2),
        .memory_write_enable(memory_write_enable2),
        .reset_enable_flag1(reset_enable_flag1_2),
        .reset_enable_flag2(reset_enable_flag2_2),
        .reset_enable_flag3(reset_enable_flag3_2),
        .read_data1(read_data1_2), 
        .read_data2(read_data2_2),  
        .confirm_rs_flag(confirm_rs_flag2),  
        .adder_reset_write_enable_flag(adder_reset_write_enable_flag2),  
        .multiplier_reset_write_enable_flag(multiplier_reset_write_enable_flag2),
        .memory_reset_write_enable_flag(memory_reset_write_enable_flag2)
    );

    // Instantiate the Memory Unit
    memory_unit top_memory_unit1 (
        .clk(clk),
        .reset(reset),
        .memory_address(memory_address1),
        .start_memory_read(start_memory_read1), 
        .start_memory_write(start_memory_write1), 
        .memory_write_data(memory_write_data1),
        .rd(rd1),
        .memory_reset_write_enable_flag(memory_reset_write_enable_flag1),
        .reset_read_memory_operation_complete(reset_read_memory_operation_complete1),
        .reset_write_memory_operation_complete(reset_write_memory_operation_complete1),
        .reset_instruction_in_progress_memory_read(reset_instruction_in_progress_memory_read1),
        .reset_instruction_in_progress_memory_write(reset_instruction_in_progress_memory_write1),
        .memory_read_data(memory_read_data1),
        .load_busy(load_busy1),
        .store_busy(store_busy1),
        .memory_write_dest(memory_write_dest1),
        .memory_write_enable(memory_write_enable1),
        .read_memory_operation_started(read_memory_operation_started1),
        .write_memory_operation_started(write_memory_operation_started1),
        .read_memory_operation_complete(read_memory_operation_complete1), 
        .write_memory_operation_complete(write_memory_operation_complete1),
        .read_memory_reset_operation_complete(read_memory_reset_operation_complete1),
        .write_memory_reset_operation_complete(write_memory_reset_operation_complete1),
        .reset_enable_flag3(reset_enable_flag3_1)
    );

    // Instantiate the Second Memory Unit
    memory_unit top_memory_unit2 (
        .clk(clk),
        .reset(reset),
        .memory_address(memory_address2),
        .start_memory_read(start_memory_read2), 
        .start_memory_write(start_memory_write2), 
        .memory_write_data(memory_write_data2),
        .rd(rd2),
        .memory_reset_write_enable_flag(memory_reset_write_enable_flag2),
        .reset_read_memory_operation_complete(reset_read_memory_operation_complete2),
        .reset_write_memory_operation_complete(reset_write_memory_operation_complete2),
        .reset_instruction_in_progress_memory_read(reset_instruction_in_progress_memory_read2),
        .reset_instruction_in_progress_memory_write(reset_instruction_in_progress_memory_write2),
        .memory_read_data(memory_read_data2),
        .load_busy(load_busy2),
        .store_busy(store_busy2),
        .memory_write_dest(memory_write_dest2),
        .memory_write_enable(memory_write_enable2),
        .read_memory_operation_started(read_memory_operation_started2),
        .write_memory_operation_started(write_memory_operation_started2),
        .read_memory_operation_complete(read_memory_operation_complete2), 
        .write_memory_operation_complete(write_memory_operation_complete2),
        .read_memory_reset_operation_complete(read_memory_reset_operation_complete2),
        .write_memory_reset_operation_complete(write_memory_reset_operation_complete2),
        .reset_enable_flag3(reset_enable_flag3_2)
    );

    // Instantiate the Dispatch Unit
    dispatch_unit top_dispatch (
        .clk(clk),
        .reset(reset),
        .rs1_1(rs1_1),
        .rs2_1(rs2_1),
        .rs1_2(rs1_2),
        .rs2_2(rs2_2),
        .read_data1_1(read_data1_1),
        .read_data2_1(read_data2_1),
        .read_data1_2(read_data1_2),
        .read_data2_2(read_data2_2),
        .type_add1(type_add1),
        .type_mul1(type_mul1),
        .type_load1(type_load1),
        .type_store1(type_store1),
        .type_nop1(type_nop1),
        .type_add2(type_add2),
        .type_mul2(type_mul2),
        .type_load2(type_load2),
        .type_store2(type_store2),
        .type_nop2(type_nop2),
        .adder_busy1(adder_busy1),
        .adder_busy2(adder_busy2),
        .multiplier_busy1(multiplier_busy1),
        .multiplier_busy2(multiplier_busy2),
        .load_busy1(load_busy1),
        .load_busy2(load_busy2),
        .store_busy1(store_busy1),
        .store_busy2(store_busy2),
        .reset_instruction_in_progress_adder1(reset_instruction_in_progress_adder1),
        .reset_instruction_in_progress_adder2(reset_instruction_in_progress_adder2),
        .reset_instruction_in_progress_multiplier1(reset_instruction_in_progress_multiplier1),
        .reset_instruction_in_progress_multiplier2(reset_instruction_in_progress_multiplier2),
        .reset_instruction_in_progress_memory_read1(reset_instruction_in_progress_memory_read1),
        .reset_instruction_in_progress_memory_read2(reset_instruction_in_progress_memory_read2),
        .reset_instruction_in_progress_memory_write1(reset_instruction_in_progress_memory_write1),
        .reset_instruction_in_progress_memory_write2(reset_instruction_in_progress_memory_write2),
        .immediate1(immediate1),
        .immediate2(immediate2),
        .confirm_rs_flag1(confirm_rs_flag1),
        .confirm_rs_flag2(confirm_rs_flag2),
        .read_memory_operation_complete1(read_memory_operation_complete1),
        .read_memory_operation_complete2(read_memory_operation_complete2),
        .write_memory_operation_complete1(write_memory_operation_complete1),
        .write_memory_operation_complete2(write_memory_operation_complete2),
        .data_hazard(data_hazard),
        .adder_write_enable1(adder_write_enable1),
        .adder_write_enable2(adder_write_enable2),
        .multiplier_write_enable1(multiplier_write_enable1),
        .multiplier_write_enable2(multiplier_write_enable2),
        .adder_complete1(adder_complete1),
        .adder_complete2(adder_complete2),
        .multiplier_complete1(multiplier_complete1),
        .multiplier_complete2(multiplier_complete2),
        .adder_reset_operation_complete1(adder_reset_operation_complete1),
        .adder_reset_operation_complete2(adder_reset_operation_complete2),
        .multiplier_reset_operation_complete1(multiplier_reset_operation_complete1),
        .multiplier_reset_operation_complete2(multiplier_reset_operation_complete2),
        .read_memory_reset_operation_complete1(read_memory_reset_operation_complete1),
        .read_memory_reset_operation_complete2(read_memory_reset_operation_complete2),
        .write_memory_reset_operation_complete1(write_memory_reset_operation_complete1),
        .write_memory_reset_operation_complete2(write_memory_reset_operation_complete2),
        .start_adder1(start_adder1),
        .start_adder2(start_adder2),
        .start_multiplier1(start_multiplier1),
        .start_multiplier2(start_multiplier2),
        .reset_adder_complete1(reset_adder_complete1),
        .reset_adder_complete2(reset_adder_complete2),
        .reset_multiplier_complete1(reset_multiplier_complete1),
        .reset_multiplier_complete2(reset_multiplier_complete2),
        .reset_read_memory_operation_complete1(reset_read_memory_operation_complete1),
        .reset_read_memory_operation_complete2(reset_read_memory_operation_complete2),
        .reset_write_memory_operation_complete1(reset_write_memory_operation_complete1),
        .reset_write_memory_operation_complete2(reset_write_memory_operation_complete2),
        .request_rs_flag1(request_rs_flag1),
        .request_rs_flag2(request_rs_flag2),
        .request_rs1_1(request_rs1_1),
        .request_rs2_1(request_rs2_1),
        .request_rs1_2(request_rs1_2),
        .request_rs2_2(request_rs2_2),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .memory_address1(memory_address1),
        .memory_address2(memory_address2),
        .start_memory_read1(start_memory_read1),
        .start_memory_read2(start_memory_read2),
        .start_memory_write1(start_memory_write1),
        .start_memory_write2(start_memory_write2),
        .memory_write_data1(memory_write_data1),
        .memory_write_data2(memory_write_data2),
        .no_operation_instruction1(no_operation_instruction1),
        .no_operation_instruction2(no_operation_instruction2),
        .notify_tb_of_data_hazard(notify_tb_of_data_hazard)
    );

    // Instantiate the First Adder Functional Unit
    adder_unit top_adder1 (
        .clk(clk),
        .reset(reset),
        .start(start_adder1),
        .rd(rd1),
        .operand_a(read_data1_1),
        .operand_b(read_data2_1),
        .adder_reset_write_enable_flag(adder_reset_write_enable_flag1),
        .reset_adder_complete(reset_adder_complete1),
        .adder_result(adder_result1), 
        .reset_instruction_in_progress_adder(reset_instruction_in_progress_adder1),
        .adder_write_dest(adder_write_dest1),
        .adder_write_enable(adder_write_enable1), 
        .adder_started(adder_started1),
        .adder_complete(adder_complete1),
        .adder_busy(adder_busy1),
        .adder_reset_operation_complete(adder_reset_operation_complete1),
        .reset_enable_flag1(reset_enable_flag1_2)
    );

    // Instantiate the Second Adder Functional Unit
    adder_unit top_adder2 (
        .clk(clk),
        .reset(reset),
        .start(start_adder2),
        .rd(rd2),
        .operand_a(read_data1_2),
        .operand_b(read_data2_2),
        .adder_reset_write_enable_flag(adder_reset_write_enable_flag2),
        .reset_adder_complete(reset_adder_complete2),
        .adder_result(adder_result2), 
        .reset_instruction_in_progress_adder(reset_instruction_in_progress_adder2),
        .adder_write_dest(adder_write_dest2),
        .adder_write_enable(adder_write_enable2),
        .adder_started(adder_started2),
        .adder_complete(adder_complete2),
        .adder_busy(adder_busy2),
        .adder_reset_operation_complete(adder_reset_operation_complete2),
        .reset_enable_flag1(reset_enable_flag1_2)
    );

    // Instantiate the First Multiplier Functional Unit
    multiplier_unit top_multiplier1 (
        .clk(clk),
        .reset(reset),
        .start(start_multiplier1),
        .rd(rd1),
        .operand_a(read_data1_1),
        .operand_b(read_data2_1),
        .multiplier_reset_write_enable_flag(multiplier_reset_write_enable_flag1),
        .reset_multiplier_complete(reset_multiplier_complete1),
        .multiplier_result(multiplier_result1), 
        .reset_instruction_in_progress_multiplier(reset_instruction_in_progress_multiplier1), 
        .multiplier_write_dest(multiplier_write_dest1),
        .multiplier_write_enable(multiplier_write_enable1), 
        .multiplier_started(multiplier_started1),
        .multiplier_complete(multiplier_complete1),
        .multiplier_busy(multiplier_busy1),
        .multiplier_reset_operation_complete(multiplier_reset_operation_complete1),
        .reset_enable_flag2(reset_enable_flag2_1)
    );

    // Instantiate the Second Multiplier Functional Unit
    multiplier_unit top_multiplier2 (
        .clk(clk),
        .reset(reset),
        .start(start_multiplier2),
        .rd(rd2),
        .operand_a(read_data1_2),
        .operand_b(read_data2_2),
        .multiplier_reset_write_enable_flag(multiplier_reset_write_enable_flag2),
        .reset_multiplier_complete(reset_multiplier_complete2),
        .multiplier_result(multiplier_result2), 
        .reset_instruction_in_progress_multiplier(reset_instruction_in_progress_multiplier2), 
        .multiplier_write_dest(multiplier_write_dest2),
        .multiplier_write_enable(multiplier_write_enable2),
        .multiplier_started(multiplier_started2),
        .multiplier_complete(multiplier_complete2),
        .multiplier_busy(multiplier_busy2),
        .multiplier_reset_operation_complete(multiplier_reset_operation_complete2),
        .reset_enable_flag2(reset_enable_flag2_2)
    );

    always begin
        #5 clk = ~clk; // Toggle clock every 5 time units
    end

    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1; 
        queue_advance = 0;
        data_hazard = 0;
        #20 reset = 0; // Wait a little longer for reset to take effect

        // Test Case 1: Dual Instruction Dispatch Capability Test

        queue_advance = 1;

        wait(valid_out1 && valid_out2); // Wait for dual dispatch

        queue_advance = 0;

        #175

        if (start_adder1 && start_multiplier2) begin
            $display("\nDual instruction dispatch verified at time: %tns", $time);
        end else begin
            $error("\nFailed to dispatch dual instructions simultaneously.");
        end

        // Test Case 2: Functional Unit Latency Compliance Test for both Adder and Multiplier

        // Next three lines allows the program to progress instruction queue (will be used throughout tb)
        queue_advance = 1;

        #10 //brief delay

        queue_advance = 0;
        
        // Wait for operations to start and complete
        wait(adder_started1); // Wait for the adder to start
        $display("\nAdder operation started at time: %t", $time);
        #40; // Wait for adder's completion (4 cycles, 10 ns cycle time)
        if (adder_complete1) begin
            $display("\nAdder operation completed successfully within 4 cycles at time: %t", $time);
        end else begin
            $error("\nAdder did not complete in 4 cycles. Current simulation time: %tns", $time);
        end

        queue_advance = 1;

        #10 //brief delay

        queue_advance = 0;

        wait(start_multiplier1); // Wait for the multiplier to start after adder's completion
        wait(multiplier_started1); // Wait for the adder to start
        $display("\nMultiplier operation started at time: %t", $time);
        #60; // Wait for multiplier's completion (6 cycles)
        if (multiplier_complete1) begin
            $display("\nMultiplier operation completed successfully within 6 cycles at time: %t", $time);
        end else begin
            $error("\nMultiplier did not complete in 6 cycles. Current simulation time: %tns", $time);
        end

        // Test Case 3: Instruction Type Handling Test for Add, Mul, Load/Store, and NOP 

        queue_advance = 1;

        #10 //brief delay

        queue_advance = 0;

        //Add
        expected_addition_result = 32'h00000005;
        #10
        wait(start_adder1); 
        if (adder_result1 === expected_addition_result) begin
            $display("\nAdd operation result is correct. Expected %h, got %h", expected_addition_result, adder_result1);
        end else begin
            $error("\nAdd operation result is incorrect. Expected %h, got %h", expected_addition_result, adder_result1);
        end

        //Multiply
        expected_multiplication_result = 32'h0000000f; 
        #10
        wait(start_multiplier2); 
        if (multiplier_result2 === expected_multiplication_result) begin
            $display("\nMultiply operation result is correct. Expected %h, got %h", expected_multiplication_result, multiplier_result2);
        end else begin
            $error("\nMultiply operation result is incorrect. Expected %h, got %h", expected_multiplication_result, multiplier_result2);
        end

        queue_advance = 1;

        #10 //brief delay

        queue_advance = 0;

        //Load
        expected_memory_read_data = 32'hFEEDBEEF; //this expected value is obtained after fetching from memory 
        #50
        if (memory_read_data1 === expected_memory_read_data) begin
            $display("\nLoad operation completed successfully. Expected %h, got %h", expected_memory_read_data, memory_read_data1);
        end else begin
            $error("\nLoad operation failed. Expected %h, got %h", expected_memory_read_data, memory_read_data1);
        end

        queue_advance = 1;

        #10 //brief delay

        queue_advance = 0;

        //Store
        expected_memory_address = 32'h0000000a; //this expected value is the addition of the immediate value and the rs1 value from the instruction address
        expected_memory_write_data = 32'hFEEDBEEF; //rs2 expected value
        #30
        if (memory_address1 === expected_memory_address) begin
            $display("\nStore operation passed with correct memory address. Expected %h, got %h", expected_memory_address, memory_address1);
        end else begin
            $error("\nStore operation failed, wrong memory address. Expected %h, got %h", expected_memory_address, memory_address1);
        end

        #20 //brief delay

        if (memory_write_data1 === expected_memory_write_data) begin
            $display("\nStore operation passed with correct write data. Expected %h, got %h", expected_memory_write_data, memory_write_data1);
        end else begin
            $error("Store operation failed, incorrect write data. Expected %h, got %h", expected_memory_write_data, memory_write_data1);
        end

        #10 //brief delay

        //NOP
        expected_no_operation_instruction = 1;
        if (no_operation_instruction2 === expected_no_operation_instruction) begin
            $display("\nNo operation instruction completed");
        end else begin
            $error("\nNo operation instruction did not complete");
        end

        // Test Case 4: In-Order Execution and Stalling Test (using dependent instructions)

        queue_advance = 1;

        #10 //brief delay

        queue_advance = 0;

        // WAR
        #25
        if (start_memory_read1 && start_memory_write2) begin
            $display("\nDual instruction dispatch verified at %t", $time);
            data_hazard <= 1;
        end else begin
            $error("\nFailed to dispatch dual instructions simultaneously.");
        end

        wait(notify_tb_of_data_hazard);
        $display("\nWAR Test completed successfully.");
        
        data_hazard <= 0;

        queue_advance = 1;

        #20 //brief delay

        queue_advance = 0;

        // RAW
        #25
        if (start_memory_write1 && start_memory_read2) begin
            $display("\nDual instruction dispatch verified at %t", $time);
            data_hazard <= 1;
        end else begin
            $error("\nFailed to dispatch dual instructions simultaneously.");
        end

        wait(notify_tb_of_data_hazard);
        $display("\nRAW Test completed successfully.");

        data_hazard <= 0;

        queue_advance = 1;

        #20 //brief delay

        queue_advance = 0;

        // WAW
        #25
        if (start_memory_write1 && start_memory_write2) begin
            $display("\nDual instruction dispatch verified at %t", $time);
            data_hazard <= 1;
        end else begin
            $error("\nFailed to dispatch dual instructions simultaneously.");
        end

        wait(notify_tb_of_data_hazard);
        $display("\nWAW Test completed successfully.");

        data_hazard <= 0;

        queue_advance = 1; //testing complete, clear out queue by advancing program to complete simulation

        wait(queue_empty); 
        $display("\nData Hazards Test completed successfully.");

        queue_advance = 0;
    end

    initial begin
        $monitor(
            "
            Time=%0t clk=%b reset=%b simulation_end=%b
            Dispatch1: Opcode=%b RD1=%b RS1=%b RS2=%b Add=%b Mul=%b Load=%b Store=%b NOP=%b 
            Dispatch2: Opcode=%b RD2=%b RS1=%b RS2=%b Add=%b Mul=%b Load=%b Store=%b NOP=%b
            Data Hazard=%b Notify Testbench of Data Hazard=%b
            start_memory_write1=%b, start_memory_read2=%b
            Queue Advance=%b funct3_1=%0b",
            $time, clk, reset, queue_empty,
            opcode1, rd1, rs1_1, rs2_1, type_add1, type_mul1, type_load1, type_store1, type_nop1, 
            opcode2, rd2, rs1_2, rs2_2, type_add2, type_mul2, type_load2, type_store2, type_nop2,
            data_hazard,  notify_tb_of_data_hazard, 
            start_memory_write1, start_memory_read2,
            queue_advance, funct3_1
        );
    end
endmodule