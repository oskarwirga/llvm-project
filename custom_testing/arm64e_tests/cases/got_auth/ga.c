extern void puts(const char *);

void (*global_fp)(const char *) = &puts;  //   <-- lives in __data

int main(void) {
  global_fp("GOT auth test\n");
}
