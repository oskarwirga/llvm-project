// block_ptr.c
#include <Block.h>
int (^block_var)(int) = ^int(int x) { return x + 2; }; // Should emit auth-rebase or auth-bind

int call_block(int y) { return block_var(y); }

int main(void) { return call_block(40); }
