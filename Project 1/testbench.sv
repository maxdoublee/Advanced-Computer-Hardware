//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//testbench

import cache_config::*;
import main_memory_config::*;

module testbench();
    logic clk;
    logic reset;
    logic cache_a_read_request, cache_b_read_request, cache_c_read_request, cache_d_read_request;
    logic cache_a_write_request, cache_b_write_request, cache_c_write_request, cache_d_write_request;
    logic [ADDRESS_WIDTH-1:0] cache_L1a_memory_address, cache_L1b_memory_address, cache_L1c_memory_address, cache_L1d_memory_address;
    logic [DATA_WIDTH-1:0] cache_1a_write_data, cache_1b_write_data, cache_1c_write_data, cache_1d_write_data;
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
    logic [ADDRESS_WIDTH-1:0] cache_L2a_memory_address, cache_L2b_memory_address, cache_L2c_memory_address, cache_L2d_memory_address; 
    logic arbiter_confirmed_L3_ready_for_L2a, arbiter_confirmed_L3_ready_for_L2b, arbiter_confirmed_L3_ready_for_L2c, arbiter_confirmed_L3_ready_for_L2d;
    logic write_back_to_L3_from_arbiter_a_verified, write_back_to_L3_from_arbiter_b_verified, write_back_to_L3_from_arbiter_c_verified, write_back_to_L3_from_arbiter_d_verified;
	logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache_a, mesi_state_to_cache_b, mesi_state_to_cache_c, mesi_state_to_cache_d;
    logic arbiter_verify_a, arbiter_verify_b, arbiter_verify_c, arbiter_verify_d;
	logic cache_fsm_L2a_block_to_arbiter_verified, cache_fsm_L2b_block_to_arbiter_verified, cache_fsm_L2c_block_to_arbiter_verified, cache_fsm_L2d_block_to_arbiter_verified;
    logic read_from_L3_request_from_L2a, read_from_L3_request_from_L2b, read_from_L3_request_from_L2c, read_from_L3_request_from_L2d;
    logic write_back_to_L3_request_from_L2a, write_back_to_L3_request_from_L2b, write_back_to_L3_request_from_L2c, write_back_to_L3_request_from_L2d;
    logic arbiter_read_update_from_L2a_cache_modules, arbiter_read_update_from_L2b_cache_modules, arbiter_read_update_from_L2c_cache_modules, arbiter_read_update_from_L2d_cache_modules;
    logic arbiter_write_update_from_L2a_cache_modules, arbiter_write_update_from_L2b_cache_modules, arbiter_write_update_from_L2c_cache_modules, arbiter_write_update_from_L2d_cache_modules;
	logic [ADDRESS_WIDTH-1:0] block_a_to_determine_mesi_state_from_arbiter, block_b_to_determine_mesi_state_from_arbiter, block_c_to_determine_mesi_state_from_arbiter, block_d_to_determine_mesi_state_from_arbiter;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2a_local_data, L2b_local_data, L2c_local_data, L2d_local_data;
    logic acknowledge_arbiter_verify_a, acknowledge_arbiter_verify_b, acknowledge_arbiter_verify_c, acknowledge_arbiter_verify_d;
    logic cache_fsm_L2a_block_to_arbiter, cache_fsm_L2b_block_to_arbiter, cache_fsm_L2c_block_to_arbiter, cache_fsm_L2d_block_to_arbiter;
    logic cache_L3a_memory_address_to_array_L3a_to_arbiter_flag, cache_L3b_memory_address_to_array_L3b_to_arbiter_flag, cache_L3c_memory_address_to_array_L3c_to_arbiter_flag, cache_L3d_memory_address_to_array_L3d_to_arbiter_flag;
    logic read_from_arbiter_request_from_L2a_to_L3, read_from_arbiter_request_from_L2b_to_L3, read_from_arbiter_request_from_L2c_to_L3, read_from_arbiter_request_from_L2d_to_L3;
    logic write_back_to_L3a_request, write_back_to_L3b_request, write_back_to_L3c_request, write_back_to_L3d_request;
    logic L3a_ready, L3b_ready, L3c_ready, L3d_ready;
    logic write_back_to_L3_from_L2a_verified, write_back_to_L3_from_L2b_verified, write_back_to_L3_from_L2c_verified, write_back_to_L3_from_L2d_verified; 
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3a_data, write_back_to_L3b_data, write_back_to_L3c_data, write_back_to_L3d_data;
	logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2a_from_L3a, write_data_to_L2b_from_L3b, write_data_to_L2c_from_L3c, write_data_to_L2d_from_L3d;
    logic [ADDRESS_WIDTH-1:0] cache_L3a_memory_address, cache_L3b_memory_address, cache_L3c_memory_address, cache_L3d_memory_address; 
    logic main_memory_read_request, main_memory_write_request;
    logic main_memory_ready;
    logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data, main_memory_write_data;
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
    logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] memory_address_for_processor_a_for_testbench;
    logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] memory_address_for_processor_b_for_testbench;
    logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] memory_address_for_processor_c_for_testbench;
    logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] memory_address_for_processor_d_for_testbench;

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
        .L1a_cache_ready(L1a_cache_ready)
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
        .L1b_cache_ready(L1b_cache_ready)
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
        .L1c_cache_ready(L1c_cache_ready)
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
        .L1d_cache_ready(L1d_cache_ready)
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
        .cache_L3a_memory_address_to_array_L3a_to_arbiter_flag(cache_L3a_memory_address_to_array_L3a_to_arbiter_flag)
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
        .cache_L3b_memory_address_to_array_L3b_to_arbiter_flag(cache_L3b_memory_address_to_array_L3b_to_arbiter_flag)
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
        .cache_L3c_memory_address_to_array_L3c_to_arbiter_flag(cache_L3c_memory_address_to_array_L3c_to_arbiter_flag)
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
        .cache_L3d_memory_address_to_array_L3d_to_arbiter_flag(cache_L3d_memory_address_to_array_L3d_to_arbiter_flag)
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
        .L3_cache_ready(L3_cache_ready)
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
        .cache_L3d_memory_address_to_array_L3d_from_arbiter_flag(cache_L3d_memory_address_to_array_L3d_from_arbiter_flag)
    );

    always begin
        #5 clk = ~clk; // Toggle clock every 5 time units
    end

    initial begin
        // Initialize testbench signals
        clk = 0;
        reset = 1;
        cache_a_read_request = 0;
        cache_b_read_request = 0;
        cache_c_read_request = 0;
        cache_d_read_request = 0;
        cache_a_write_request = 0;
        cache_b_write_request = 0;
        cache_c_write_request = 0;
        cache_d_write_request = 0;
        cache_L1a_memory_address = 0;
        cache_L1b_memory_address = 0;
        cache_L1c_memory_address = 0;
        cache_L1d_memory_address = 0;
        cache_1a_write_data = 0;
        cache_1b_write_data = 0;
        cache_1c_write_data = 0;
        cache_1d_write_data = 0;
        L2a_ready = 0;
        L2b_ready = 0;
        L2c_ready = 0;
        L2d_ready = 0;
        write_to_L2a_verified = 0;
        write_to_L2b_verified = 0;
        write_to_L2c_verified = 0;
        write_to_L2d_verified = 0;
        write_data_to_L1a_from_L2a = 0;
        write_data_to_L1b_from_L2b = 0;
        write_data_to_L1c_from_L2c = 0;
        write_data_to_L1d_from_L2d = 0;
        write_back_to_L2a_verified = 0;
        write_back_to_L2b_verified = 0;
        write_back_to_L2c_verified = 0;
        write_back_to_L2d_verified = 0;
        write_to_L2a_request = 0;
        write_to_L2b_request = 0;
        write_to_L2c_request = 0;
        write_to_L2d_request = 0;
        write_back_to_L2a_request = 0;
        write_back_to_L2b_request = 0;
        write_back_to_L2c_request = 0;
        write_back_to_L2d_request = 0;
        read_from_L2a_request = 0;
        read_from_L2b_request = 0;
        read_from_L2c_request = 0;
        read_from_L2d_request = 0;
        write_back_to_L2a_data = 0;
        write_back_to_L2b_data = 0;
        write_back_to_L2c_data = 0;
        write_back_to_L2d_data = 0;
        cache_L1a_read_data = 0;
        cache_L1b_read_data = 0;
        cache_L1c_read_data = 0;
        cache_L1d_read_data = 0;
        cache_1a_write_data_to_L2a = 0;
        cache_1b_write_data_to_L2b = 0;
        cache_1c_write_data_to_L2c = 0;
        cache_1d_write_data_to_L2d = 0;
        cache_L2a_memory_address = 0;
        cache_L2b_memory_address = 0;
        cache_L2c_memory_address = 0;
        cache_L2d_memory_address = 0;
        arbiter_confirmed_L3_ready_for_L2a = 0;
        arbiter_confirmed_L3_ready_for_L2b = 0;
        arbiter_confirmed_L3_ready_for_L2c = 0;
        arbiter_confirmed_L3_ready_for_L2d = 0;
        write_back_to_L3_from_arbiter_a_verified = 0;
        write_back_to_L3_from_arbiter_b_verified = 0;
        write_back_to_L3_from_arbiter_c_verified = 0;
        write_back_to_L3_from_arbiter_d_verified = 0;
        mesi_state_to_cache_a = 0;
        mesi_state_to_cache_b = 0;
        mesi_state_to_cache_c = 0;
        mesi_state_to_cache_d = 0;
        arbiter_verify_a = 0;
        arbiter_verify_b = 0;
        arbiter_verify_c = 0;
        arbiter_verify_d = 0;
        cache_fsm_L2a_block_to_arbiter_verified = 0;
        cache_fsm_L2b_block_to_arbiter_verified = 0;
        cache_fsm_L2c_block_to_arbiter_verified = 0;
        cache_fsm_L2d_block_to_arbiter_verified = 0;
        read_from_L3_request_from_L2a = 0;
        read_from_L3_request_from_L2b = 0;
        read_from_L3_request_from_L2c = 0;
        read_from_L3_request_from_L2d = 0;
        write_back_to_L3_request_from_L2a = 0;
        write_back_to_L3_request_from_L2b = 0;
        write_back_to_L3_request_from_L2c = 0;
        write_back_to_L3_request_from_L2d = 0;
        arbiter_read_update_from_L2a_cache_modules = 0;
        arbiter_read_update_from_L2b_cache_modules = 0;
        arbiter_read_update_from_L2c_cache_modules = 0;
        arbiter_read_update_from_L2d_cache_modules = 0;
        arbiter_write_update_from_L2a_cache_modules = 0;
        arbiter_write_update_from_L2b_cache_modules = 0;
        arbiter_write_update_from_L2c_cache_modules = 0;
        arbiter_write_update_from_L2d_cache_modules = 0;
        block_a_to_determine_mesi_state_from_arbiter = 0;
        block_b_to_determine_mesi_state_from_arbiter = 0;
        block_c_to_determine_mesi_state_from_arbiter = 0;
        block_d_to_determine_mesi_state_from_arbiter = 0;
        L2a_local_data = 0;
        L2b_local_data = 0;
        L2c_local_data = 0;
        L2d_local_data = 0;
        acknowledge_arbiter_verify_a = 0;
        acknowledge_arbiter_verify_b = 0;
        acknowledge_arbiter_verify_c = 0;
        acknowledge_arbiter_verify_d = 0;
        cache_fsm_L2a_block_to_arbiter = 0;
        cache_fsm_L2b_block_to_arbiter = 0;
        cache_fsm_L2c_block_to_arbiter = 0;
        cache_fsm_L2d_block_to_arbiter = 0;
        cache_L3a_memory_address_to_array_L3a_to_arbiter_flag = 0;
        cache_L3b_memory_address_to_array_L3b_to_arbiter_flag = 0;
        cache_L3c_memory_address_to_array_L3c_to_arbiter_flag = 0;
        cache_L3d_memory_address_to_array_L3d_to_arbiter_flag = 0;
        read_from_arbiter_request_from_L2a_to_L3 = 0;
        read_from_arbiter_request_from_L2b_to_L3 = 0;
        read_from_arbiter_request_from_L2c_to_L3 = 0;
        read_from_arbiter_request_from_L2d_to_L3 = 0;
        write_back_to_L3a_request = 0;
        write_back_to_L3b_request = 0;
        write_back_to_L3c_request = 0;
        write_back_to_L3d_request = 0;
        L3a_ready = 0;
        L3b_ready = 0;
        L3c_ready = 0;
        L3d_ready = 0;
        write_back_to_L3_from_L2a_verified = 0;
        write_back_to_L3_from_L2b_verified = 0;
        write_back_to_L3_from_L2c_verified = 0;
        write_back_to_L3_from_L2d_verified = 0;
        write_back_to_L3a_data = 0;
        write_back_to_L3b_data = 0;
        write_back_to_L3c_data = 0;
        write_back_to_L3d_data = 0;
        write_data_to_L2a_from_L3a = 0;
        write_data_to_L2b_from_L3b = 0;
        write_data_to_L2c_from_L3c = 0;
        write_data_to_L2d_from_L3d = 0;
        cache_L3a_memory_address = 0;
        cache_L3b_memory_address = 0;
        cache_L3c_memory_address = 0;
        cache_L3d_memory_address = 0;
        main_memory_read_request = 0;
        main_memory_write_request = 0;
        main_memory_ready = 0;
        main_memory_address = 0;
        main_memory_read_data = 0;
        main_memory_write_data = 0; 
        L1a_cache_hit = 0;
        L1b_cache_hit = 0;
        L1c_cache_hit = 0;
        L1d_cache_hit = 0;
        L1a_cache_miss = 0;
        L1b_cache_miss = 0;
        L1c_cache_miss = 0;
        L1d_cache_miss = 0;
        L1a_cache_ready = 0;
        L1b_cache_ready = 0;
        L1c_cache_ready = 0;
        L1d_cache_ready = 0;
        L2a_cache_read_hit = 0;
        L2b_cache_read_hit = 0;
        L2c_cache_read_hit = 0;
        L2d_cache_read_hit = 0;
        L2a_cache_write_hit = 0;
        L2b_cache_write_hit = 0;
        L2c_cache_write_hit = 0;
        L2d_cache_write_hit = 0;
        L2a_cache_miss = 0;
        L2b_cache_miss = 0;
        L2c_cache_miss = 0;
        L2d_cache_miss = 0;
        L2a_cache_ready = 0;
        L2b_cache_ready = 0;
        L2c_cache_ready = 0;
        L2d_cache_ready = 0;
        L3_cache_hit = 0;
        L3_cache_miss = 0;
        L3_cache_ready = 0;
        memory_address_for_processor_a_for_testbench = 0;
        memory_address_for_processor_b_for_testbench = 0;
        memory_address_for_processor_c_for_testbench = 0;
        memory_address_for_processor_d_for_testbench = 0;

        //Reset the system
        #20 reset = 0; //Wait a little longer for reset to take effect

        //Test Case 1: LRU

        //Test Case 2: Inclusion policy

        //Test Case 3: MESI
        //Start with providing main memory an arbitrary address and data as cache hierarchy starts blank
        memory_address_for_processor_a_for_testbench = 32'h20000000;
        main_memory_address = memory_address_for_processor_a_for_testbench;
        main_memory_write_data = 128'hDFFFFFFFDFFFFFFFDFFFFFFFDFFFFFFF; 
        main_memory_write_request = 1'b1;
        wait(main_memory_ready);
        $display("Main memory received inputted data");
        main_memory_write_request = 1'b0;
        //Now that main memory has data, I will send out a request from processor a which will lead to a cascading of allocates throughout cache levels until fetching the data from main memory and that same data eventually being allocated into cache level one. 
        cache_L1a_memory_address = memory_address_for_processor_a_for_testbench; //requested address from processor
        cache_a_read_request = 1'b1; 
        wait(L1a_cache_miss);
        $display("Cache L1a missed");
        wait(L2a_cache_miss);
        $display("Cache L2a missed");
        wait(L3_cache_miss);
        $display("L3 miss");
        wait(main_memory_ready);
        $display("main_memory_read_data now holds data stored");
    end
        
    // Monitor signals during simulation
    initial begin
        $monitor(
            "   
            Time= %g clk= %0b reset= %0b   
            cache_a_read_request= %0b cache_b_read_request= %0b cache_c_read_request= %0b cache_d_read_request= %0b   
            cache_a_write_request= %0b cache_b_write_request= %0b cache_c_write_request= %0b cache_d_write_request= %0b  
            cache_L1a_memory_address= %0h cache_L1b_memory_address= %0h cache_L1c_memory_address= %0h cache_L1d_memory_address= %0h   
            cache_1a_write_data= %0h cache_1b_write_data= %0h cache_1c_write_data= %0h cache_1d_write_data= %0h  
            L2a_ready= %0b L2b_ready= %0b L2c_ready= %0b L2d_ready= %0b   
            write_to_L2a_verified= %0b write_to_L2b_verified= %0b write_to_L2c_verified= %0b write_to_L2d_verified= %0b   
            write_data_to_L1a_from_L2a= %0b write_data_to_L1b_from_L2b= %0b write_data_to_L1c_from_L2c= %0b write_data_to_L1d_from_L2d= %0b   
            write_back_to_L2a_verified= %0b write_back_to_L2b_verified= %0b write_back_to_L2c_verified= %0b write_back_to_L2d_verified= %0b   
            write_to_L2a_request= %0b write_to_L2b_request= %0b write_to_L2c_request= %0b write_to_L2d_request= %0b   
            write_back_to_L2a_request= %0b write_back_to_L2b_request= %0b write_back_to_L2c_request= %0b write_back_to_L2d_request= %0b   
            read_from_L2a_request= %0b read_from_L2b_request= %0b read_from_L2c_request= %0b read_from_L2d_request= %0b   
            write_back_to_L2a_data= %0h write_back_to_L2b_data= %0h write_back_to_L2c_data= %0h write_back_to_L2d_data= %0h  
            cache_L1a_read_data= %0h cache_L1b_read_data= %0h cache_L1c_read_data= %0h cache_L1d_read_data= %0h   
            cache_1a_write_data_to_L2a= %0h cache_1b_write_data_to_L2b= %0h cache_1c_write_data_to_L2c= %0h cache_1d_write_data_to_L2d= %0h   
            cache_L2a_memory_address= %0h cache_L2b_memory_address= %0h cache_L2c_memory_address= %0h cache_L2d_memory_address= %0h   
            arbiter_confirmed_L3_ready_for_L2a= %0b arbiter_confirmed_L3_ready_for_L2b= %0b arbiter_confirmed_L3_ready_for_L2c= %0b arbiter_confirmed_L3_ready_for_L2d= %0b   
            write_back_to_L3_from_arbiter_a_verified= %0b write_back_to_L3_from_arbiter_b_verified= %0b write_back_to_L3_from_arbiter_c_verified= %0b write_back_to_L3_from_arbiter_d_verified= %0b   
            mesi_state_to_cache_a= %0h mesi_state_to_cache_b= %0h mesi_state_to_cache_c= %0h mesi_state_to_cache_d= %0h   
            arbiter_verify_a= %0b arbiter_verify_b= %0b arbiter_verify_c= %0b arbiter_verify_d= %0b   
            cache_fsm_L2a_block_to_arbiter_verified= %0b cache_fsm_L2b_block_to_arbiter_verified= %0b cache_fsm_L2c_block_to_arbiter_verified= %0b cache_fsm_L2d_block_to_arbiter_verified= %0b   
            read_from_L3_request_from_L2a= %0b read_from_L3_request_from_L2b= %0b read_from_L3_request_from_L2c= %0b read_from_L3_request_from_L2d= %0b   
            write_back_to_L3_request_from_L2a= %0b write_back_to_L3_request_from_L2b= %0b write_back_to_L3_request_from_L2c= %0b write_back_to_L3_request_from_L2d= %0b   
            arbiter_read_update_from_L2a_cache_modules= %0b arbiter_read_update_from_L2b_cache_modules= %0b arbiter_read_update_from_L2c_cache_modules= %0b arbiter_read_update_from_L2d_cache_modules= %0b   
            arbiter_write_update_from_L2a_cache_modules= %0b arbiter_write_update_from_L2b_cache_modules= %0b arbiter_write_update_from_L2c_cache_modules= %0b arbiter_write_update_from_L2d_cache_modules= %0b   
            block_a_to_determine_mesi_state_from_arbiter= %0b block_b_to_determine_mesi_state_from_arbiter= %0b block_c_to_determine_mesi_state_from_arbiter= %0b block_d_to_determine_mesi_state_from_arbiter= %0b   
            L2a_local_data= %0b L2b_local_data= %0b L2c_local_data= %0b L2d_local_data= %0b   
            acknowledge_arbiter_verify_a= %0b acknowledge_arbiter_verify_b= %0b acknowledge_arbiter_verify_c= %0b acknowledge_arbiter_verify_d= %0b   
            cache_fsm_L2a_block_to_arbiter= %0b cache_fsm_L2b_block_to_arbiter= %0b cache_fsm_L2c_block_to_arbiter= %0b cache_fsm_L2d_block_to_arbiter= %0b   
            cache_L3a_memory_address_to_array_L3a_to_arbiter_flag= %0b cache_L3b_memory_address_to_array_L3b_to_arbiter_flag= %0b cache_L3c_memory_address_to_array_L3c_to_arbiter_flag= %0b cache_L3d_memory_address_to_array_L3d_to_arbiter_flag= %0b   
            read_from_arbiter_request_from_L2a_to_L3= %0b read_from_arbiter_request_from_L2b_to_L3= %0b read_from_arbiter_request_from_L2c_to_L3= %0b read_from_arbiter_request_from_L2d_to_L3= %0b   
            write_back_to_L3a_request= %0b write_back_to_L3b_request= %0b write_back_to_L3c_request= %0b write_back_to_L3d_request= %0b   
            L3a_ready= %0b L3b_ready= %0b L3c_ready= %0b L3d_ready= %0b   
            write_back_to_L3_from_L2a_verified= %0b write_back_to_L3_from_L2b_verified= %0b write_back_to_L3_from_L2c_verified= %0b write_back_to_L3_from_L2d_verified= %0b   
            write_back_to_L3a_data= %0h write_back_to_L3a_data= %0h write_back_to_L3a_data= %0h write_back_to_L3a_data= %0h   
            write_data_to_L2a_from_L3a= %0h write_data_to_L2b_from_L3b= %0h write_data_to_L2c_from_L3c= %0h write_data_to_L2d_from_L3d= %0h   
            cache_L3a_memory_address= %0h cache_L3b_memory_address= %0h cache_L3c_memory_address= %0h cache_L3d_memory_address= %0h   
            main_memory_read_request= %0b main_memory_write_request= %0b main_memory_ready= %0b main_memory_address= %0h main_memory_read_data= %0h main_memory_write_data= %0h   
            L1a_cache_hit= %0b L1b_cache_hit= %0b L1c_cache_hit= %0b L1d_cache_hit= %0b  
            L1a_cache_miss= %0b L1b_cache_miss= %0b L1c_cache_miss= %0b L1d_cache_miss= %0b  
            L1a_cache_ready= %0b L1b_cache_ready= %0b L1c_cache_ready= %0b L1d_cache_ready= %0b  
            L2a_cache_read_hit= %0b L2b_cache_read_hit= %0b L2c_cache_read_hit= %0b L2d_cache_read_hit= %0b  
            L2a_cache_write_hit= %0b L2b_cache_write_hit= %0b L2c_cache_write_hit= %0b L2d_cache_write_hit= %0b  
            L2a_cache_miss= %0b L2b_cache_miss= %0b L2c_cache_miss= %0b L2d_cache_miss= %0b  
            L2a_cache_ready= %0b L2b_cache_ready= %0b L2c_cache_ready= %0b L2d_cache_ready= %0b  
            L3_cache_hit= %0b L3_cache_miss= %0b L3_cache_ready= %0b  
            memory_address_for_processor_a_for_testbench= %0h memory_address_for_processor_b_for_testbench= %0h memory_address_for_processor_c_for_testbench= %0h memory_address_for_processor_d_for_testbench= %0h",
            $time, 
            clk, 
            reset, 
            cache_a_read_request, cache_b_read_request, cache_c_read_request, cache_d_read_request,
            cache_a_write_request, cache_b_write_request, cache_c_write_request, cache_d_write_request,
            cache_L1a_memory_address, cache_L1b_memory_address, cache_L1c_memory_address, cache_L1d_memory_address,
            cache_1a_write_data, cache_1b_write_data, cache_1c_write_data, cache_1d_write_data,
            L2a_ready, L2b_ready, L2c_ready, L2d_ready,
            write_to_L2a_verified, write_to_L2b_verified, write_to_L2c_verified, write_to_L2d_verified,
            write_data_to_L1a_from_L2a, write_data_to_L1b_from_L2b, write_data_to_L1c_from_L2c, write_data_to_L1d_from_L2d,
            write_back_to_L2a_verified, write_back_to_L2b_verified, write_back_to_L2c_verified, write_back_to_L2d_verified,
            write_to_L2a_request, write_to_L2b_request, write_to_L2c_request, write_to_L2d_request,
            write_back_to_L2a_request, write_back_to_L2b_request, write_back_to_L2c_request, write_back_to_L2d_request,
            read_from_L2a_request, read_from_L2b_request, read_from_L2c_request, read_from_L2d_request,
            write_back_to_L2a_data, write_back_to_L2b_data, write_back_to_L2c_data, write_back_to_L2d_data, 
            cache_L1a_read_data, cache_L1b_read_data, cache_L1c_read_data, cache_L1d_read_data,
            cache_1a_write_data_to_L2a, cache_1b_write_data_to_L2b, cache_1c_write_data_to_L2c, cache_1d_write_data_to_L2d,
            cache_L2a_memory_address, cache_L2b_memory_address, cache_L2c_memory_address, cache_L2d_memory_address,
            arbiter_confirmed_L3_ready_for_L2a, arbiter_confirmed_L3_ready_for_L2b, arbiter_confirmed_L3_ready_for_L2c, arbiter_confirmed_L3_ready_for_L2d,
            write_back_to_L3_from_arbiter_a_verified, write_back_to_L3_from_arbiter_b_verified, write_back_to_L3_from_arbiter_c_verified, write_back_to_L3_from_arbiter_d_verified,
            mesi_state_to_cache_a, mesi_state_to_cache_b, mesi_state_to_cache_c, mesi_state_to_cache_d,
            arbiter_verify_a, arbiter_verify_b, arbiter_verify_c, arbiter_verify_d,
            cache_fsm_L2a_block_to_arbiter_verified, cache_fsm_L2b_block_to_arbiter_verified, cache_fsm_L2c_block_to_arbiter_verified, cache_fsm_L2d_block_to_arbiter_verified,
            read_from_L3_request_from_L2a, read_from_L3_request_from_L2b, read_from_L3_request_from_L2c, read_from_L3_request_from_L2d,
            write_back_to_L3_request_from_L2a, write_back_to_L3_request_from_L2b, write_back_to_L3_request_from_L2c, write_back_to_L3_request_from_L2a,
            arbiter_read_update_from_L2a_cache_modules, arbiter_read_update_from_L2b_cache_modules, arbiter_read_update_from_L2c_cache_modules, arbiter_read_update_from_L2d_cache_modules,
            arbiter_write_update_from_L2a_cache_modules, arbiter_write_update_from_L2b_cache_modules, arbiter_write_update_from_L2c_cache_modules, arbiter_write_update_from_L2d_cache_modules,
            block_a_to_determine_mesi_state_from_arbiter, block_b_to_determine_mesi_state_from_arbiter, block_c_to_determine_mesi_state_from_arbiter, block_d_to_determine_mesi_state_from_arbiter,
            L2a_local_data, L2b_local_data, L2c_local_data, L2d_local_data,
            acknowledge_arbiter_verify_a, acknowledge_arbiter_verify_b, acknowledge_arbiter_verify_c, acknowledge_arbiter_verify_d,
            cache_fsm_L2a_block_to_arbiter, cache_fsm_L2b_block_to_arbiter, cache_fsm_L2c_block_to_arbiter, cache_fsm_L2d_block_to_arbiter,
            cache_L3a_memory_address_to_array_L3a_to_arbiter_flag, cache_L3b_memory_address_to_array_L3b_to_arbiter_flag, cache_L3c_memory_address_to_array_L3c_to_arbiter_flag, cache_L3d_memory_address_to_array_L3d_to_arbiter_flag,
            read_from_arbiter_request_from_L2a_to_L3, read_from_arbiter_request_from_L2b_to_L3, read_from_arbiter_request_from_L2c_to_L3, read_from_arbiter_request_from_L2d_to_L3,
            write_back_to_L3a_request, write_back_to_L3b_request, write_back_to_L3c_request, write_back_to_L3d_request,
            L3a_ready, L3b_ready, L3c_ready, L3d_ready,
            write_back_to_L3_from_L2a_verified, write_back_to_L3_from_L2b_verified, write_back_to_L3_from_L2c_verified, write_back_to_L3_from_L2d_verified,
            write_back_to_L3a_data, write_back_to_L3b_data, write_back_to_L3c_data, write_back_to_L3d_data,
            write_data_to_L2a_from_L3a, write_data_to_L2b_from_L3b, write_data_to_L2c_from_L3c, write_data_to_L2d_from_L3d,
            cache_L3a_memory_address, cache_L3b_memory_address, cache_L3c_memory_address, cache_L3d_memory_address,
            main_memory_read_request, main_memory_write_request, main_memory_ready, main_memory_address, main_memory_read_data, main_memory_write_data, 
            L1a_cache_hit, L1b_cache_hit, L1c_cache_hit, L1d_cache_hit,
            L1a_cache_miss, L1b_cache_miss, L1c_cache_miss, L1d_cache_miss,
            L1a_cache_ready, L1b_cache_ready, L1c_cache_ready, L1d_cache_ready,
            L2a_cache_read_hit, L2b_cache_read_hit, L2c_cache_read_hit, L2d_cache_read_hit,
            L2a_cache_write_hit, L2b_cache_write_hit, L2c_cache_write_hit, L2d_cache_write_hit,
            L2a_cache_miss, L2b_cache_miss, L2c_cache_miss, L2d_cache_miss,
            L2a_cache_ready, L2b_cache_ready, L2c_cache_ready, L2d_cache_ready,
            L3_cache_hit, L3_cache_miss, L3_cache_ready,
            memory_address_for_processor_a_for_testbench, memory_address_for_processor_b_for_testbench, memory_address_for_processor_c_for_testbench, memory_address_for_processor_d_for_testbench
        );
    end
endmodule