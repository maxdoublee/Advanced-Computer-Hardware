//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache package setup 

package cache_config;
	
  //Cache configuration parameters
  parameter int CACHE_LEVEL = 1; //1 for L1, 2 for L2
  parameter int ASSOCIATIVE  = (CACHE_LEVEL == 1) ? 1 : 4; //Direct-mapped for L1, four-way set-associative for L2
  parameter int WRITE_POLICY = 1; //0 for write-through, 1 for write-back
  parameter int WORD_SIZE = 4; //word size in bytes
  parameter int BLOCK_SIZE = (CACHE_LEVEL == 1) ? 1 : 4; //Bytes per block, smaller blocks for L1, larger for L2
  parameter int NUM_BLOCKS = (CACHE_LEVEL == 1) ? 4 : 16; //More blocks for L2
  parameter int NUM_SETS = NUM_BLOCKS / ASSOCIATIVE; //Number of sets dependent on how cache placement is setup
  parameter int CACHE_SIZE = NUM_BLOCKS * BLOCK_SIZE; //Total cache size
  parameter int ADDRESS_WIDTH = 32; //Width of the address bus, determines how many unique memory locations can be addressed
  parameter int DATA_WIDTH = 32; //Width of the data bus from processor to cache, this means it can read or write 32 bits of data to or from memory in one go
  parameter int INDEX_WIDTH = $clog2(NUM_SETS); //Number of bits for cache index
  parameter int BYTE_OFFSET_WIDTH = $clog2(WORD_SIZE); //Number of bits for byte offset
  parameter int BLOCK_OFFSET_WIDTH = $clog2(BLOCK_SIZE / WORD_SIZE); //Number of bits for block offset
  parameter int TAG_WIDTH = (ADDRESS_WIDTH - (INDEX_WIDTH + BYTE_OFFSET_WIDTH + BLOCK_OFFSET_WIDTH)); //Number of bits for tag 
  parameter int INDEX_START = ADDRESS_WIDTH - TAG_WIDTH; //for slicing main memory addresses for cache blocks 
  parameter int OFFSET_START = INDEX_START - INDEX_WIDTH; //for slicing main memory addresses for selecting correct word in block

  //Internal state of the cache 
  logic [1:0] valid_bits[NUM_SETS-1:0]; //Array of valid bits, one for each cache line
  logic [1:0] dirty_bits[NUM_SETS-1:0]; //Array of dirty bits, one for each cache line
  logic [TAG_WIDTH-1:0] tags[NUM_SETS-1:0]; //Array of tags, one for each cache line
  logic [DATA_WIDTH-1:0] data[NUM_SETS-1:0]; //Array of data, one for each cache line
  
endpackage;