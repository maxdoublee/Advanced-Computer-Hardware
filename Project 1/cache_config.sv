//Project 1: Multi-Layer Cache
//Max Destil
//RIN: 662032859

//cache package setup 

package cache_config;
	
  //Cache configuration parameters
  parameter int BLOCK_SIZE = 4; //Bytes per block
  parameter int WORDS_BLOCK_SIZE = 1; //Words per blocks
  parameter int NUM_BLOCKS = 4; //Number of blocks in the cache
  parameter int CACHE_SIZE = NUM_BLOCKS * BLOCK_SIZE; //Total cache size
  parameter int WRITE_POLICY = 1; //0 for write-through, 1 for write-back
  parameter int ADDRESS_WIDTH = 32; //Width of the address bus, determines how many unique memory locations can be addressed
  parameter int DATA_WIDTH = 32; //Width of the data bus from processor to cache, this means it can read or write 32 bits of data to or from memory in one go
  parameter int MAIN_MEM_DATA_WIDTH = 128; //Width of the data bus from cache to memory, this means it can read or write 128 bits of data to or from memory in one go
  parameter int BYTE_OFFSET_WIDTH = 2; //Number of bits for byte offset, log_2(word size in bytes)
  parameter int BLOCK_OFFSET_WIDTH = 2; //Number of bits for block offset, BLOCK_SIZE / word size in bytes = x, log_2(x)
  parameter int INDEX_WIDTH = 9; //Number of bits for cache index, log_2(NUM_BLOCKS)
  parameter int TAG_WIDTH = 19; //Number of bits for tag (WORD_SIZE - (CACHE_INDEX_WIDTH + BYTE_OFFSET_WIDTH + BLOCK_OFFSET_WIDTH))
  parameter int INDEX_START = ADDRESS_WIDTH - TAG_WIDTH; //for slicing main memory addresses for cache blocks 
  parameter int OFFSET_START = INDEX_START - INDEX_WIDTH; //for slicing main memory addresses for selecting correct word in block
  
  //Signal interface parameters
  parameter int READ_WRITE_SIGNAL_WIDTH = 1; //Width of the Read/Write signal
  parameter int VALID_SIGNAL_WIDTH = 1; //Width of the Valid signal, indicate a cache operation or not
  parameter int READY_SIGNAL_WIDTH = 1; //Width of the Ready signal, indicate the cache operation is complete

  //Internal state of the cache 
  logic [1:0] valid_bits[NUM_BLOCKS-1:0]; //Array of valid bits, one for each cache line
  logic [1:0] dirty_bits[NUM_BLOCKS-1:0]; //Array of dirty bits, one for each cache line
  logic [TAG_WIDTH-1:0] tags[NUM_BLOCKS-1:0]; //Array of tags, one for each cache line
  logic [DATA_WIDTH-1:0] data[NUM_BLOCKS-1:0]; //Array of data, one for each cache line
  
endpackage