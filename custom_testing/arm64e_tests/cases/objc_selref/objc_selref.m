// objc_selref.m
#import <Foundation/Foundation.h>
void *p;

int main(void) {
    SEL sel = @selector(description); // Should emit rebase in __objc_selrefs
    p = sel;
    return 0;
}
