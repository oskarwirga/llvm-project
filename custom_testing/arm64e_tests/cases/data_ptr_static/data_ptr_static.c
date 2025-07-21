// data_ptr_static.c
static int hidden = 7;
int *p_hidden = &hidden; // Should emit rebase in __const or __data

int main(void) { return *p_hidden; }
