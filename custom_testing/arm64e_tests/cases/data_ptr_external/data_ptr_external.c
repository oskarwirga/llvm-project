// data_ptr_external.c
extern int errno;
int *p_errno = &errno; // Should emit bind in __got

int main(void) { return *p_errno; }
