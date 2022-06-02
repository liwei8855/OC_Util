//
//  NSString+Size.m
//  CCMSDK
//
//  Created by 李威 on 2022/6/2.
//

#import "NSString+Size.h"
#import <CoreText/CoreText.h>

@implementation NSString (Size)

- (CGSize)getStringSizeByFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    if (!font) {
        NSLog(@"font不能为nil");
        return CGSizeZero;
    }
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGSize size = [self boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    float height = size.height + size.height/15;
    size.height = height;
    return size;
}


-(void)stringFont:(UIFont *)font maxSize:(CGSize)maxSize lineSpace:(float)lineSpace completion:(void(^)(CGSize size ,NSMutableAttributedString *attString))completion
{
    if (!font || lineSpace<0) {
        NSLog(@"font不能为nil");
        return;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attributedString length])];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self length])];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributedString);
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0, [attributedString length]), NULL,maxSize, NULL);
    CFRelease(framesetter);
    
    suggestedSize.height += 5;
    
    completion(suggestedSize,attributedString);
}
@end
