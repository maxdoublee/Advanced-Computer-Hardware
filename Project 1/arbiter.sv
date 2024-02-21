//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//arbiter implementation

import cache_config::*;
import main_memory_config::*;

module arbiter #(
  parameter CACHE_LEVEL = 2
)(
    input logic clk,
    input logic reset,
    input logic [ADDRESS_WIDTH-1:0] block_to_determine_mesi_state_from_arbiter,
    input logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2a_local_data,
    input logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2b_local_data,
    input logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2c_local_data,
    input logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2d_local_data,
    input logic arbiter_read_update_from_L2_cache_modules,
    input logic arbiter_write_update_from_L2_cache_modules,
    input logic acknowledge_arbiter_verify,

    output logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache,
    output logic arbiter_verify
);

    typedef enum logic [1:0] {
        MESI_INVALID,
        MESI_SHARED,
        MESI_EXCLUSIVE,
        MESI_MODIFIED
    } mesi_state_t;

    // Internal state for tracking MESI states across all caches
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] local_L2a_data_storage[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0];
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] local_L2b_data_storage[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0];
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] local_L2c_data_storage[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0];
    logic [MAIN_MEMORY_DATA_WIDTH-1:0] local_L2d_data_storage[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0];
    logic [MESI_STATE_WIDTH-1:0] arbiter_MESI_states[NUM_SETS-1:0][NUM_BLOCKS_PER_SET-1:0];

    logic [TAG_WIDTH-1:0] tag;
	 logic [INDEX_WIDTH-1:0] index;
    logic first_arbiter_interaction;
    logic dataMismatch;

    // always_ff @(posedge clk or posedge reset) begin
    //     if (reset) begin
	// 		// Reset MESI states to Invalid (I) in the beginning
    //         for (int set = 0; set < NUM_SETS; set++) begin
    //             for (int block = 0; block < NUM_BLOCKS_PER_SET; block++) begin
    //                 arbiter_MESI_states[set][block] <= MESI_INVALID; // Initialize MESI states to Invalid
    //             end
    //         end
    //     end 
    // end

    always_comb begin
        mesi_state_to_cache = 1'b0;
        arbiter_verify = 1'b0;
        tag = 1'b0;
		index = 1'b0;
        first_arbiter_interaction = 1'b0;
        for (int set = 0; set < NUM_SETS; set++) begin
			for (int block = 0; block < NUM_BLOCKS_PER_SET; block++) begin
				local_L2a_data_storage[set][block] <= 1'b0; // Initialize valid bits to 0
			end
		end
        for (int set = 0; set < NUM_SETS; set++) begin
			for (int block = 0; block < NUM_BLOCKS_PER_SET; block++) begin
				local_L2b_data_storage[set][block] <= 1'b0; // Initialize valid bits to 0
			end
		end
        for (int set = 0; set < NUM_SETS; set++) begin
			for (int block = 0; block < NUM_BLOCKS_PER_SET; block++) begin
				local_L2c_data_storage[set][block] <= 1'b0; // Initialize valid bits to 0
			end
		end
        for (int set = 0; set < NUM_SETS; set++) begin
			for (int block = 0; block < NUM_BLOCKS_PER_SET; block++) begin
				local_L2d_data_storage[set][block] <= 1'b0; // Initialize valid bits to 0
			end
		end
        for (int set = 0; set < NUM_SETS; set++) begin
			for (int block = 0; block < NUM_BLOCKS_PER_SET; block++) begin
				arbiter_MESI_states[set][block] <= 1'b0; // Initialize valid bits to 0
			end
		end
        tag = block_to_determine_mesi_state_from_arbiter[ADDRESS_WIDTH-3 -: TAG_WIDTH];
        index = block_to_determine_mesi_state_from_arbiter[INDEX_START -: INDEX_WIDTH];
        local_L2a_data_storage[index][tag] = L2a_local_data;
        local_L2b_data_storage[index][tag] = L2b_local_data;
        local_L2c_data_storage[index][tag] = L2c_local_data;
        local_L2d_data_storage[index][tag] = L2d_local_data;

        dataMismatch = 1'b0; //assume data is consistent throughout L2 caches 

        // Compare the data across all L2 caches for the given index and tag
        dataMismatch = ((local_L2a_data_storage[index][tag] != local_L2b_data_storage[index][tag]) && (|local_L2a_data_storage[index][tag] && |local_L2b_data_storage[index][tag])) || 
        ((local_L2a_data_storage[index][tag] != local_L2c_data_storage[index][tag]) && (|local_L2a_data_storage[index][tag] && |local_L2c_data_storage[index][tag])) ||
        ((local_L2a_data_storage[index][tag] != local_L2d_data_storage[index][tag]) && (|local_L2a_data_storage[index][tag] && |local_L2d_data_storage[index][tag])) ||
        ((local_L2b_data_storage[index][tag] != local_L2c_data_storage[index][tag]) && (|local_L2b_data_storage[index][tag] && |local_L2c_data_storage[index][tag])) ||
        ((local_L2b_data_storage[index][tag] != local_L2d_data_storage[index][tag]) && (|local_L2b_data_storage[index][tag] && |local_L2d_data_storage[index][tag])) ||
        ((local_L2c_data_storage[index][tag] != local_L2d_data_storage[index][tag]) && (|local_L2c_data_storage[index][tag] && |local_L2d_data_storage[index][tag]));

        // Read mesi states from arbiter 
        if (arbiter_read_update_from_L2_cache_modules && !first_arbiter_interaction) begin
            //When mesi state is found, set its mesi state into local cache to evaluate the block properly
            if (arbiter_MESI_states[index][tag] == MESI_INVALID) begin
                arbiter_MESI_states[index][tag] = MESI_EXCLUSIVE;
                mesi_state_to_cache = MESI_EXCLUSIVE;
                arbiter_verify = 1'b1;
            end else if (arbiter_MESI_states[index][tag] == MESI_EXCLUSIVE) begin
                if (dataMismatch) begin
                    arbiter_MESI_states[index][tag] = MESI_MODIFIED;
                    mesi_state_to_cache = MESI_MODIFIED;
                end else begin
                    arbiter_MESI_states[index][tag] = MESI_SHARED;
                    mesi_state_to_cache = MESI_SHARED;
                end
                arbiter_verify = 1'b1;
            end else if (arbiter_MESI_states[index][tag] == MESI_SHARED) begin 
                mesi_state_to_cache = MESI_SHARED;
                arbiter_verify = 1'b1;
            end else if (arbiter_MESI_states[index][tag] == MESI_MODIFIED) begin 
                arbiter_MESI_states[index][tag] = MESI_INVALID;
                mesi_state_to_cache = MESI_INVALID;
                arbiter_verify = 1'b1;
            end
            first_arbiter_interaction = 1'b1;
        end else if (arbiter_write_update_from_L2_cache_modules && !first_arbiter_interaction) begin
            // New data has been written locally to data array so let the arbiter know about that change 
            arbiter_MESI_states[index][tag] = MESI_MODIFIED;
            mesi_state_to_cache = MESI_MODIFIED;
            arbiter_verify = 1'b1;
            first_arbiter_interaction = 1'b1;
        end

        if(acknowledge_arbiter_verify) begin //from L2
            first_arbiter_interaction = 1'b0;
            arbiter_verify = 1'b0;
        end

    end
endmodule