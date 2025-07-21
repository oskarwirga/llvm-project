extern void puts(const char *);
int main(void) {
  void (*p)(const char *) = puts;   // forces GOT + auth
  p("hello");
  return 0;
}
