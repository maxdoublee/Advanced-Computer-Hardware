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
    input logic [ADDRESS_WIDTH-1:0] block_a_to_determine_mesi_state_from_arbiter,
    input logic [ADDRESS_WIDTH-1:0] block_b_to_determine_mesi_state_from_arbiter,
    input logic [ADDRESS_WIDTH-1:0] block_c_to_determine_mesi_state_from_arbiter,
    input logic [ADDRESS_WIDTH-1:0] block_d_to_determine_mesi_state_from_arbiter,
    input logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2a_local_data,
    input logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2b_local_data,
    input logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2c_local_data,
    input logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2d_local_data,
    input logic arbiter_read_update_from_L2a_cache_modules,
    input logic arbiter_read_update_from_L2b_cache_modules,
    input logic arbiter_read_update_from_L2c_cache_modules,
    input logic arbiter_read_update_from_L2d_cache_modules,
    input logic arbiter_write_update_from_L2a_cache_modules,
    input logic arbiter_write_update_from_L2b_cache_modules,
    input logic arbiter_write_update_from_L2c_cache_modules,
    input logic arbiter_write_update_from_L2d_cache_modules,
    input logic acknowledge_arbiter_verify_a,
    input logic acknowledge_arbiter_verify_b,
    input logic acknowledge_arbiter_verify_c,
    input logic acknowledge_arbiter_verify_d,
    input logic cache_fsm_L2a_block_to_arbiter,
    input logic cache_fsm_L2b_block_to_arbiter,
    input logic cache_fsm_L2c_block_to_arbiter,
    input logic cache_fsm_L2d_block_to_arbiter,
    input logic read_from_L3_request_from_L2a,
    input logic read_from_L3_request_from_L2b,
    input logic read_from_L3_request_from_L2c,
    input logic read_from_L3_request_from_L2d,
    input logic L3a_ready,
    input logic L3b_ready,
    input logic L3c_ready,
    input logic L3d_ready,
    input logic write_back_to_L3_from_L2a_verified,
    input logic write_back_to_L3_from_L2b_verified,
    input logic write_back_to_L3_from_L2c_verified,
    input logic write_back_to_L3_from_L2d_verified,
    input logic cache_L3a_memory_address_to_array_L3a_to_arbiter_flag,
    input logic cache_L3b_memory_address_to_array_L3b_to_arbiter_flag,
    input logic cache_L3c_memory_address_to_array_L3c_to_arbiter_flag,
    input logic cache_L3d_memory_address_to_array_L3d_to_arbiter_flag,
    input logic write_back_to_L3_request_from_L2a,
    input logic write_back_to_L3_request_from_L2b,
    input logic write_back_to_L3_request_from_L2c,
    input logic write_back_to_L3_request_from_L2d,

    output logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache_a,
    output logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache_b,
    output logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache_c,
    output logic [MESI_STATE_WIDTH-1:0] mesi_state_to_cache_d,
    output logic arbiter_verify_a,
    output logic arbiter_verify_b,
    output logic arbiter_verify_c,
    output logic arbiter_verify_d,
    output logic cache_fsm_L2a_block_to_arbiter_verified,
    output logic cache_fsm_L2b_block_to_arbiter_verified,
    output logic cache_fsm_L2c_block_to_arbiter_verified,
    output logic cache_fsm_L2d_block_to_arbiter_verified,
    output logic write_back_to_L3_request_from_L2a_arbiter,
    output logic write_back_to_L3_request_from_L2b_arbiter,
    output logic write_back_to_L3_request_from_L2c_arbiter,
    output logic write_back_to_L3_request_from_L2d_arbiter,
    output logic read_from_arbiter_request_from_L2a_to_L3,
    output logic read_from_arbiter_request_from_L2b_to_L3,
    output logic read_from_arbiter_request_from_L2c_to_L3,
    output logic read_from_arbiter_request_from_L2d_to_L3,
    output logic arbiter_confirmed_L3_ready_for_L2a,
    output logic arbiter_confirmed_L3_ready_for_L2b,
    output logic arbiter_confirmed_L3_ready_for_L2c,
    output logic arbiter_confirmed_L3_ready_for_L2d,
    output logic write_back_to_L3_from_arbiter_a_verified,
    output logic write_back_to_L3_from_arbiter_b_verified,
    output logic write_back_to_L3_from_arbiter_c_verified,
    output logic write_back_to_L3_from_arbiter_d_verified,
    output logic cache_L3a_memory_address_to_array_L3a_from_arbiter_flag,
    output logic cache_L3b_memory_address_to_array_L3b_from_arbiter_flag,
    output logic cache_L3c_memory_address_to_array_L3c_from_arbiter_flag,
    output logic cache_L3d_memory_address_to_array_L3d_from_arbiter_flag
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
    logic data_storage_flag;
    logic dataMismatch_flag;
    logic check_arbiter_MESI_state_flag;
    logic exclusive_state_now_flag;
    logic modified_state_now_flag;
    logic shared_state_now_flag;
    logic invalid_state_now_flag;
    logic update_arbiter_MESI_state_flag;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            //Initialize variables
            exclusive_state_now_flag = 1'b0;
            modified_state_now_flag = 1'b0;
            shared_state_now_flag = 1'b0;
            invalid_state_now_flag = 1'b0;
            dataMismatch = 1'b0; 

			// Reset MESI states to Invalid (I) in the beginning
            for (int set = 0; set < NUM_SETS; set++) begin
                for (int block = 0; block < NUM_BLOCKS_PER_SET; block++) begin
                    local_L2a_data_storage[set][block] <= 1'b0; // Initialize valid bits to 0
                    local_L2b_data_storage[set][block] <= 1'b0; // Initialize valid bits to 0
				    local_L2c_data_storage[set][block] <= 1'b0; // Initialize valid bits to 0
				    local_L2d_data_storage[set][block] <= 1'b0; // Initialize valid bits to 0
                    arbiter_MESI_states[set][block] <= MESI_INVALID; // Initialize MESI states to Invalid
                end
            end
        end else begin
            if(data_storage_flag) begin
                local_L2a_data_storage[index][tag] = L2a_local_data;
                local_L2b_data_storage[index][tag] = L2b_local_data;
                local_L2c_data_storage[index][tag] = L2c_local_data;
                local_L2d_data_storage[index][tag] = L2d_local_data;
            end
            if(dataMismatch_flag) begin
                // Compare the data across all L2 caches for the given index and tag
                dataMismatch = ((local_L2a_data_storage[index][tag] != local_L2b_data_storage[index][tag]) && (|local_L2a_data_storage[index][tag] && |local_L2b_data_storage[index][tag])) || 
                ((local_L2a_data_storage[index][tag] != local_L2c_data_storage[index][tag]) && (|local_L2a_data_storage[index][tag] && |local_L2c_data_storage[index][tag])) ||
                ((local_L2a_data_storage[index][tag] != local_L2d_data_storage[index][tag]) && (|local_L2a_data_storage[index][tag] && |local_L2d_data_storage[index][tag])) ||
                ((local_L2b_data_storage[index][tag] != local_L2c_data_storage[index][tag]) && (|local_L2b_data_storage[index][tag] && |local_L2c_data_storage[index][tag])) ||
                ((local_L2b_data_storage[index][tag] != local_L2d_data_storage[index][tag]) && (|local_L2b_data_storage[index][tag] && |local_L2d_data_storage[index][tag])) ||
                ((local_L2c_data_storage[index][tag] != local_L2d_data_storage[index][tag]) && (|local_L2c_data_storage[index][tag] && |local_L2d_data_storage[index][tag]));
            end
            if(check_arbiter_MESI_state_flag) begin
                if (arbiter_MESI_states[index][tag] == MESI_INVALID) begin
                    arbiter_MESI_states[index][tag] = MESI_EXCLUSIVE;
                    exclusive_state_now_flag = 1'b1;
                end else if (arbiter_MESI_states[index][tag] == MESI_EXCLUSIVE) begin
                    if (dataMismatch) begin
                        arbiter_MESI_states[index][tag] = MESI_MODIFIED;
                        modified_state_now_flag = 1'b1;
                    end else begin
                        arbiter_MESI_states[index][tag] = MESI_SHARED;
                        shared_state_now_flag = 1'b1;
                    end
                end else if (arbiter_MESI_states[index][tag] == MESI_SHARED) begin 
                    shared_state_now_flag = 1'b1;
                end else if (arbiter_MESI_states[index][tag] == MESI_MODIFIED) begin 
                    arbiter_MESI_states[index][tag] = MESI_INVALID;
                    invalid_state_now_flag = 1'b1;
                end
            end
            if(update_arbiter_MESI_state_flag) begin
                // New data has been written locally to data array so let the arbiter know about that change 
                arbiter_MESI_states[index][tag] = MESI_MODIFIED;
            end
        end
    end

    always_comb begin
        cache_fsm_L2a_block_to_arbiter_verified = 1'b0;
        cache_fsm_L2b_block_to_arbiter_verified = 1'b0;
        cache_fsm_L2c_block_to_arbiter_verified = 1'b0;
        cache_fsm_L2d_block_to_arbiter_verified = 1'b0;
        mesi_state_to_cache_a = 1'b0;
        mesi_state_to_cache_b = 1'b0;
        mesi_state_to_cache_c = 1'b0;
        mesi_state_to_cache_d = 1'b0;
        arbiter_verify_a = 1'b0;
        arbiter_verify_b = 1'b0;
        arbiter_verify_c = 1'b0;
        arbiter_verify_d = 1'b0;
        tag = 1'b0;
        index = 1'b0;
        first_arbiter_interaction = 1'b0;
        data_storage_flag = 1'b0;
        dataMismatch_flag = 1'b0;
        check_arbiter_MESI_state_flag = 1'b0;
        update_arbiter_MESI_state_flag = 1'b0;
        write_back_to_L3_request_from_L2a_arbiter = 1'b0;
        write_back_to_L3_request_from_L2b_arbiter = 1'b0;
        write_back_to_L3_request_from_L2c_arbiter = 1'b0;
        write_back_to_L3_request_from_L2d_arbiter = 1'b0;
        // read_from_arbiter_request_from_L2a_to_L3 = 1'b0;
        read_from_arbiter_request_from_L2b_to_L3 = 1'b0;
        read_from_arbiter_request_from_L2c_to_L3 = 1'b0;
        read_from_arbiter_request_from_L2d_to_L3 = 1'b0;
        arbiter_confirmed_L3_ready_for_L2a = 1'b0;
        arbiter_confirmed_L3_ready_for_L2b = 1'b0;
        arbiter_confirmed_L3_ready_for_L2c = 1'b0;
        arbiter_confirmed_L3_ready_for_L2d = 1'b0;
        write_back_to_L3_from_arbiter_a_verified = 1'b0;
        write_back_to_L3_from_arbiter_b_verified = 1'b0;
        write_back_to_L3_from_arbiter_c_verified = 1'b0;
        write_back_to_L3_from_arbiter_d_verified = 1'b0;
        cache_L3a_memory_address_to_array_L3a_from_arbiter_flag = 1'b0;
        cache_L3b_memory_address_to_array_L3b_from_arbiter_flag = 1'b0;
        cache_L3c_memory_address_to_array_L3c_from_arbiter_flag = 1'b0;
        cache_L3d_memory_address_to_array_L3d_from_arbiter_flag = 1'b0;

        if(cache_fsm_L2a_block_to_arbiter) begin 
            tag = block_a_to_determine_mesi_state_from_arbiter[ADDRESS_WIDTH-3 -: TAG_WIDTH];
            index = block_a_to_determine_mesi_state_from_arbiter[INDEX_START -: INDEX_WIDTH];
            cache_fsm_L2a_block_to_arbiter_verified = 1'b1;
        end else if(cache_fsm_L2b_block_to_arbiter) begin 
            tag = block_b_to_determine_mesi_state_from_arbiter[ADDRESS_WIDTH-3 -: TAG_WIDTH];
            index = block_b_to_determine_mesi_state_from_arbiter[INDEX_START -: INDEX_WIDTH];
            cache_fsm_L2b_block_to_arbiter_verified = 1'b1;
        end else if(cache_fsm_L2c_block_to_arbiter) begin
            tag = block_c_to_determine_mesi_state_from_arbiter[ADDRESS_WIDTH-3 -: TAG_WIDTH];
            index = block_c_to_determine_mesi_state_from_arbiter[INDEX_START -: INDEX_WIDTH];
            cache_fsm_L2c_block_to_arbiter_verified = 1'b1;
        end else if(cache_fsm_L2d_block_to_arbiter) begin 
            tag = block_d_to_determine_mesi_state_from_arbiter[ADDRESS_WIDTH-3 -: TAG_WIDTH];
            index = block_d_to_determine_mesi_state_from_arbiter[INDEX_START -: INDEX_WIDTH];
            cache_fsm_L2d_block_to_arbiter_verified = 1'b1;
        end 
        
        data_storage_flag = 1'b1;

        dataMismatch_flag = 1'b1;

        // Read mesi states from arbiter 
        if (arbiter_read_update_from_L2a_cache_modules && !first_arbiter_interaction) begin
            //When mesi state is found, set its mesi state into local cache to evaluate the block properly
            check_arbiter_MESI_state_flag = 1'b1;
            if(exclusive_state_now_flag) begin 
                mesi_state_to_cache_a = MESI_EXCLUSIVE;
                arbiter_verify_a = 1'b1;
            end else if(modified_state_now_flag) begin 
                mesi_state_to_cache_a = MESI_MODIFIED;
                arbiter_verify_a = 1'b1;
            end else if(shared_state_now_flag) begin
                mesi_state_to_cache_a = MESI_SHARED;
                arbiter_verify_a = 1'b1;
            end else if(invalid_state_now_flag) begin
                mesi_state_to_cache_a = MESI_INVALID;
                arbiter_verify_a = 1'b1;
            end
            first_arbiter_interaction = 1'b1;
        end else if(arbiter_read_update_from_L2b_cache_modules && !first_arbiter_interaction) begin
            check_arbiter_MESI_state_flag = 1'b1;
            if(exclusive_state_now_flag) begin 
                mesi_state_to_cache_b = MESI_EXCLUSIVE;
                arbiter_verify_b = 1'b1;
            end else if(modified_state_now_flag) begin 
                mesi_state_to_cache_b = MESI_MODIFIED;
                arbiter_verify_b = 1'b1;
            end else if(shared_state_now_flag) begin
                mesi_state_to_cache_b = MESI_SHARED;
                arbiter_verify_b = 1'b1;
            end else if(invalid_state_now_flag) begin
                mesi_state_to_cache_b = MESI_INVALID;
                arbiter_verify_b = 1'b1;
            end
            first_arbiter_interaction = 1'b1;
        end else if(arbiter_read_update_from_L2c_cache_modules && !first_arbiter_interaction) begin
            check_arbiter_MESI_state_flag = 1'b1;
            if(exclusive_state_now_flag) begin 
                mesi_state_to_cache_c = MESI_EXCLUSIVE;
                arbiter_verify_c = 1'b1;
            end else if(modified_state_now_flag) begin 
                mesi_state_to_cache_c = MESI_MODIFIED;
                arbiter_verify_c = 1'b1;
            end else if(shared_state_now_flag) begin
                mesi_state_to_cache_c = MESI_SHARED;
                arbiter_verify_c = 1'b1;
            end else if(invalid_state_now_flag) begin
                mesi_state_to_cache_c = MESI_INVALID;
                arbiter_verify_c = 1'b1;
            end
            first_arbiter_interaction = 1'b1;
        end else if(arbiter_read_update_from_L2d_cache_modules && !first_arbiter_interaction) begin
            check_arbiter_MESI_state_flag = 1'b1;
            if(exclusive_state_now_flag) begin 
                mesi_state_to_cache_d = MESI_EXCLUSIVE;
                arbiter_verify_d = 1'b1;
            end else if(modified_state_now_flag) begin 
                mesi_state_to_cache_d = MESI_MODIFIED;
                arbiter_verify_d = 1'b1;
            end else if(shared_state_now_flag) begin
                mesi_state_to_cache_d = MESI_SHARED;
                arbiter_verify_d = 1'b1;
            end else if(invalid_state_now_flag) begin
                mesi_state_to_cache_d = MESI_INVALID;
                arbiter_verify_d = 1'b1;
            end
            first_arbiter_interaction = 1'b1;
        end else begin
            if(arbiter_write_update_from_L2a_cache_modules && !first_arbiter_interaction) begin
                update_arbiter_MESI_state_flag = 1'b1;
                mesi_state_to_cache_a = MESI_MODIFIED;
                arbiter_verify_a = 1'b1;
                first_arbiter_interaction = 1'b1;
            end else if(arbiter_write_update_from_L2b_cache_modules && !first_arbiter_interaction) begin
                update_arbiter_MESI_state_flag = 1'b1;
                mesi_state_to_cache_b = MESI_MODIFIED;
                arbiter_verify_b = 1'b1;
                first_arbiter_interaction = 1'b1;
            end else if(arbiter_write_update_from_L2c_cache_modules && !first_arbiter_interaction) begin
                update_arbiter_MESI_state_flag = 1'b1;
                mesi_state_to_cache_c = MESI_MODIFIED;
                arbiter_verify_c = 1'b1;
                first_arbiter_interaction = 1'b1;
            end else if(arbiter_write_update_from_L2d_cache_modules && !first_arbiter_interaction) begin
                update_arbiter_MESI_state_flag = 1'b1;
                mesi_state_to_cache_d = MESI_MODIFIED;
                arbiter_verify_d = 1'b1;
                first_arbiter_interaction = 1'b1;
            end 
        end

        //Acknowledgement from L2 caches in order to restart mesi state checking 
        if(acknowledge_arbiter_verify_a) begin //from L2a
            first_arbiter_interaction = 1'b0;
            arbiter_verify_a = 1'b0;
        end else if(acknowledge_arbiter_verify_b) begin //from L2b
            first_arbiter_interaction = 1'b0;
            arbiter_verify_b = 1'b0;
        end else if(acknowledge_arbiter_verify_c) begin //from L2c
            first_arbiter_interaction = 1'b0;
            arbiter_verify_c = 1'b0;
        end else if(acknowledge_arbiter_verify_d) begin //from L2d
            first_arbiter_interaction = 1'b0;
            arbiter_verify_d = 1'b0;
        end

        //Signals from L2 cache that are sent to L3 according to which L2 module sends the signal
        if(read_from_L3_request_from_L2a) begin 
            read_from_arbiter_request_from_L2a_to_L3 = 1'b1;
        end else if(read_from_L3_request_from_L2b) begin
            read_from_arbiter_request_from_L2b_to_L3 = 1'b1;
        end else if(read_from_L3_request_from_L2b) begin
            read_from_arbiter_request_from_L2c_to_L3 = 1'b1;
        end else if(read_from_L3_request_from_L2b) begin
            read_from_arbiter_request_from_L2d_to_L3 = 1'b1;
        end 

        if(write_back_to_L3_request_from_L2a) begin 
            write_back_to_L3_request_from_L2a_arbiter = 1'b1;
        end else if(write_back_to_L3_request_from_L2b) begin
            write_back_to_L3_request_from_L2b_arbiter = 1'b1;
        end else if(write_back_to_L3_request_from_L2c) begin
            write_back_to_L3_request_from_L2c_arbiter = 1'b1;
        end else if(write_back_to_L3_request_from_L2d) begin
            write_back_to_L3_request_from_L2d_arbiter = 1'b1;
        end

        //Signals from L3 cache that are sent to the L2 level to confirm the correct L2 module allocates from L3
        if(L3a_ready) begin
            $display("jcwya");
            arbiter_confirmed_L3_ready_for_L2a = 1'b1; 
            read_from_arbiter_request_from_L2a_to_L3 = 1'b0;
        end else if(L3b_ready) begin
            arbiter_confirmed_L3_ready_for_L2b = 1'b1; 
        end else if(L3c_ready) begin
            arbiter_confirmed_L3_ready_for_L2c = 1'b1; 
        end else if(L3d_ready) begin
            arbiter_confirmed_L3_ready_for_L2d = 1'b1; 
        end 

        if(write_back_to_L3_from_L2a_verified) begin
            write_back_to_L3_from_arbiter_a_verified = 1'b1; 
        end else if(write_back_to_L3_from_L2b_verified) begin
            write_back_to_L3_from_arbiter_b_verified = 1'b1; 
        end else if(write_back_to_L3_from_L2c_verified) begin
            write_back_to_L3_from_arbiter_c_verified = 1'b1; 
        end else if(write_back_to_L3_from_L2d_verified) begin
            write_back_to_L3_from_arbiter_d_verified = 1'b1; 
        end 

        //Setup so that L3 can get the correct address from the specific L2 module 
        if(cache_L3a_memory_address_to_array_L3a_to_arbiter_flag) begin 
            cache_L3a_memory_address_to_array_L3a_from_arbiter_flag = 1'b1;
        end else if(cache_L3b_memory_address_to_array_L3b_to_arbiter_flag) begin
            cache_L3b_memory_address_to_array_L3b_from_arbiter_flag = 1'b1;
        end else if(cache_L3c_memory_address_to_array_L3c_to_arbiter_flag) begin
            cache_L3c_memory_address_to_array_L3c_from_arbiter_flag = 1'b1;
        end else if(cache_L3d_memory_address_to_array_L3d_to_arbiter_flag) begin
            cache_L3d_memory_address_to_array_L3d_from_arbiter_flag = 1'b1;
        end
    end
endmodule