//
//  UIViewController+HOOK.h
//  UtilsFramework
//
//  Created by 李威 on 2022/7/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (HOOK)
- (void)my_viewDidAppear:(BOOL)animated;
- (void)my_viewWillAppear:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
