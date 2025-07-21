// fp_static.c
static void my_static_fn(int x) { (void)x; }
void (*fp)(int) = my_static_fn; // Should emit auth-rebase in __const or __data

int main(void) { fp(123); return 0; }
