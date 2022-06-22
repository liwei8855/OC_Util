//
//  ViewController.m
//  UtilsFramework
//
//  Created by 李威 on 2022/5/30.
//

#import "ViewController.h"
#import "framework/CCMSDK.framework/Headers/CCMSDK.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     
    // Do any additional setup after loading the view.
    BOOL isJail = [Common isJail];
    NSLog(@"=====%d",isJail);
}


@end
