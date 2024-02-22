//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache FSM, L2b

import cache_config::*;
import main_memory_config::*;

module cache_fsm_L2b #(
  parameter CACHE_LEVEL = 2
)(
	input logic clk,
	input logic reset,
	input logic L3_ready,
	input logic [ADDRESS_WIDTH-1:0] cache_L2_memory_address,
	input logic [DATA_WIDTH-1:0] cache_write_data,
	input logic write_to_L2_request,
	input logic read_from_L2_request,
	input logic write_back_to_L2_request,
	input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2_data,
	input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2_from_L3,
	input logic write_back_to_L3_verified,
	input logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache,
	input logic arbiter_verify,

	output logic write_to_L2_verified,
	output logic read_from_L3_request,
	output logic write_back_to_L3_request,
	output logic L2_ready,
	output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L1_from_L2,
	output logic write_back_to_L2_verified,
	output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3_data,
   output logic [ADDRESS_WIDTH-1:0] cache_L3_memory_address,
	output logic arbiter_read_update_from_L2_cache_modules,
   output logic arbiter_write_update_from_L2_cache_modules,
	output logic [ADDRESS_WIDTH-1:0] block_to_determine_mesi_state_from_arbiter,
	output logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2b_local_data,
	output logic acknowledge_arbiter_verify,
	output logic L2_cache_hit,
	output logic L2_cache_read_hit,
	output logic L2_cache_write_hit,
	output logic L2_cache_miss,
	output logic L2_cache_read_miss,
	output logic L2_cache_write_miss,
	output logic L2_cache_ready
);

	//Define cache states
	typedef enum logic [1:0] { //Size of each enumerator, it indicates that each enumerator is represented using 2 bits (00, 01, 10, 11)
		IDLE,
		COMPARE,
		ALLOCATE,
		WRITE_BACK
	} state_t; 

	typedef enum logic [1:0] {
        MESI_INVALID,
        MESI_SHARED,
        MESI_EXCLUSIVE,
        MESI_MODIFIED
    } mesi_state_t;

	state_t current_state, next_state;

	//Internal state of the cache level 2, L2
	logic [ADDRESS_WIDTH-1:0] array_of_cache_L2_memory_addresses[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0]; // Array of cache level 2 addresses for each block within each set for writing lru addressed to lower level
	logic [1:0] L2_LRU[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0]; // Array of LRU bits for each block within each set
	logic L2_valid_bits[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0]; //Array of valid bits, one for each cache line of each set
	logic L2_dirty_bits[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0]; //Array of dirty bits, one for each cache line of each set 
	logic [TAG_WIDTH-1:0] L2_tags[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0]; //Array of tags, one for each cache line
	logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2_data[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0]; //Array of data, one for each cache line
	logic [MESI_STATE_WIDTH-1:0] L2_MESI_states[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0]; //MESI states storage

	logic [1:0] processor_id; //Separate the processor ID from the actual address
	logic [TAG_WIDTH-1:0] tag;
	logic [INDEX_WIDTH-1:0] index;
	logic [BLOCK_OFFSET_WIDTH-1:0] offset; 
	logic [1:0] mru; // most recently used value
	logic [1:0] new_lru_value;
	logic update_mesi_state_flag;
	logic write_back_modified_block_for_cache_coherence;
	logic word_start_bit;
	logic lru_way;
    logic check_if_cache_hit_flag;
	logic update_lru_flag;
    logic update_cache_L2_memory_addresses_for_cache_hit_flag;
    logic find_lru_way_and_mesi_prep_flag;
    logic mesi_read_prep_flag; 
    logic after_invalid_flag;
    logic after_shared_flag;
    logic after_exclusive_flag;
    logic after_modified_flag;
    logic mesi_write_prep_flag;
    logic allocate_flag;
    logic write_back_cache_coherence_1_flag;
    logic write_back_cache_coherence_2_flag;
    logic write_back_1_flag;
    logic write_back_2_flag;
    logic dirty_flag;
    logic clean_flag;
    logic cache_hit_flag;
    logic word_start_flag;
    logic cache_L3_memory_address_flag;
    logic block_to_determine_mesi_state_from_arbiter_flag;

	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
            // Set initial values
            word_start_bit = 1'b0;
            lru_way = 1'b0;
            after_invalid_flag = 1'b0;
            after_shared_flag = 1'b0;
            after_exclusive_flag = 1'b0;
            after_modified_flag = 1'b0;
            dirty_flag = 1'b0;
            clean_flag = 1'b0;
            cache_hit_flag = 1'b0;
            write_data_to_L1_from_L2 = 1'b0;
            write_back_to_L3_data = 1'b0;
            cache_L3_memory_address = 1'b0;
            L2b_local_data = 1'b0;
			current_state <= IDLE;
            for (int set = 0; set < NUM_SETS; set++) begin
				for (int block = 0; block < NUM_BLOCKS_PER_SET; block++) begin
					array_of_cache_L2_memory_addresses[set][block] <= 0; // Initialize addresses to 0
					L2_LRU[set][block] <= 0; // Initialize lru bits to 0
					L2_valid_bits[set][block] <= 0; // Initialize valid bits to 0
					L2_dirty_bits[set][block] <= 0; // Initialize dirty bits to 0
					L2_data[set][block] <= 0; // Initialize data to 0
					L2_tags[set][block] <= 0; // Initialize tags to 0
					L2_MESI_states[set][block] <= MESI_INVALID; // Initialize MESI states to Invalid
            	end
        	end
		end else begin
			current_state <= next_state;
			if(check_if_cache_hit_flag) begin 
                // Cache hit
				if(L2_tags[index][tag] == tag && L2_valid_bits[index][tag] == 1) begin //checks if set holds the requested tag i.e. block and if that block has been marked valid or not
					cache_hit_flag = 1'b1;
				end else begin
                    // Cache miss
                    mru = 2'b11;
                    for (int way = 0; way < NUM_BLOCKS_PER_SET; way++) begin 
                        if (L2_LRU[index][way] < mru) begin
                            mru = L2_LRU[index][way]; 
                            lru_way = way;
                        end 
                    end
                    if (L2_dirty_bits[index][lru_way] == 1'b1) begin
                        dirty_flag = 1'b1;
                    end else begin
                        clean_flag = 1'b1;
                    end
				end 
            end
            if(word_start_flag) begin
                word_start_bit = offset * DATA_WIDTH; //Offset is multiplied by the width of data bus
            end
            if (update_lru_flag) begin
        		for (int i = 0; i < NUM_BLOCKS_PER_SET; i++) begin
					// Shift other blocks down in the order, unless they are already least recently used 
					if (L2_LRU[index][i] > 0) begin
						L2_LRU[index][i] = (L2_LRU[index][i] - 1) & 2'b11;
					end
				end
				// Set the accessed block to most recently used
				L2_LRU[index][tag] = new_lru_value;
			end
			if(update_cache_L2_memory_addresses_for_cache_hit_flag) begin
				array_of_cache_L2_memory_addresses[index][tag] = cache_L2_memory_address; //Keep track of old cache addresses
			end 
            if(find_lru_way_and_mesi_prep_flag) begin 
                mru = 2'b11;
                for (int way = 0; way < NUM_BLOCKS_PER_SET; way++) begin 
                    if (L2_LRU[index][way] < mru) begin
                        mru = L2_LRU[index][way]; 
                        lru_way = way;
                    end 
                end
    			L2_data[index][lru_way] = write_back_to_L2_data;
                // Reporting to arbiter needs to occur in write back due to the nature of how lru works and the address that hits may not be the address that gets its data changed 
			    block_to_determine_mesi_state_from_arbiter = array_of_cache_L2_memory_addresses[index][lru_way]; 
			    L2b_local_data = L2_data[index][lru_way]; //provide data to bus from least recently used block
            end
            if(mesi_read_prep_flag) begin
                L2b_local_data = L2_data[index][tag];
            end
            if(update_mesi_state_flag) begin 
                L2_MESI_states[index][tag] = mesi_state_to_cache; //assign mesi state gotten from arbiter
				if(L2_MESI_states[index][tag] == MESI_INVALID) begin 
					after_invalid_flag = 1'b1;
				end else if(L2_MESI_states[index][tag] == MESI_SHARED) begin
					write_data_to_L1_from_L2 = L2_data[index][tag];
                    after_shared_flag = 1'b1;
				end else if(L2_MESI_states[index][tag] == MESI_EXCLUSIVE) begin
					write_data_to_L1_from_L2 = L2_data[index][tag];
					after_exclusive_flag = 1'b1;
				end else if(L2_MESI_states[index][tag] == MESI_MODIFIED) begin
					after_modified_flag = 1'b1;
				end 
            end
            if(mesi_write_prep_flag) begin 
                L2_data[index][tag][word_start_bit +: DATA_WIDTH] = cache_write_data; //Write new data to the specific place in block
                L2_dirty_bits[index][tag] = 1'b1; //Mark tag i.e. block within four way associative set as dirty
                L2b_local_data = L2_data[index][tag];
            end
            if(cache_L3_memory_address_flag) begin
                cache_L3_memory_address = cache_L2_memory_address;
            end
            if(block_to_determine_mesi_state_from_arbiter_flag) begin
                block_to_determine_mesi_state_from_arbiter = cache_L2_memory_address; 
            end
            if(allocate_flag) begin
                L2_tags[index][tag] = tag; //Get tag from requested address and assign it to block 
			    L2_valid_bits[index][tag] = 1'b1; //When the line is first brought into cache set line as valid 
			    L2_data[index][tag] = write_data_to_L2_from_L3; // Assign new memory data to the L2 cache block that has been evict due to it handling the MSB value 
            end
            if(write_back_cache_coherence_1_flag) begin 
                write_back_to_L3_data = L2_data[index][tag]; //Write data to the third level of cache
            end
            if(write_back_cache_coherence_2_flag) begin
                L2_dirty_bits[index][tag] = 1'b0; //Clear dirty bit
            end
            if(write_back_1_flag) begin 
                //Write back least recently used L2 cache block to L3 cache block 
				cache_L3_memory_address = array_of_cache_L2_memory_addresses[index][lru_way]; //Assigns old dirty address to L3 cache
				write_back_to_L3_data = L2_data[index][lru_way]; //Write data to the third level of cache
            end
            if(write_back_2_flag) begin
                L2_dirty_bits[index][lru_way] = 1'b0; //Clear dirty bit
            end
        end
    end

	always_comb begin
		//Reset values for the next evaluation of states
        cache_L3_memory_address_flag = 1'b0;
        block_to_determine_mesi_state_from_arbiter_flag = 1'b0;
        write_back_to_L3_request = 1'b0;
        read_from_L3_request = 1'b0;
        processor_id = 1'b0;
        tag = 1'b0;
        index = 1'b0;
        offset = 1'b0;
        new_lru_value = 1'b0;
        check_if_cache_hit_flag = 1'b0;
        update_lru_flag = 1'b0;
        update_cache_L2_memory_addresses_for_cache_hit_flag = 1'b0;
        find_lru_way_and_mesi_prep_flag = 1'b0;
        mesi_read_prep_flag = 1'b0;
        update_mesi_state_flag = 1'b0;
        mesi_write_prep_flag = 1'b0;
        allocate_flag = 1'b0;
        write_back_cache_coherence_1_flag = 1'b0;
        write_back_cache_coherence_2_flag = 1'b0;
        write_back_1_flag = 1'b0;
        write_back_2_flag = 1'b0;
		L2_cache_ready = 1'b0;
		L2_cache_hit = 1'b0;
		L2_cache_read_hit = 1'b0;
		L2_cache_write_hit = 1'b0;
		L2_cache_miss = 1'b0;
		L2_cache_read_miss = 1'b0;
		L2_cache_write_miss = 1'b0;
		write_to_L2_verified = 1'b0;
		L2_ready = 1'b0;
        word_start_flag = 1'b0;
		write_back_to_L2_verified = 1'b0;
		arbiter_read_update_from_L2_cache_modules = 1'b0;
		arbiter_write_update_from_L2_cache_modules = 1'b0;
		write_back_modified_block_for_cache_coherence = 1'b0;
		acknowledge_arbiter_verify = 1'b0;
		next_state = state_t'(1'b0);
		//Extract the top two bits as the processor ID
		processor_id = cache_L2_memory_address[31:30]; 
		//Bit-slicing to extract the appropriate number of bits for each segment of the cache address
		tag = cache_L2_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
		index = cache_L2_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		offset = cache_L2_memory_address[OFFSET_START -: BLOCK_OFFSET_WIDTH]; //Get offset from requested address
		//Basic Cache States 
		case (current_state)
			IDLE: begin
				if((processor_id == 1) && (write_back_to_L2_request || read_from_L2_request || write_to_L2_request)) begin
					next_state = COMPARE; 
				end else begin
					next_state = IDLE;
				end			  
			end
			COMPARE: begin  
				check_if_cache_hit_flag = 1'b1;
				if(cache_hit_flag) begin
					//Cache hit
					L2_cache_hit = 1'b1;
                    word_start_flag = 1'b1;
					update_lru_flag = 1'b1; // Signal that LRU should be updated					
					update_cache_L2_memory_addresses_for_cache_hit_flag = 1'b1;
					//Write back request from L1 
					if(write_back_to_L2_request) begin
                        find_lru_way_and_mesi_prep_flag = 1'b1;
                        arbiter_write_update_from_L2_cache_modules = 1'b1; //update bus
						if(arbiter_verify) begin
							acknowledge_arbiter_verify = 1'b1;
							arbiter_write_update_from_L2_cache_modules = 1'b0;
							write_back_to_L2_verified = 1'b1;
							//Mark Cache ready 
							L2_cache_ready = 1'b1;
							next_state = IDLE;
						end else begin
							next_state = COMPARE;
						end
					end else if(read_from_L2_request) begin
						//Read hit 
						L2_cache_read_hit = 1'b1;
                        block_to_determine_mesi_state_from_arbiter_flag = 1'b1;
                        mesi_read_prep_flag = 1'b1;
						arbiter_read_update_from_L2_cache_modules = 1'b1; //sends out a read request to arbiter to determine state of block 
						if(arbiter_verify) begin
							acknowledge_arbiter_verify = 1'b1;
							arbiter_read_update_from_L2_cache_modules = 1'b0; //reset read request signal
							update_mesi_state_flag = 1'b1;
                            if(after_invalid_flag) begin
                                next_state = ALLOCATE;
                            end else if(after_shared_flag) begin
                                L2_ready = 1'b1; 
                                //Mark Cache ready 
                                L2_cache_ready = 1'b1;
                                next_state = IDLE;
                            end else if(after_exclusive_flag) begin
                                L2_ready = 1'b1; 
                                //Mark Cache ready 
                                L2_cache_ready = 1'b1;
                                next_state = IDLE;
                            end else if(after_modified_flag) begin
                                write_back_modified_block_for_cache_coherence = 1'b1; //because writeback for four way associative is handled with lru logic, I needed a signal to differentiate between writing back lru versus modified block for cache coherence								next_state = WRITE_BACK;
                                next_state = WRITE_BACK;
                            end
						end else begin
							next_state = COMPARE;
						end
					end else if(write_to_L2_request) begin
						//Write hit 
						L2_cache_write_hit = 1'b1;
						mesi_write_prep_flag = 1'b1;
                        block_to_determine_mesi_state_from_arbiter_flag = 1'b1;
						arbiter_write_update_from_L2_cache_modules = 1'b1; 
						if(arbiter_verify) begin
							acknowledge_arbiter_verify = 1'b1;
							arbiter_write_update_from_L2_cache_modules = 1'b0;
							write_to_L2_verified = 1'b1;
							//Mark Cache ready 
							L2_cache_ready = 1'b1;
							next_state = IDLE;
						end else begin
							next_state = COMPARE;
						end
					end else begin 
						//Mark Cache ready 
						L2_cache_ready = 1'b1;
						next_state = IDLE;
					end 
				end else begin
					// Cache miss
					L2_cache_miss = 1'b1;
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
				//Instead of continuously replacing blocks in L2, search L3 to see if the requested address is found there 
				cache_L3_memory_address_flag = 1'b1;
				read_from_L3_request <= 1'b1; //Initiate a read request
				if(L3_ready) begin 
					allocate_flag = 1'b1;
					//Reset read request flag
					read_from_L3_request <= 1'b0;
					next_state = COMPARE;
				end else begin 
					next_state = ALLOCATE;
				end
			end
			WRITE_BACK: begin
				//Write back the current block to L3 cache block as it has been marked as modified by the arbiter
				if(write_back_modified_block_for_cache_coherence) begin 
                    write_back_modified_block_for_cache_coherence = 1'b0;
				    cache_L3_memory_address_flag = 1'b1;
					write_back_cache_coherence_1_flag = 1'b1;
			        write_back_to_L3_request = 1'b1;
                    if(write_back_to_L3_verified) begin
                        write_back_cache_coherence_2_flag = 1'b1;
						write_back_to_L3_request = 1'b0;
				        next_state = COMPARE;
                    end else begin
				        next_state = WRITE_BACK; //keep in state until data from L2 is verified to be sent to L3
			        end 
                end else begin
                    write_back_1_flag = 1'b1;
                    write_back_to_L3_request = 1'b1; 
                    if(write_back_to_L3_verified) begin
                        write_back_2_flag = 1'b1;
                        write_back_to_L3_request = 1'b0;
						next_state = ALLOCATE;
                    end else begin
						next_state = WRITE_BACK; //keep in state until data from L2 is verified to be sent to L3
					end 
                end
			end
			default: begin 
				next_state = IDLE; //Default state 
			end
		endcase
	end
endmodule