// data_ptr_global.c
int global_var = 77;
int *p_global = &global_var; // Should emit rebase in __data

int main(void) { return *p_global; }
