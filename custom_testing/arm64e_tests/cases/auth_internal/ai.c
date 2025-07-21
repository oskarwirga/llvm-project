static void local(int x) { (void)x; }

void (*global_fp)(int) = local;   // lives in __DATA, points to internal code

int main(void) {
  global_fp(42);
}
