//
//  UIViewController+FishHook.m
//  UtilsFramework
//
//  Created by 李威 on 2022/7/5.
//

#import "UIViewController+FishHook.h"
#import "fishhook/fishhook.h"
#import <objc/runtime.h>

@implementation UIViewController (FishHook)
+ (void)load {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        struct rebinding exchange;
        exchange.name = "method_exchangeImplementations";
        exchange.replacement = hookExchange;
        exchange.replaced = (void *)&origExchange;
        
        struct rebinding rebinds[1] = {exchange};
        rebind_symbols(rebinds, 1);
    });
}

static void (*origExchange)(Method m1, Method m2);

void hookExchange(Method m1, Method m2) {
    NSLog(@"hook: method_exchangeImplementations");
    //在此处设置白名单 允许交换的方法执行交换
    SEL sel1 = method_getName(m1);
    if (@selector(viewDidAppear:) == sel1) {
//        SEL sel2 = method_getName(m2);
//        IMP imp1 = method_getImplementation(m1);
//        IMP imp2 = method_getImplementation(m2);
//        origExchange(m1,m2);
        NSLog(@"交换成功 ！！！！");
    } else {
//        exit(0);
    }
    
}

@end
