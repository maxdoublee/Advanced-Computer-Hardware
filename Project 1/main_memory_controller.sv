//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//main memory controller

import cache_config::*;
import main_memory_config::*;

module main_memory_controller (
    input logic clk,
    input logic reset,
    input logic main_memory_read_request,
    input logic main_memory_write_request,
    input logic [MAIN_MEMORY_ADDRESS_WIDTH-1:0] main_memory_address,
    input logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_write_data,
	
    output logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory_read_data,
    output logic main_memory_ready 
);

	logic [INDEX_WIDTH-1:0] index;

	//Internal main memory array
	logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory[MAIN_MEMORY_NUM_BLOCKS-1:0];

	//Temporary signals used for read and write operations (flags)
	logic main_memory_read_in_progress, main_memory_write_in_progress;
	logic reset_main_memory_ready;

	logic request_reset_main_memory;
	logic read_from_main_memory_flag;
	logic write_to_main_memory_flag;

	//Sequential logic for read/write in progress flags
	always_ff @(posedge clk or posedge reset) begin
		 if (reset) begin
			main_memory_ready = 1'b0; // Default assignment for main_memory_ready
			request_reset_main_memory = 1'b0;
			main_memory_read_in_progress = 1'b0;
			main_memory_write_in_progress = 1'b0;
			main_memory_read_data = {MAIN_MEMORY_DATA_WIDTH{1'b0}}; // Default assignment for main_memory_read_data
		 end else begin
			index = main_memory_address[INDEX_START -: INDEX_WIDTH]; //index starts in space place as it would for a non-id processor address despite shrinking the tag array 
			if (main_memory_read_request && !main_memory_read_in_progress) begin
				main_memory_read_in_progress = 1'b1;
			end else if (main_memory_read_in_progress) begin
				main_memory_read_in_progress = 1'b0;
			end
			if (main_memory_write_request && !main_memory_write_in_progress) begin
				main_memory_write_in_progress = 1'b1;
			end else if (main_memory_write_in_progress) begin
				main_memory_write_in_progress = 1'b0;
			end
			if(read_from_main_memory_flag) begin
				main_memory_read_data = main_memory[index];
				main_memory_ready = 1'b1;
				request_reset_main_memory = 1'b1;
			end
			if(write_to_main_memory_flag) begin
				main_memory[index] = main_memory_write_data;
				main_memory_ready = 1'b1;
				request_reset_main_memory = 1'b1;
			end
			if(reset_main_memory_ready) begin
				main_memory_ready = 1'b0;
				request_reset_main_memory = 1'b0;
			end
		end
	end

	//Combinational logic for handling read and write data
	always_comb begin
		read_from_main_memory_flag = 1'b0;
		write_to_main_memory_flag = 1'b0;
		reset_main_memory_ready = 1'b0;
		if (main_memory_read_in_progress) begin
			//Handle read data and indicate memory is ready
			read_from_main_memory_flag = 1'b1;
		end else if (main_memory_write_in_progress) begin
			//Handle write data and indicate memory is ready
			write_to_main_memory_flag = 1'b1;
		end
		if(request_reset_main_memory) begin
			reset_main_memory_ready = 1'b1;
		end
	end
endmodule