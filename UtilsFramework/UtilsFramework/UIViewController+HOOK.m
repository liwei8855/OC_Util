//
//  UIViewController+HOOK.m
//  UtilsFramework
//
//  Created by 李威 on 2022/7/4.
//

#import "UIViewController+HOOK.h"
#import <objc/runtime.h>

@implementation UIViewController (HOOK)
+ (void)load {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        
        Method viewDidAppear = class_getInstanceMethod(self, @selector(viewDidAppear:));
        Method my_viewDidAppear = class_getInstanceMethod(self, @selector(my_viewDidAppear:));
        method_exchangeImplementations(viewDidAppear, my_viewDidAppear);
        
        Method viewWillAppear = class_getInstanceMethod(self, @selector(viewWillAppear:));
        Method my_viewWillAppear = class_getInstanceMethod(self, @selector(my_viewWillAppear:));
        method_exchangeImplementations(viewWillAppear, my_viewWillAppear);
       
    });
}

- (void)my_viewDidAppear:(BOOL)animated {
    NSLog(@"hook viewDidAppear !!!");
    [self my_viewDidAppear:animated];
}

- (void)my_viewWillAppear:(BOOL)animated {
    NSLog(@"hook viewWillAppear !!!");
    [self my_viewWillAppear:animated];
}
@end
