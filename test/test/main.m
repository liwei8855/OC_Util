//
//  main.m
//  test
//
//  Created by 李威 on 2022/6/16.
//

#import <Foundation/Foundation.h>

void getMemory(char *p) {
    p = (char *)malloc(100);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
//        char * str = NULL;
//        getMemory(str);
//        strcpy(str, "hello world");
//        printf(str);
        
        char string[10];
        char * str1 = "012345678";
        strcpy(string, str1);
    }
    return 0;
}
