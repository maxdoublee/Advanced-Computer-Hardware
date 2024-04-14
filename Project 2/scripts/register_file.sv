//Project 2: Superscalar & Out-of-Order
//Max Destil
//RIN: 662032859

//Register File

module register_file(
    input logic clk,
    input logic reset,
    input logic request_rs_flag,
    input logic [4:0] adder_write_dest, multiplier_write_dest, memory_write_dest, request_rs1, request_rs2,
    input logic [31:0] adder_result, multiplier_result, memory_read_data,
    input logic adder_write_enable, multiplier_write_enable, memory_write_enable,
    input logic reset_enable_flag1, reset_enable_flag2, reset_enable_flag3,

    output logic [31:0] read_data1, read_data2,
    output logic confirm_rs_flag,
    output logic adder_reset_write_enable_flag, multiplier_reset_write_enable_flag, memory_reset_write_enable_flag
);
    // Register file storage
    logic [31:0] registers[31:0];
    logic enable_flag1, enable_flag2, enable_flag3;

    // Write operation
    always_ff @(posedge clk) begin
        if (reset) begin
            read_data1 <= 32'b0;
            read_data2 <= 32'b0;
            confirm_rs_flag <= 0;
            adder_reset_write_enable_flag <= 0;
            multiplier_reset_write_enable_flag <= 0;
            memory_reset_write_enable_flag <= 0;
            enable_flag1 = 0;
            enable_flag2 = 0;
            enable_flag3 = 0;
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0; // Set unused registers to 0 
            end
            for (int i = 1; i < 11; i++) begin
                if(!(i > 5 && i < 10)) begin
                    registers[i] <= i + 1; // Set used registers to initialized values 
                end
            end
        end else begin
            // To dispatch unit for operand values
            if (request_rs_flag) begin // Read operation
                read_data1 <= registers[request_rs1];
                read_data2 <= registers[request_rs2];
                confirm_rs_flag <= 1;
            end 
            // From functional units for storing computations
            if (adder_write_enable && adder_write_dest != 0 && !enable_flag1) begin // Ensure not to write-back to register x0 which is always zero
                enable_flag1 <= 1;
                confirm_rs_flag <= 0;
                registers[adder_write_dest] <= adder_result;
                adder_reset_write_enable_flag <= 1;
            end else if (multiplier_write_enable && multiplier_write_dest != 0 && !enable_flag2) begin // Ensure not to write-back to register x0 which is always zero
                enable_flag2 <= 1;
                confirm_rs_flag <= 0;
                registers[multiplier_write_dest] <= multiplier_result;
                multiplier_reset_write_enable_flag <= 1;
            end else if (memory_write_enable && memory_write_dest != 0 && !enable_flag3) begin // Ensure not to write-back to register x0 which is always zero
                enable_flag3 <= 1;
                confirm_rs_flag <= 0;
                registers[memory_write_dest] <= memory_read_data;
                memory_reset_write_enable_flag <= 1;
            end
            if(reset_enable_flag1) begin 
                enable_flag1 <= 0;
            end else if(reset_enable_flag2) begin 
                enable_flag2 <= 0;
            end else if(reset_enable_flag3) begin 
                enable_flag3 <= 0;
            end
        end
    end
endmodule