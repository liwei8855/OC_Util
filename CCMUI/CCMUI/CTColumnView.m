//
//  CTColumnView.m
//  CoreTextDemo
//
//  Created by lee on 2018/3/21.
//  Copyright © 2018年 mjsfax. All rights reserved.
//

#import "CTColumnView.h"
@interface CTColumnView()
@property (strong, nonatomic) NSMutableArray *frames;
@property (strong, nonatomic) NSMutableString *attString;
@end

@implementation CTColumnView

- (void)buildFrames {
    float frameXOffset = 20;
    float frameYOffset = 20;
    self.pagingEnabled = YES;
    self.delegate = self;
    self.frames = [NSMutableArray array];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect textFrame = CGRectInset(self.bounds, frameXOffset, frameYOffset);
    CGPathAddRect(path, NULL, textFrame);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attString);
    int textPos = 0;
    int columnIndex = 0;
    
    while (textPos<[self.attString length]) {
        CGPoint colOffset = CGPointMake((columnIndex+1)*frameXOffset+columnIndex*(textFrame.size.width/2), 20);
        CGRect colRect = CGRectMake(0, 0, textFrame.size.width/2-10, textFrame.size.height-40);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, colRect);
        
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        
        CTColumnView *content = [[CTColumnView alloc] initWithFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
        content.backgroundColor = [UIColor clearColor];
        content.frame = CGRectMake(colOffset.x, colOffset.y, colRect.size.width, colRect.size.height);
        
        [content setCtFrame:frame];
        [self.frames addObject:(__bridge id _Nonnull)(frame)];
        [self addSubview:content];
        
        textPos += frameRange.length;
        CFRelease(path);
        columnIndex++;
    }
    
    int totalPages = (columnIndex+1)/2;
    self.contentSize = CGSizeMake(totalPages*self.bounds.size.width, textFrame.size.height);
    
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFrameDraw((CTFrameRef)self.ctFrame, context);
}

@end
