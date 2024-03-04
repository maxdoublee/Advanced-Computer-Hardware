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
  input logic [ADDRESS_WIDTH-1:0] cache_L3a_memory_address,
  input logic [ADDRESS_WIDTH-1:0] cache_L3b_memory_address,
  input logic [ADDRESS_WIDTH-1:0] cache_L3c_memory_address,
  input logic [ADDRESS_WIDTH-1:0] cache_L3d_memory_address,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data,
  input logic read_from_arbiter_request_from_L2a_to_L3,
  input logic read_from_arbiter_request_from_L2b_to_L3,
  input logic read_from_arbiter_request_from_L2c_to_L3,
  input logic read_from_arbiter_request_from_L2d_to_L3,
  input logic write_back_to_L3_request_from_L2a_arbiter,
  input logic write_back_to_L3_request_from_L2b_arbiter,
  input logic write_back_to_L3_request_from_L2c_arbiter,
  input logic write_back_to_L3_request_from_L2d_arbiter,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3a_data,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3b_data,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3c_data,
  input logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_back_to_L3d_data,
  input logic cache_L3a_memory_address_to_array_L3a_from_arbiter_flag,
  input logic cache_L3b_memory_address_to_array_L3b_from_arbiter_flag,
  input logic cache_L3c_memory_address_to_array_L3c_from_arbiter_flag,
  input logic cache_L3d_memory_address_to_array_L3d_from_arbiter_flag,

  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_write_data,
  output logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address,
  output logic main_memory_read_request,
  output logic main_memory_write_request,
  output logic L3a_ready,
  output logic L3b_ready,
  output logic L3c_ready,
  output logic L3d_ready,
  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2a_from_L3a,
  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2b_from_L3b,
  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2c_from_L3c,
  output logic [MAIN_MEMORY_DATA_WIDTH-1:0] write_data_to_L2d_from_L3d,
  output logic write_back_to_L3_from_L2a_verified,
  output logic write_back_to_L3_from_L2b_verified,
  output logic write_back_to_L3_from_L2c_verified,
  output logic write_back_to_L3_from_L2d_verified,
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

	//Internal state of the cache level 3, L3
	logic [ADDRESS_WIDTH-1:0] array_of_cache_L3a_memory_addresses[NUM_SETS-1:0]; // Array of cache level 3 addresses for each block within each set for writing lru addressed to lower level
	logic [ADDRESS_WIDTH-1:0] array_of_cache_L3b_memory_addresses[NUM_SETS-1:0]; // Array of cache level 3 addresses for each block within each set for writing lru addressed to lower level
	logic [ADDRESS_WIDTH-1:0] array_of_cache_L3c_memory_addresses[NUM_SETS-1:0]; // Array of cache level 3 addresses for each block within each set for writing lru addressed to lower level
	logic [ADDRESS_WIDTH-1:0] array_of_cache_L3d_memory_addresses[NUM_SETS-1:0]; // Array of cache level 3 addresses for each block within each set for writing lru addressed to lower level
	logic [1:0] L3_valid_bits[NUM_SETS-1:0]; //Array of valid bits, one for each cache line
	logic [1:0] L3_dirty_bits[NUM_SETS-1:0]; //Array of dirty bits, one for each cache line
	logic [TAG_WIDTH-1:0] L3_tags[NUM_SETS-1:0]; //Array of tags, one for each cache line
	logic [MAIN_MEMORY_DATA_WIDTH-1:0] L3_data[NUM_SETS-1:0]; //Array of data, one for each cache line

	logic [TAG_WIDTH-1:0] tag;
	logic [INDEX_WIDTH-1:0] index;
    logic check_if_cache_hit_flag;
    logic allocate_flag;
    logic write_back_1_flag;
    logic write_back_2_flag;
    logic dirty_flag;
    logic clean_flag;
    logic cache_array_container_flag;
    logic write_back_to_L3_from_L2a_flag;
    logic write_back_to_L3_from_L2b_flag;
    logic write_back_to_L3_from_L2c_flag;
    logic write_back_to_L3_from_L2d_flag;
    logic read_from_L3a_flag;
    logic read_from_L3b_flag;
    logic read_from_L3c_flag;
    logic read_from_L3d_flag;
	logic cache_hit_flag;
	logic main_memory_address_flag;
	logic check_L3_allocate_once_to_comb_flag;
	logic check_L3_allocate_once_to_set_ff_flag;
	logic check_L3_allocate_once_to_reset_ff_flag;

    always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
            // Set initial values
			main_memory_write_data = 1'b0; 
			dirty_flag = 1'b0;
			clean_flag = 1'b0;
			write_data_to_L2a_from_L3a = 1'b0;
			write_data_to_L2b_from_L3b = 1'b0;
			write_data_to_L2c_from_L3c = 1'b0;
			write_data_to_L2d_from_L3d = 1'b0;
			main_memory_address = 1'b0;
			check_L3_allocate_once_to_comb_flag = 1'b0;
			current_state <= IDLE;
            for (int set = 0; set < NUM_SETS; set++) begin
                array_of_cache_L3a_memory_addresses[set] <= 0; // Initialize addresses to 0
                array_of_cache_L3b_memory_addresses[set] <= 0; // Initialize addresses to 0
                array_of_cache_L3c_memory_addresses[set] <= 0; // Initialize addresses to 0
                array_of_cache_L3d_memory_addresses[set] <= 0; // Initialize addresses to 0
                L3_valid_bits[set] <= 0; // Initialize valid bits to 0
                L3_dirty_bits[set] <= 0; // Initialize dirty bits to 0
                L3_data[set]<= 0; // Initialize data to 0
                L3_tags[set] <= 0; // Initialize tags to 0
        	end
		end else begin
			current_state <= next_state;
            if(check_if_cache_hit_flag) begin 
                // Cache hit
				if(L3_tags[index] == tag && L3_valid_bits[index] == 1) begin //checks if line is marked valid and tags match in L1 cache
					cache_hit_flag = 1'b1;
				end else begin
					//Cache miss
					if (L3_dirty_bits[index] == 1'b1) begin
                        dirty_flag = 1'b1;
					end else begin
                        clean_flag = 1'b1;
					end
				end
            end
            if(cache_array_container_flag) begin
				if(cache_L3a_memory_address_to_array_L3a_from_arbiter_flag) begin 
					array_of_cache_L3a_memory_addresses[index] = cache_L3a_memory_address; //Keep track of old cache addresses
				end else if(cache_L3b_memory_address_to_array_L3b_from_arbiter_flag) begin
					array_of_cache_L3b_memory_addresses[index] = cache_L3b_memory_address; //Keep track of old cache addresses
				end else if(cache_L3c_memory_address_to_array_L3c_from_arbiter_flag) begin
                	array_of_cache_L3c_memory_addresses[index] = cache_L3c_memory_address; //Keep track of old cache addresses
				end else if(cache_L3d_memory_address_to_array_L3d_from_arbiter_flag) begin
                	array_of_cache_L3d_memory_addresses[index] = cache_L3d_memory_address; //Keep track of old cache addresses
				end
			end
            if(write_back_to_L3_from_L2a_flag) begin
                L3_data[index] = write_back_to_L3a_data;
			end else if(write_back_to_L3_from_L2b_flag) begin
                L3_data[index] = write_back_to_L3b_data;
			end else if(write_back_to_L3_from_L2c_flag) begin
                L3_data[index] = write_back_to_L3c_data;
			end else if(write_back_to_L3_from_L2d_flag) begin
                L3_data[index] = write_back_to_L3d_data;
            end
            if(read_from_L3a_flag) begin
                write_data_to_L2a_from_L3a = L3_data[index];
			end else if(read_from_L3b_flag) begin 
				write_data_to_L2b_from_L3b = L3_data[index];
			end else if(read_from_L3c_flag) begin 
				write_data_to_L2c_from_L3c = L3_data[index];
			end else if(read_from_L3d_flag) begin 
				write_data_to_L2d_from_L3d = L3_data[index];
			end
			if(check_L3_allocate_once_to_set_ff_flag) begin 
				check_L3_allocate_once_to_comb_flag = 1'b1;
			end
			if(check_L3_allocate_once_to_reset_ff_flag) begin 
				check_L3_allocate_once_to_comb_flag = 1'b0;
			end
			if(main_memory_address_flag) begin
				if(cache_L3a_memory_address_to_array_L3a_from_arbiter_flag) begin 
					main_memory_address = cache_L3a_memory_address;
				end else if(cache_L3b_memory_address_to_array_L3b_from_arbiter_flag) begin
					main_memory_address = cache_L3b_memory_address;
				end else if(cache_L3c_memory_address_to_array_L3c_from_arbiter_flag) begin
					main_memory_address = cache_L3c_memory_address;
				end else if(cache_L3d_memory_address_to_array_L3d_from_arbiter_flag) begin
					main_memory_address = cache_L3d_memory_address;
				end
            end
            if(allocate_flag) begin
                L3_tags[index] = tag; //Get tag from requested address and assign it to block 
                L3_valid_bits[index] = 1'b1; //When the line is first brought into cache set it as valid 
                L3_data[index] = main_memory_read_data; //Assign new memory data to the cache L2 block
            end
            if(write_back_1_flag) begin 
                //Keep track of old cache addresses
				if(cache_L3a_memory_address_to_array_L3a_from_arbiter_flag) begin 
					main_memory_address = array_of_cache_L3a_memory_addresses[index]; //Assigns old dirty address to main memory 
				end else if(cache_L3b_memory_address_to_array_L3b_from_arbiter_flag) begin
					main_memory_address = array_of_cache_L3b_memory_addresses[index]; //Assigns old dirty address to main memory 
				end else if(cache_L3c_memory_address_to_array_L3c_from_arbiter_flag) begin
					main_memory_address = array_of_cache_L3c_memory_addresses[index]; //Assigns old dirty address to main memory 
				end else if(cache_L3d_memory_address_to_array_L3d_from_arbiter_flag) begin
					main_memory_address = array_of_cache_L3d_memory_addresses[index]; //Assigns old dirty address to main memory 
				end
				main_memory_write_data = L3_data[index]; //Write data to main memory
            end
            if(write_back_2_flag) begin
                //Assigned old dirty data block to main memory
                L3_dirty_bits[index] = 1'b0; //Clear dirty bit
            end
		end
	end

	always_comb begin
		L3_cache_hit = 1'b0;
		L3_cache_miss = 1'b0;
		L3_cache_ready = 1'b0;
		main_memory_read_request = 1'b0;
        check_if_cache_hit_flag = 1'b0;
        allocate_flag = 1'b0;
        write_back_1_flag = 1'b0;
        write_back_2_flag = 1'b0;
		L3a_ready = 1'b0;
		L3b_ready = 1'b0;
		L3c_ready = 1'b0;
		L3d_ready = 1'b0;
		tag = 1'b0;
		index = 1'b0;
		main_memory_write_request = 1'b0;
		write_back_to_L3_from_L2a_verified = 1'b0;
		write_back_to_L3_from_L2b_verified = 1'b0;
		write_back_to_L3_from_L2c_verified = 1'b0;
		write_back_to_L3_from_L2d_verified = 1'b0;
        cache_array_container_flag = 1'b0;;
        write_back_to_L3_from_L2a_flag = 1'b0;
        write_back_to_L3_from_L2b_flag = 1'b0;
        write_back_to_L3_from_L2c_flag = 1'b0;
        write_back_to_L3_from_L2d_flag = 1'b0;
        read_from_L3a_flag = 1'b0;
        read_from_L3b_flag = 1'b0;
        read_from_L3c_flag = 1'b0;
        read_from_L3d_flag = 1'b0;
		main_memory_address_flag = 1'b0;
		check_L3_allocate_once_to_set_ff_flag = 1'b0;
		check_L3_allocate_once_to_reset_ff_flag = 1'b0;
		next_state = state_t'(1'b0);
		//Bit-slicing to extract the appropriate number of bits for each segment of the cache address
		if(cache_L3a_memory_address_to_array_L3a_from_arbiter_flag) begin 
			tag = cache_L3a_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
			index = cache_L3a_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		end else if(cache_L3b_memory_address_to_array_L3b_from_arbiter_flag) begin
			tag = cache_L3b_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
			index = cache_L3b_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		end else if(cache_L3c_memory_address_to_array_L3c_from_arbiter_flag) begin
			tag = cache_L3c_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
			index = cache_L3c_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		end else if(cache_L3d_memory_address_to_array_L3d_from_arbiter_flag) begin
			tag = cache_L3d_memory_address[ADDRESS_WIDTH-3 -: TAG_WIDTH]; //minus three for processor id implementation (also zero is included)
			index = cache_L3d_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
		end
		//Basic Cache States 
		case (current_state)
			IDLE: begin
				if(write_back_to_L3_request_from_L2a_arbiter || write_back_to_L3_request_from_L2b_arbiter || write_back_to_L3_request_from_L2c_arbiter || write_back_to_L3_request_from_L2d_arbiter || read_from_arbiter_request_from_L2a_to_L3 || read_from_arbiter_request_from_L2b_to_L3 || read_from_arbiter_request_from_L2c_to_L3 || read_from_arbiter_request_from_L2d_to_L3) begin
					next_state = COMPARE;
				end else begin
					next_state = IDLE;
				end			  
			end
			COMPARE: begin
				check_if_cache_hit_flag = 1'b1;
				if(cache_hit_flag) begin
					//Cache hit
					L3_cache_hit = 1'b1;
                    cache_array_container_flag = 1'b1;
					//Write back request from L2
					if(write_back_to_L3_request_from_L2a_arbiter) begin
                        write_back_to_L3_from_L2a_flag = 1'b1;
						write_back_to_L3_from_L2a_verified = 1'b1;
						//Mark Cache ready 
						L3_cache_ready = 1'b1;
						next_state = IDLE;
					end else if(write_back_to_L3_request_from_L2b_arbiter) begin
						write_back_to_L3_from_L2b_flag = 1'b1;
						write_back_to_L3_from_L2b_verified = 1'b1;
						//Mark Cache ready 
						L3_cache_ready = 1'b1;
						next_state = IDLE;
					end else if(write_back_to_L3_request_from_L2c_arbiter) begin
						write_back_to_L3_from_L2c_flag = 1'b1;
						write_back_to_L3_from_L2c_verified = 1'b1;
						//Mark Cache ready 
						L3_cache_ready = 1'b1;
						next_state = IDLE;
					end else if(write_back_to_L3_request_from_L2d_arbiter) begin
						write_back_to_L3_from_L2d_flag = 1'b1;
						write_back_to_L3_from_L2d_verified = 1'b1;
						//Mark Cache ready 
						L3_cache_ready = 1'b1;
						next_state = IDLE;
					end else begin 
						if(read_from_arbiter_request_from_L2a_to_L3) begin
							read_from_L3a_flag = 1'b1;
							L3a_ready = 1'b1;
							//Mark Cache ready 
							L3_cache_ready = 1'b1;
							next_state = IDLE;
						end else if(read_from_arbiter_request_from_L2b_to_L3) begin 
							read_from_L3b_flag = 1'b1;
							L3b_ready = 1'b1; 
							//Mark Cache ready 
							L3_cache_ready = 1'b1;
							next_state = IDLE;
						end else if(read_from_arbiter_request_from_L2c_to_L3) begin 
							read_from_L3c_flag = 1'b1;
							L3c_ready = 1'b1; 
							//Mark Cache ready 
							L3_cache_ready = 1'b1;
							next_state = IDLE;
						end else if(read_from_arbiter_request_from_L2d_to_L3) begin 
							read_from_L3d_flag = 1'b1;
							L3d_ready = 1'b1; 
							//Mark Cache ready 
							L3_cache_ready = 1'b1;
							next_state = IDLE;
						end else begin 
							//Mark Cache ready 
							L3_cache_ready = 1'b1;
							next_state = IDLE;
						end
					end
				end else begin
					// Cache miss
					L3_cache_miss = 1'b1;
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
				if(!check_L3_allocate_once_to_comb_flag) begin
					check_L3_allocate_once_to_set_ff_flag = 1'b1;
					main_memory_address_flag = 1'b1;
					main_memory_read_request = 1'b1; //Initiate a read request to main memory
					next_state = ALLOCATE;
				end else begin
					if(main_memory_ready) begin
						check_L3_allocate_once_to_reset_ff_flag = 1'b1;
						allocate_flag = 1'b1;
						//Reset read request flag
						main_memory_read_request = 1'b0;
						next_state = COMPARE;
					end else begin
						next_state = ALLOCATE;
					end
				end
			end
			WRITE_BACK: begin
                write_back_1_flag = 1'b1;
				main_memory_write_request = 1'b1; //Initiate a rewrite request to main memory
				if(main_memory_ready) begin
                    write_back_2_flag = 1'b1;
					//Reset write request flag
					main_memory_write_request = 1'b0;
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