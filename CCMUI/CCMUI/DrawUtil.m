//
//  DrawUtil.m
//  CCMUI
//
//  Created by 李威 on 2022/6/23.
//

#import "DrawUtil.h"
#define smallWidth 0.3
@implementation DrawUtil
//画线
+(void)drawLineFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint withLineWidth:(float)width withLineColor:(CGColorRef)color inContext:(CGContextRef)context
{
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, width);
    //加上width/2是为了能画出实际宽度的线条
    CGContextMoveToPoint(context, startPoint.x+width/2, startPoint.y+width/2);
    CGContextAddLineToPoint(context, endPoint.x+width/2, endPoint.y+width/2);
    CGContextStrokePath(context);
}

//颜色填充矩形
+(void)drawFillRect:(CGRect)rect withFillColor:(CGColorRef)color inContext:(CGContextRef)context
{
    CGContextSetFillColorWithColor(context, color);
    CGContextFillRect(context, rect);
    CGContextDrawPath(context, kCGPathStroke);
}
////画红色空心园
//+(void)drawcircleInCenterPoint:(CGPoint)centerPoint inContext:(CGContextRef)context
//{
//    CGRect rect = CGRectMake(centerPoint.x-contentPane/2, centerPoint.y-contentPane/2, contentPane, contentPane);
//    CGContextSetRGBStrokeColor(context, 1, 0, 0, 1.0);
//    CGContextSetLineWidth(context, bigWidth);
//    CGContextAddEllipseInRect(context, rect);
//    CGContextDrawPath(context, kCGPathStroke);
//}
//
////画红色实心园
//+(void)drawFillCircleInCenterPoint:(CGPoint)centerPoint inContext:(CGContextRef)context
//{
//    CGRect rect = CGRectMake(centerPoint.x-contentPane/2, centerPoint.y-contentPane/2, contentPane, contentPane);
//    CGContextSetRGBFillColor(context, 1, 0, 0, 1.0);
//    CGContextSetLineWidth(context, bigWidth);
//    CGContextFillEllipseInRect(context, rect);
//    CGContextDrawPath(context, kCGPathStroke);
//}
//
////画蓝色交叉线
//+(void)drawCrossLineInCenterPoint:(CGPoint)centerPoint inContext:(CGContextRef)context
//{
//    CGPoint startPointOne = CGPointMake(centerPoint.x-contentPane/2, centerPoint.y-contentPane/2);
//    CGPoint endPointOne = CGPointMake(centerPoint.x+contentPane/2, centerPoint.y+contentPane/2);
//
//    CGPoint startPointTwo = CGPointMake(centerPoint.x+contentPane/2, centerPoint.y-contentPane/2);
//    CGPoint endPointTwo = CGPointMake(centerPoint.x-contentPane/2, centerPoint.y+contentPane/2);
//
//    CGColorRef color = [[UIColor colorWithRed:58.0/255.0 green:149.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor];
//    [self drawLineFromStartPoint:startPointOne toEndPoint:endPointOne withLineWidth:signWidth withLineColor:color inContext:context];
//    [self drawLineFromStartPoint:startPointTwo toEndPoint:endPointTwo withLineWidth:signWidth withLineColor:color inContext:context];
//}

//居中画文本
+(void)drawText:(NSString *)text InRect:(CGRect)rect withFont:(UIFont *)font inContext:(CGContextRef)context
{
    [self drawText:text InRect:rect withFont:font inContext:context alignment:NSTextAlignmentCenter];
}

//居右画文本
+(void)drawText:(NSString *)text InRect:(CGRect)rect withFont:(UIFont *)font inContext:(CGContextRef)context alignment:(NSTextAlignment)alignment
{
    if(!text|| [@"" isEqualToString:text]) return;
    if (![text isKindOfClass:[NSString class]]) {
        text = [NSString stringWithFormat:@"%@", text];
    }
    CGContextSetLineWidth(context, smallWidth);
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = alignment;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dic = @{NSFontAttributeName: font,NSParagraphStyleAttributeName: paragraphStyle};
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(1000, rect.size.height)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font} context:nil].size;
    CGRect textRect = CGRectMake(rect.origin.x,rect.origin.y+(rect.size.height-font.pointSize-2)/2,
                                 textSize.width>rect.size.width?textSize.width:rect.size.width,font.pointSize+2);
    [text drawInRect:textRect withAttributes:dic];
}

//居中画文本,可以设置颜色
+(void)drawText:(NSString *)text InRect:(CGRect)rect withFont:(UIFont *)font withColor:(UIColor *)color inContext:(CGContextRef)context
{
    if(!text|| [@"" isEqualToString:text]) return;
    if (![text isKindOfClass:[NSString class]]) {
        text = [NSString stringWithFormat:@"%@", text];
    }
    CGContextSetLineWidth(context, smallWidth);
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dic = @{NSFontAttributeName: font,NSParagraphStyleAttributeName: paragraphStyle,NSForegroundColorAttributeName:color};
    CGRect textRect = CGRectMake(rect.origin.x,rect.origin.y+(rect.size.height-font.pointSize-2)/2,rect.size.width,font.pointSize+2);
    [text drawInRect:textRect withAttributes:dic];
}

//居中画多行文本
+(void)drawText:(NSString *)text InRect:(CGRect)rect withFont:(UIFont *)font withRow:(NSInteger)row inContext:(CGContextRef)context
{
    if(!text|| [@"" isEqualToString:text]) return;
    if (![text isKindOfClass:[NSString class]]) {
        text = [NSString stringWithFormat:@"%@", text];
    }
    CGContextSetLineWidth(context, smallWidth);
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *dic = @{NSFontAttributeName: font,NSParagraphStyleAttributeName: paragraphStyle};
    CGRect textRect = CGRectMake(rect.origin.x,rect.origin.y+(rect.size.height-row*font.pointSize-2)/2,rect.size.width,row*font.pointSize+2);
    [text drawInRect:textRect withAttributes:dic];
}

//画折线
+(void)drawMutableLineWithPoints:(NSMutableArray *)points withColor:(UIColor *)color withStorkeWidth:(float)width inContext:(CGContextRef)context
{
    if (!points || (NSNull *)points == [NSNull null] || points.count == 0 ) {
        return;
    }
    CGContextSetLineWidth(context, width);
    [color setStroke];
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, [points[0] CGPointValue].x, [points[0] CGPointValue].y);
    for (int i=1; i<points.count; i++) {
        //        CGPathMoveToPoint(path, nil, [points[i] CGPointValue].x, [points[i] CGPointValue].y);
        CGPathAddLineToPoint(path, nil,[points[i] CGPointValue].x, [points[i] CGPointValue].y);
    }
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
}

//填充
+(void)drawFillAreaWithPoints:(NSArray *)points withColor:(UIColor *)color inContext:(CGContextRef)context
{
    if (!points || (NSNull *)points == [NSNull null] || points.count == 0 ) {
        return;
    }
    CGContextSetLineWidth(context, smallWidth);
    [color setFill];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, [points[0] CGPointValue].x, [points[0] CGPointValue].y);
    for (int i=1; i<points.count; i++) {
        CGPathAddLineToPoint(path, nil,[points[i] CGPointValue].x, [points[i] CGPointValue].y);
    }
    CGContextClosePath(context);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathFill);
    CGPathRelease(path);
}
@end
