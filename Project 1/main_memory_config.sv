//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//main memory package setup

package main_memory_config;

    //Main memory configuration parameters
    parameter int MAIN_MEMORY_BLOCK_SIZE = 4; //Bytes per block    
    parameter int MAIN_MEMORY_NUM_BLOCKS = 64; //Number of blocks in the main memory 
    parameter int MAIN_MEMORY_SIZE = MAIN_MEMORY_NUM_BLOCKS * MAIN_MEMORY_BLOCK_SIZE; //size of a main memory in bytes
    parameter int MAIN_MEMORY_ADDRESS_WIDTH = 32; //Width of the main memory address bus
    parameter int MAIN_MEMORY_DATA_WIDTH = 128; //Width of the main memory data bus

endpackage