// cpp_vtable.cpp
struct Base { virtual void foo(); };
void Base::foo() {}

int main() {
    Base b;
    b.foo(); // Should emit auth-rebase or auth-bind for vtable slot
    return 0;
}
