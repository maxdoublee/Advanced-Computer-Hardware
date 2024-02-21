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

	//Internal main memory array
	logic [MAIN_MEMORY_DATA_WIDTH-1:0] main_memory[MAIN_MEMORY_NUM_BLOCKS-1:0];

	//Temporary signals used for read and write operations (flags)
	logic main_memory_read_in_progress, main_memory_write_in_progress;

	//Sequential logic for read/write in progress flags
	always_ff @(posedge clk or posedge reset) begin
		 if (reset) begin
			  main_memory_read_in_progress <= 1'b0;
			  main_memory_write_in_progress <= 1'b0;
		 end else begin
			  if (main_memory_read_request && !main_memory_read_in_progress) begin
					main_memory_read_in_progress <= 1'b1;
			  end else if (main_memory_read_in_progress) begin
					main_memory_read_in_progress <= 1'b0;
			  end
			  if (main_memory_write_request && !main_memory_write_in_progress) begin
					main_memory_write_in_progress <= 1'b1;
			  end else if (main_memory_write_in_progress) begin
					main_memory_write_in_progress <= 1'b0;
			  end
		 end
	end

	//Combinational logic for handling read and write data
	always_comb begin
		 main_memory_ready = 1'b0; // Default assignment for main_memory_ready
		 main_memory_read_data = {MAIN_MEMORY_DATA_WIDTH{1'b0}}; // Default assignment for main_memory_read_data
		 if (main_memory_read_in_progress) begin
			  //Handle read data and indicate memory is ready
			  main_memory_read_data = main_memory[main_memory_address];
			  main_memory_ready = 1'b1;
		 end else if (main_memory_write_in_progress) begin
			  //Handle write data and indicate memory is ready
			  main_memory[main_memory_address] = main_memory_write_data;
			  main_memory_ready = 1'b1;
		 end
	end

endmodule