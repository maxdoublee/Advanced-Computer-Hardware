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

	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
			current_state <= IDLE;
		end else begin
			current_state <= next_state;
		end
	end

	//Internal state of the cache level 3, L3
	logic [ADDRESS_WIDTH-1:0] array_of_cache_L3_memory_addresses[NUM_SETS-1:0]; // Array of cache level 3 addresses for each block within each set for writing lru addressed to lower level
	logic [1:0] L3_valid_bits[NUM_SETS-1:0]; //Array of valid bits, one for each cache line
	logic [1:0] L3_dirty_bits[NUM_SETS-1:0]; //Array of dirty bits, one for each cache line
	logic [TAG_WIDTH-1:0] L3_tags[NUM_SETS-1:0]; //Array of tags, one for each cache line
	logic [MAIN_MEMORY_DATA_WIDTH-1:0] L3_data[NUM_SETS-1:0]; //Array of data, one for each cache line

	logic [TAG_WIDTH-1:0] tag;
	logic [INDEX_WIDTH-1:0] index;
	logic [BLOCK_OFFSET_WIDTH-1:0] offset; 

	always_comb begin
		L3_cache_hit = 1'b0;
		L3_cache_miss = 1'b0;
		L3_cache_ready = 1'b0;
		main_memory_read_request = 1'b0;
		next_state = state_t'(1'b0);
		L3_ready = 1'b0;
		write_data_to_L2_from_L3 = 1'b0;
		for (int set = 0; set < NUM_SETS; set++) begin
			L3_valid_bits[set] <= 1'b0; // Initialize valid bits to 0
		end
		for (int set = 0; set < NUM_SETS; set++) begin
			L3_dirty_bits[set] <= 1'b0; // Initialize valid bits to 0
		end
		for (int set = 0; set < NUM_SETS; set++) begin
			L3_tags[set]<= 1'b0; // Initialize valid bits to 0
		end
		for (int set = 0; set < NUM_SETS; set++) begin
			L3_data[set] <= 1'b0; // Initialize valid bits to 0
		end
		for (int set = 0; set < NUM_SETS; set++) begin
			array_of_cache_L3_memory_addresses[set] <= 1'b0; // Initialize valid bits to 0
		end
		tag = 1'b0;
		index = 1'b0;
		offset = 1'b0;
		main_memory_write_data = 1'b0; 
		main_memory_address = 1'b0;
		main_memory_write_request = 1'b0;
		write_back_to_L3_verified = 1'b0;
		//Bit-slicing to extract the appropriate number of bits for each segment of the cache address
		tag = cache_L3_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
		index = cache_L3_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		offset = cache_L3_memory_address[OFFSET_START -: BLOCK_OFFSET_WIDTH]; //Get offset from requested address
		//Basic Cache States 
		case (current_state)
			IDLE: begin
				if(write_back_to_L3_request || read_from_L3_request) begin
					L3_cache_ready = 1'b0;
					L3_cache_hit = 1'b0;
					L3_cache_miss = 1'b0;
					L3_ready = 1'b0;
					next_state = COMPARE;
				end else begin
					next_state = IDLE;
				end			  
			end
			COMPARE: begin
				if(L3_tags[index] == tag && L3_valid_bits[index] == 1) begin //checks if line is marked valid and tags match with L2 cache driving bus 
					//Cache hit
					L3_cache_hit = 1'b1;
					array_of_cache_L3_memory_addresses[index] = cache_L3_memory_address; //Keep track of old cache addresses
					//Write back request from L2
					if(write_back_to_L3_request) begin
						L3_data[index] = write_back_to_L3_data;
						write_back_to_L3_verified = 1'b1;
						//Mark Cache ready 
						L3_cache_ready = 1'b1;
						next_state = IDLE;
					end else if(read_from_L3_request) begin
						write_data_to_L2_from_L3 = L3_data[index];
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
					if (L3_dirty_bits[index] == 1'b1) begin
						// If block is dirty initiate write back 
						next_state = WRITE_BACK;
					end
					else begin
						// Block is clean
						next_state = ALLOCATE;
					end
				end
			end
			ALLOCATE: begin
				main_memory_address = cache_L3_memory_address;
				main_memory_read_request <= 1'b1; //Initiate a read request to main memory
				if(main_memory_ready) begin
					L3_tags[index] = tag; //Get tag from requested address and assign it to block 
					L3_valid_bits[index] = 1'b1; //When the line is first brought into cache set it as valid 
					L3_data[index] = main_memory_read_data; //Assign new memory data to the cache L2 block
					//Reset read request flag
					main_memory_read_request <= 1'b0;
					next_state = COMPARE;
				end else begin
					next_state = ALLOCATE;
				end
			end
			WRITE_BACK: begin
				main_memory_address = array_of_cache_L3_memory_addresses[index]; //Assigns old dirty address to main memory 
				main_memory_write_data = L3_data[index]; //Write data to main memory
				main_memory_write_request = 1'b1; //Initiate a rewrite request to main memory
				if(main_memory_ready) begin
					//Assigned old dirty data block to main memory
					L3_dirty_bits[index] = 1'b0; //Clear dirty bit
					//Reset write request flag
					main_memory_write_request <= 1'b0;
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