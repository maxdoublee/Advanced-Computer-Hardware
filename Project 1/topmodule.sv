//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//top module implementation

import cache_config::*;
import main_memory_config::*;

module topmodule(
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
    logic write_back_to_L2_request;
    logic read_from_L2_request;
    logic L2_ready;
    logic write_to_L1_request;
    logic write_to_L2_verified;
    logic write_back_to_L2_verified;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2_data;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L1_from_L2;

    // Signals for L2 to L3 communication
    logic [ADDRESS_WIDTH-1:0] cache_L3_memory_address;
    logic write_back_to_L3_request;
    logic read_from_L3_request;
    logic L3_ready;
    logic write_to_L2_request;
    logic write_to_L1_verified;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3_data;
    logic write_back_to_L3_verified;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2_from_L3;

    // Signals for L3 to Memory Interface communication 
    logic main_memory_read_request;
    logic main_memory_write_request;
    logic main_memory_ready;
    logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_write_data;

    // Instantiate cache FSMs based on CACHE_LEVEL parameter
    // This generate block dynamically instantiates each cache FSM based on the CACHE_LEVEL parameter.
    generate
        // Loop through each cache level based on CACHE_LEVEL parameter
		  int i = 0;
        for (i = 1; i <= cache_config::CACHE_LEVEL; i++) begin: gen_cache_level
            // Calculate cache memory address based on cache level
            logic [ADDRESS_WIDTH-1:0] cache_memory_address;
            if (i == 1) begin
                cache_memory_address := cache_L1_memory_address;
            end else if (i == 2) begin
                cache_memory_address = cache_L2_memory_address;
            end else if (i == 3) begin
                cache_memory_address = cache_L3_memory_address;
            end
            
            // Instantiate cache FSM
            cache_fsm top_cache_fsm (
                .clk(clk),
                .reset(reset),
                .cache_read_request(cache_read_request),
                .cache_write_request(cache_write_request),
                .cache_memory_address(cache_memory_address),
                .cache_write_data(cache_write_data),
                .cache_read_data(cache_read_data),
                .cache_hit(cache_hit),
                .cache_miss(cache_miss),
                .cache_ready(cache_ready)
            );
        end
    endgenerate

    // Instantiate main_memory_controller, arbiter, and other components as before

endmodule