// array_of_ptrs.c
static void sfn(void) {}
extern void puts(const char *);
extern void fputs(const char *s, void *stream);

void (*arr[4])(void) = { sfn, (void(*)(void))puts, sfn, (void(*)(void))fputs }; // Should emit mix of auth-rebase, auth-bind

int main(void) { arr[1](); arr[0](); arr[2](); return 0; }
