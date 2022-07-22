//
//  UtilsFrameworkTests.m
//  UtilsFrameworkTests
//
//  Created by 李威 on 2022/5/30.
//

#import <XCTest/XCTest.h>
#import "TimerUtil.h"
//oc swift乔接时系统自动生成的头文件，不显示，在oc中调用swift时需要引入
//$CONFIGURATION_TEMP_DIR 系统配置路径
//配置header search路径：$CONFIGURATION_TEMP_DIR/UtilsFramework.build/DerivedSources
//配置好引入下边头文件 就可以调用swift类了，swift泪需要加 @objc
#import "UtilsFramework-Swift.h"

@interface UtilsFrameworkTests : XCTestCase

@end

@implementation UtilsFrameworkTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
}

- (void)testSwift {
    SwiftTestModel *m = [SwiftTestModel new];
    XCTAssertNotNil(m,"failed");
}

- (void)testObjectC {
    TimerUtil *t = [TimerUtil new];
    XCTAssertNotNil(t, @"failed");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
