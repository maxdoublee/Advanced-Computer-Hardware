//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache FSM, L1a

import cache_config::*;
import main_memory_config::*;

module cache_fsm_L1a #(
  parameter CACHE_LEVEL = 1
)(
  input logic clk,
  input logic reset,
  input logic cache_a_read_request,
  input logic cache_a_write_request,
  input logic L2a_ready,
  input logic [ADDRESS_WIDTH-1:0] cache_L1a_memory_address,
  input logic [DATA_WIDTH-1:0] cache_1a_write_data,
  input logic write_to_L2a_verified,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L1a_from_L2a,
  input logic write_back_to_L2a_verified,

  output logic [ADDRESS_WIDTH-1:0] cache_L2a_memory_address,
  output logic write_to_L2a_request,
  output logic write_back_to_L2a_request,
  output logic read_from_L2a_request,
  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2a_data,
  output logic [DATA_WIDTH-1:0] cache_L1a_read_data,
  output logic [DATA_WIDTH-1:0] cache_1a_write_data_to_L2a,
  output logic L1a_cache_hit,
  output logic L1a_cache_miss,
  output logic L1a_cache_ready
);

	//Define cache states
	typedef enum logic [1:0] { //Size of each enumerator, it indicates that each enumerator is represented using 2 bits (00, 01, 10, 11)
		IDLE,
		COMPARE,
		ALLOCATE,
		WRITE_BACK
	} state_t; 

	state_t current_state, next_state;

	//Internal state of the cache level 1, L1
	logic [ADDRESS_WIDTH-1:0] array_of_cache_L1a_memory_addresses[NUM_SETS-1:0]; // Array of cache level 2 addresses for each block within each set for writing lru addressed to lower level
	logic [1:0] L1_valid_bits[NUM_SETS-1:0]; //Array of valid bits, one for each cache line
	logic [1:0] L1_dirty_bits[NUM_SETS-1:0]; //Array of dirty bits, one for each cache line
	logic [TAG_WIDTH-1:0] L1_tags[NUM_SETS-1:0]; //Array of tags, one for each cache line
	logic [MAIN_MEMORY_DATA_WIDTH-1:0] L1_data[NUM_SETS-1:0]; //Array of data, one for each cache line

	logic [1:0] processor_id; //Separate the processor ID from the actual address
	logic [TAG_WIDTH-1:0] tag;
	logic [INDEX_WIDTH-1:0] index;
	logic [BLOCK_OFFSET_WIDTH-1:0] offset; 
	logic word_start_bit;
	logic first_write_to_L1_request;
   logic check_if_cache_hit_flag;
   logic cache_read_data_flag;
   logic cache_write_inclusion_policy_flag;
   logic allocate_flag;
   logic write_back_1_flag;
   logic write_back_2_flag;
   logic dirty_flag;
   logic clean_flag;
   logic cache_hit_flag;
   logic cache_L2a_memory_address_flag;
   logic setup_flag;
   logic word_start_flag;

    always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
			// Set initial values
            cache_L1a_read_data = 1'b0;
            cache_L2a_memory_address = 1'b0;
            dirty_flag = 1'b0;
            clean_flag = 1'b0;
            cache_hit_flag = 1'b0;
            write_back_to_L2a_data = 1'b0;
            processor_id = 1'b0;
            tag = 1'b0;
            index = 1'b0;
            offset = 1'b0;
            word_start_bit = 1'b0;
			current_state <= IDLE;
            for (int set = 0; set < NUM_SETS; set++) begin
                array_of_cache_L1a_memory_addresses[set] <= 0; // Initialize addresses to 0
                L1_valid_bits[set] <= 0; // Initialize valid bits to 0
                L1_dirty_bits[set] <= 0; // Initialize dirty bits to 0
                L1_data[set]<= 0; // Initialize data to 0
                L1_tags[set] <= 0; // Initialize tags to 0
        	end
		end else begin
			current_state <= next_state;
            if(setup_flag) begin 
                //Extract the top two bits as the processor ID
                processor_id = cache_L1a_memory_address[31:30]; 
                //Bit-slicing to extract the appropriate number of bits for each segment of the cache address
                tag = cache_L1a_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
                index = cache_L1a_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
                offset = cache_L1a_memory_address[OFFSET_START -: BLOCK_OFFSET_WIDTH]; //Get offset from requested address
            end
            if(check_if_cache_hit_flag) begin 
                // Cache hit
				if(L1_tags[index] == tag && L1_valid_bits[index] == 1) begin //checks if line is marked valid and tags match in L1 cache
					cache_hit_flag = 1'b1;
				end else begin
					//Cache miss
					if (L1_dirty_bits[index] == 1'b1) begin
                        dirty_flag = 1'b1;
					end else begin
                        clean_flag = 1'b1;
					end
				end
            end
            if(word_start_flag) begin
                word_start_bit = offset * DATA_WIDTH; //Offset is multiplied by the width of data bus
            end
            if(cache_read_data_flag) begin 
                cache_L1a_read_data = L1_data[index][word_start_bit +: DATA_WIDTH]; //Read data from the specific word in block for processor
            end
            if(cache_write_inclusion_policy_flag) begin 
                array_of_cache_L1a_memory_addresses[index] = cache_L1a_memory_address; //stores all cache addresses that are or once were in cache 
                L1_data[index][word_start_bit +: DATA_WIDTH] = cache_1a_write_data; //Write new data to the specific place in block
                L1_dirty_bits[index] = 1'b1; //Mark index as dirty	
            end
            if(cache_L2a_memory_address_flag) begin
                cache_L2a_memory_address = cache_L1a_memory_address;
            end
            if(allocate_flag) begin
                L1_tags[index] = tag; //Get tag from requested address and assign it to block 
                L1_valid_bits[index] = 1'b1; //When the line is first brought into cache set it as valid 
                L1_data[index] = write_data_to_L1a_from_L2a; //Assign new memory data to the L1 cache block
            end
            if(write_back_1_flag) begin 
                //Keep track of old cache addresses
				cache_L2a_memory_address = array_of_cache_L1a_memory_addresses[index]; //Assigns old dirty address to L2 cache
				write_back_to_L2a_data = L1_data[index]; // Pass the data to write back to L2
            end
            if(write_back_2_flag) begin
                L1_dirty_bits[index] = 1'b0; //since block has been evicted clear dirty bit marker and prepare for the new data that is coming into that block location
            end
		end
	end

	always_comb begin
        write_to_L2a_request = 1'b0;
        write_back_to_L2a_request = 1'b0;
        read_from_L2a_request = 1'b0;
        L1a_cache_hit = 1'b0;
        L1a_cache_ready = 1'b0;
        L1a_cache_miss = 1'b0;
        check_if_cache_hit_flag = 1'b0;
        cache_read_data_flag = 1'b0;
        cache_write_inclusion_policy_flag = 1'b0;
        allocate_flag = 1'b0;
        write_back_1_flag = 1'b0;
        write_back_2_flag = 1'b0;
        cache_L2a_memory_address_flag = 1'b0;
        setup_flag = 1'b0;
        word_start_flag = 1'b0;
        cache_1a_write_data_to_L2a = 1'b0;
		next_state = state_t'(1'b0);
        first_write_to_L1_request = 1'b1;
		setup_flag = 1'b1;
		//Basic Cache States 
		case (current_state)
			IDLE: begin
				if((processor_id == 0) && (cache_a_read_request || cache_a_write_request)) begin
					next_state = COMPARE;
				end
				else begin
					next_state = IDLE;
				end			  
			end
			COMPARE: begin
                check_if_cache_hit_flag = 1'b1;
				if(cache_hit_flag) begin
					//Cache hit
					L1a_cache_hit = 1'b1;
                    word_start_flag = 1'b1;
					if (cache_a_read_request) begin
                        cache_read_data_flag = 1'b1;
						//Mark Cache ready 
						L1a_cache_ready = 1'b1;
						next_state = IDLE;
					end else if (cache_a_write_request && first_write_to_L1_request) begin
						//Inclusion policy
                        cache_write_inclusion_policy_flag = 1'b1;
                        cache_1a_write_data_to_L2a = cache_1a_write_data;
                        cache_L2a_memory_address_flag = 1'b1;
						write_to_L2a_request = 1'b1; //sends request to L2 for cache inclusion policy 
						first_write_to_L1_request = 1'b0; //prevent writing to the same block location again when waiting for L2 to verify it received the same data to maintain the inclusion policy between L1 and L2
					end
					if(write_to_L2a_verified) begin
						//Mark Cache ready 
						L1a_cache_ready = 1'b1;
						next_state = IDLE;
					end else begin
						next_state = COMPARE;
					end
				end else begin
					//Cache miss
					L1a_cache_miss = 1'b1;
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
				//Instead of continuously replacing blocks in L1, search L2 to see if the requested address is found there 
                cache_L2a_memory_address_flag = 1'b1;
				read_from_L2a_request = 1'b1; //Initiate a read request 
                if(L2a_ready) begin //Still for the inclusion policy, L1 gets the same data that L2 grabs L3 by way of this flag outputted from L2
					//Inclusion miss 
                    allocate_flag = 1'b1;
					//Reset read request flag
					read_from_L2a_request = 1'b0;
					next_state = COMPARE;
				end
				else begin
					next_state = ALLOCATE;
				end
			end
			WRITE_BACK: begin
                write_back_1_flag = 1'b1;
                write_back_to_L2a_request = 1'b1; //explicit signal to let l2 know that data needs to get written back to it
				if(write_back_to_L2a_verified) begin 
                    write_back_2_flag = 1'b1;
					write_back_to_L2a_request = 1'b0;
					next_state = ALLOCATE;
				end
				else begin
					next_state = WRITE_BACK; //keep in state until data from L1 is verified to be sent to L2
				end 
			end
			default: begin 
				next_state = IDLE; //Default state 
			end
		endcase
	end
endmodule