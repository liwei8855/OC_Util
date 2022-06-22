//
//  JailUtil.m
//
//  Created by 李威 on 2022/3/12.
//

#import "JailUtil.h"

@implementation JailUtil

//判断是否越狱
+ (BOOL)isJail {
    //判断是否安装了Cydia.appe  不同版本手机文件系统可能不一样
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isJailbreak {
    if (getenv("DYLD_INSERT_LIBRARIES")) {
        return YES;
    }
    ///还有其他判断条件 google一下
    return NO;
}

@end
