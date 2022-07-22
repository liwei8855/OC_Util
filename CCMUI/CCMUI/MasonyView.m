//
//  MasonyView.m
//  CCMUI
//
//  Created by 李威 on 2022/6/23.
//

#import "MasonyView.h"
#import <Masonry/Masonry.h>

@implementation MasonyView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UIView *v = [[UIView alloc]init];
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        
    }];
}

@end
