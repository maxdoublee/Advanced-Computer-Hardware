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
    input logic cache_read_request, 
    input logic cache_write_request, 
    input logic [ADDRESS_WIDTH-1:0] cache_L1_memory_address,
    input logic [DATA_WIDTH-1:0] cache_write_data
);

    // Internal signals for L1 to L2 communication
    logic write_to_L2_request, read_from_L2_request, write_back_to_L2_request;
    logic write_to_L2_verified, write_back_to_L2_verified;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L1_from_L2; 
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2_data;
    logic [ADDRESS_WIDTH-1:0] cache_L2_memory_address; // For addressing L2 cache

    // Internal signals for L2 to L3 communication
    logic read_from_L3_request, write_back_to_L3_request;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3_data; 
    logic write_back_to_L3_verified; 
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2_from_L3; 
    logic [ADDRESS_WIDTH-1:0] cache_L3_memory_address; // For addressing L3 cache

    // Internal signals for L3 to Main Memory communication
    logic main_memory_read_request, main_memory_write_request;
    logic main_memory_ready;
    logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data, main_memory_write_data;

    // Internal signals for L2 to arbiter communication
    logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache;
    logic arbiter_verify;
    logic arbiter_read_update_from_L2_cache_modules;
    logic arbiter_write_update_from_L2_cache_modules;
    logic [ADDRESS_WIDTH-1:0] block_to_determine_mesi_state_from_arbiter;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2a_local_data, L2b_local_data, L2c_local_data, L2d_local_data;
    logic acknowledge_arbiter_verify;

    // Internal signals to indicate cache status
    logic L2_ready, L3_ready; // Status signals for L2 and L3 caches

    // Instantiate L1 caches
    cache_fsm_L1a #(
        .CACHE_LEVEL(1)
    ) top_cache_fsm_L1a (
        .clk(clk),
        .reset(reset),
        .L2_ready(L2_ready),
        .cache_L1_memory_address(cache_L1_memory_address),
        .write_to_L2_verified(write_to_L2_verified),
        .write_data_to_L1_from_L2(write_data_to_L1_from_L2),
        .write_back_to_L2_verified(write_back_to_L2_verified),
        .cache_L1_read_data(cache_L1_read_data),
        .L1_cache_hit(L1_cache_hit),
        .L1_cache_miss(L1_cache_miss),
        .L1_cache_ready(L1_cache_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2_request(write_to_L2_request),
        .write_back_to_L2_request(write_back_to_L2_request),
        .write_back_to_L2_data(write_back_to_L2_data)
    ); 
    cache_fsm_L1b #(
        .CACHE_LEVEL(1)
    ) top_cache_fsm_L1b (
        .clk(clk),
        .reset(reset),
        .L2_ready(L2_ready),
        .cache_L1_memory_address(cache_L1_memory_address),
        .write_to_L2_verified(write_to_L2_verified),
        .write_data_to_L1_from_L2(write_data_to_L1_from_L2),
        .write_back_to_L2_verified(write_back_to_L2_verified),
        .cache_L1_read_data(cache_L1_read_data),
        .L1_cache_hit(L1_cache_hit),
        .L1_cache_miss(L1_cache_miss),
        .L1_cache_ready(L1_cache_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2_request(write_to_L2_request),
        .write_back_to_L2_request(write_back_to_L2_request),
        .write_back_to_L2_data(write_back_to_L2_data)
    );  
    cache_fsm_L1c #(
        .CACHE_LEVEL(1)
    ) top_cache_fsm_L1c (
        .clk(clk),
        .reset(reset),
        .L2_ready(L2_ready),
        .cache_L1_memory_address(cache_L1_memory_address),
        .write_to_L2_verified(write_to_L2_verified),
        .write_data_to_L1_from_L2(write_data_to_L1_from_L2),
        .write_back_to_L2_verified(write_back_to_L2_verified),
        .cache_L1_read_data(cache_L1_read_data),
        .L1_cache_hit(L1_cache_hit),
        .L1_cache_miss(L1_cache_miss),
        .L1_cache_ready(L1_cache_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2_request(write_to_L2_request),
        .write_back_to_L2_request(write_back_to_L2_request),
        .write_back_to_L2_data(write_back_to_L2_data)
    );  
    cache_fsm_L1d #(
        .CACHE_LEVEL(1)
    ) top_cache_fsm_L1d (
        .clk(clk),
        .reset(reset),
        .L2_ready(L2_ready),
        .cache_L1_memory_address(cache_L1_memory_address),
        .write_to_L2_verified(write_to_L2_verified),
        .write_data_to_L1_from_L2(write_data_to_L1_from_L2),
        .write_back_to_L2_verified(write_back_to_L2_verified),
        .cache_L1_read_data(cache_L1_read_data),
        .L1_cache_hit(L1_cache_hit),
        .L1_cache_miss(L1_cache_miss),
        .L1_cache_ready(L1_cache_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2_request(write_to_L2_request),
        .write_back_to_L2_request(write_back_to_L2_request),
        .write_back_to_L2_data(write_back_to_L2_data)
    );    

    // Instantiate L2 caches
    cache_fsm_L2a #(
        .CACHE_LEVEL(2)
    ) top_cache_fsm_L2a (
        .clk(clk),
        .reset(reset),
        .L3_ready(L3_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2_request(write_to_L2_request),
        .read_from_L2_request(read_from_L2_request),
        .write_back_to_L2_request(write_back_to_L2_request),
        .write_back_to_L2_data(write_back_to_L2_data),
        .write_data_to_L2_from_L3(write_data_to_L2_from_L3),
        .write_back_to_L3_verified(write_back_to_L3_verified),
        .mesi_state_to_cache(mesi_state_to_cache),
        .arbiter_verify(arbiter_verify),
        .L2_cache_hit(L2_cache_hit),
        .L2_cache_read_hit(L2_cache_read_hit),
        .L2_cache_write_hit(L2_cache_write_hit),
        .L2_cache_miss(L2_cache_miss),
        .L2_cache_read_miss(L2_cache_read_miss),
        .L2_cache_write_miss(L2_cache_write_miss),
        .L2_cache_ready(L2_cache_ready),
        .write_to_L2_verified(write_to_L2_verified),
        .read_from_L3_request(read_from_L3_request),
        .write_back_to_L3_request(write_back_to_L3_request),
        .L2_ready(L2_ready),
        .write_data_to_L1_from_L2(write_data_to_L1_from_L2),
        .write_back_to_L2_verified(write_back_to_L2_verified),
        .write_back_to_L3_data(write_back_to_L3_data),
        .cache_L3_memory_address(cache_L3_memory_address),
        .arbiter_read_update_from_L2_cache_modules(arbiter_read_update_from_L2_cache_modules),
        .arbiter_write_update_from_L2_cache_modules(arbiter_write_update_from_L2_cache_modules),
        .block_to_determine_mesi_state_from_arbiter(block_to_determine_mesi_state_from_arbiter),
        .L2a_local_data(L2a_local_data),
        .acknowledge_arbiter_verify(acknowledge_arbiter_verify)
    );
    cache_fsm_L2b #(
        .CACHE_LEVEL(2)
    ) top_cache_fsm_L2b (
        .clk(clk),
        .reset(reset),
        .L3_ready(L3_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2_request(write_to_L2_request),
        .read_from_L2_request(read_from_L2_request),
        .write_back_to_L2_request(write_back_to_L2_request),
        .write_back_to_L2_data(write_back_to_L2_data),
        .write_data_to_L2_from_L3(write_data_to_L2_from_L3),
        .write_back_to_L3_verified(write_back_to_L3_verified),
        .mesi_state_to_cache(mesi_state_to_cache),
        .arbiter_verify(arbiter_verify),
        .L2_cache_hit(L2_cache_hit),
        .L2_cache_read_hit(L2_cache_read_hit),
        .L2_cache_write_hit(L2_cache_write_hit),
        .L2_cache_miss(L2_cache_miss),
        .L2_cache_read_miss(L2_cache_read_miss),
        .L2_cache_write_miss(L2_cache_write_miss),
        .L2_cache_ready(L2_cache_ready),
        .write_to_L2_verified(write_to_L2_verified),
        .read_from_L3_request(read_from_L3_request),
        .write_back_to_L3_request(write_back_to_L3_request),
        .L2_ready(L2_ready),
        .write_data_to_L1_from_L2(write_data_to_L1_from_L2),
        .write_back_to_L2_verified(write_back_to_L2_verified),
        .write_back_to_L3_data(write_back_to_L3_data),
        .cache_L3_memory_address(cache_L3_memory_address),
        .arbiter_read_update_from_L2_cache_modules(arbiter_read_update_from_L2_cache_modules),
        .arbiter_write_update_from_L2_cache_modules(arbiter_write_update_from_L2_cache_modules),
        .block_to_determine_mesi_state_from_arbiter(block_to_determine_mesi_state_from_arbiter),
        .L2b_local_data(L2a_local_data),
        .acknowledge_arbiter_verify(acknowledge_arbiter_verify)
    );
    cache_fsm_L2c #(
        .CACHE_LEVEL(2)
    ) top_cache_fsm_L2c (
        .clk(clk),
        .reset(reset),
        .L3_ready(L3_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2_request(write_to_L2_request),
        .read_from_L2_request(read_from_L2_request),
        .write_back_to_L2_request(write_back_to_L2_request),
        .write_back_to_L2_data(write_back_to_L2_data),
        .write_data_to_L2_from_L3(write_data_to_L2_from_L3),
        .write_back_to_L3_verified(write_back_to_L3_verified),
        .mesi_state_to_cache(mesi_state_to_cache),
        .arbiter_verify(arbiter_verify),
        .L2_cache_hit(L2_cache_hit),
        .L2_cache_read_hit(L2_cache_read_hit),
        .L2_cache_write_hit(L2_cache_write_hit),
        .L2_cache_miss(L2_cache_miss),
        .L2_cache_read_miss(L2_cache_read_miss),
        .L2_cache_write_miss(L2_cache_write_miss),
        .L2_cache_ready(L2_cache_ready),
        .write_to_L2_verified(write_to_L2_verified),
        .read_from_L3_request(read_from_L3_request),
        .write_back_to_L3_request(write_back_to_L3_request),
        .L2_ready(L2_ready),
        .write_data_to_L1_from_L2(write_data_to_L1_from_L2),
        .write_back_to_L2_verified(write_back_to_L2_verified),
        .write_back_to_L3_data(write_back_to_L3_data),
        .cache_L3_memory_address(cache_L3_memory_address),
        .arbiter_read_update_from_L2_cache_modules(arbiter_read_update_from_L2_cache_modules),
        .arbiter_write_update_from_L2_cache_modules(arbiter_write_update_from_L2_cache_modules),
        .block_to_determine_mesi_state_from_arbiter(block_to_determine_mesi_state_from_arbiter),
        .L2c_local_data(L2a_local_data),
        .acknowledge_arbiter_verify(acknowledge_arbiter_verify)
    );
    cache_fsm_L2d #(
        .CACHE_LEVEL(2)
    ) top_cache_fsm_L2d (
        .clk(clk),
        .reset(reset),
        .L3_ready(L3_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2_request(write_to_L2_request),
        .read_from_L2_request(read_from_L2_request),
        .write_back_to_L2_request(write_back_to_L2_request),
        .write_back_to_L2_data(write_back_to_L2_data),
        .write_data_to_L2_from_L3(write_data_to_L2_from_L3),
        .write_back_to_L3_verified(write_back_to_L3_verified),
        .mesi_state_to_cache(mesi_state_to_cache),
        .arbiter_verify(arbiter_verify),
        .L2_cache_hit(L2_cache_hit),
        .L2_cache_read_hit(L2_cache_read_hit),
        .L2_cache_write_hit(L2_cache_write_hit),
        .L2_cache_miss(L2_cache_miss),
        .L2_cache_read_miss(L2_cache_read_miss),
        .L2_cache_write_miss(L2_cache_write_miss),
        .L2_cache_ready(L2_cache_ready),
        .write_to_L2_verified(write_to_L2_verified),
        .read_from_L3_request(read_from_L3_request),
        .write_back_to_L3_request(write_back_to_L3_request),
        .L2_ready(L2_ready),
        .write_data_to_L1_from_L2(write_data_to_L1_from_L2),
        .write_back_to_L2_verified(write_back_to_L2_verified),
        .write_back_to_L3_data(write_back_to_L3_data),
        .cache_L3_memory_address(cache_L3_memory_address),
        .arbiter_read_update_from_L2_cache_modules(arbiter_read_update_from_L2_cache_modules),
        .arbiter_write_update_from_L2_cache_modules(arbiter_write_update_from_L2_cache_modules),
        .block_to_determine_mesi_state_from_arbiter(block_to_determine_mesi_state_from_arbiter),
        .L2d_local_data(L2a_local_data),
        .acknowledge_arbiter_verify(acknowledge_arbiter_verify)
    );

    // Instantiate shared L3 cache
    cache_fsm_L3 #(
        .CACHE_LEVEL(3)
    ) top_cache_fsm_L3 (
        .clk(clk),
        .reset(reset),
        .main_memory_ready(main_memory_ready),
        .cache_L3_memory_address(cache_L3_memory_address),
        .main_memory_read_data(main_memory_read_data),
        .read_from_L3_request(read_from_L3_request),
        .write_back_to_L3_request(write_back_to_L3_request),
        .write_back_to_L3_data(write_back_to_L3_data),
        .main_memory_write_data(main_memory_write_data),
        .main_memory_address(main_memory_address),
        .L3_cache_hit(L3_cache_hit),
        .L3_cache_miss(L3_cache_miss),
        .L3_cache_ready(L3_cache_ready),
        .main_memory_read_request(main_memory_read_request),
        .main_memory_write_request(main_memory_write_request),
        .L3_ready(L3_ready),
        .write_data_to_L2_from_L3(write_data_to_L2_from_L3),
        .write_back_to_L3_verified(write_back_to_L3_verified)
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
        .block_to_determine_mesi_state_from_arbiter(block_to_determine_mesi_state_from_arbiter),
        .L2a_local_data(L2a_local_data),
        .L2b_local_data(L2b_local_data),
        .L2c_local_data(L2c_local_data),
        .L2d_local_data(L2d_local_data),
        .arbiter_read_update_from_L2_cache_modules(arbiter_read_update_from_L2_cache_modules),
        .arbiter_write_update_from_L2_cache_modules(arbiter_write_update_from_L2_cache_modules),
        .acknowledge_arbiter_verify(acknowledge_arbiter_verify),
        .mesi_state_to_cache(mesi_state_to_cache),
        .arbiter_verify(arbiter_verify),
    );
endmodule