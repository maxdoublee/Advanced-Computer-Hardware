//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//testbench

import cache_config::*;
import main_memory_config::*;

module testbench();
    logic clk;
    logic reset;
    logic cache_read_request;
    logic cache_write_request;
    logic L2_ready;
    logic [ADDRESS_WIDTH-1:0] cache_L1_memory_address;
    logic [DATA_WIDTH-1:0] cache_write_data;
    logic write_to_L1_request, 
    logic write_to_L2_verified,
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L1_from_L2,
    logic write_back_to_L2_verified,
    logic [DATA_WIDTH-1:0] cache_read_data;
    logic L1_cache_hit;
    logic L1_cache_miss;
    logic L1_cache_ready;
    logic [ADDRESS_WIDTH-1:0] cache_L2_memory_address;
    logic write_to_L2_request;
    logic write_to_L1_verified;
    logic write_back_to_L2_request;
    logic read_from_L2_request;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2_data;
    logic L3_ready;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2_from_L3;
    logic write_back_to_L3_verified;
    logic L2_cache_hit;
    logic L2_cache_miss;
    logic L2_cache_ready;
    logic read_from_L3_request;
    logic write_back_to_L3_request;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3_data;
    logic [ADDRESS_WIDTH-1:0] cache_L3_memory_address;
    logic main_memory_ready;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_write_data;
    logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address;
    logic L3_cache_hit;
    logic L3_cache_miss;
    logic L3_cache_ready;
    logic main_memory_read_request;
    logic main_memory_write_request;

    // Instantiate L1 caches
    cache_fsm_L1a #(
        .CACHE_LEVEL(1)
    ) top_cache_fsm_L1a (
        .clk(clk),
        .reset(reset),
        .cache_read_request(cache_read_request),
        .cache_write_request(cache_write_request),
        .L2_ready(L2_ready),
        .cache_L1_memory_address(cache_L1_memory_address),
        .cache_write_data(cache_write_data),
        .write_to_L1_request(write_to_L1_request),
        .write_to_L2_verified(write_to_L2_verified),
        .write_data_to_L1_from_L2(write_data_to_L1_from_L2),
        .write_back_to_L2_verified(write_back_to_L2_verified),
        .cache_read_data(cache_read_data),
        .L1_cache_hit(L1_cache_hit),
        .L1_cache_miss(L1_cache_miss),
        .L1_cache_ready(L1_cache_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2_request(write_to_L2_request),
        .write_to_L1_verified(write_to_L1_verified),
        .write_back_to_L2_request(write_back_to_L2_request),
        .read_from_L2_request(read_from_L2_request),
        .write_back_to_L2_data(write_back_to_L2_data)
    ); 

    // Instantiate L2 caches
    cache_fsm_L2a #(
        .CACHE_LEVEL(2)
    ) top_cache_fsm_L2a (
        .clk(clk),
        .reset(reset),
        .cache_write_request(cache_write_request),
        .L3_ready(L3_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .cache_write_data(cache_write_data),
        .write_to_L2_request(write_to_L2_request),
        .write_to_L1_verified(write_to_L1_verified),
        .read_from_L2_request(read_from_L2_request),
        .write_back_to_L2_request(write_back_to_L2_request),
        .write_back_to_L2_data(write_back_to_L2_data),
        .write_data_to_L2_from_L3(write_data_to_L2_from_L3),
        .write_back_to_L3_verified(write_back_to_L3_verified),
        .cache_read_data(cache_read_data),
        .L2_cache_hit(L2_cache_hit),
        .L2_cache_miss(L2_cache_miss),
        .L2_cache_ready(L2_cache_ready),
        .write_to_L1_request(write_to_L1_request),
        .write_to_L2_verified(write_to_L2_verified),
        .read_from_L3_request(read_from_L3_request),
        .write_back_to_L3_request(write_back_to_L3_request),
        .L2_ready(L2_ready),
        .write_data_to_L1_from_L2(write_data_to_L1_from_L2),
        .write_back_to_L2_verified(write_back_to_L2_verified),
        .write_back_to_L3_data(write_back_to_L3_data),
        .cache_L3_memory_address(cache_L3_memory_address)
    );

    // Instantiate shared L3 cache
    cache_fsm_L3 #(
        .CACHE_LEVEL(3)
    ) top_cache_fsm_L3 (
        .clk(clk),
        .reset(reset),
        .cache_write_request(cache_write_request),
        .main_memory_ready(main_memory_ready),
        .cache_L3_memory_address(cache_L3_memory_address),
        .cache_write_data(cache_write_data),
        .main_memory_read_data(main_memory_read_data),
        .read_from_L3_request(read_from_L3_request),
        .write_back_to_L3_request(write_back_to_L3_request),
        .write_back_to_L3_data(write_back_to_L3_data),
        .main_memory_write_data(main_memory_write_data),
        .main_memory_address(main_memory_address),
        .cache_read_data(cache_read_data),
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
        .main_memory_ready(main_memory_ready),
        .main_memory_address(main_memory_address),
        .main_memory_read_data(main_memory_read_data),
        .main_memory_write_data(main_memory_write_data)
    );

    always begin
        #5 clk = ~clk; // Toggle clock every 5 time units
    end

    initial begin
        // Initialize testbench signals
        clk = 0;
        reset = 1;
        cache_read_request = 0;
        cache_write_request = 0;
        L2_ready = 0;
        cache_L1_memory_address = 0;
        cache_write_data = 0;
        write_to_L1_request = 0;
        write_to_L2_verified = 0;
        write_data_to_L1_from_L2 = 0;
        write_back_to_L2_verified = 0;
        cache_read_data = 0;
        L1_cache_hit = 0;
        L1_cache_miss = 0;
        L1_cache_ready = 0;
        cache_L2_memory_address = 0;
        write_to_L2_request = 0;
        write_to_L1_verified = 0;
        write_back_to_L2_request = 0;
        read_from_L2_request = 0;
        write_back_to_L2_data = 0;
        L3_ready = 0;
        write_data_to_L2_from_L3 = 0;
        write_back_to_L3_verified = 0;
        L2_cache_hit = 0;
        L2_cache_miss = 0;
        L2_cache_ready = 0;
        read_from_L3_request = 0;
        write_back_to_L3_request = 0;
        write_back_to_L3_data = 0;
        cache_L3_memory_address = 0;
        main_memory_ready = 0;
        main_memory_read_data = 0;
        main_memory_write_data = 0; 
        main_memory_address = 0;
        L3_cache_hit = 0;
        L3_cache_miss = 0;
        L3_cache_ready = 0;
        main_memory_read_request = 0;
        main_memory_write_request = 0;

        //Reset the system
        #20 reset = 0; //Wait a little longer for reset to take effect

        //Test Case 1: LRU
       
    end
        
    //Monitor signals during simulation
    initial begin
        $monitor(
            "Time=%g 
            clk=%b 
            reset=%b 
            cache_read_request=%b 
            cache_write_request=%b
            L2_ready=%b 
            cache_L1_memory_address=%h 
            cache_write_data=%h 
            write_to_L2_verified=%h
            cache_read_data=%h 
            cache_hit=%b 
            cache_miss=%b 
            cache_ready=%b",
            
            $time, 
            clk, 
            reset, 
            cache_read_request, 
            cache_write_request, 
            L2_ready,
            cache_L1_memory_address, 
            cache_write_data,
            write_to_L2_verified, 
            cache_read_data, 
            cache_hit, 
            cache_miss, 
            cache_ready);
    end

endmodule