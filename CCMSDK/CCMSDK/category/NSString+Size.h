//
//  NSString+Size.h
//  CCMSDK
//
//  Created by 李威 on 2022/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Size)
-(CGSize)getStringSizeByFont:(UIFont*)font maxSize:(CGSize)maxSize;

-(void)stringFont:(UIFont *)font maxSize:(CGSize)maxSize lineSpace:(float)lineSpace completion:(void(^)(CGSize size ,NSMutableAttributedString *attString))completion;
@end

NS_ASSUME_NONNULL_END
