// fp_external.c
extern void puts(const char *);
void (*fp)(const char *) = puts; // Should emit auth-bind in __auth_got

int main(void) { fp("external"); return 0; }
