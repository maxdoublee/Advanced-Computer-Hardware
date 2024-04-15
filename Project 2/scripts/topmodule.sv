//Project 2: Superscalar & Out-of-Order
//Max Destil
//RIN: 662032859

//Top Module

module topmodule (
    input logic clk,
    input logic reset,

    output logic data_hazard,
    output logic queue_advance //advances queue for testing purposes
);

    // Outputs from the instruction queue module
    logic queue_empty;
    // logic queue_advance;
    logic [31:0] instruction_out1, instruction_out2; // Instructions outputted per cycle
    logic valid_out1, valid_out2; // Validity flags for the instructions

    // Signals for instruction decoder with handling for two instructions
    logic [6:0] opcode1, opcode2;
    logic [4:0] rd1, rs1_1, rs2_1;
    logic [4:0] rd2, rs1_2, rs2_2;
    logic [2:0] funct3_1, funct3_2;
    logic [6:0] funct7_1, funct7_2;
    logic type_add1, type_mul1, type_load1, type_store1, type_nop1;
    logic type_add2, type_mul2, type_load2, type_store2, type_nop2;
    logic [31:0] immediate1, immediate2;
    logic unrecognized_instruction1, unrecognized_instruction2;

    // Register signals 
    logic request_rs_flag1, request_rs_flag2;
    logic [4:0] adder_write_dest1, multiplier_write_dest1, memory_write_dest1, request_rs1_1, request_rs2_1;
    logic [4:0] adder_write_dest2, multiplier_write_dest2, memory_write_dest2, request_rs1_2, request_rs2_2; 
    logic [31:0] adder_result1, multiplier_result1, adder_result2, multiplier_result2, memory_read_data1, memory_read_data2;
    logic adder_write_enable1, multiplier_write_enable1, adder_write_enable2, multiplier_write_enable2, memory_write_enable1, memory_write_enable2;
    logic adder_started1, adder_started2, multiplier_started1, multiplier_started2;
    logic adder_complete1, multiplier_complete1, adder_complete2, multiplier_complete2;
    logic adder_complete;
    logic multiplier_complete;
    logic [31:0] read_data1, read_data2;
    logic confirm_rs_flag1, confirm_rs_flag2;
    logic multiplier_reset_write_enable_flag;
    logic adder_reset_write_enable_flag1, adder_reset_write_enable_flag2;
    logic multiplier_reset_write_enable_flag1, multiplier_reset_write_enable_flag2;
    logic reset_enable_flag1, reset_enable_flag2, reset_enable_flag3;

    // Memory signals
    logic [31:0] memory_address;
    logic start_memory_read;
    logic start_memory_write; 
    logic [31:0] memory_write_data;
    logic [31:0] memory_read_data;
    logic load_busy;
    logic store_busy;
    logic [4:0] memory_write_dest; 
    logic memory_write_enable;
    logic read_memory_operation_complete;
    logic write_memory_operation_complete;
    logic [31:0] memory_address1, memory_address2;
    logic start_memory_read1; 
    logic start_memory_read2;
    logic start_memory_write1;
    logic start_memory_write2; 
    logic [31:0] memory_write_data1, memory_write_data2;
    logic read_memory_operation_started1, read_memory_operation_started2;
    logic read_memory_operation_complete1, read_memory_operation_complete2;
    logic write_memory_operation_started1, write_memory_operation_started2;
    logic write_memory_operation_complete1, write_memory_operation_complete2;
    logic reset_read_memory_operation_complete1, reset_read_memory_operation_complete2;
    logic reset_write_memory_operation_complete1, reset_write_memory_operation_complete2;
    logic memory_reset_write_enable_flag1, memory_reset_write_enable_flag2;
    logic read_memory_reset_operation_complete1, read_memory_reset_operation_complete2;
    logic write_memory_reset_operation_complete1, write_memory_reset_operation_complete2;

    // Dispatch signals 
    logic [31:0] read_data1_1, read_data2_1;
    logic [31:0] read_data1_2, read_data2_2;
    logic adder_busy1, multiplier_busy1, load_busy1, store_busy1;
    logic adder_busy2, multiplier_busy2, load_busy2, store_busy2;
    logic reset_instruction_in_progress_adder1, reset_instruction_in_progress_adder2;
    logic reset_instruction_in_progress_multiplier1, reset_instruction_in_progress_multiplier2;
    logic confirm_rs_flag;
    logic start_adder1, start_adder2;
    logic start_multiplier1, start_multiplier2;
    logic request_rs_flag;
    logic [31:0] operand_a, operand_b;
    logic no_operation_instruction;
    logic no_operation_instruction1;
    logic no_operation_instruction2;
    logic notify_tb_of_data_hazard;
    // logic data_hazard;

    // Adder signals 
    logic start;
    logic [4:0] rd;
    logic adder_reset_write_enable_flag;
    logic [31:0] adder_result;
    logic reset_instruction_in_progress_adder;
    logic [4:0] adder_write_dest;
    logic adder_write_enable;
    logic adder_busy;
    logic reset_adder_complete;
    logic reset_adder_complete1, reset_adder_complete2;
    logic adder_reset_operation_complete1, adder_reset_operation_complete2;

    // Multiplier Signals 
    logic [31:0] multiplier_result;
    logic reset_instruction_in_progress_multiplier;
    logic [4:0] multiplier_write_dest;
    logic multiplier_write_enable;
    logic multiplier_busy;
    logic reset_multiplier_complete;
    logic reset_multiplier_complete1, reset_multiplier_complete2;
    logic multiplier_reset_operation_complete1, multiplier_reset_operation_complete2;

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
endmodule