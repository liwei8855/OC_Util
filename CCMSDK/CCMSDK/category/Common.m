//
//  Common.m
//  CCMSDK
//
//  Created by 李威 on 2022/6/22.
//

#import "Common.h"
#import "CCMUtils.h"

@implementation Common
+ (BOOL)isJail {
    BOOL isJail = NO;
    if ([JailUtil isJail]) {
        isJail = YES;
    } else if ([JailUtil isJailbreak]) {
        isJail = YES;
    }
    return isJail;
}
@end
