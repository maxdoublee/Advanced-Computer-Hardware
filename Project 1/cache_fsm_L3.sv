//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache FSM, L3

import cache_config::*;
import main_memory_config::*;
import main_memory_controller::*;

module cache_fsm (
  input logic clk,
  input logic reset,
  input logic cache_read_request,
  input logic cache_write_request,
  input logic main_memory_ready,
  input logic [ADDRESS_WIDTH-1:0] cache_L3_memory_address,
  input logic [DATA_WIDTH-1:0] cache_write_data,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data,
  input logic read_from_L3_request,

  output logic [DATA_WIDTH-1:0] cache_read_data,
  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_write_data,
  output logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address,
  output logic cache_hit,
  output logic cache_miss,
  output logic cache_ready,
  output logic main_memory_read_request,
  output logic main_memory_write_request,
  output logic L3_ready
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

//Temporary values with specified bit width
logic [TAG_WIDTH-1:0] tag;
logic [INDEX_WIDTH-1:0] index;
logic [BLOCK_OFFSET_WIDTH-1:0] offset; 
logic [ADDRESS_WIDTH-1:0] old_cache_L3_memory_address;
logic [MAIN_MEMORY_DATA_WIDTH-1:0] old_cache_L3_memory_data; 

//Temporary values without specified bit width
int word_start_bit;

always_comb begin
		//Bit-slicing to extract the appropriate number of bits for each segment of the cache address
		tag = cache_L3_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
		index = cache_L3_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		offset = cache_L3_memory_address[OFFSET_START -: BLOCK_OFFSET_WIDTH]; //Get offset from requested address
		//Basic Cache States 
		case (current_state)
			  IDLE: begin
				  if(cache_read_request || cache_write_request) begin
					cache_ready = 1'b0;
					cache_hit = 1'b0;
					cache_miss = 1'b0;
					L3_ready = 1'b0;
					next_state = COMPARE;
				  end
				  else begin
					next_state = IDLE;
				  end			  
			  end
			  COMPARE: begin
				  if(L3_tags[index] == tag && L3_valid_bits[index] == 1) begin //checks if line is marked valid and tags match with L2 cache driving bus 
						//Cache hit
						cache_hit = 1'b1;
						L3_ready = 1'b1;  //I know at this point L3 has the data being searched for by L2 so no need to go into the allocate state of this cache and will allow L1 allocate to proceed
						word_start_bit = offset * DATA_WIDTH; //Offset is multiplied by the width of data bus
						if (cache_read_request) begin
      						cache_read_data = L3_data[index][word_start_bit +: DATA_WIDTH]; //Read data from the specific word in block for processor
							//arbiter = cache_read_data?
						end
						else if (cache_write_request) begin
      						L3_data[index][word_start_bit +: DATA_WIDTH] = cache_write_data; //Write new data to the specific place in block
							L3_dirty_bits[index] = 1'b1; //Mark index as dirty	
							//MESI stuff would go here 
						end
						//Mark Cache ready 
						cache_ready = 1'b1;
						next_state = IDLE;
				  end 
				  else begin
						//Cache miss
						cache_miss = 1'b1;
						if (L3_dirty_bits[index] == 1'b1) begin
							//Old block is dirty 
							old_cache_L3_memory_address = cache_L3_memory_address; //Keep track of old cache address
							old_cache_L3_memory_data = L3_data[index]; //store entire dirty block to main memory
							next_state = WRITE_BACK;
						end
						else begin
							//Old block is clean
							next_state = ALLOCATE;
						end
					end
			  end
			  ALLOCATE: begin
				if(read_from_L3_request) begin 
					main_memory_read_request <= 1'b1; //Initiate a read request to main memory
					if(main_memory_ready) begin
						L3_tags[index] = cache_L3_memory_address[ADDRESS_WIDTH-1 -: TAG_WIDTH]; //Get tag from requested address and assign it to block 
						L3_valid_bits[index] = 1'b1; //When the line is first brought into cache set it as valid 
						L3_data[index] = main_memory_read_data; //Assign new memory data to the cache L2 block
						L3_ready = 1'b1;
						//Reset read request flag
						main_memory_read_request <= 1'b0;
						next_state = COMPARE;
					end
					else begin
						next_state = ALLOCATE;
					end
				end
			  end
			  WRITE_BACK: begin
				main_memory_address = old_cache_L3_memory_address; //Assigns old dirty address to main memory 
				main_memory_write_data = old_cache_L3_memory_data; //Write data to main memory
				main_memory_write_request <= 1'b1; //Initiate a rewrite request to main memory
				if(main_memory_ready) begin
					//Assigned old dirty data block to main memory
					//Clear dirty bit
					L3_dirty_bits[index] = 1'b0;
					//Reset write request flag
					main_memory_write_request <= 1'b0;
					next_state = ALLOCATE;
				end 
				else begin
					next_state = WRITE_BACK;
				end
			  end
			  default: begin 
				  next_state = IDLE; // Default state 
			  end
		 endcase
	end
endmodule