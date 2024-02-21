//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache package setup 

import main_memory_config::*;

package cache_config;
	
  //Cache configuration parameters
  parameter int CACHE_LEVEL = 1; //1 for L1, 2 for L2, 3 for L3
  parameter int ASSOCIATIVE  = (CACHE_LEVEL == 1) ? 1 : (CACHE_LEVEL == 2) ? 4 : 1; //Direct-mapped for L1, four-way set-associative for L2, Direct-mapped for L3
  parameter int WRITE_POLICY = 1; //0 for write-through, 1 for write-back
  parameter int WORD_SIZE = 4; //word size in bytes
  parameter int BLOCK_SIZE = 16; //block size in bytes
  parameter int WORDS_PER_BLOCK = 4; //Words per blocks, each word is 32 bits
  parameter int NUM_BLOCKS_PER_SET = 4; //Blocks per set
  parameter int NUM_BLOCKS = (CACHE_LEVEL == 1) ? 4 : (CACHE_LEVEL == 2) ? 16 : 32; //Total number of blocks for each level of cache
  parameter int NUM_SETS = NUM_BLOCKS / ASSOCIATIVE; //Number of sets dependent on how cache placement is setup
  parameter int CACHE_SIZE = NUM_BLOCKS * BLOCK_SIZE; //Total cache size
  parameter int ADDRESS_WIDTH = 32; //Width of the address bus, determines how many unique memory locations can be addressed
  parameter int DATA_WIDTH = 32; //Width of the data bus from processor to cache, this means it can read or write 32 bits of data to or from memory in one go
  parameter int INDEX_WIDTH = $clog2(NUM_SETS); //Number of bits for cache index
  parameter int BYTE_OFFSET_WIDTH = $clog2(WORD_SIZE); //Number of bits for byte offset
  parameter int BLOCK_OFFSET_WIDTH = $clog2(BLOCK_SIZE / WORD_SIZE); //Number of bits for block offset
  parameter int TAG_WIDTH = (ADDRESS_WIDTH - (INDEX_WIDTH + BYTE_OFFSET_WIDTH + BLOCK_OFFSET_WIDTH)) - 2; //Number of bits for tag, minus two for processor id implementation
  parameter int INDEX_START = (ADDRESS_WIDTH - TAG_WIDTH) - 2; //for slicing main memory addresses for cache blocks 
  parameter int OFFSET_START = INDEX_START - INDEX_WIDTH; //for slicing main memory addresses for selecting correct word in block
  parameter int MESI_STATE_WIDTH = 2; //2 bits to represent the four MESI states
  
endpackage