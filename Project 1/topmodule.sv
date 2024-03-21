//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//top module implementation

import cache_config::*;
import main_memory_config::*;

module topmodule (
    input logic clk,
    input logic reset,
    // Processor Interfaces
    input logic cache_a_read_request, 
    input logic cache_a_write_request, 
    input logic [ADDRESS_WIDTH-1:0] cache_L1a_memory_address,
    input logic [DATA_WIDTH-1:0] cache_1a_write_data,
    input logic cache_b_read_request, 
    input logic cache_b_write_request, 
    input logic [ADDRESS_WIDTH-1:0] cache_L1b_memory_address,
    input logic [DATA_WIDTH-1:0] cache_1b_write_data,
    input logic cache_c_read_request, 
    input logic cache_c_write_request, 
    input logic [ADDRESS_WIDTH-1:0] cache_L1c_memory_address,
    input logic [DATA_WIDTH-1:0] cache_1c_write_data,
    input logic cache_d_read_request, 
    input logic cache_d_write_request, 
    input logic [ADDRESS_WIDTH-1:0] cache_L1d_memory_address,
    input logic [DATA_WIDTH-1:0] cache_1d_write_data,
    // Main memory Interfaces
    input logic main_memory_write_request,
    input logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address,
    input logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_write_data
);

    // Internal signals for L1 to L2 communication
    logic L2a_ready, L2b_ready, L2c_ready, L2d_ready;
    logic write_to_L2a_verified, write_to_L2b_verified, write_to_L2c_verified, write_to_L2d_verified;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L1a_from_L2a, write_data_to_L1b_from_L2b, write_data_to_L1c_from_L2c, write_data_to_L1d_from_L2d; 
    logic write_back_to_L2a_verified, write_back_to_L2b_verified, write_back_to_L2c_verified, write_back_to_L2d_verified;
    logic write_to_L2a_request, write_to_L2b_request, write_to_L2c_request, write_to_L2d_request;
    logic write_back_to_L2a_request, write_back_to_L2b_request, write_back_to_L2c_request, write_back_to_L2d_request;
    logic read_from_L2a_request, read_from_L2b_request, read_from_L2c_request, read_from_L2d_request;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2a_data, write_back_to_L2b_data, write_back_to_L2c_data, write_back_to_L2d_data;
    logic [DATA_WIDTH-1:0] cache_L1a_read_data, cache_L1b_read_data, cache_L1c_read_data, cache_L1d_read_data;
    logic [DATA_WIDTH-1:0] cache_1a_write_data_to_L2a, cache_1b_write_data_to_L2b, cache_1c_write_data_to_L2c, cache_1d_write_data_to_L2d;
    logic [ADDRESS_WIDTH-1:0] cache_L2a_memory_address, cache_L2b_memory_address, cache_L2c_memory_address, cache_L2d_memory_address; // For addressing L2 cache

    // Internal signals for L2 to arbiter communication
    logic arbiter_confirmed_L3_ready_for_L2a, arbiter_confirmed_L3_ready_for_L2b, arbiter_confirmed_L3_ready_for_L2c, arbiter_confirmed_L3_ready_for_L2d;
    logic write_back_to_L3_from_arbiter_a_verified, write_back_to_L3_from_arbiter_b_verified, write_back_to_L3_from_arbiter_c_verified, write_back_to_L3_from_arbiter_d_verified;
	logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache_a, mesi_state_to_cache_b, mesi_state_to_cache_c, mesi_state_to_cache_d;
    logic arbiter_verify_a, arbiter_verify_b, arbwrite_back_to_L3_request_from_L2d_arbiteriter_verify_c, arbiter_verify_d;
	logic cache_fsm_L2a_block_to_arbiter_verified, cache_fsm_L2b_block_to_arbiter_verified, cache_fsm_L2c_block_to_arbiter_verified, cache_fsm_L2d_block_to_arbiter_verified;
    logic read_from_L3_request_from_L2a, read_from_L3_request_from_L2b, read_from_L3_request_from_L2c, read_from_L3_request_from_L2d;
    logic write_back_to_L3_request_from_L2a, write_back_to_L3_request_from_L2b, write_back_to_L3_request_from_L2c, write_back_to_L3_request_from_L2d;
    logic arbiter_read_update_from_L2a_cache_modules, arbiter_read_update_from_L2b_cache_modules, arbiter_read_update_from_L2c_cache_modules, arbiter_read_update_from_L2d_cache_modules;
    logic arbiter_write_update_from_L2a_cache_modules, arbiter_write_update_from_L2b_cache_modules, arbiter_write_update_from_L2c_cache_modules, arbiter_write_update_from_L2d_cache_modules;
	logic [ADDRESS_WIDTH-1:0] block_a_to_determine_mesi_state_from_arbiter, block_b_to_determine_mesi_state_from_arbiter, block_c_to_determine_mesi_state_from_arbiter, block_d_to_determine_mesi_state_from_arbiter;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2a_local_data, L2b_local_data, L2c_local_data, L2d_local_data;
    logic acknowledge_arbiter_verify_a, acknowledge_arbiter_verify_b, acknowledge_arbiter_verify_c, acknowledge_arbiter_verify_d;
    logic cache_fsm_L2a_block_to_arbiter, cache_fsm_Lwrite_back_to_L3_from_arbiter_d_verified2b_block_to_arbiter, cache_fsm_L2c_block_to_arbiter, cache_fsm_L2d_block_to_arbiter;
    logic cache_L3a_memory_address_to_array_L3a_to_arbiter_flag, cache_L3b_memory_address_to_array_L3b_to_arbiter_flag, cache_L3c_memory_address_to_array_L3c_to_arbiter_flag, cache_L3d_memory_address_to_array_L3d_to_arbiter_flag;
    logic [1:0] lru_way_a, lru_way_b, lru_way_c, lru_way_d;
    logic mesi_state_confirmation_verified_flag;
    logic [MESI_STATE_WIDTH-1:0] MESI_state_from_arbiter_for_testbench;

    // Internal signals for L3 to arbiter communication
    logic read_from_arbiter_request_from_L2a_to_L3, read_from_arbiter_request_from_L2b_to_L3, read_from_arbiter_request_from_L2c_to_L3, read_from_arbiter_request_from_L2d_to_L3;
    logic write_back_to_L3_request_from_L2a_arbiter, write_back_to_L3_request_from_L2b_arbiter, write_back_to_L3_request_from_L2c_arbiter, write_back_to_L3_request_from_L2d_arbiter;
    logic cache_L3a_memory_address_to_array_L3a_from_arbiter_flag, cache_L3a_memory_address_to_array_L3b_from_arbiter_flag, cache_L3a_memory_address_to_array_L3c_from_arbiter_flag, cache_L3a_memory_address_to_array_L3d_from_arbiter_flag;
    logic L3a_ready, L3b_ready, L3c_ready, L3d_ready;
    logic write_back_to_L3_from_L2a_verified, write_back_to_L3_from_L2b_verified, write_back_to_L3_from_L2c_verified, write_back_to_L3_from_L2d_verified; 

    // Internal signals for L2 to L3 communication
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3a_data, write_back_to_L3b_data, write_back_to_L3c_data, write_back_to_L3d_data;
	logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2a_from_L3a, write_data_to_L2b_from_L3b, write_data_to_L2c_from_L3c, write_data_to_L2d_from_L3d;
    logic [ADDRESS_WIDTH-1:0] cache_L3a_memory_address, cache_L3b_memory_address, cache_L3c_memory_address, cache_L3d_memory_address; // For addressing L3 cache

    // Internal signals for L3 to Main Memory communication
    logic main_memory_read_request;
    logic main_memory_ready;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data;

    //Outputs of individual cache modules not connected to any another module (setup for testbench)
    logic L1a_cache_hit, L1b_cache_hit, L1c_cache_hit, L1d_cache_hit;
    logic L1a_cache_miss, L1b_cache_miss, L1c_cache_miss, L1d_cache_miss;
    logic L1a_cache_ready, L1b_cache_ready, L1c_cache_ready, L1d_cache_ready;
    logic L2a_cache_read_hit, L2b_cache_read_hit, L2c_cache_read_hit, L2d_cache_read_hit;
    logic L2a_cache_write_hit, L2b_cache_write_hit, L2c_cache_write_hit, L2d_cache_write_hit;
    logic L2a_cache_miss, L2b_cache_miss, L2c_cache_miss, L2d_cache_miss;
    logic L2a_cache_ready, L2b_cache_ready, L2c_cache_ready, L2d_cache_ready;
    logic L3_cache_hit;
    logic L3_cache_miss;
    logic L3_cache_ready;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] data_stored_at_cache_L1a_from_main_memory, data_stored_at_cache_L1a_written_by_testbench, data_stored_at_cache_L1b_written_by_testbench, data_stored_at_cache_L1c_written_by_testbench, data_stored_at_cache_L1d_written_by_testbench;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] data_stored_at_cache_L2a_from_main_memory, data_stored_at_cache_L2b_from_main_memory, data_stored_at_cache_L2c_from_main_memory, data_stored_at_cache_L2d_from_main_memory;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] data_stored_at_cache_L3_from_main_memory;

        // Instantiate L1 caches
    cache_fsm_L1a #(
        .CACHE_LEVEL(1)
    ) top_cache_fsm_L1a (
        .clk(clk),
        .reset(reset),
        .cache_a_read_request(cache_a_read_request),
        .cache_a_write_request(cache_a_write_request),
        .L2a_ready(L2a_ready),
        .cache_L1a_memory_address(cache_L1a_memory_address),
        .cache_1a_write_data(cache_1a_write_data),
        .write_to_L2a_verified(write_to_L2a_verified),
        .write_data_to_L1a_from_L2a(write_data_to_L1a_from_L2a),
        .write_back_to_L2a_verified(write_back_to_L2a_verified),
        .cache_L2a_memory_address(cache_L2a_memory_address),
        .write_to_L2a_request(write_to_L2a_request),
        .write_back_to_L2a_request(write_back_to_L2a_request),
        .read_from_L2a_request(read_from_L2a_request),
        .write_back_to_L2a_data(write_back_to_L2a_data),
        .cache_L1a_read_data(cache_L1a_read_data),
        .cache_1a_write_data_to_L2a(cache_1a_write_data_to_L2a),
        .L1a_cache_hit(L1a_cache_hit),
        .L1a_cache_miss(L1a_cache_miss),
        .L1a_cache_ready(L1a_cache_ready),
        .data_stored_at_cache_L1a_written_by_testbench(data_stored_at_cache_L1a_written_by_testbench),
        .data_stored_at_cache_L1a_from_main_memory(data_stored_at_cache_L1a_from_main_memory)
    );
    cache_fsm_L1b #(
        .CACHE_LEVEL(1)
    ) top_cache_fsm_L1b (
        .clk(clk),
        .reset(reset),
        .cache_b_read_request(cache_b_read_request),
        .cache_b_write_request(cache_b_write_request),
        .L2b_ready(L2b_ready),
        .cache_L1b_memory_address(cache_L1b_memory_address),
        .cache_1b_write_data(cache_1b_write_data),
        .write_to_L2b_verified(write_to_L2b_verified),
        .write_data_to_L1b_from_L2b(write_data_to_L1b_from_L2b),
        .write_back_to_L2b_verified(write_back_to_L2b_verified),
        .cache_L2b_memory_address(cache_L2b_memory_address),
        .write_to_L2b_request(write_to_L2b_request),
        .write_back_to_L2b_request(write_back_to_L2b_request),
        .read_from_L2b_request(read_from_L2b_request),
        .write_back_to_L2b_data(write_back_to_L2b_data),
        .cache_L1b_read_data(cache_L1b_read_data),
        .cache_1b_write_data_to_L2b(cache_1b_write_data_to_L2b),
        .L1b_cache_hit(L1b_cache_hit),
        .L1b_cache_miss(L1b_cache_miss),
        .L1b_cache_ready(L1b_cache_ready),
        .data_stored_at_cache_L1b_written_by_testbench(data_stored_at_cache_L1b_written_by_testbench)
    );  
    cache_fsm_L1c #(
    .CACHE_LEVEL(1)
    ) top_cache_fsm_L1c (
        .clk(clk),
        .reset(reset),
        .cache_c_read_request(cache_c_read_request),
        .cache_c_write_request(cache_c_write_request),
        .L2c_ready(L2c_ready),
        .cache_L1c_memory_address(cache_L1c_memory_address),
        .cache_1c_write_data(cache_1c_write_data),
        .write_to_L2c_verified(write_to_L2c_verified),
        .write_data_to_L1c_from_L2c(write_data_to_L1c_from_L2c),
        .write_back_to_L2c_verified(write_back_to_L2c_verified),
        .cache_L2c_memory_address(cache_L2c_memory_address),
        .write_to_L2c_request(write_to_L2c_request),
        .write_back_to_L2c_request(write_back_to_L2c_request),
        .read_from_L2c_request(read_from_L2c_request),
        .write_back_to_L2c_data(write_back_to_L2c_data),
        .cache_L1c_read_data(cache_L1c_read_data),
        .cache_1c_write_data_to_L2c(cache_1c_write_data_to_L2c),
        .L1c_cache_hit(L1c_cache_hit),
        .L1c_cache_miss(L1c_cache_miss),
        .L1c_cache_ready(L1c_cache_ready),
        .data_stored_at_cache_L1c_written_by_testbench(data_stored_at_cache_L1c_written_by_testbench)
    );
    cache_fsm_L1d #(
    .CACHE_LEVEL(1)
    ) top_cache_fsm_L1d (
        .clk(clk),
        .reset(reset),
        .cache_d_read_request(cache_d_read_request),
        .cache_d_write_request(cache_d_write_request),
        .L2d_ready(L2d_ready),
        .cache_L1d_memory_address(cache_L1d_memory_address),
        .cache_1d_write_data(cache_1d_write_data),
        .write_to_L2d_verified(write_to_L2d_verified),
        .write_data_to_L1d_from_L2d(write_data_to_L1d_from_L2d),
        .write_back_to_L2d_verified(write_back_to_L2d_verified),
        .cache_L2d_memory_address(cache_L2d_memory_address),
        .write_to_L2d_request(write_to_L2d_request),
        .write_back_to_L2d_request(write_back_to_L2d_request),
        .read_from_L2d_request(read_from_L2d_request),
        .write_back_to_L2d_data(write_back_to_L2d_data),
        .cache_L1d_read_data(cache_L1d_read_data),
        .cache_1d_write_data_to_L2d(cache_1d_write_data_to_L2d),
        .L1d_cache_hit(L1d_cache_hit),
        .L1d_cache_miss(L1d_cache_miss),
        .L1d_cache_ready(L1d_cache_ready),
        .data_stored_at_cache_L1d_written_by_testbench(data_stored_at_cache_L1d_written_by_testbench)
    );

    // Instantiate L2 caches
    cache_fsm_L2a #(
        .CACHE_LEVEL(2)
    ) top_cache_fsm_L2a (
        .clk(clk),
        .reset(reset),
        .arbiter_confirmed_L3_ready_for_L2a(arbiter_confirmed_L3_ready_for_L2a),
        .cache_L2a_memory_address(cache_L2a_memory_address),
        .cache_1a_write_data_to_L2a(cache_1a_write_data_to_L2a),
        .write_to_L2a_request(write_to_L2a_request),
        .read_from_L2a_request(read_from_L2a_request),
        .write_back_to_L2a_request(write_back_to_L2a_request),
        .write_back_to_L2a_data(write_back_to_L2a_data),
        .write_data_to_L2a_from_L3a(write_data_to_L2a_from_L3a),
        .write_back_to_L3_from_arbiter_a_verified(write_back_to_L3_from_arbiter_a_verified),
        .mesi_state_to_cache_a(mesi_state_to_cache_a),
        .arbiter_verify_a(arbiter_verify_a),
        .cache_fsm_L2a_block_to_arbiter_verified(cache_fsm_L2a_block_to_arbiter_verified),
        .mesi_state_confirmation_a(mesi_state_confirmation_a),
        .MESI_state_from_arbiter_for_testbench(MESI_state_from_arbiter_for_testbench),
        .write_to_L2a_verified(write_to_L2a_verified),
        .read_from_L3_request_from_L2a(read_from_L3_request_from_L2a),
        .write_back_to_L3_request_from_L2a(write_back_to_L3_request_from_L2a),
        .L2a_ready(L2a_ready),
        .write_data_to_L1a_from_L2a(write_data_to_L1a_from_L2a),
        .write_back_to_L2a_verified(write_back_to_L2a_verified),
        .write_back_to_L3a_data(write_back_to_L3a_data),
        .cache_L3a_memory_address(cache_L3a_memory_address),
        .arbiter_read_update_from_L2a_cache_modules(arbiter_read_update_from_L2a_cache_modules),
        .arbiter_write_update_from_L2a_cache_modules(arbiter_write_update_from_L2a_cache_modules),
        .block_a_to_determine_mesi_state_from_arbiter(block_a_to_determine_mesi_state_from_arbiter),
        .L2a_local_data(L2a_local_data),
        .acknowledge_arbiter_verify_a(acknowledge_arbiter_verify_a),
        .L2a_cache_hit(L2a_cache_hit),
        .L2a_cache_read_hit(L2a_cache_read_hit),
        .L2a_cache_write_hit(L2a_cache_write_hit),
        .L2a_cache_miss(L2a_cache_miss),
        .L2a_cache_ready(L2a_cache_ready),
        .cache_fsm_L2a_block_to_arbiter(cache_fsm_L2a_block_to_arbiter),
        .cache_L3a_memory_address_to_array_L3a_to_arbiter_flag(cache_L3a_memory_address_to_array_L3a_to_arbiter_flag),
        .lru_way_a(lru_way_a),
        .mesi_state_confirmation_verified_flag_a(mesi_state_confirmation_verified_flag_a),
        .data_stored_at_cache_L2a_from_main_memory(data_stored_at_cache_L2a_from_main_memory)
    );
    cache_fsm_L2b #(
        .CACHE_LEVEL(2)
    ) top_cache_fsm_L2b (
        .clk(clk),
        .reset(reset),
        .arbiter_confirmed_L3_ready_for_L2b(arbiter_confirmed_L3_ready_for_L2b),
        .cache_L2b_memory_address(cache_L2b_memory_address),
        .cache_1b_write_data_to_L2b(cache_1b_write_data_to_L2b),
        .write_to_L2b_request(write_to_L2b_request),
        .read_from_L2b_request(read_from_L2b_request),
        .write_back_to_L2b_request(write_back_to_L2b_request),
        .write_back_to_L2b_data(write_back_to_L2b_data),
        .write_data_to_L2b_from_L3b(write_data_to_L2b_from_L3b),
        .write_back_to_L3_from_arbiter_b_verified(write_back_to_L3_from_arbiter_b_verified),
        .mesi_state_to_cache_b(mesi_state_to_cache_b),
        .arbiter_verify_b(arbiter_verify_b),
        .cache_fsm_L2b_block_to_arbiter_verified(cache_fsm_L2b_block_to_arbiter_verified),
        .mesi_state_confirmation_b(mesi_state_confirmation_b),
        .MESI_state_from_arbiter_for_testbench(MESI_state_from_arbiter_for_testbench),
        .write_to_L2b_verified(write_to_L2b_verified),
        .read_from_L3_request_from_L2b(read_from_L3_request_from_L2b),
        .write_back_to_L3_request_from_L2b(write_back_to_L3_request_from_L2b),
        .L2b_ready(L2b_ready),
        .write_data_to_L1b_from_L2b(write_data_to_L1b_from_L2b),
        .write_back_to_L2b_verified(write_back_to_L2b_verified),
        .write_back_to_L3b_data(write_back_to_L3b_data),
        .cache_L3b_memory_address(cache_L3b_memory_address),
        .arbiter_read_update_from_L2b_cache_modules(arbiter_read_update_from_L2b_cache_modules),
        .arbiter_write_update_from_L2b_cache_modules(arbiter_write_update_from_L2b_cache_modules),
        .block_b_to_determine_mesi_state_from_arbiter(block_b_to_determine_mesi_state_from_arbiter),
        .L2b_local_data(L2b_local_data),
        .acknowledge_arbiter_verify_b(acknowledge_arbiter_verify_b),
        .L2b_cache_hit(L2b_cache_hit),
        .L2b_cache_read_hit(L2b_cache_read_hit),
        .L2b_cache_write_hit(L2b_cache_write_hit),
        .L2b_cache_miss(L2b_cache_miss),
        .L2b_cache_ready(L2b_cache_ready),
        .cache_fsm_L2b_block_to_arbiter(cache_fsm_L2b_block_to_arbiter),
        .cache_L3b_memory_address_to_array_L3b_to_arbiter_flag(cache_L3b_memory_address_to_array_L3b_to_arbiter_flag),
        .lru_way_b(lru_way_b),
        .mesi_state_confirmation_verified_flag_b(mesi_state_confirmation_verified_flag_b),
        .data_stored_at_cache_L2b_from_main_memory(data_stored_at_cache_L2b_from_main_memory)
    );
    cache_fsm_L2c #(
        .CACHE_LEVEL(2)
    ) top_cache_fsm_L2c (
        .clk(clk),
        .reset(reset),
        .arbiter_confirmed_L3_ready_for_L2c(arbiter_confirmed_L3_ready_for_L2c),
        .cache_L2c_memory_address(cache_L2c_memory_address),
        .cache_1c_write_data_to_L2c(cache_1c_write_data_to_L2c),
        .write_to_L2c_request(write_to_L2c_request),
        .read_from_L2c_request(read_from_L2c_request),
        .write_back_to_L2c_request(write_back_to_L2c_request),
        .write_back_to_L2c_data(write_back_to_L2c_data),
        .write_data_to_L2c_from_L3c(write_data_to_L2c_from_L3c),
        .write_back_to_L3_from_arbiter_c_verified(write_back_to_L3_from_arbiter_c_verified),
        .mesi_state_to_cache_c(mesi_state_to_cache_c),
        .arbiter_verify_c(arbiter_verify_c),
        .cache_fsm_L2c_block_to_arbiter_verified(cache_fsm_L2c_block_to_arbiter_verified),
        .mesi_state_confirmation_c(mesi_state_confirmation_c),
        .MESI_state_from_arbiter_for_testbench(MESI_state_from_arbiter_for_testbench),
        .write_to_L2c_verified(write_to_L2c_verified),
        .read_from_L3_request_from_L2c(read_from_L3_request_from_L2c),
        .write_back_to_L3_request_from_L2c(write_back_to_L3_request_from_L2c),
        .L2c_ready(L2c_ready),
        .write_data_to_L1c_from_L2c(write_data_to_L1c_from_L2c),
        .write_back_to_L2c_verified(write_back_to_L2c_verified),
        .write_back_to_L3c_data(write_back_to_L3c_data),
        .cache_L3c_memory_address(cache_L3c_memory_address),
        .arbiter_read_update_from_L2c_cache_modules(arbiter_read_update_from_L2c_cache_modules),
        .arbiter_write_update_from_L2c_cache_modules(arbiter_write_update_from_L2c_cache_modules),
        .block_c_to_determine_mesi_state_from_arbiter(block_c_to_determine_mesi_state_from_arbiter),
        .L2c_local_data(L2c_local_data),
        .acknowledge_arbiter_verify_c(acknowledge_arbiter_verify_c),
        .L2c_cache_hit(L2c_cache_hit),
        .L2c_cache_read_hit(L2c_cache_read_hit),
        .L2c_cache_write_hit(L2c_cache_write_hit),
        .L2c_cache_miss(L2c_cache_miss),
        .L2c_cache_ready(L2c_cache_ready),
        .cache_fsm_L2c_block_to_arbiter(cache_fsm_L2c_block_to_arbiter),
        .cache_L3c_memory_address_to_array_L3c_to_arbiter_flag(cache_L3c_memory_address_to_array_L3c_to_arbiter_flag),
        .lru_way_c(lru_way_c),
        .mesi_state_confirmation_verified_flag_c(mesi_state_confirmation_verified_flag_c),
        .data_stored_at_cache_L2c_from_main_memory(data_stored_at_cache_L2c_from_main_memory)
    );
    cache_fsm_L2d #(
        .CACHE_LEVEL(2)
        ) top_cache_fsm_L2d (
        .clk(clk),
        .reset(reset),
        .arbiter_confirmed_L3_ready_for_L2d(arbiter_confirmed_L3_ready_for_L2d),
        .cache_L2d_memory_address(cache_L2d_memory_address),
        .cache_1d_write_data_to_L2d(cache_1d_write_data_to_L2d),
        .write_to_L2d_request(write_to_L2d_request),
        .read_from_L2d_request(read_from_L2d_request),
        .write_back_to_L2d_request(write_back_to_L2d_request),
        .write_back_to_L2d_data(write_back_to_L2d_data),
        .write_data_to_L2d_from_L3d(write_data_to_L2d_from_L3d),
        .write_back_to_L3_from_arbiter_d_verified(write_back_to_L3_from_arbiter_d_verified),
        .mesi_state_to_cache_d(mesi_state_to_cache_d),
        .arbiter_verify_d(arbiter_verify_d),
        .cache_fsm_L2d_block_to_arbiter_verified(cache_fsm_L2d_block_to_arbiter_verified),
        .mesi_state_confirmation_d(mesi_state_confirmation_d),
        .write_to_L2d_verified(write_to_L2d_verified),
        .read_from_L3_request_from_L2d(read_from_L3_request_from_L2d),
        .write_back_to_L3_request_from_L2d(write_back_to_L3_request_from_L2d),
        .L2d_ready(L2d_ready),
        .write_data_to_L1d_from_L2d(write_data_to_L1d_from_L2d),
        .write_back_to_L2d_verified(write_back_to_L2d_verified),
        .write_back_to_L3d_data(write_back_to_L3d_data),
        .cache_L3d_memory_address(cache_L3d_memory_address),
        .arbiter_read_update_from_L2d_cache_modules(arbiter_read_update_from_L2d_cache_modules),
        .arbiter_write_update_from_L2d_cache_modules(arbiter_write_update_from_L2d_cache_modules),
        .block_d_to_determine_mesi_state_from_arbiter(block_d_to_determine_mesi_state_from_arbiter),
        .L2d_local_data(L2d_local_data),
        .acknowledge_arbiter_verify_d(acknowledge_arbiter_verify_d),
        .L2d_cache_hit(L2d_cache_hit),
        .L2d_cache_read_hit(L2d_cache_read_hit),
        .L2d_cache_write_hit(L2d_cache_write_hit),
        .L2d_cache_miss(L2d_cache_miss),
        .L2d_cache_ready(L2d_cache_ready),
        .cache_fsm_L2d_block_to_arbiter(cache_fsm_L2d_block_to_arbiter),
        .cache_L3d_memory_address_to_array_L3d_to_arbiter_flag(cache_L3d_memory_address_to_array_L3d_to_arbiter_flag),
        .lru_way_d(lru_way_d),
        .mesi_state_confirmation_verified_flag_d(mesi_state_confirmation_verified_flag_d),
        .data_stored_at_cache_L2d_from_main_memory(data_stored_at_cache_L2d_from_main_memory)
    );

    // Instantiate shared L3 cache
    cache_fsm_L3 #(
        .CACHE_LEVEL(3)
    ) top_cache_fsm_L3 (
        .clk(clk),
        .reset(reset),
        .main_memory_ready(main_memory_ready),
        .cache_L3a_memory_address(cache_L3a_memory_address),
        .cache_L3b_memory_address(cache_L3b_memory_address),
        .cache_L3c_memory_address(cache_L3c_memory_address),
        .cache_L3d_memory_address(cache_L3d_memory_address),
        .main_memory_read_data(main_memory_read_data),
        .read_from_arbiter_request_from_L2a_to_L3(read_from_arbiter_request_from_L2a_to_L3),
        .read_from_arbiter_request_from_L2b_to_L3(read_from_arbiter_request_from_L2b_to_L3),
        .read_from_arbiter_request_from_L2c_to_L3(read_from_arbiter_request_from_L2c_to_L3),
        .read_from_arbiter_request_from_L2d_to_L3(read_from_arbiter_request_from_L2d_to_L3),
        .write_back_to_L3_request_from_L2a_arbiter(write_back_to_L3_request_from_L2a_arbiter),
        .write_back_to_L3_request_from_L2b_arbiter(write_back_to_L3_request_from_L2b_arbiter),
        .write_back_to_L3_request_from_L2c_arbiter(write_back_to_L3_request_from_L2c_arbiter),
        .write_back_to_L3_request_from_L2d_arbiter(write_back_to_L3_request_from_L2d_arbiter),
        .write_back_to_L3a_data(write_back_to_L3a_data),
        .write_back_to_L3b_data(write_back_to_L3b_data),
        .write_back_to_L3c_data(write_back_to_L3c_data),
        .write_back_to_L3d_data(write_back_to_L3d_data),
        .cache_L3a_memory_address_to_array_L3a_from_arbiter_flag(cache_L3a_memory_address_to_array_L3a_from_arbiter_flag),
        .cache_L3b_memory_address_to_array_L3b_from_arbiter_flag(cache_L3b_memory_address_to_array_L3b_from_arbiter_flag),
        .cache_L3c_memory_address_to_array_L3c_from_arbiter_flag(cache_L3c_memory_address_to_array_L3c_from_arbiter_flag),
        .cache_L3d_memory_address_to_array_L3d_from_arbiter_flag(cache_L3d_memory_address_to_array_L3d_from_arbiter_flag),
        .main_memory_write_data(main_memory_write_data),
        .main_memory_address(main_memory_address),
        .main_memory_read_request(main_memory_read_request),
        .main_memory_write_request(main_memory_write_request),
        .L3a_ready(L3a_ready),
        .L3b_ready(L3b_ready),
        .L3c_ready(L3c_ready),
        .L3d_ready(L3d_ready),
        .write_data_to_L2a_from_L3a(write_data_to_L2a_from_L3a),
        .write_data_to_L2b_from_L3b(write_data_to_L2b_from_L3b),
        .write_data_to_L2c_from_L3c(write_data_to_L2c_from_L3c),
        .write_data_to_L2d_from_L3d(write_data_to_L2d_from_L3d),
        .write_back_to_L3_from_L2a_verified(write_back_to_L3_from_L2a_verified),
        .write_back_to_L3_from_L2b_verified(write_back_to_L3_from_L2b_verified),
        .write_back_to_L3_from_L2c_verified(write_back_to_L3_from_L2c_verified),
        .write_back_to_L3_from_L2d_verified(write_back_to_L3_from_L2d_verified),
        .L3_cache_hit(L3_cache_hit),
        .L3_cache_miss(L3_cache_miss),
        .L3_cache_ready(L3_cache_ready),
        .data_stored_at_cache_L3_from_main_memory(data_stored_at_cache_L3_from_main_memory)
    );

    // Instantiate main_memory_controller
    main_memory_controller top_memory_controller(
        .clk(clk),
        .reset(reset),
        .main_memory_read_request(main_memory_read_request),
        .main_memory_write_request(main_memory_write_request),
        .main_memory_address(main_memory_address),
        .main_memory_write_data(main_memory_write_data),
        .main_memory_read_data(main_memory_read_data),
        .main_memory_ready(main_memory_ready)
    );

    // Instantiate bus arbiter
    arbiter #(
        .CACHE_LEVEL(2)
    ) top_arbiter (
        .clk(clk),
        .reset(reset),
        .block_a_to_determine_mesi_state_from_arbiter(block_a_to_determine_mesi_state_from_arbiter),
        .block_b_to_determine_mesi_state_from_arbiter(block_b_to_determine_mesi_state_from_arbiter),
        .block_c_to_determine_mesi_state_from_arbiter(block_c_to_determine_mesi_state_from_arbiter),
        .block_d_to_determine_mesi_state_from_arbiter(block_d_to_determine_mesi_state_from_arbiter),
        .L2a_local_data(L2a_local_data),
        .L2b_local_data(L2b_local_data),
        .L2c_local_data(L2c_local_data),
        .L2d_local_data(L2d_local_data),
        .arbiter_read_update_from_L2a_cache_modules(arbiter_read_update_from_L2a_cache_modules),
        .arbiter_read_update_from_L2b_cache_modules(arbiter_read_update_from_L2b_cache_modules),
        .arbiter_read_update_from_L2c_cache_modules(arbiter_read_update_from_L2c_cache_modules),
        .arbiter_read_update_from_L2d_cache_modules(arbiter_read_update_from_L2d_cache_modules),
        .arbiter_write_update_from_L2a_cache_modules(arbiter_write_update_from_L2a_cache_modules),
        .arbiter_write_update_from_L2b_cache_modules(arbiter_write_update_from_L2b_cache_modules),
        .arbiter_write_update_from_L2c_cache_modules(arbiter_write_update_from_L2c_cache_modules),
        .arbiter_write_update_from_L2d_cache_modules(arbiter_write_update_from_L2d_cache_modules),
        .acknowledge_arbiter_verify_a(acknowledge_arbiter_verify_a),
        .acknowledge_arbiter_verify_b(acknowledge_arbiter_verify_b),
        .acknowledge_arbiter_verify_c(acknowledge_arbiter_verify_c),
        .acknowledge_arbiter_verify_d(acknowledge_arbiter_verify_d),
        .cache_fsm_L2a_block_to_arbiter(cache_fsm_L2a_block_to_arbiter),
        .cache_fsm_L2b_block_to_arbiter(cache_fsm_L2b_block_to_arbiter),
        .cache_fsm_L2c_block_to_arbiter(cache_fsm_L2c_block_to_arbiter),
        .cache_fsm_L2d_block_to_arbiter(cache_fsm_L2d_block_to_arbiter),
        .read_from_L3_request_from_L2a(read_from_L3_request_from_L2a),
        .read_from_L3_request_from_L2b(read_from_L3_request_from_L2b),
        .read_from_L3_request_from_L2c(read_from_L3_request_from_L2c),
        .read_from_L3_request_from_L2d(read_from_L3_request_from_L2d),
        .L3a_ready(L3a_ready),
        .L3b_ready(L3b_ready),
        .L3c_ready(L3c_ready),
        .L3d_ready(L3d_ready),
        .write_back_to_L3_from_L2a_verified(write_back_to_L3_from_L2a_verified),
        .write_back_to_L3_from_L2b_verified(write_back_to_L3_from_L2b_verified),
        .write_back_to_L3_from_L2c_verified(write_back_to_L3_from_L2c_verified),
        .write_back_to_L3_from_L2d_verified(write_back_to_L3_from_L2d_verified),
        .cache_L3a_memory_address_to_array_L3a_to_arbiter_flag(cache_L3a_memory_address_to_array_L3a_to_arbiter_flag),
        .cache_L3b_memory_address_to_array_L3b_to_arbiter_flag(cache_L3b_memory_address_to_array_L3b_to_arbiter_flag),
        .cache_L3c_memory_address_to_array_L3c_to_arbiter_flag(cache_L3c_memory_address_to_array_L3c_to_arbiter_flag),
        .cache_L3d_memory_address_to_array_L3d_to_arbiter_flag(cache_L3d_memory_address_to_array_L3d_to_arbiter_flag),
        .write_back_to_L3_request_from_L2a(write_back_to_L3_request_from_L2a),
        .write_back_to_L3_request_from_L2b(write_back_to_L3_request_from_L2b),
        .write_back_to_L3_request_from_L2c(write_back_to_L3_request_from_L2c),
        .write_back_to_L3_request_from_L2d(write_back_to_L3_request_from_L2d),
        .lru_way_a(lru_way_a),
        .lru_way_b(lru_way_b),
        .lru_way_c(lru_way_c),
        .lru_way_d(lru_way_d),
        .mesi_state_confirmation_verified_flag_a(mesi_state_confirmation_verified_flag_a),
        .mesi_state_confirmation_verified_flag_b(mesi_state_confirmation_verified_flag_b),
        .mesi_state_confirmation_verified_flag_c(mesi_state_confirmation_verified_flag_c),
        .mesi_state_confirmation_verified_flag_d(mesi_state_confirmation_verified_flag_d),
        .mesi_state_to_cache_a(mesi_state_to_cache_a),
        .mesi_state_to_cache_b(mesi_state_to_cache_b),
        .mesi_state_to_cache_c(mesi_state_to_cache_c),
        .mesi_state_to_cache_d(mesi_state_to_cache_d),
        .arbiter_verify_a(arbiter_verify_a),
        .arbiter_verify_b(arbiter_verify_b),
        .arbiter_verify_c(arbiter_verify_c),
        .arbiter_verify_d(arbiter_verify_d),
        .cache_fsm_L2a_block_to_arbiter_verified(cache_fsm_L2a_block_to_arbiter_verified),
        .cache_fsm_L2b_block_to_arbiter_verified(cache_fsm_L2b_block_to_arbiter_verified),
        .cache_fsm_L2c_block_to_arbiter_verified(cache_fsm_L2c_block_to_arbiter_verified),
        .cache_fsm_L2d_block_to_arbiter_verified(cache_fsm_L2d_block_to_arbiter_verified),
        .write_back_to_L3_request_from_L2a_arbiter(write_back_to_L3_request_from_L2a_arbiter),
        .write_back_to_L3_request_from_L2b_arbiter(write_back_to_L3_request_from_L2b_arbiter),
        .write_back_to_L3_request_from_L2c_arbiter(write_back_to_L3_request_from_L2c_arbiter),
        .write_back_to_L3_request_from_L2d_arbiter(write_back_to_L3_request_from_L2d_arbiter),
        .read_from_arbiter_request_from_L2a_to_L3(read_from_arbiter_request_from_L2a_to_L3),
        .read_from_arbiter_request_from_L2b_to_L3(read_from_arbiter_request_from_L2b_to_L3),
        .read_from_arbiter_request_from_L2c_to_L3(read_from_arbiter_request_from_L2c_to_L3),
        .read_from_arbiter_request_from_L2d_to_L3(read_from_arbiter_request_from_L2d_to_L3),
        .arbiter_confirmed_L3_ready_for_L2a(arbiter_confirmed_L3_ready_for_L2a),
        .arbiter_confirmed_L3_ready_for_L2b(arbiter_confirmed_L3_ready_for_L2b),
        .arbiter_confirmed_L3_ready_for_L2c(arbiter_confirmed_L3_ready_for_L2c),
        .arbiter_confirmed_L3_ready_for_L2d(arbiter_confirmed_L3_ready_for_L2d),
        .write_back_to_L3_from_arbiter_a_verified(write_back_to_L3_from_arbiter_a_verified),
        .write_back_to_L3_from_arbiter_b_verified(write_back_to_L3_from_arbiter_b_verified),
        .write_back_to_L3_from_arbiter_c_verified(write_back_to_L3_from_arbiter_c_verified),
        .write_back_to_L3_from_arbiter_d_verified(write_back_to_L3_from_arbiter_d_verified),
        .cache_L3a_memory_address_to_array_L3a_from_arbiter_flag(cache_L3a_memory_address_to_array_L3a_from_arbiter_flag),
        .cache_L3b_memory_address_to_array_L3b_from_arbiter_flag(cache_L3b_memory_address_to_array_L3b_from_arbiter_flag),
        .cache_L3c_memory_address_to_array_L3c_from_arbiter_flag(cache_L3c_memory_address_to_array_L3c_from_arbiter_flag),
        .cache_L3d_memory_address_to_array_L3d_from_arbiter_flag(cache_L3d_memory_address_to_array_L3d_from_arbiter_flag),
        .mesi_state_confirmation_a(mesi_state_confirmation_a),
        .mesi_state_confirmation_b(mesi_state_confirmation_b),
        .mesi_state_confirmation_c(mesi_state_confirmation_c),
        .mesi_state_confirmation_d(mesi_state_confirmation_d),
        .MESI_state_from_arbiter_for_testbench(MESI_state_from_arbiter_for_testbench)
    );
endmodule