//
//  GCDTimer.h
//  basic_tips
//
//  Created by 李威 on 2021/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCDTimer : NSObject
+ (NSString *)execTask:(dispatch_block_t)task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async;
+ (NSString *)execTask:(id)target selector:(SEL)selector start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async;
+ (void)cancelTask:(NSString *)taskName;
@end

NS_ASSUME_NONNULL_END
