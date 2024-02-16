//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache FSM, L1a

import cache_config::*;
import cache_fsm_L2a::*;
import main_memory_config::*

module cache_fsm (
  input logic clk,
  input logic reset,
  input logic cache_read_request,
  input logic cache_write_request,
  input logic L2_ready,
  input logic [ADDRESS_WIDTH-1:0] cache_L1_memory_address,
  input logic [DATA_WIDTH-1:0] cache_write_data,
  input logic write_to_L1_request, //remember to set this high in the testbench for first L1 cache read
  input logic write_to_L2_verified,

  output logic [DATA_WIDTH-1:0] cache_read_data,
  output logic cache_hit,
  output logic cache_miss,
  output logic cache_ready,
  output logic [ADDRESS_WIDTH-1:0] cache_L2_memory_address,
  output logic write_to_L2_request,
  output logic write_to_L1_verified,
  output logic write_back_to_L2_request,
  output logic read_from_L2_request
);

//Define cache states
typedef enum logic [1:0] { //Size of each enumerator, it indicates that each enumerator is represented using 2 bits (00, 01, 10, 11)
	IDLE,
	COMPARE,
	ALLOCATE,
	WRITE_BACK
} state_t; 

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= IDLE;
    end else begin
		current_state <= next_state;
    end
end

//Separate the processor ID from the actual address
logic [1:0] processor_id;

//Temporary values with specified bit width
logic [TAG_WIDTH-1:0] tag;
logic [INDEX_WIDTH-1:0] index;
logic [BLOCK_OFFSET_WIDTH-1:0] offset; 
logic [ADDRESS_WIDTH-1:0] old_cache_L1_memory_address;
logic [MAIN_MEMORY_DATA_WIDTH-1:0] old_cache_L1_memory_data; 

//Temporary values without specified bit width
int word_start_bit;
int first_write_to_L1_request;

always_comb begin
		//Extract the top two bits as the processor ID
		processor_id = cache_L1_memory_address[31:30]; 
		//Bit-slicing to extract the appropriate number of bits for each segment of the cache address
		tag = cache_L1_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
		index = cache_L1_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		offset = cache_L1_memory_address[OFFSET_START -: BLOCK_OFFSET_WIDTH]; //Get offset from requested address
		//Basic Cache States 
		case (current_state)
			  IDLE: begin
				  if((processor_id == 0) && (cache_read_request || cache_write_request)) begin
					cache_ready = 1'b0;
					cache_hit = 1'b0;
					cache_miss = 1'b0;
					write_to_L2_request = 1'b0;
					write_to_L1_verified = 1'b0;
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
						cache_hit = 1'b1;
						word_start_bit = offset * DATA_WIDTH; //Offset is multiplied by the width of data bus
						if (cache_read_request) begin
      						cache_read_data = L1_data[index][word_start_bit +: DATA_WIDTH]; //Read data from the specific word in block for processor
							//arbiter = cache_read_data?
						end
						else if (cache_write_request) begin
							//Inclusion hit 
							if(write_to_L1_request && first_write_to_L1_request) begin //receives request from L1 cache for inclusion policy 
								L1_data[index][word_start_bit +: DATA_WIDTH] = cache_write_data; //Write new data to the specific place in block
								L1_dirty_bits[index] = 1'b1; //Mark index as dirty	
								cache_L2_memory_address = cache_L1_memory_address; //necessary information for L2 so that it can store the same data as L1
								write_to_L2_request = 1'b1; //sends request to L2 for cache inclusion policy 
								write_to_L1_verified = 1'b1; //send message back to L2 letting it know L1 received same cache data 
								first_write_to_L1_request = 1'b0; //prevent writing data to cache again while waiting for L2 to verify its received data
							end
							if(write_to_L2_verified) begin
								//Mark Cache ready 
								cache_ready = 1'b1;
								next_state = IDLE;
							end else begin
								next_state = COMPARE;
							end
						end
				  end 
				  else begin
					//Cache miss
					cache_miss = 1'b1;
					if (L1_dirty_bits[index] == 1'b1) begin
						//Old block is dirty 
						old_cache_L1_memory_address = cache_L1_memory_address; //Keep track of old cache address
						old_cache_L1_memory_data = L1_data[index]; //store entire dirty block to L2 cache 
						next_state = WRITE_BACK;
					end
					else begin
						//Old block is clean
						next_state = ALLOCATE;
					end
				end
			  end
			  ALLOCATE: begin 
				cache_L2_memory_address = cache_L1_memory_address;
				read_from_L2_request <= 1'b1; //Initiate a read request 
				if(L2_ready) begin //Still for the inclusion policy, L1 gets the same data that L2 grabs L3 by way of this flag outputted from L2
					//Inclusion miss 
					L1_tags[index] = tag; //Get tag from requested address and assign it to block 
					L1_valid_bits[index] = 1'b1; //When the line is first brought into cache set it as valid 
					L1_data[index] = L2_data[tag]; //Assign new memory data to the L1 cache block
					//Reset read request flag
					read_from_L2_request <= 1'b0;
					next_state = COMPARE;
				end
				else begin
					next_state = ALLOCATE;
				end
			  end
			  WRITE_BACK: begin
				cache_L2_memory_address = old_cache_L1_memory_address; //Assigns old dirty address to L2 cache
				L2_data[tag] = old_cache_L1_memory_data; //Write data to the second level of cache
				write_back_to_L2_request = 1'b1; //explicit signal to let l2 know that data needs to get written back to it
				L1_dirty_bits[index] = 1'b0;
				next_state = ALLOCATE;
			  end
			  default: begin 
				  next_state = IDLE; //Default state 
			  end
		 endcase
	end
endmodule