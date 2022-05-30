//
//  TimerProxy.h
//  basic_tips
//
//  Created by 李威 on 2021/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimerProxy : NSObject
+ (instancetype)proxyWithTarget:(id)target;
@property (nonatomic, weak) id target;
@end

NS_ASSUME_NONNULL_END
