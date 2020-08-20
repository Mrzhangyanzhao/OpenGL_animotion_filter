//
//  FilterBarCell.m
//  OpenGLESGLSL
//
//  Created by yz on 2020/8/11.
//  Copyright © 2020 yz. All rights reserved.
//

#import "FilterBarCell.h"

@interface FilterBarCell()

@property (nonatomic, strong) UILabel *label;

@end

@implementation FilterBarCell
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
-(void)initUI{
    self.label =[[UILabel alloc]initWithFrame:self.bounds];
    self.label.font = [UIFont systemFontOfSize:15];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.label];
}
-(void)setTitle:(NSString *)title{
    if (_title != title) {
        _title = title;
        self.label.text = title;
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectInset(self.label.frame, 10, 10);
}
- (void)setIsSelect:(BOOL)isSelect {
    _isSelect = isSelect;
    self.label.backgroundColor = isSelect ? [UIColor blackColor] : [UIColor clearColor];
    self.label.textColor = isSelect ? [UIColor whiteColor] : [UIColor blackColor];
}
@end
