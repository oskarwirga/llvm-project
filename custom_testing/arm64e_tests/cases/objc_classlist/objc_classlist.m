// objc_classlist.m
#import <Foundation/Foundation.h>

@interface Foo : NSObject @end
@implementation Foo @end

int main(void) {
    Foo *f = [[Foo alloc] init]; // Should emit rebase in __objc_classlist, etc.
    return [f description] != nil;
}
