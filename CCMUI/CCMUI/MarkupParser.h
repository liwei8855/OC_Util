//
//  MarkupParser.h
//  CoreTextDemo
//
//  Created by lee on 2018/3/20.
//  Copyright © 2018年 mjsfax. All rights reserved.
/*
 文本标记解析器，使用简单的标签设置格式
 */

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface MarkupParser : NSObject

@property (copy, nonatomic) NSString *font;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *strokeColor;
@property (assign, readwrite) float strokeWidth;
@property (strong, nonatomic) NSMutableArray *images;
- (NSAttributedString *)attrStringFromMarkup:(NSString *)markup;

@end
