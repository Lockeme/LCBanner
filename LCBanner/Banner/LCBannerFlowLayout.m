//
//  LCBannerFlowLayout.m
//  LCLottery
//
//  Created by Lockeme on 2017/12/26.
//  Copyright © 2017年 Lockeme. All rights reserved.
//

#import "LCBannerFlowLayout.h"

@implementation LCBannerFlowLayout
#pragma mark - Override
-(void)prepareLayout
{
    [super prepareLayout];
    
    [self collectionViewSetting];
}

- (void)collectionViewSetting
{
    // 水平滚动
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // 设置内边距
    self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //item size
    self.itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame));
    //设置cell间距
    self.minimumLineSpacing = 0;
}

//自定义布局
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
@end
