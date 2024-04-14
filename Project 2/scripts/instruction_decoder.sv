//Project 2: Superscalar & Out-of-Order
//Max Destil
//RIN: 662032859

//Instruction Decoder

module instruction_decoder (
    input logic clk,
    input logic reset,
    input logic [31:0] instruction, // Single instruction input for decoding

    output logic [6:0] opcode, // Opcode field
    output logic [4:0] rd, // Destination register
    output logic [4:0] rs1, // Source register 1
    output logic [4:0] rs2, // Source register 2
    output logic [2:0] funct3, // Function field (3 bits)
    output logic [6:0] funct7, // Function field (7 bits) 
    output logic type_add, // Indicates an add instruction
    output logic type_mul, // Indicates a mul instruction
    output logic type_load, // Indicates a load instruction
    output logic type_store, // Indicates a store instruction
    output logic type_nop, // Indicates a nop instruction
    output logic [31:0] immediate, // Immediate value extracted from the instruction, used for operations requiring immediate operands such as load and store 
    output logic unrecognized_instruction // Indicates an unrecognized instruction
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset logic for output signals
            opcode <= 7'b0;
            rd <= 5'b0;
            rs1 <= 5'b0;
            rs2 <= 5'b0;
            funct3 <= 3'b0;
            funct7 <= 7'b0;
            type_add <= 0;
            type_mul <= 0;
            type_load <= 0;
            type_store <= 0;
            type_nop <= 0;
            immediate <= 32'b0;
            unrecognized_instruction <= 0;
        end else begin
            // Decode the opcode
            opcode <= instruction[6:0];
            // Decode fields
            rd <= instruction[11:7];
            funct3 <= instruction[14:12];
            rs1 <= instruction[19:15];
            rs2 <= instruction[24:20];
            funct7 <= instruction[31:25];
            // Decoding logic 
            case(opcode)
                7'b0110011: begin // R-type
                    if(funct3 == 3'b000 && funct7 == 7'b0000000) begin
                        type_mul <= 0;
                        type_load <= 0;
                        type_store <= 0;
                        type_nop <= 0;
                        unrecognized_instruction <= 0;
                        type_add <= 1; // ADD instruction
                    end else if(funct3 == 3'b000 && funct7 == 7'b0000001) begin
                        type_load <= 0;
                        type_store <= 0;
                        type_nop <= 0;
                        type_add <= 0; 
                        unrecognized_instruction <= 0;
                        type_mul <= 1; // MUL instruction
                    end
                end
                7'b0000011: begin // LOAD instruction (I-type)
                    type_mul <= 0;
                    type_store <= 0;
                    type_nop <= 0;
                    type_add <= 0;
                    unrecognized_instruction <= 0;
                    immediate <= {{20{instruction[31]}}, instruction[31:20]};
                    type_load <= 1;
                end
                7'b0100011: begin // STORE instruction (S-type)
                    type_mul <= 0;
                    type_load <= 0;
                    type_nop <= 0;
                    type_add <= 0; 
                    unrecognized_instruction <= 0;
                    immediate <= {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                    type_store <= 1;
                end
                7'b0010011: begin // I-type, could be NOP if all zeros
                    if (rs1 == 5'b0 && rd == 5'b0 && instruction[31:20] == 12'b0) begin
                        type_mul <= 0;
                        type_load <= 0;
                        type_store <= 0;
                        type_add <= 0;
                        unrecognized_instruction <= 0;
                        immediate <= {{20{instruction[31]}}, instruction[31:20]};
                        type_nop <= 1; // NOP instruction
                    end 
                end
                default: begin
                    // Unrecognized instruction
                    unrecognized_instruction <= 1;
                end
            endcase
        end
    end
endmodule