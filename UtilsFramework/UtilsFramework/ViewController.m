//
//  ViewController.m
//  UtilsFramework
//
//  Created by 李威 on 2022/5/30.
//

#import "ViewController.h"
#import "framework/CCMSDK.framework/Headers/CCMSDK.h"
#import "framework/CCMUI.framework/Headers/CCMUI.h"

#import "fishhook/fishhook.h"

#import "UIViewController+HOOK.h"
#import "UtilsFramework-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     
    // Do any additional setup after loading the view.
//    BOOL isJail = [Common isJail];
//    NSLog(@"=====%d",isJail);
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"测试");
    
}

- (void)my_viewDidAppear:(BOOL)animated {
    NSLog(@"controller viewDidAppear");
}

- (void)my_viewWillAppear:(BOOL)animated {
    NSLog(@"controller viewWillAppear");
}

@end
