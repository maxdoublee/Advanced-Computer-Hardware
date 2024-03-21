//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache FSM, L2d

import cache_config::*;
import main_memory_config::*;

module cache_fsm_L2d #(
  parameter CACHE_LEVEL = 2
)(
	input logic clk,
	input logic reset,
	input logic arbiter_confirmed_L3_ready_for_L2d,
	input logic [ADDRESS_WIDTH-1:0] cache_L2d_memory_address,
	input logic [DATA_WIDTH-1:0] cache_1d_write_data_to_L2d,
	input logic write_to_L2d_request,
	input logic read_from_L2d_request,
	input logic write_back_to_L2d_request,
	input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L2d_data,
	input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2d_from_L3d,
	input logic write_back_to_L3_from_arbiter_d_verified,
	input logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache_d,
	input logic arbiter_verify_d,
	input logic cache_fsm_L2d_block_to_arbiter_verified,
	input logic mesi_state_confirmation_d,

	output logic write_to_L2d_verified,
	output logic read_from_L3_request_from_L2d,
	output logic write_back_to_L3_request_from_L2d,
	output logic L2d_ready,
	output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L1d_from_L2d,
	output logic write_back_to_L2d_verified,
	output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3d_data,
   output logic [ADDRESS_WIDTH-1:0] cache_L3d_memory_address,
	output logic arbiter_read_update_from_L2d_cache_modules,
   output logic arbiter_write_update_from_L2d_cache_modules,
	output logic [ADDRESS_WIDTH-1:0] block_d_to_determine_mesi_state_from_arbiter,
	output logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2d_local_data,
	output logic acknowledge_arbiter_verify_d,
	output logic L2d_cache_hit,
	output logic L2d_cache_read_hit,
	output logic L2d_cache_write_hit,
	output logic L2d_cache_miss,
	output logic L2d_cache_ready,
	output logic cache_fsm_L2d_block_to_arbiter,
	output logic cache_L3d_memory_address_to_array_L3d_to_arbiter_flag,
	output logic [1:0] lru_way_d,
	output logic mesi_state_confirmation_verified_flag_d,
	output logic [MAIN_MEMORY_DATA_WIDTH-1:0] data_stored_at_cache_L2d_from_main_memory	
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
	logic [ADDRESS_WIDTH-1:0] array_of_cache_L2d_memory_addresses[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0]; // Array of cache level 2 addresses for each block within each set for writing lru addressed to lower level
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
	logic [1:0] lru_value;
	logic [1:0] accessed_way;
	logic update_mesi_state_flag;
	logic once_update_mesi_state_flag;
	logic write_back_modified_block_for_cache_coherence;
	logic word_start_bit;
    logic check_if_cache_hit_flag;
	logic update_lru_flag;
    logic update_cache_L2d_memory_addresses_for_cache_hit_flag;
    logic find_lru_way_d_and_mesi_prep_flag;
    logic mesi_read_prep_flag; 
    logic after_invalid_flag;
    logic after_shared_flag;
    logic after_exclusive_flag;
    logic after_modified_flag;
	logic reset_after_invalid_flag;
	logic reset_after_shared_flag;
	logic reset_after_exclusive_flag;
	logic reset_after_modified_flag;
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
    logic cache_L3d_memory_address_flag;
    logic block_d_to_determine_mesi_state_from_arbiter_flag;
	logic cache_fsm_L2d_block_to_arbiter_flag;
	logic check_L2d_allocate_once_to_set_ff_flag;
	logic check_L2d_allocate_once_to_reset_ff_flag;
	logic check_L2d_allocate_once_to_comb_flag;
	logic first_read_flag;
	logic set_arbiter_read_update_from_L2d_cache_modules_flag;
	logic reset_arbiter_read_update_from_L2d_cache_modules_flag;
	logic arbiter_read_update_from_L2d_cache_modules_flag;
	logic reset_update_mesi_state_flag;
	logic set_reading_flag;
	logic reset_reading_flag;
	logic reenter_compare_state;
	logic acknowledge_arbiter_verify_d_flag;
	logic set_acknowledge_arbiter_verify_d_flag;
	logic reset_acknowledge_arbiter_verify_d_flag;
	logic release_L2d_compare;

	int stop_reading_flag = 0;
	int internal_set_reading_flag = 0;

	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
            // Set initial values
            word_start_bit = 1'b0;
            lru_way_d = 1'b0;
			accessed_way = 1'b0;
            after_invalid_flag = 1'b0;
            after_shared_flag = 1'b0;
            after_exclusive_flag = 1'b0;
            after_modified_flag = 1'b0;
            dirty_flag = 1'b0;
            clean_flag = 1'b0;
            cache_hit_flag = 1'b0;
            write_data_to_L1d_from_L2d = 1'b0;
            write_back_to_L3d_data = 1'b0;
            cache_L3d_memory_address = 1'b0;
            L2d_local_data = 1'b0;
			cache_fsm_L2d_block_to_arbiter = 1'b0;
			check_L2d_allocate_once_to_comb_flag = 1'b0;
			arbiter_read_update_from_L2d_cache_modules_flag = 1'b0; 
			set_reading_flag = 1'b0;
			acknowledge_arbiter_verify_d_flag = 1'b0;
			current_state <= IDLE;
            for (int set = 0; set < NUM_SETS; set++) begin
				for (int block = 0; block < NUM_BLOCKS_PER_SET; block++) begin
					array_of_cache_L2d_memory_addresses[set][block] <= 0; // Initialize addresses to 0
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
				if(L2_tags[index][lru_way_d] == tag && L2_valid_bits[index][lru_way_d] == 1) begin //checks if set holds the requested tag i.e. block and if that block has been marked valid or not
					cache_hit_flag = 1'b1;
				end else begin
                    // Cache miss
					lru_value = 1'b0; // Assuming higher values are less recently used
					lru_way_d = 1'b0; // Default to first way
					for (int way = 0; way < NUM_BLOCKS_PER_SET; way++) begin 
						if (L2_LRU[index][way] > lru_value) begin
							lru_value = L2_LRU[index][way]; // Find the block with the highest LRU value
							lru_way_d = way; // This is the LRU way
						end 
					end
                    if (L2_dirty_bits[index][lru_way_d] == 1'b1) begin
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
				// Updates the LRU bits for all the ways within the set.
				for (int i = 0; i < NUM_BLOCKS_PER_SET; i++) begin
					// Decreases the LRU value of other blocks
					if (i != accessed_way && L2_LRU[index][i] < L2_LRU[index][accessed_way]) begin
						L2_LRU[index][i] = L2_LRU[index][i] + 1;
					end
				end
				// Set the accessed block to most recently used
				L2_LRU[index][accessed_way] = 0; // Assuming 0 is most recently used
			end
			if(update_cache_L2d_memory_addresses_for_cache_hit_flag) begin
				array_of_cache_L2d_memory_addresses[index][lru_way_d] = cache_L2d_memory_address; //Keep track of old cache addresses
			end 
            if(find_lru_way_d_and_mesi_prep_flag) begin 
    			L2_data[index][lru_way_d] = write_back_to_L2d_data;
                // Reporting to arbiter needs to occur in write back due to the nature of how lru works and the address that hits may not be the address that gets its data changed 
			    block_d_to_determine_mesi_state_from_arbiter = array_of_cache_L2d_memory_addresses[index][lru_way_d]; 
			    L2d_local_data = L2_data[index][lru_way_d]; //provide data to bus from least recently used block
            end
			if(block_d_to_determine_mesi_state_from_arbiter_flag) begin
                block_d_to_determine_mesi_state_from_arbiter = cache_L2d_memory_address; 
            end
			if(cache_fsm_L2d_block_to_arbiter_flag) begin 
				cache_fsm_L2d_block_to_arbiter = 1'b1;
			end
			if(cache_fsm_L2d_block_to_arbiter_verified) begin 
				cache_fsm_L2d_block_to_arbiter = 1'b0;
			end
            if(mesi_read_prep_flag) begin
                L2d_local_data = L2_data[index][tag];
            end
			if(set_arbiter_read_update_from_L2d_cache_modules_flag) begin
				arbiter_read_update_from_L2d_cache_modules_flag = 1'b1; 
			end
			if(reset_arbiter_read_update_from_L2d_cache_modules_flag) begin
				arbiter_read_update_from_L2d_cache_modules_flag = 1'b0; 
			end
            if(update_mesi_state_flag) begin 
                L2_MESI_states[index][lru_way_d] = mesi_state_to_cache_d; //assign mesi state gotten from arbiter
				if(L2_MESI_states[index][lru_way_d] == MESI_INVALID && mesi_state_confirmation_d) begin
					reset_update_mesi_state_flag = 1'b1;
					mesi_state_confirmation_verified_flag_d = 1'b1;
					after_invalid_flag = 1'b1;
				end else if(L2_MESI_states[index][lru_way_d] == MESI_SHARED && mesi_state_confirmation_d) begin
					reset_update_mesi_state_flag = 1'b1;
					write_data_to_L1d_from_L2d = L2_data[index][lru_way_d];
					mesi_state_confirmation_verified_flag_d = 1'b1;
                    after_shared_flag = 1'b1;
				end else if(L2_MESI_states[index][lru_way_d] == MESI_EXCLUSIVE && mesi_state_confirmation_d) begin
					reset_update_mesi_state_flag = 1'b1;
					write_data_to_L1d_from_L2d = L2_data[index][lru_way_d];
					mesi_state_confirmation_verified_flag_d = 1'b1;
					after_exclusive_flag = 1'b1;
				end else if(L2_MESI_states[index][lru_way_d] == MESI_MODIFIED && mesi_state_confirmation_d) begin
					reset_update_mesi_state_flag = 1'b1;
					mesi_state_confirmation_verified_flag_d = 1'b1;
					after_modified_flag = 1'b1;
				end 
            end
			if(reset_after_invalid_flag) begin 
				after_invalid_flag = 1'b0;
			end else if(reset_after_shared_flag) begin 
				after_shared_flag = 1'b0;
			end else if(reset_after_exclusive_flag) begin 
				after_exclusive_flag = 1'b0;
			end else if(reset_after_modified_flag) begin 
				after_modified_flag = 1'b0;
			end
			if(internal_set_reading_flag) begin
				set_reading_flag = 1'b1;
			end
			if(reset_reading_flag) begin 
				set_reading_flag = 1'b0;
			end 
            if(mesi_write_prep_flag) begin 
                L2_data[index][lru_way_d][word_start_bit +: DATA_WIDTH] = cache_1d_write_data_to_L2d; //Write new data to the specific place in block
                L2_dirty_bits[index][lru_way_d] = 1'b1; //Mark tag i.e. block within four way associative set as dirty
                L2d_local_data = L2_data[index][lru_way_d];
            end
			if(set_acknowledge_arbiter_verify_d_flag) begin
				acknowledge_arbiter_verify_d_flag = 1'b1;
			end
			if(reset_acknowledge_arbiter_verify_d_flag) begin
				acknowledge_arbiter_verify_d_flag = 1'b0;
			end 
			if(check_L2d_allocate_once_to_set_ff_flag) begin 
				check_L2d_allocate_once_to_comb_flag = 1'b1;
			end 
			if(check_L2d_allocate_once_to_reset_ff_flag) begin 
				check_L2d_allocate_once_to_comb_flag = 1'b0;
			end 
            if(cache_L3d_memory_address_flag) begin
                cache_L3d_memory_address = cache_L2d_memory_address;
            end
            if(allocate_flag) begin
                L2_tags[index][lru_way_d] = tag; //Get tag from requested address and assign it to block 
			    L2_valid_bits[index][lru_way_d] = 1'b1; //When the line is first brought into cache set line as valid 
			    L2_data[index][lru_way_d] = write_data_to_L2d_from_L3d; // Assign new memory data to the L2 cache block that has been evict due to it handling the MSB value 
     			data_stored_at_cache_L2d_from_main_memory = L2_data[index][lru_way_d];
            end
            if(write_back_cache_coherence_1_flag) begin 
                write_back_to_L3d_data = L2_data[index][lru_way_d]; //Write data to the third level of cache
            end
            if(write_back_cache_coherence_2_flag) begin
                L2_dirty_bits[index][lru_way_d] = 1'b0; //Clear dirty bit
            end
            if(write_back_1_flag) begin 
                //Write back least recently used L2 cache block to L3 cache block 
				cache_L3d_memory_address = array_of_cache_L2d_memory_addresses[index][lru_way_d]; //Assigns old dirty address to L3 cache
				write_back_to_L3d_data = L2_data[index][lru_way_d]; //Write data to the third level of cache
            end
            if(write_back_2_flag) begin
                L2_dirty_bits[index][lru_way_d] = 1'b0; //Clear dirty bit
            end
        end
    end

	always_comb begin
		//Reset values for the next evaluation of states
        cache_L3d_memory_address_flag = 1'b0;
        write_back_to_L3_request_from_L2d = 1'b0;
        read_from_L3_request_from_L2d = 1'b0;
        processor_id = 1'b0;
        tag = 1'b0;
        index = 1'b0;
        offset = 1'b0;
        check_if_cache_hit_flag = 1'b0;
        update_lru_flag = 1'b0;
        update_cache_L2d_memory_addresses_for_cache_hit_flag = 1'b0;
        find_lru_way_d_and_mesi_prep_flag = 1'b0;
        mesi_read_prep_flag = 1'b0;
        allocate_flag = 1'b0;
        write_back_cache_coherence_1_flag = 1'b0;
        write_back_cache_coherence_2_flag = 1'b0;
        write_back_1_flag = 1'b0;
        write_back_2_flag = 1'b0;
		L2d_cache_ready = 1'b0;
		L2d_cache_hit = 1'b0;
		L2d_cache_read_hit = 1'b0;
		L2d_cache_write_hit = 1'b0;
		L2d_cache_miss = 1'b0;
        word_start_flag = 1'b0;
		write_back_to_L2d_verified = 1'b0;
		write_back_modified_block_for_cache_coherence = 1'b0;
		check_L2d_allocate_once_to_set_ff_flag = 1'b0;
		check_L2d_allocate_once_to_reset_ff_flag = 1'b0;
		next_state = state_t'(1'b0);
		//Extract the top two bits as the processor ID
		processor_id = cache_L2d_memory_address[31:30]; 
		//Bit-slicing to extract the appropriate number of bits for each segment of the cache address
		tag = cache_L2d_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
		index = cache_L2d_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		offset = cache_L2d_memory_address[OFFSET_START -: BLOCK_OFFSET_WIDTH]; //Get offset from requested address
		//Basic Cache States 
		case (current_state)
			IDLE: begin
				if((processor_id == 3) && (write_back_to_L2d_request || read_from_L2d_request || write_to_L2d_request)) begin
					first_read_flag = 1'b0;
					block_d_to_determine_mesi_state_from_arbiter_flag = 1'b0;
					cache_fsm_L2d_block_to_arbiter_flag = 1'b0;
					arbiter_write_update_from_L2d_cache_modules = 1'b0;
					mesi_read_prep_flag = 1'b0;
					mesi_write_prep_flag = 1'b0;
					set_arbiter_read_update_from_L2d_cache_modules_flag = 1'b0;
					reset_arbiter_read_update_from_L2d_cache_modules_flag = 1'b0;
        			update_mesi_state_flag = 1'b0;
					once_update_mesi_state_flag = 1'b0;
					reset_after_invalid_flag = 1'b0;
					reset_after_shared_flag = 1'b0;
					reset_after_exclusive_flag = 1'b0;
					reset_after_modified_flag = 1'b0;
					reset_reading_flag = 1'b0;
					reenter_compare_state = 1'b0;
					write_to_L2d_verified = 1'b0;
					acknowledge_arbiter_verify_d = 1'b0;
					set_acknowledge_arbiter_verify_d_flag = 1'b0;
					reset_acknowledge_arbiter_verify_d_flag = 1'b0;
					L2d_ready = 1'b0;
					cache_L3d_memory_address_to_array_L3d_to_arbiter_flag = 1'b0;
					arbiter_read_update_from_L2d_cache_modules = 1'b0;
					release_L2d_compare = 1'b0;
					if(set_reading_flag) begin 
						reset_reading_flag = 1'b1;
						internal_set_reading_flag = 0;
						stop_reading_flag = 0;
					end
					next_state = COMPARE; 
				end else begin
					acknowledge_arbiter_verify_d = 1'b0;
					next_state = IDLE;
				end			  
			end
			COMPARE: begin 
				if(reenter_compare_state) begin
					next_state = IDLE;
				end else begin
					check_if_cache_hit_flag = 1'b1;
					if(cache_hit_flag) begin
						//Cache hit
						L2d_cache_hit = 1'b1;
						word_start_flag = 1'b1;
						update_lru_flag = 1'b1; // Signal that LRU should be updated					
						update_cache_L2d_memory_addresses_for_cache_hit_flag = 1'b1;
						//Write back request from L1 
						if(write_back_to_L2d_request) begin
							find_lru_way_d_and_mesi_prep_flag = 1'b1;
							cache_fsm_L2d_block_to_arbiter_flag = 1'b1;
							arbiter_write_update_from_L2d_cache_modules = 1'b1; //update bus
							if(arbiter_verify_d) begin
								acknowledge_arbiter_verify_d = 1'b1;
								arbiter_write_update_from_L2d_cache_modules = 1'b0;
								write_back_to_L2d_verified = 1'b1;
								//Mark Cache ready 
								L2d_cache_ready = 1'b1;
								next_state = IDLE;
							end else begin
								next_state = COMPARE;
							end
						end else if(read_from_L2d_request && !stop_reading_flag) begin
							//Read hit 
							L2d_cache_read_hit = 1'b1;
							if(!first_read_flag) begin
								first_read_flag = 1'b1;
								block_d_to_determine_mesi_state_from_arbiter_flag = 1'b1;
								cache_fsm_L2d_block_to_arbiter_flag = 1'b1;
								mesi_read_prep_flag = 1'b1;
								set_arbiter_read_update_from_L2d_cache_modules_flag = 1'b1;
							end
							if(arbiter_read_update_from_L2d_cache_modules_flag) begin
								reset_arbiter_read_update_from_L2d_cache_modules_flag = 1'b1;
								arbiter_read_update_from_L2d_cache_modules = 1'b1;
							end
							if(arbiter_verify_d) begin
								if(!once_update_mesi_state_flag) begin 
									once_update_mesi_state_flag = 1'b1;
									update_mesi_state_flag = 1'b1;
									arbiter_read_update_from_L2d_cache_modules = 1'b0;
									block_d_to_determine_mesi_state_from_arbiter_flag = 1'b0;
									cache_fsm_L2d_block_to_arbiter_flag = 1'b0;
									mesi_read_prep_flag = 1'b0;
									set_arbiter_read_update_from_L2d_cache_modules_flag = 1'b0;
								end 
								if(reset_update_mesi_state_flag) begin
									update_mesi_state_flag = 1'b0;
								end
								if(after_invalid_flag) begin
									once_update_mesi_state_flag = 1'b0;
									update_mesi_state_flag = 1'b0;
									reset_after_invalid_flag = 1'b1;
									acknowledge_arbiter_verify_d = 1'b1;
									reset_arbiter_read_update_from_L2d_cache_modules_flag = 1'b0;
									first_read_flag = 1'b0;
									stop_reading_flag = 1;
									internal_set_reading_flag = 1;
									next_state = ALLOCATE;
								end else if(after_shared_flag) begin
									L2d_ready = 1'b1; 
									//Mark Cache ready 
									L2d_cache_ready = 1'b1;
									once_update_mesi_state_flag = 1'b0;
									update_mesi_state_flag = 1'b0;
									reset_after_shared_flag = 1'b1;
									acknowledge_arbiter_verify_d = 1'b1;
									reset_arbiter_read_update_from_L2d_cache_modules_flag = 1'b0;
									first_read_flag = 1'b0;
									stop_reading_flag = 1;
									internal_set_reading_flag = 1;
									next_state = IDLE;
								end else if(after_exclusive_flag) begin
									L2d_ready = 1'b1; 
									//Mark Cache ready 
									L2d_cache_ready = 1'b1;
									once_update_mesi_state_flag = 1'b0;
									update_mesi_state_flag = 1'b0;
									reset_after_exclusive_flag = 1'b1;
									acknowledge_arbiter_verify_d = 1'b1;
									reset_arbiter_read_update_from_L2d_cache_modules_flag = 1'b0;
									first_read_flag = 1'b0;
									stop_reading_flag = 1;
									internal_set_reading_flag = 1;
									reenter_compare_state = 1'b1;
									next_state = IDLE;
								end else if(after_modified_flag) begin
									write_back_modified_block_for_cache_coherence = 1'b1; //because writeback for four way associative is handled with lru logic, I needed a signal to differentiate between writing back lru versus modified block for cache coherence								
									once_update_mesi_state_flag = 1'b0;
									update_mesi_state_flag = 1'b0;
									reset_after_modified_flag = 1'b1;
									acknowledge_arbiter_verify_d = 1'b1;
									reset_arbiter_read_update_from_L2d_cache_modules_flag = 1'b0;
									first_read_flag = 1'b0;
									stop_reading_flag = 1;
									internal_set_reading_flag = 1;
									next_state = WRITE_BACK;
								end
							end else begin
								next_state = COMPARE;
							end
						end else if(write_to_L2d_request) begin
							//Write hit 4
							if(!once_update_mesi_state_flag) begin 
								once_update_mesi_state_flag = 1'b1;
								L2d_cache_write_hit = 1'b1;
								mesi_write_prep_flag = 1'b1;
								block_d_to_determine_mesi_state_from_arbiter_flag = 1'b1;
								cache_fsm_L2d_block_to_arbiter_flag = 1'b1;
								arbiter_write_update_from_L2d_cache_modules = 1'b1; 
							end 
							if(arbiter_verify_d) begin
								arbiter_write_update_from_L2d_cache_modules = 1'b0;
								write_to_L2d_verified = 1'b1;
								set_acknowledge_arbiter_verify_d_flag = 1'b1;
								//Mark Cache ready 
								L2d_cache_ready = 1'b1;
								if(acknowledge_arbiter_verify_d_flag) begin 
									acknowledge_arbiter_verify_d = 1'b1;
									reset_acknowledge_arbiter_verify_d_flag = 1'b1;
									next_state = IDLE;
								end else begin
									next_state = COMPARE;
								end
							end else if(!arbiter_verify_d && !release_L2d_compare) begin
								next_state = COMPARE;
							end else if(!arbiter_verify_d && release_L2d_compare) begin
								next_state = IDLE;
							end
						end else begin 
							//Mark Cache ready 
							L2d_cache_ready = 1'b1;
							next_state = IDLE;
						end 
					end else begin
						// Cache miss
						L2d_cache_miss = 1'b1;
						if(dirty_flag) begin 
							// If block is dirty initiate write back
							next_state = WRITE_BACK;
						end else if(clean_flag) begin
							//Block is clean
							next_state = ALLOCATE;
						end
					end
				end 
			end
			ALLOCATE: begin
				//Instead of continuously replacing blocks in L2, search L3 to see if the requested address is found there 
				if(!check_L2d_allocate_once_to_comb_flag) begin
					check_L2d_allocate_once_to_set_ff_flag = 1'b1;
					cache_L3d_memory_address_flag = 1'b1;
					read_from_L3_request_from_L2d = 1'b1; //Initiate a read request
					cache_L3d_memory_address_to_array_L3d_to_arbiter_flag = 1'b1;
					next_state = ALLOCATE;
				end else begin
					if(arbiter_confirmed_L3_ready_for_L2d) begin
						check_L2d_allocate_once_to_reset_ff_flag = 1'b1;
						cache_L3d_memory_address_to_array_L3d_to_arbiter_flag = 1'b0;
						allocate_flag = 1'b1;
						//Reset read request flag
						read_from_L3_request_from_L2d = 1'b0;
						next_state = COMPARE;
					end else begin
						next_state = ALLOCATE;
					end
				end
			end
			WRITE_BACK: begin
				//Write back the current block to L3 cache block as it has been marked as modified by the arbiter
				if(write_back_modified_block_for_cache_coherence) begin 
                    write_back_modified_block_for_cache_coherence = 1'b0;
				    cache_L3d_memory_address_flag = 1'b1;
					cache_L3d_memory_address_to_array_L3d_to_arbiter_flag = 1'b1;
					write_back_cache_coherence_1_flag = 1'b1;
			        write_back_to_L3_request_from_L2d = 1'b1;
                    if(write_back_to_L3_from_arbiter_d_verified) begin
                        write_back_cache_coherence_2_flag = 1'b1;
						write_back_to_L3_request_from_L2d = 1'b0;
				        next_state = COMPARE;
                    end else begin
				        next_state = WRITE_BACK; //keep in state until data from L2 is verified to be sent to L3
			        end 
                end else begin
                    write_back_1_flag = 1'b1;
                    write_back_to_L3_request_from_L2d = 1'b1; 
                    if(write_back_to_L3_from_arbiter_d_verified) begin
                        write_back_2_flag = 1'b1;
                        write_back_to_L3_request_from_L2d = 1'b0;
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