//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache FSM, L3

import cache_config::*;
import main_memory_config::*;

module cache_fsm_L3 #(
  parameter CACHE_LEVEL = 3
)(
  input logic clk,
  input logic reset,
  input logic main_memory_ready,
  input logic [ADDRESS_WIDTH-1:0] cache_L3_memory_address,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data,
  input logic read_from_L3_request,
  input logic write_back_to_L3_request,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3_data,

  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_write_data,
  output logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address,
  output logic main_memory_read_request,
  output logic main_memory_write_request,
  output logic L3_ready,
  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2_from_L3,
  output logic write_back_to_L3_verified,
  output logic L3_cache_hit,
  output logic L3_cache_miss,
  output logic L3_cache_ready
);

	//Define cache states
	typedef enum logic [1:0] { //Size of each enumerator, it indicates that each enumerator is represented using 2 bits (00, 01, 10, 11)
		IDLE,
		COMPARE,
		ALLOCATE,
		WRITE_BACK
	} state_t; 

	state_t current_state, next_state;

	//Internal state of the cache level 3, L3
	logic [ADDRESS_WIDTH-1:0] array_of_cache_L3_memory_addresses[NUM_SETS-1:0]; // Array of cache level 3 addresses for each block within each set for writing lru addressed to lower level
	logic [1:0] L3_valid_bits[NUM_SETS-1:0]; //Array of valid bits, one for each cache line
	logic [1:0] L3_dirty_bits[NUM_SETS-1:0]; //Array of dirty bits, one for each cache line
	logic [TAG_WIDTH-1:0] L3_tags[NUM_SETS-1:0]; //Array of tags, one for each cache line
	logic [MAIN_MEMORY_DATA_WIDTH-1:0] L3_data[NUM_SETS-1:0]; //Array of data, one for each cache line

	logic [TAG_WIDTH-1:0] tag;
	logic [INDEX_WIDTH-1:0] index;
    logic check_if_cache_hit_flag;
    logic allocate_flag;
    logic write_back_1_flag;
    logic write_back_2_flag;
    logic dirty_flag;
    logic clean_flag;
    logic cache_array_container_flag;
    logic write_back_to_L3_flag;
    logic read_from_L3_flag;
	logic cache_hit_flag;
	logic main_memory_address_flag;

    always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
            // Set initial values
			main_memory_write_data = 1'b0; 
			dirty_flag = 1'b0;
			clean_flag = 1'b0;
			write_data_to_L2_from_L3 = 1'b0;
			main_memory_address = 1'b0;
			current_state <= IDLE;
            for (int set = 0; set < NUM_SETS; set++) begin
                array_of_cache_L3_memory_addresses[set] <= 0; // Initialize addresses to 0
                L3_valid_bits[set] <= 0; // Initialize valid bits to 0
                L3_dirty_bits[set] <= 0; // Initialize dirty bits to 0
                L3_data[set]<= 0; // Initialize data to 0
                L3_tags[set] <= 0; // Initialize tags to 0
        	end
		end else begin
			current_state <= next_state;
            if(check_if_cache_hit_flag) begin 
                // Cache hit
				if(L3_tags[index] == tag && L3_valid_bits[index] == 1) begin //checks if line is marked valid and tags match in L1 cache
					cache_hit_flag = 1'b1;
				end else begin
					//Cache miss
					if (L3_dirty_bits[index] == 1'b1) begin
                        dirty_flag = 1'b1;
					end else begin
                        clean_flag = 1'b1;
					end
				end
            end
            if(cache_array_container_flag) begin
                array_of_cache_L3_memory_addresses[index] = cache_L3_memory_address; //Keep track of old cache addresses
            end
            if(write_back_to_L3_flag) begin
                L3_data[index] = write_back_to_L3_data;
            end
            if(read_from_L3_flag) begin 
                write_data_to_L2_from_L3 = L3_data[index];
            end
			if(main_memory_address_flag) begin
				main_memory_address = cache_L3_memory_address;
            end
            if(allocate_flag) begin
                L3_tags[index] = tag; //Get tag from requested address and assign it to block 
                L3_valid_bits[index] = 1'b1; //When the line is first brought into cache set it as valid 
                L3_data[index] = main_memory_read_data; //Assign new memory data to the cache L2 block
            end
            if(write_back_1_flag) begin 
                //Keep track of old cache addresses
				main_memory_address = array_of_cache_L3_memory_addresses[index]; //Assigns old dirty address to main memory 
				main_memory_write_data = L3_data[index]; //Write data to main memory
            end
            if(write_back_2_flag) begin
                //Assigned old dirty data block to main memory
                L3_dirty_bits[index] = 1'b0; //Clear dirty bit
            end
		end
	end

	always_comb begin
		L3_cache_hit = 1'b0;
		L3_cache_miss = 1'b0;
		L3_cache_ready = 1'b0;
		main_memory_read_request = 1'b0;
        check_if_cache_hit_flag = 1'b0;
        allocate_flag = 1'b0;
        write_back_1_flag = 1'b0;
        write_back_2_flag = 1'b0;
		L3_ready = 1'b0;
		tag = 1'b0;
		index = 1'b0;
		main_memory_write_request = 1'b0;
		write_back_to_L3_verified = 1'b0;
        cache_array_container_flag = 1'b0;;
        write_back_to_L3_flag = 1'b0;
        read_from_L3_flag = 1'b0;
		main_memory_address_flag = 1'b0;
		next_state = state_t'(1'b0);
		//Bit-slicing to extract the appropriate number of bits for each segment of the cache address
		tag = cache_L3_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
		index = cache_L3_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		//Basic Cache States 
		case (current_state)
			IDLE: begin
				if(write_back_to_L3_request || read_from_L3_request) begin
					next_state = COMPARE;
				end else begin
					next_state = IDLE;
				end			  
			end
			COMPARE: begin
                check_if_cache_hit_flag = 1'b1;
				if(cache_hit_flag) begin
					//Cache hit
					L3_cache_hit = 1'b1;
                    cache_array_container_flag = 1'b1;
					//Write back request from L2
					if(write_back_to_L3_request) begin
                        write_back_to_L3_flag = 1'b1;
						write_back_to_L3_verified = 1'b1;
						//Mark Cache ready 
						L3_cache_ready = 1'b1;
						next_state = IDLE;
					end else if(read_from_L3_request) begin
                        read_from_L3_flag = 1'b1;
						L3_ready = 1'b1; 
						//Mark Cache ready 
						L3_cache_ready = 1'b1;
						next_state = IDLE;
					end else begin 
						//Mark Cache ready 
						L3_cache_ready = 1'b1;
						next_state = IDLE;
					end 
				end else begin
					// Cache miss
					L3_cache_miss = 1'b1;
					if(dirty_flag) begin 
                        // If block is dirty initiate write back
                        next_state = WRITE_BACK;
                    end else if(clean_flag) begin
                        //Block is clean
                        next_state = ALLOCATE;
                    end
				end
			end
			ALLOCATE: begin
				main_memory_address_flag = 1'b1;
				main_memory_read_request = 1'b1; //Initiate a read request to main memory
				if(main_memory_ready) begin
                    allocate_flag = 1'b1;
					//Reset read request flag
					main_memory_read_request = 1'b0;
					next_state = COMPARE;
				end else begin
					next_state = ALLOCATE;
				end
			end
			WRITE_BACK: begin
                write_back_1_flag = 1'b1;
				main_memory_write_request = 1'b1; //Initiate a rewrite request to main memory
				if(main_memory_ready) begin
                    write_back_2_flag = 1'b1;
					//Reset write request flag
					main_memory_write_request = 1'b0;
					next_state = ALLOCATE;
				end else begin
					next_state = WRITE_BACK; //keep in state until data from L3 is verified to be sent to main memory
				end
			end 
			default: begin 
				next_state = IDLE; // Default state 
			end
		endcase
	end
endmodule