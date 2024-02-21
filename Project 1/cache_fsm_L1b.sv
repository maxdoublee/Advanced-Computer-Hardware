//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache FSM, L1b

import cache_config::*;
import main_memory_config::*;

module cache_fsm_L1b #(
  parameter CACHE_LEVEL = 1
)(
  input logic clk,
  input logic reset,
  input logic cache_read_request,
  input logic cache_write_request,
  input logic L2_ready,
  input logic [ADDRESS_WIDTH-1:0] cache_L1_memory_address,
  input logic [DATA_WIDTH-1:0] cache_write_data,
  input logic write_to_L2_verified,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L1_from_L2,
  input logic write_back_to_L2_verified,

  output logic [ADDRESS_WIDTH-1:0] cache_L2_memory_address,
  output logic write_to_L2_request,
  output logic write_back_to_L2_request,
  output logic read_from_L2_request,
  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2_data,
  output logic [DATA_WIDTH-1:0] cache_L1_read_data,
  output logic L1_cache_hit,
  output logic L1_cache_miss,
  output logic L1_cache_ready
);

	//Define cache states
	typedef enum logic [1:0] { //Size of each enumerator, it indicates that each enumerator is represented using 2 bits (00, 01, 10, 11)
		IDLE,
		COMPARE,
		ALLOCATE,
		WRITE_BACK
	} state_t; 

	state_t current_state, next_state;
	
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
			current_state <= IDLE;
		end else begin
			current_state <= next_state;
		end
	end

	//Internal state of the cache level 1, L1
	logic [ADDRESS_WIDTH-1:0] array_of_cache_L1_memory_addresses[NUM_SETS-1:0]; // Array of cache level 2 addresses for each block within each set for writing lru addressed to lower level
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

	always_comb begin
		cache_L1_read_data = 1'b0;
		L1_cache_hit = 1'b0;
		L1_cache_miss = 1'b0;
		L1_cache_ready = 1'b0;
		cache_L2_memory_address = 1'b0;
		write_to_L2_request = 1'b0;
		write_back_to_L2_request = 1'b0;
		read_from_L2_request = 1'b0;
		write_back_to_L2_data = 1'b0;
		next_state = state_t'(1'b0);
		for (int set = 0; set < NUM_SETS; set++) begin
			L1_valid_bits[set] <= 1'b0; // Initialize valid bits to 0
		end
		for (int set = 0; set < NUM_SETS; set++) begin
			L1_dirty_bits[set] <= 1'b0; // Initialize valid bits to 0
		end
		for (int set = 0; set < NUM_SETS; set++) begin
			L1_tags[set]<= 1'b0; // Initialize valid bits to 0
		end
		for (int set = 0; set < NUM_SETS; set++) begin
			L1_data[set] <= 1'b0; // Initialize valid bits to 0
		end
		for (int set = 0; set < NUM_SETS; set++) begin
			array_of_cache_L1_memory_addresses[set] <= 1'b0; // Initialize valid bits to 0
		end
		processor_id = 1'b0;
		tag = 1'b0;
		index = 1'b0;
		offset = 1'b0;
		word_start_bit = 1'b0;
		first_write_to_L1_request = 1'b0;
		//Extract the top two bits as the processor ID
		processor_id = cache_L1_memory_address[31:30]; 
		//Bit-slicing to extract the appropriate number of bits for each segment of the cache address
		tag = cache_L1_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
		index = cache_L1_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		offset = cache_L1_memory_address[OFFSET_START -: BLOCK_OFFSET_WIDTH]; //Get offset from requested address
		//Basic Cache States 
		case (current_state)
			IDLE: begin
				if((processor_id == 1) && (cache_read_request || cache_write_request)) begin
					L1_cache_ready = 1'b0;
					L1_cache_hit = 1'b0;
					L1_cache_miss = 1'b0;
					write_to_L2_request = 1'b0;
					first_write_to_L1_request = 1'b1;
					next_state = COMPARE;
				end
				else begin
					next_state = IDLE;
				end			  
			end
			COMPARE: begin
				if(L1_tags[index] == tag && L1_valid_bits[index] == 1) begin //checks if line is marked valid and tags match in L1 cache
					//Cache hit
					L1_cache_hit = 1'b1;
					word_start_bit = offset * DATA_WIDTH; //Offset is multiplied by the width of data bus
					if (cache_read_request) begin
						cache_L1_read_data = L1_data[index][word_start_bit +: DATA_WIDTH]; //Read data from the specific word in block for processor
						//Mark Cache ready 
						L1_cache_ready = 1'b1;
						next_state = IDLE;
					end else if (cache_write_request && first_write_to_L1_request) begin
						//Inclusion policy
						array_of_cache_L1_memory_addresses[index] = cache_L1_memory_address; //stores all cache addresses that are or once were in cache 
						L1_data[index][word_start_bit +: DATA_WIDTH] = cache_write_data; //Write new data to the specific place in block
						L1_dirty_bits[index] = 1'b1; //Mark index as dirty	
						cache_L2_memory_address = cache_L1_memory_address;
						write_to_L2_request = 1'b1; //sends request to L2 for cache inclusion policy 
						first_write_to_L1_request = 1'b0; //prevent writing to the same block location again when waiting for L2 to verify it received the same data to maintain the inclusion policy between L1 and L2
					end
					if(write_to_L2_verified) begin
						//Mark Cache ready 
						L1_cache_ready = 1'b1;
						next_state = IDLE;
					end else begin
						next_state = COMPARE;
					end
				end else begin
					//Cache miss
					L1_cache_miss = 1'b1;
					if (L1_dirty_bits[index] == 1'b1) begin
						//Old block is dirty 
						next_state = WRITE_BACK;
					end
					else begin
						//Old block is clean
						next_state = ALLOCATE;
					end
				end
			end
			ALLOCATE: begin 
				//Instead of continuously replacing blocks in L1, search L2 to see if the requested address is found there 
				cache_L2_memory_address = cache_L1_memory_address;
				read_from_L2_request = 1'b1; //Initiate a read request 
				if(L2_ready) begin //Still for the inclusion policy, L1 gets the same data that L2 grabs L3 by way of this flag outputted from L2
					//Inclusion miss 
					L1_tags[index] = tag; //Get tag from requested address and assign it to block 
					L1_valid_bits[index] = 1'b1; //When the line is first brought into cache set it as valid 
					L1_data[index] = write_data_to_L1_from_L2; //Assign new memory data to the L1 cache block
					//Reset read request flag
					read_from_L2_request = 1'b0;
					next_state = COMPARE;
				end
				else begin
					next_state = ALLOCATE;
				end
			end
			WRITE_BACK: begin
				//Keep track of old cache addresses
				cache_L2_memory_address = array_of_cache_L1_memory_addresses[index]; //Assigns old dirty address to L2 cache
				write_back_to_L2_data = L1_data[index]; // Pass the data to write back to L2
				write_back_to_L2_request = 1'b1; //explicit signal to let l2 know that data needs to get written back to it
				if(write_back_to_L2_verified) begin 
					L1_dirty_bits[index] = 1'b0; //since block has been evicted clear dirty bit marker and prepare for the new data that is coming into that block location
					write_back_to_L2_request = 1'b0;
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