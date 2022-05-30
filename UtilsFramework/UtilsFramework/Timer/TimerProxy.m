//
//  TimerProxy.m
//  basic_tips
//
//  Created by 李威 on 2021/10/8.
//

#import "TimerProxy.h"

@implementation TimerProxy
+ (instancetype)proxyWithTarget:(id)target {
    TimerProxy *proxy = [[TimerProxy alloc]init];
    proxy.target = target;
    return proxy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.target;
}

//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//
//}
//
//- (void)forwardInvocation:(NSInvocation *)anInvocation

@end
