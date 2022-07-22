//
//  MarkupParser.m
//  CoreTextDemo
//
//  Created by lee on 2018/3/20.
//  Copyright © 2018年 mjsfax. All rights reserved.
//

#import "MarkupParser.h"

static void deallocCallback(void *ref) {
    ref = nil;
}

static CGFloat ascentCallback(void *ref) {
    return [(NSString *)[(__bridge NSDictionary *)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref) {
    return [(NSString *)[(NSDictionary *)CFBridgingRelease(ref) objectForKey:@"descent"] floatValue];
}

static CGFloat widthCallback(void *ref) {
    return [(NSString *)[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
}

@implementation MarkupParser
- (instancetype)init {
    if (self = [super init]) {
        self.font = @"Arial";
        self.color = [UIColor blackColor];
        self.strokeColor = [UIColor whiteColor];
        self.strokeWidth = 0.0;
        self.images = [NSMutableArray array];
    }
    return self;
}

- (NSAttributedString *)attrStringFromMarkup:(NSString *)markup {
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(.*?)(<[^>]+>|\\Z)" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray *chunks = [regex matchesInString:markup options:0 range:NSMakeRange(0, [markup length])];
    
    for (NSTextCheckingResult *b in chunks) {
        NSArray *parts = [[markup substringWithRange:b.range] componentsSeparatedByString:@"<"];
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.font, 24.0f, NULL);
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:(id)self.color.CGColor,kCTForegroundColorAttributeName,fontRef,kCTFontAttributeName,(id)self.strokeColor.CGColor,(NSString *)kCTStrokeColorAttributeName,(id)[NSNumber numberWithFloat:self.strokeWidth],(NSString *)kCTStrokeWidthAttributeName, nil];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[parts objectAtIndex:0] attributes:attrs]];
        CFRelease(fontRef);
        
        if ([parts count] > 1) {
            NSString *tag = (NSString *)[parts objectAtIndex:1];
            if ([tag hasPrefix:@"font"]) {
                //stroke color
                NSRegularExpression *scolorRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=strokeColor=\")\\w+" options:0 error:NULL];
                [scolorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                   
                    if ([[tag substringWithRange:result.range] isEqualToString:@"none"]) {
                        self.strokeWidth = 0.0;
                    } else {
                        self.strokeWidth = -3.0;
                        SEL colorSel = NSSelectorFromString([NSString stringWithFormat:@"%@Color",[tag substringWithRange:result.range]]);
                        self.strokeColor = [UIColor performSelector:colorSel];
                    }
                    
                }];
                
                //color
                NSRegularExpression *colorRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=color=\")\\w+" options:0 error:NULL];
                [colorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                   
                    SEL colorSel = NSSelectorFromString([NSString stringWithFormat:@"%@Color",[tag substringWithRange:result.range]]);
                    self.color = [UIColor performSelector:colorSel];
                    
                }];
                
                //face
                NSRegularExpression *faceRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=face=\")[^\"]+" options:0 error:NULL];
                [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                   
                    self.font = [tag substringWithRange:result.range];
                }];
            }//end of font parsing
            
            if ([tag hasPrefix:@"img"]) {
                __block NSNumber *width = [NSNumber numberWithInt:0];
                __block NSNumber *height = [NSNumber numberWithInt:0];
                __block NSString *fileName = @"";
                
                //width
                NSRegularExpression *widthRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=width=\")[^\"]+" options:0 error:NULL];
                [widthRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, tag.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                   
                    width = [NSNumber numberWithInt:[[tag substringWithRange:result.range] intValue]];
                }];
                
                //height
                NSRegularExpression *heightRegex = [[NSRegularExpression alloc] initWithPattern:@"(?<=height=\")[^\"]+" options:0 error:NULL];
                [heightRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, tag.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                   
                    height = [NSNumber numberWithInt:[[tag substringWithRange:result.range] intValue]];
                }];
                
                //image
                NSRegularExpression *srcRegex = [[NSRegularExpression alloc] initWithPattern:@"" options:0 error:NULL];
                [srcRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, tag.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                   
                    fileName = [tag substringWithRange:result.range];
                }];
                
                //add image for drawing
                [self.images addObject:[NSDictionary dictionaryWithObjectsAndKeys:width,@"width",height,@"height",fileName,@"fileName",[NSNumber numberWithInt:(int)aString.length],@"location", nil]];
                
                //render empty space for drawing the image in the text
                CTRunDelegateCallbacks callbacks;
                callbacks.version = kCTRunDelegateVersion1;
                callbacks.getAscent = ascentCallback;
                callbacks.getDescent = descentCallback;
                callbacks.getWidth = widthCallback;
                callbacks.dealloc = deallocCallback;
                
                NSDictionary *imgAttr = [NSDictionary dictionaryWithObjectsAndKeys:width,@"width",height,@"height", nil];
                CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)(imgAttr));
                NSDictionary *attrDictionaryDelegate = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)delegate,(NSString *)kCTRunDelegateAttributeName, nil];
                
                //add a space to the text so that it can call the delegate
                [aString appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attrDictionaryDelegate]];
                
            }
            
        }
    }
    
    
    return aString;
}

@end
