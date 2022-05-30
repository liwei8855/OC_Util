//
//  GCDTimer.m
//  basic_tips
//
//  Created by 李威 on 2021/10/8.
//

#import "GCDTimer.h"

@implementation GCDTimer

static NSMutableDictionary *timers_;
dispatch_semaphore_t semaphore_;

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers_ = [NSMutableDictionary dictionary];
        semaphore_ = dispatch_semaphore_create(1);
    });
}

+ (NSString *)execTask:(dispatch_block_t)task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async {
    
    if (!task || start<0 || (interval<=0 && repeats)) return nil;
    
    dispatch_queue_t queue = async ? dispatch_queue_create(0, 0) : dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, start*NSEC_PER_SEC, interval * NSEC_PER_SEC, 0);
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);//加锁操作dict
    NSString *name = [NSString stringWithFormat:@"%zd",timers_.count];
    timers_[name] = timer;
    dispatch_semaphore_signal(semaphore_);//解锁
    
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeats) {
            [self cancelTask:name];
        }
    });
    dispatch_source_set_cancel_handler(timer, ^{
        //取消dispatch source时的处理
    });
    dispatch_resume(timer);
    return name;
    
}
//target被block持有 不能释放 不要手动cannel：优化一下
+ (NSString *)execTask:(id)target selector:(SEL)selector start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async {
    
    if (!target || !selector) return nil;
    return [self execTask:^{
        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector];
#pragma clang diagnostic pop
        }
        
    } start:start interval:interval repeats:repeats async:async];
    
}

+ (void)cancelTask:(NSString *)taskName {
    if (taskName.length == 0) return;
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = timers_[taskName];
    if (timer) {
        dispatch_source_cancel(timer);
        [timers_ removeObjectForKey:taskName];
    }
    dispatch_semaphore_signal(semaphore_);
}

@end
