//
//  LCBannerCell.m
//  LCLottery
//
//  Created by Lockeme on 2017/12/30.
//  Copyright © 2017年 Lockeme. All rights reserved.
//

#import "LCBannerCell.h"

@interface LCBannerCell()

@property (nonatomic, strong) UIImageView *bannerImg;
@end

@implementation LCBannerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.bannerImg];
    }
    return self;
}

-(UIImageView *)bannerImg
{
    if (!_bannerImg) {
        _bannerImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    }
    return _bannerImg;
}

-(void)setImageObj:(id)imageObj
{
    if ([imageObj isKindOfClass:[NSString class]]) {
        _bannerImg.image = [UIImage imageNamed:(NSString *)imageObj];
    } else if ([imageObj isKindOfClass:[UIImage class]]) {
        _bannerImg.image = (UIImage *)imageObj;
    }
}
@end
