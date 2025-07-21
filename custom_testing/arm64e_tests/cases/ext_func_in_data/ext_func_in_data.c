// ext_func_in_data.c
extern void puts(const char *);
void (*myputs)(const char *) = puts; // Should emit auth-bind in __auth_got

int main(void) { myputs("assigned in .data"); return 0; }
