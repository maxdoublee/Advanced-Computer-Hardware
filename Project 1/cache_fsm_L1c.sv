//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache FSM, L1c

import cache_config::*;
import main_memory_config::*;

module cache_fsm (
  input logic clk,
  input logic reset,
  input logic cache_read_request,
  input logic cache_write_request,
  input logic main_memory_ready,
  input logic [ADDRESS_WIDTH-1:0] cache_memory_address,
  input logic [DATA_WIDTH-1:0] cache_write_data,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data,

  output logic [DATA_WIDTH-1:0] cache_read_data,
  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_write_data,
  output logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address,
  output logic cache_hit,
  output logic cache_miss,
  output logic cache_ready,
  output logic main_memory_read_request,
  output logic main_memory_write_request
);

//Define states
typedef enum logic [1:0] { // Size of each enumerator, it indicates that each enumerator is represented using 2 bits (00, 01, 10, 11)
	IDLE,
	COMPARE,
	ALLOCATE,
	WRITE_BACK
}	state_t; 

state_t current_state, next_state;

always_ff@(posedge clk or posedge reset)
begin
	if (reset) begin
		current_state <= IDLE;
	end
	else begin
		current_state <= next_state;
	end
end

//Temporary values with specified bit width
logic [TAG_WIDTH-1:0] tag;
logic [INDEX_WIDTH-1:0] index;
logic [BLOCK_OFFSET_WIDTH-1:0] offset; 
logic [ADDRESS_WIDTH-1:0] old_cache_memory_address[NUM_BLOCKS-1:0];
logic [MAIN_MEMORY_DATA_WIDTH-1:0] old_cache_memory_data; //Because data between cache and main memory needs to be 128 bits wide 

//Temporary values without specified bit width
int block_start_index;
int word_index_within_block;

always_comb
	begin
		//Bit-slicing to extract the appropriate number of bits for each segment of the cache address
		tag = cache_memory_address[ADDRESS_WIDTH-1 -: TAG_WIDTH];
		index = cache_memory_address[INDEX_START -: INDEX_WIDTH];
		offset = cache_memory_address[OFFSET_START -: BLOCK_OFFSET_WIDTH]; //Get offset from requested address
		//States 
		case (current_state)
			  IDLE: 
			  begin
				  if (cache_read_request || cache_write_request) begin
						cache_ready = 1'b0;
						cache_hit = 1'b0;
						cache_miss = 1'b0;
						next_state = COMPARE;
				  end
				  else begin
						next_state = IDLE;
				  end			  
			  end
			  COMPARE: 
			  begin
				  if(valid_bits[index] == 1 && (tags[index] == tag)) begin //checks if line is marked valid and tags match
						//Cache hit
						cache_hit = 1'b1;
						block_start_index = index * WORDS_BLOCK_SIZE; //Computes start of block in data array
						word_index_within_block = block_start_index + offset; //Finds specific word index in block (4 words total)
						if (cache_read_request) begin
							cache_read_data = data[word_index_within_block]; //Reads data from specific word in block for processor 
						end
						else if (cache_write_request) begin
							data[word_index_within_block] = cache_write_data; //Writes data from specific word in block to cache from processor 
							dirty_bits[index] = 1'b1; //Mark entire index as dirty
						end
						//Mark Cache ready 
						cache_ready = 1'b1;
						next_state = IDLE;
				  end 
				  else begin
						//Cache miss
						cache_miss = 1'b1;
						if (dirty_bits[index] == 1'b1) begin
							//Old block is dirty 
							block_start_index = index * WORDS_BLOCK_SIZE; //Computes start of block in data array
							//Increment through the block in cache memory to grab each word from block to be stored into main memory
							for (int i = 0; i < WORDS_BLOCK_SIZE; i++) begin 
								old_cache_memory_data[((i+1) * DATA_WIDTH)-1 -: DATA_WIDTH] = data[block_start_index + i]; //Because old_cache_memory_data is 128 bits wide, slice through it to assign the 32 bits segments from cache memory block 
							end
							next_state = WRITE_BACK;
						 end
						 else begin
							//Old block is clean
							next_state = ALLOCATE;
						 end
				   end
			  end
			  ALLOCATE: 
			  begin
					main_memory_read_request <= 1'b1; // Initiate a read request to main memory
					if(main_memory_ready) begin
						block_start_index = index * WORDS_BLOCK_SIZE; //Computes start of block in data array
						for(int i = 0; i < WORDS_BLOCK_SIZE; i++) begin
							tags[block_start_index + i] = cache_memory_address[ADDRESS_WIDTH-1 -: TAG_WIDTH]; //Get same tag from requested address and assign to subsequent word indexes
							data[block_start_index + i] = main_memory_read_data[(i+1) * DATA_WIDTH-1 -: DATA_WIDTH-1]; //Assign new memory data to the cache in segments of 32 bits which comes from a 128 bit address from main memory for spatial locality
						end
						valid_bits[index] = 1'b1; //When the line is first brought into cache set it as valid 
						//Keep track of old cache addresses 
						old_cache_memory_address[index] = cache_memory_address;
						//Reset read request flag
						main_memory_read_request <= 1'b0;
						next_state = COMPARE;
					end 
					else begin
						next_state = ALLOCATE;
					end
			  end
			  WRITE_BACK: 
			  begin
				  main_memory_write_request <= 1; //Initiate a rewrite request to main memory
				  if(main_memory_ready) begin
						main_memory_address = old_cache_memory_address[index]; //Assigns old dirty address to main memory 
						//Assigns old dirty data block to main memory
						for (int i = 0; i < WORDS_BLOCK_SIZE; i++) begin 
							main_memory_write_data = old_cache_memory_data[((i+1) * DATA_WIDTH)-1 -: DATA_WIDTH]; 
						end
						//Clear dirty bit
						dirty_bits[index] = 1'b0;
						//Reset write request flag
						main_memory_write_request <= 1'b0;
						next_state = ALLOCATE;
				  end 
				  else begin
						next_state = WRITE_BACK;
				  end
			  end
			  default: 
			  begin 
				  next_state = IDLE; // Default state 
			  end
		 endcase
	end
endmodule