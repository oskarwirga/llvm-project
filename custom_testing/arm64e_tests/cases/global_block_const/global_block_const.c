// global_block_const.c
#include <Block.h>

const int (^gBlock)(int) = ^(int x) { return x + 1; };

int main(void) { return gBlock(41); }
