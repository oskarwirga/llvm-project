// cfstring_ptr.m
#import <CoreFoundation/CoreFoundation.h>

CFStringRef gStr = CFSTR("hi");   // emits __DATA_CONST,__cfstring

int main(void) { return (int)CFStringGetLength(gStr); }
