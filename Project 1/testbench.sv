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
    logic write_to_L1_request;
    logic write_to_L2_verified;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L1_from_L2;
    logic write_back_to_L2_verified;
    logic [DATA_WIDTH-1:0] cache_read_data;
    logic L1_cache_hit;
    logic L1_cache_miss;
    logic L1_cache_ready;
    logic [ADDRESS_WIDTH-1:0] cache_L2_memory_address;
    logic write_to_L2a_request;
    logic write_to_L2b_request;
    logic write_to_L2c_request;
    logic write_to_L2d_request;
    logic write_back_to_L2a_request;
    logic write_back_to_L2b_request;
    logic write_back_to_L2c_request;
    logic write_back_to_L2d_request;
    logic read_from_L2a_request;
    logic read_from_L2b_request;
    logic read_from_L2c_request;
    logic read_from_L2d_request;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2a_data;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2b_data;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2c_data;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2d_data;
    logic [DATA_WIDTH-1:0] cache_L1a_read_data;
    logic [DATA_WIDTH-1:0] cache_L1b_read_data;
    logic [DATA_WIDTH-1:0] cache_L1c_read_data;
    logic [DATA_WIDTH-1:0] cache_L1d_read_data;
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
    logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache;
    logic arbiter_verify;
    logic arbiter_read_update_from_L2_cache_modules;
    logic arbiter_write_update_from_L2_cache_modules;
    logic [ADDRESS_WIDTH-1:0] block_to_determine_mesi_state_from_arbiter;
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2a_local_data, L2b_local_data, L2c_local_data, L2d_local_data;
    logic acknowledge_arbiter_verify;

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
        .cache_L1a_read_data(cache_L1a_read_data),
        .L1a_cache_hit(L1a_cache_hit),
        .L1a_cache_miss(L1_cache_miss),
        .L1a_cache_ready(L1_cache_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2a_request(write_to_L2a_request),
        .write_back_to_L2a_request(write_back_to_L2a_request),
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
        .cache_L1b_read_data(cache_L1b_read_data),
        .L1b_cache_hit(L1b_cache_hit),
        .L1b_cache_miss(L1_cache_miss),
        .L1b_cache_ready(L1_cache_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2b_request(write_to_L2b_request),
        .write_back_to_L2b_request(write_back_to_L2b_request),
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
        .cache_L1c_read_data(cache_L1c_read_data),
        .L1c_cache_hit(L1c_cache_hit),
        .L1c_cache_miss(L1_cache_miss),
        .L1c_cache_ready(L1_cache_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2c_request(write_to_L2c_request),
        .write_back_to_L2c_request(write_back_to_L2c_request),
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
        .cache_L1d_read_data(cache_L1d_read_data),
        .L1d_cache_hit(L1d_cache_hit),
        .L1d_cache_miss(L1_cache_miss),
        .L1d_cache_ready(L1_cache_ready),
        .cache_L2_memory_address(cache_L2_memory_address),
        .write_to_L2d_request(write_to_L2d_request),
        .write_back_to_L2d_request(write_back_to_L2d_request),
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
        .write_to_L2a_request(write_to_L2a_request),
        .read_from_L2a_request(read_from_L2a_request),
        .write_back_to_L2a_request(write_back_to_L2a_request),
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
        .write_to_L2b_request(write_to_L2b_request),
        .read_from_L2b_request(read_from_L2b_request),
        .write_back_to_L2b_request(write_back_to_L2b_request),
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
        .write_to_L2c_request(write_to_L2c_request),
        .read_from_L2c_request(read_from_L2c_request),
        .write_back_to_L2c_request(write_back_to_L2c_request),
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
        .write_to_L2d_request(write_to_L2d_request),
        .read_from_L2d_request(read_from_L2d_request),
        .write_back_to_L2d_request(write_back_to_L2d_request),
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
        .arbiter_verify(arbiter_verify)
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
        cache_L2a_memory_address = 0;
        cache_L2b_memory_address = 0;
        cache_L2c_memory_address = 0;
        cache_L2d_memory_address = 0;
        write_to_L2_request = 0;
        write_to_L1_verified = 0;
        write_back_to_L2a_request = 0;
        write_back_to_L2b_request = 0;
        write_back_to_L2c_request = 0;
        write_back_to_L2d_request = 0;
        read_from_L2_request = 0;
        write_back_to_L2a_data = 0;
        write_back_to_L2b_data = 0;
        write_back_to_L2c_data = 0;
        write_back_to_L2d_data = 0;
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
        mesi_state_to_cache = 0;
        arbiter_verify = 0;
        arbiter_read_update_from_L2_cache_modules = 0;
        arbiter_write_update_from_L2_cache_modules = 0;
        block_to_determine_mesi_state_from_arbiter = 0;
        L2a_local_data = 0;
        L2b_local_data = 0;
        L2c_local_data = 0;
        L2d_local_data = 0;
        acknowledge_arbiter_verify = 0;

        //Reset the system
        #20 reset = 0; //Wait a little longer for reset to take effect

        //Test Case 1: LRU

        //Test Case 2: Inclusion policy

        //Test Case 3: MESI
        cache_write_request = 1; //arbitrary write request
        cache_L1_memory_address = 32'b00100000000000000000000000000000; //requested address from processor
        wait(L1_cache_miss);
        $display("Cache missed");
    end
        
    // Monitor signals during simulation
    initial begin
        $monitor("Time=%g clk=%b reset=%b cache_read_request=%b cache_write_request=%b L2_ready=%b cache_L1_memory_address=%h cache_write_data=%h write_to_L1_request=%b write_to_L2_verified=%h write_data_to_L1_from_L2=%h write_back_to_L2_verified=%h cache_read_data=%h L1_cache_hit=%b L1_cache_miss=%b L1_cache_ready=%b cache_L2_memory_address=%h write_to_L2_request=%b write_to_L1_verified=%b write_back_to_L2_request=%b read_from_L2_request=%b write_back_to_L2_data=%h L3_ready=%b write_data_to_L2_from_L3=%h write_back_to_L3_verified=%h L2_cache_hit=%b L2_cache_miss=%b L2_cache_ready=%b read_from_L3_request=%b write_back_to_L3_request=%b write_back_to_L3_data=%h cache_L3_memory_address=%h main_memory_ready=%b main_memory_read_data=%h main_memory_write_data=%h main_memory_address=%h L3_cache_hit=%b L3_cache_miss=%b L3_cache_ready=%b main_memory_read_request=%b main_memory_write_request=%b mesi_state_to_cache=%h arbiter_verify=%b arbiter_read_update_from_L2_cache_modules=%b arbiter_write_update_from_L2_cache_modules=%b block_to_determine_mesi_state_from_arbiter=%h L2a_local_data=%h L2b_local_data=%h L2c_local_data=%h L2d_local_data=%h acknowledge_arbiter_verify=%b",
        $time, 
        clk, 
        reset, 
        cache_read_request, 
        cache_write_request, 
        L2_ready,
        cache_L1_memory_address, 
        cache_write_data,
        write_to_L1_request,
        write_to_L2_verified, 
        write_data_to_L1_from_L2,
        write_back_to_L2_verified,
        cache_read_data, 
        L1_cache_hit, 
        L1_cache_miss, 
        L1_cache_ready,
        cache_L2_memory_address, 
        write_to_L2_request,
        write_to_L1_verified,
        write_back_to_L2_request,
        read_from_L2_request,
        write_back_to_L2_data,
        L3_ready,
        write_data_to_L2_from_L3,
        write_back_to_L3_verified,
        L2_cache_hit,
        L2_cache_miss,
        L2_cache_ready,
        read_from_L3_request,
        write_back_to_L3_request,
        write_back_to_L3_data,
        cache_L3_memory_address,
        main_memory_ready,
        main_memory_read_data,
        main_memory_write_data,
        main_memory_address,
        L3_cache_hit,
        L3_cache_miss,
        L3_cache_ready,
        main_memory_read_request,
        main_memory_write_request,
        mesi_state_to_cache,
        arbiter_verify,
        arbiter_read_update_from_L2_cache_modules,
        arbiter_write_update_from_L2_cache_modules,
        block_to_determine_mesi_state_from_arbiter,
        L2a_local_data,
        L2b_local_data,
        L2c_local_data,
        L2d_local_data,
        acknowledge_arbiter_verify);
    end
endmodule