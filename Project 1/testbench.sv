//Lab0: Simple Cache
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
  logic [ADDRESS_WIDTH-1:0] cache_memory_address;
  logic [DATA_WIDTH-1:0] cache_write_data;
  logic [DATA_WIDTH-1:0] cache_read_data;
  logic cache_hit;
  logic cache_miss;
  logic cache_ready;
  logic [DATA_WIDTH-1:0] expected_data;
  logic [MAIN_MEMORY_DATA_WIDTH-1:0] expected_memory_data;
  logic [DATA_WIDTH-1:0] expected_address;
  logic main_memory_read_request;
  logic main_memory_write_request;
  logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address;
  logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_write_data;
  logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data;
  logic main_memory_ready;

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

always begin
    #5 clk = ~clk; // Toggle clock every 5 time units
end

 initial begin
	  // Initialize testbench signals
	  clk = 0;
	  reset = 1;
	  cache_hit = 0;
	  cache_miss = 0;
	  cache_ready = 0;
	  cache_read_request = 0;
	  cache_write_request = 0;
	  cache_memory_address = 0;
	  cache_write_data = 0;
	  cache_read_data = 0;
	  expected_data = 0;
	  expected_address = 0;
	  main_memory_read_request = 0;
	  main_memory_write_request = 0;
	  main_memory_ready = 0;
	  main_memory_address = 0;
	  main_memory_write_data = 0; 
	  main_memory_read_data = 0;

	  //Reset the system
	  #20 reset = 0; //Wait a little longer for reset to take effect

 	  //Test Case 1: Write to cache 
	  cache_write_request = 1; //arbitrary write request
	  cache_memory_address = 32'b10100000000000000000000000000000; //requested address from processor
	  wait(cache_miss);
	  cache_write_request = 0; //reset request
	  wait(main_memory_ready);
	  cache_write_request = 1; //real write request
	  cache_write_data = 32'b11011110101011011011111011101111; 
	  wait(cache_hit); //waits to pass first compare if statement 
	  cache_write_request = 0; //reset request
	  wait(cache_ready); //Wait for cache to indicate the operation is complete

 	  //Test Case 2: Read from cache
	  cache_read_request = 1; //real read request
	  #20 //wouldn't work w/o this delay
	  wait(cache_hit); //waits to pass first compare if statement 
	  expected_data = 32'b11011110101011011011111011101111; //from cache write data in test case 1
	  if(expected_data == cache_read_data) begin
			$display("Read test passed!");
	  end
	  else begin
			$display("Expected data: %h", expected_data);
    		$display("Cache read data: %h", cache_read_data);
	  end
	  cache_read_request = 0; //reset request
	  wait(cache_ready); //Wait for cache to indicate the operation is complete

      //Test Case 3: Write Back Check
	  cache_write_request = 1; //arbitrary write request
	  cache_memory_address = 32'b10110001000000000000000000000000; //requested address from processor (different tag with same index)
	  wait(cache_miss); //different tag then what was written to before so should miss
	  expected_address = 32'b10100000000000000000000000000000; //old address from first write to cache in test case 1
	  expected_memory_data = 128'h00000000DEADBEEF; //old data from first write to cache in test case 1
	  wait(main_memory_ready);
	  #20 //give it some time to get the values due to for loop in fsm
	  if(expected_address == main_memory_address && expected_memory_data == main_memory_write_data) begin
			$display("Write back test passed!");
	  end
	  else begin
			$display("Expected Address: %h", expected_address);
    		$display("Main Memory data: %h", expected_memory_data);
			$display("Expected Address: %h", main_memory_address);
    		$display("Main Memory data: %h", main_memory_write_data);
	  end
	  wait(!main_memory_write_request);
	  cache_write_request = 0; //reset request

      //Test Case 4: Miss on a Clean Block
	  cache_read_request = 1; //real read request
	  #20 //wouldn't work w/o this delay
	  wait (cache_miss); //wait for the cache to miss on the clean block
	  cache_memory_address = 32'b111010010111000000000000000000000; //address not previously used
	  //Check if no write-back is initiated
	  if (!main_memory_write_request) begin
			$display("No write back as expected for clean block");
	  end 
	  else begin
			$display("Unexpected write-back for clean block");
	  end
	  cache_read_request = 0; //reset request*/
 end
     
 //Monitor signals during simulation
 initial begin
	  $monitor("Time=%g clk=%b reset=%b cache_read_request=%b cache_write_request=%b cache_memory_address=%h cache_write_data=%h cache_read_data=%h cache_hit=%b cache_miss=%b cache_ready=%b",
			  $time, clk, reset, cache_read_request, cache_write_request, cache_memory_address, cache_write_data, cache_read_data, cache_hit, cache_miss, cache_ready);
 end

endmodule