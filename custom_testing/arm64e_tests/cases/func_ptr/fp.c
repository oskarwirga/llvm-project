static void foo(void) {}
void *sink;

int main(void) {
  void (*fp)(void) = foo;
  sink = fp;          // forces emission to .data, triggers auth reloc
  return 0;
}
