//
//  LCBannerView.h
//  LCLottery
//
//  Created by Lockeme on 2017/12/26.
//  Copyright © 2017年 Lockeme. All rights reserved.
//

#import <UIKit/UIKit.h>

/** idx 从0开始 */
typedef void(^ClickBlock)(NSInteger idx);

@interface LCBannerView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>

/** 数据源 images or imageNames or urls */
@property (nonatomic, strong) NSArray *banners;
/** 位置点颜色 default is white */
@property (nonatomic, strong) UIColor *positionColor;
/** 用户点击banner后返回block */
@property (nonatomic, copy) ClickBlock clickBlock;
/** 自动轮播 default is YES */
@property (nonatomic, assign) BOOL autoScroll;
/** 轮播间隔时间 default is 5 */
@property (nonatomic, assign) int interval;
@end
