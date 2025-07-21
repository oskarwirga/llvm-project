// objc_classref.m
#import <Foundation/Foundation.h>
void *p;

int main(void) {
    Class c = [NSString class]; // Should emit bind in __objc_classrefs
    p = c;
    return 0;
}
