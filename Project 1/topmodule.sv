//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//top module implementation

import cache_config::*;
import main_memory_config::*;

module topmod(
    input logic clk,
    input logic reset,
    
    // Processor Interfaces
    input logic [3:0] cache_read_request, 
    input logic [3:0] cache_write_request, 
    input logic [ADDRESS_WIDTH-1:0] cache_L1_memory_address,
    input logic [DATA_WIDTH-1:0] cache_write_data,

    output logic [DATA_WIDTH-1:0] cache_read_data,
    output logic cache_hit,
    output logic cache_miss,
    output logic cache_ready
);

    // Signals for L1 to L2 communication
    logic [ADDRESS_WIDTH-1:0] cache_L2_memory_address;
    logic write_to_L2_request;
    logic write_to_L1_verified;
    logic write_back_to_L2_request;
    logic read_from_L2_request;
    logic write_to_L1_request; 
    logic write_to_L2_verified;
    logic L2_ready;

    // Signals for L2 to L3 communication
    logic read_from_L3_request;
    logic [ADDRESS_WIDTH-1:0] cache_L3_memory_address;
    logic write_back_to_L3_request
    logic L3_ready;

    // Signals for L3 to Memory Interface communication 
    logic main_memory_read_request;
    logic main_memory_write_request;
    logic main_memory_ready;
    logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_write_data;

    // Instantiate L1 caches
    cache_fsm top_cache_fsm_L1a(
        .clk(clk),
        .reset(reset),
        .cache_read_request(cache_read_request),
        .cache_write_request(cache_write_request),
        .cache_memory_address(cache_memory_address),
        .cache_write_data(cache_write_data),
        .cache_read_data(cache_read_data),
        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        .cache_ready(cache_ready),
    ); 
    cache_fsm top_cache_fsm_L1b(
        .clk(clk),
        .reset(reset),
        .cache_read_request(cache_read_request),
        .cache_write_request(cache_write_request),
        .cache_memory_address(cache_memory_address),
        .cache_write_data(cache_write_data),
        .cache_read_data(cache_read_data),
        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        .cache_ready(cache_ready),
    );
    cache_fsm top_cache_fsm_L1c(
        .clk(clk),
        .reset(reset),
        .cache_read_request(cache_read_request),
        .cache_write_request(cache_write_request),
        .cache_memory_address(cache_memory_address),
        .cache_write_data(cache_write_data),
        .cache_read_data(cache_read_data),
        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        .cache_ready(cache_ready),
    );
    cache_fsm top_cache_fsm_L1d(
        .clk(clk),
        .reset(reset),
        .cache_read_request(cache_read_request),
        .cache_write_request(cache_write_request),
        .cache_memory_address(cache_memory_address),
        .cache_write_data(cache_write_data),
        .cache_read_data(cache_read_data),
        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        .cache_ready(cache_ready),
    );   

    // Instantiate L2 caches
    cache_fsm top_cache_fsm_L2a(
        .clk(clk),
        .reset(reset),
        .cache_read_request(cache_read_request),
        .cache_write_request(cache_write_request),
        .cache_memory_address(cache_memory_address),
        .cache_write_data(cache_write_data),
        .cache_read_data(cache_read_data),
        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        .cache_ready(cache_ready),
    );
    cache_fsm top_cache_fsm_L2b(
        .clk(clk),
        .reset(reset),
        .cache_read_request(cache_read_request),
        .cache_write_request(cache_write_request),
        .cache_memory_address(cache_memory_address),
        .cache_write_data(cache_write_data),
        .cache_read_data(cache_read_data),
        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        .cache_ready(cache_ready),
    );
    cache_fsm top_cache_fsm_L2c(
        .clk(clk),
        .reset(reset),
        .cache_read_request(cache_read_request),
        .cache_write_request(cache_write_request),
        .cache_memory_address(cache_memory_address),
        .cache_write_data(cache_write_data),
        .cache_read_data(cache_read_data),
        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        .cache_ready(cache_ready),
    );
    cache_fsm top_cache_fsm_L2d(
        .clk(clk),
        .reset(reset),
        .cache_read_request(cache_read_request),
        .cache_write_request(cache_write_request),
        .cache_memory_address(cache_memory_address),
        .cache_write_data(cache_write_data),
        .cache_read_data(cache_read_data),
        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        .cache_ready(cache_ready),
    );

    // Instantiate shared L3 cache
    cache_fsm top_cache_fsm_L3(
        .clk(clk),
        .reset(reset),
        .cache_read_request(cache_read_request),
        .cache_write_request(cache_write_request),
        .cache_memory_address(cache_memory_address),
        .cache_write_data(cache_write_data),
        .cache_read_data(cache_read_data),
        .cache_hit(cache_hit),
        .cache_miss(cache_miss),
        .cache_ready(cache_ready),
    );

    // Instantiate main_memory_controller
    main_memory_controller top_memory_controller(
        .clk(clk),
        .reset(reset),
        .main_memory_read_request(main_memory_read_request),
        .main_memory_write_request(main_memory_write_request),
        .main_memory_ready(main_memory_ready),
        .main_memory_address(main_memory_address),
        .main_memory_read_data(main_memory_read_data),
        .main_memory_write_data(main_memory_write_data)
    );

    // Instantiate bus arbiter
    arbiter top_arb(
        .clk(clk), 
        .reset(reset), 
    );

    // Logic to connect L1, L2, and L3 caches, processors, and memory via the arbiter

endmodule