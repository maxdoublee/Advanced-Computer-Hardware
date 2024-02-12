//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache FSM, L2a

import cache_config::*;
import cache_fsm_L1a::*;

module cache_fsm (
  input logic clk,
  input logic reset,
  input logic cache_read_request,
  input logic cache_write_request,
  input logic L3_ready,
  input logic [ADDRESS_WIDTH-1:0] cache_L2_memory_address,
  input logic [DATA_WIDTH-1:0] cache_write_data,
  input logic write_to_L2_request,
  input logic write_to_L1_verified,
  input logic read_from_L2_request,
  input logic write_back_to_L2_request,

  output logic [DATA_WIDTH-1:0] cache_read_data,
  output logic cache_hit,
  output logic cache_miss,
  output logic cache_ready,
  output logic write_to_L1_request,
  output logic write_to_L2_verified,
  output logic read_from_L3_request,
  output logic write_back_to_L3_request,
  output logic L2_ready
);

//Define cache states
typedef enum logic [1:0] { //Size of each enumerator, it indicates that each enumerator is represented using 2 bits (00, 01, 10, 11)
	IDLE,
	COMPARE,
	ALLOCATE,
	WRITE_BACK
} state_t; 

//MESI state definitions
typedef enum logic [1:0] {
    MESI_MODIFIED,
    MESI_EXCLUSIVE,
    MESI_SHARED,
    MESI_INVALID
} mesi_state_t;

state_t current_state, next_state;
mesi_state_t mesi_states[NUM_SETS-1:0]; //MESI state for each cache block

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
logic [ADDRESS_WIDTH-1:0] old_cache_L2_memory_address;
logic [MAIN_MEMORY_DATA_WIDTH-1:0] old_cache_L2_memory_data; 

//Temporary values without specified bit width
int word_start_bit;
int first_write_to_L2_request;

always_comb begin
		//Extract the top two bits as the processor ID
		processor_id = processor_req_memory_address[31:30]; 
		//Bit-slicing to extract the appropriate number of bits for each segment of the cache address
		tag = cache_L2_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
		index = cache_L2_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		offset = cache_L2_memory_address[OFFSET_START -: BLOCK_OFFSET_WIDTH]; //Get offset from requested address
		//Basic Cache States 
		case (current_state)
			  IDLE: begin
				  if((processor_id == 0) && (cache_read_request || cache_write_request)) begin
					cache_ready = 1'b0;
					cache_hit = 1'b0;
					cache_miss = 1'b0;
					write_to_L1_request = 1'b0;
					write_to_L2_verified = 1'b0;
					L2_ready = 1'b0;
					first_write_to_L2_request = 1'b1;
					next_state = COMPARE;
				  end
				  else begin
					next_state = IDLE;
				  end			  
			  end
			  COMPARE: begin
				  if(L2_indexes[index] == index && L2_tags[tag] == tag && L2_valid_bits[tag] == 1) begin //checks if set holds the requested tag i.e. block and if that block has been marked valid or not
					//Cache hit
					cache_hit = 1'b1;
					L2_ready = 1'b1; //I know at this point L2 has the data being searched for by L1 so no need to go into the allocate state of this cache and will allow L1 allocate to proceed
					word_start_bit = offset * DATA_WIDTH; //Offset is multiplied by the width of data bus
					if (cache_read_request) begin
						cache_read_data = L2_data[tag][word_start_bit +: DATA_WIDTH]; //Read data from the specific word in block for processor
						//arbiter = cache_read_data?
					end
					else if (cache_write_request) begin
						if(write_to_L2_request && first_write_to_L2_request) begin //receives request from L1 cache for inclusion policy 
							L2_data[tag][word_start_bit +: DATA_WIDTH] = cache_write_data; //Write new data to the specific place in block
							L2_dirty_bits[tag] = 1'b1; //Mark tag i.e. block within four way associative set as dirty	
							cache_L1_memory_address = cache_L2_memory_address; //necessary information for L1 so that it can store the same data as L2
							write_to_L1_request = 1'b1; //sends request to L1 for cache inclusion policy 
							write_to_L2_verified = 1'b1; //send message back to L1 letting it know L2 received same cache data 
							first_write_to_L2_request = 1'b0; //prevent writing data to cache again while waiting for L1 to verify its received data
						end else if(write_back_to_L2_request) begin 

						end
						if(write_to_L1_verified) begin
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
					if (L2_dirty_bits[tag] == 1'b1) begin
						//Old block is dirty 
						old_cache_L2_memory_address = cache_L2_memory_address; //Keep track of old cache address
						old_cache_L2_memory_data = L2_data[tag]; //store entire dirty block to main memory
						next_state = WRITE_BACK;
					end
					else begin
						//Old block is clean
						next_state = ALLOCATE;
					end
				end
			  end
			  ALLOCATE: begin
				if(read_from_L2_request) begin 
					//Ensure none of the bits within the row for the L3_data array are unknowns i.e. never written to
					if(!$isunknown(L3_data[index])) begin 
						L2_indexes[index] = index; //sets array to the current index value to avoid the issue of a tag value being found in different a set of the L2 cache due to its four way associative implementation 
						L2_tags[tag] = tag; //Get tag from requested address and assign it to block 
						L2_valid_bits[tag] = 1'b1; //When the line is first brought into cache set it as valid 
						L2_data[tag] = L3_data[index]; //Assign new memory data to the L2 cache block, may change due to associative policy for between l2 and l3
						L2_ready = 1'b1;
						next_state = COMPARE;
					end 
					else begin
						cache_L3_memory_address = cache_L2_memory_address;
						read_from_L3_request <= 1'b1; //Initiate a read request
						if(L3_ready) begin 
							L2_indexes[index] = index; //sets array to the current index value to avoid the issue of a tag value being found in different a set of the L2 cache due to its four way associative implementation 
							L2_tags[tag] = tag; //Get tag from requested address and assign it to block 
							L2_valid_bits[tag] = 1'b1; //When the line is first brought into cache set it as valid 
							L2_data[tag] = L3_data[index]; //Assign new memory data to the L2 cache block, may change due to associative policy for between l2 and l3
							L2_ready = 1'b1;
							//Reset read request flag
							read_from_L3_request <= 1'b0;
							next_state = COMPARE;
						end
						else begin 
							next_state = ALLOCATE;
						end
					end 
				end
			  end
			  WRITE_BACK: begin
				write_back_to_L3_request = 1'b1;
				if(write_back_to_L3_request) begin 
					
				end
				cache_L3_memory_address = old_cache_L2_memory_address; //Assigns old dirty address to L3 cache
				L3_data[index] = old_cache_L2_memory_data; //Write data to the thirc level of cache
				L2_dirty_bits[tag] = 1'b0;
				write_back_to_L2_verified = 1'b1;
				next_state = ALLOCATE;
			  end
			  default: begin 
				  next_state = IDLE; //Default state 
			  end
		 endcase
	end
endmodule