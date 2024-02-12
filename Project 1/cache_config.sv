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
  parameter int BLOCK_SIZE = (CACHE_LEVEL == 1) ? 4 : (CACHE_LEVEL == 2) ? 16 : 32; //Bytes per block
  parameter int WORDS_PER_BLOCK_SIZE = (CACHE_LEVEL == 1) ? 4 : (CACHE_LEVEL == 2) ? 16 : 32; //Words per blocks, each word is a bit
  parameter int NUM_BLOCKS = (CACHE_LEVEL == 1) ? 4 : (CACHE_LEVEL == 2) ? 16 : 32; //Number of blocks for each level of cache
  parameter int NUM_SETS = NUM_BLOCKS / ASSOCIATIVE; //Number of sets dependent on how cache placement is setup
  parameter int NUM_TAGS = NUM_BLOCKS * NUM_SETS; //Number of tags within the cache module for L2
  parameter int CACHE_SIZE = NUM_BLOCKS * BLOCK_SIZE; //Total cache size
  parameter int ADDRESS_WIDTH = 32; //Width of the address bus, determines how many unique memory locations can be addressed
  parameter int DATA_WIDTH = 32; //Width of the data bus from processor to cache, this means it can read or write 32 bits of data to or from memory in one go
  parameter int INDEX_WIDTH = $clog2(NUM_SETS); //Number of bits for cache index
  parameter int BYTE_OFFSET_WIDTH = $clog2(WORD_SIZE); //Number of bits for byte offset
  parameter int BLOCK_OFFSET_WIDTH = $clog2(BLOCK_SIZE / WORD_SIZE); //Number of bits for block offset
  parameter int TAG_WIDTH = (ADDRESS_WIDTH - (INDEX_WIDTH + BYTE_OFFSET_WIDTH + BLOCK_OFFSET_WIDTH)) - 2; //Number of bits for tag, minus two for processor id implementation
  parameter int INDEX_START = (ADDRESS_WIDTH - TAG_WIDTH) - 2; //for slicing main memory addresses for cache blocks 
  parameter int OFFSET_START = INDEX_START - INDEX_WIDTH; //for slicing main memory addresses for selecting correct word in block

  //Internal state of the cache level 1, L1
  logic [1:0] L1_valid_bits[NUM_SETS-1:0]; //Array of valid bits, one for each cache line
  logic [1:0] L1_dirty_bits[NUM_SETS-1:0]; //Array of dirty bits, one for each cache line
  logic [TAG_WIDTH-1:0] L1_tags[NUM_SETS-1:0]; //Array of tags, one for each cache line
  logic [MAIN_MEMORY_DATA_WIDTH-1:0] L1_data[NUM_SETS-1:0]; //Array of data, one for each cache line, larger bit number to accommodate the four words, 32 bits each

  //Internal state of the cache level 2, L2
  logic [1:0] L2_valid_bits[NUM_TAGS-1:0]; //Array of valid bits, one for each cache line
  logic [1:0] L2_dirty_bits[NUM_TAGS-1:0]; //Array of dirty bits, one for each cache line
  logic [INDEX_WIDTH-1:0] L2_indexes[NUM_SETS-1:0]; //Array for verifying the correct set within the L2 cache module
  logic [TAG_WIDTH-1:0] L2_tags[NUM_TAGS-1:0]; //Array of tags, one for each cache line
  logic [MAIN_MEMORY_DATA_WIDTH-1:0] L2_data[NUM_TAGS-1:0]; //Array of data, one for each cache line

  //Internal state of the cache level 3, L3
  logic [1:0] L3_valid_bits[NUM_SETS-1:0]; //Array of valid bits, one for each cache line
  logic [1:0] L3_dirty_bits[NUM_SETS-1:0]; //Array of dirty bits, one for each cache line
  logic [TAG_WIDTH-1:0] L3_tags[NUM_SETS-1:0]; //Array of tags, one for each cache line
  logic [MAIN_MEMORY_DATA_WIDTH-1:0] L3_data[NUM_SETS-1:0]; //Array of data, one for each cache line
  
endpackage;