//
//  DrawUtil.h
//  CCMUI
//
//  Created by 李威 on 2022/6/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawUtil : NSObject

+(void)drawLineFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint withLineWidth:(float)width withLineColor:(CGColorRef)color inContext:(CGContextRef)context;

+(void)drawFillRect:(CGRect)rect withFillColor:(CGColorRef)color inContext:(CGContextRef)context;

//+(void)drawcircleInCenterPoint:(CGPoint)centerPoint inContext:(CGContextRef)context;
//
//+(void)drawFillCircleInCenterPoint:(CGPoint)centerPoint inContext:(CGContextRef)context;
//
//+(void)drawCrossLineInCenterPoint:(CGPoint)centerPoint inContext:(CGContextRef)context;

+(void)drawText:(NSString *)text InRect:(CGRect)rect withFont:(UIFont *)font inContext:(CGContextRef)context;

+(void)drawText:(NSString *)text InRect:(CGRect)rect withFont:(UIFont *)font inContext:(CGContextRef)context alignment:(NSTextAlignment)alignment;

+(void)drawText:(NSString *)text InRect:(CGRect)rect withFont:(UIFont *)font withColor:(UIColor *)color inContext:(CGContextRef)context;

+(void)drawText:(NSString *)text InRect:(CGRect)rect withFont:(UIFont *)font withRow:(NSInteger)row inContext:(CGContextRef)context;

+(void)drawMutableLineWithPoints:(NSMutableArray *)points withColor:(UIColor *)color withStorkeWidth:(float)width inContext:(CGContextRef)context;

+(void)drawFillAreaWithPoints:(NSArray *)points withColor:(UIColor *)color inContext:(CGContextRef)context;

@end

NS_ASSUME_NONNULL_END
