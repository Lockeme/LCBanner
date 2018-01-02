//
//  LCBannerView.m
//  LCLottery
//
//  Created by Lockeme on 2017/12/26.
//  Copyright © 2017年 Lockeme. All rights reserved.
//

#import "LCBannerView.h"
#import "LCBannerFlowLayout.h"
#import "LCBannerCell.h"

static NSString *const cellID = @"bannerCellID";
#define POSITION_VIEW_HEIGHT 16//小圆点View高度
#define POSITION_WEIGHT 8//小圆点宽高
#define POSITION_WEIGHT_SELECT 10//选中状态小圆点宽高
#define POSITION_TAG 9230//小圆点tag值

@interface LCBannerView()
{
    NSInteger _lastCellIndex;//最后一个cell下标
    NSInteger _currentIndex;//当前显示图片下标
}
/** 主要的Collection */
@property (nonatomic, strong) UICollectionView *bannerCollection;
/** 定位点背景图 */
@property (nonatomic, strong) UIView *positionView;
/** timer */
@property (nonatomic, strong) NSTimer *scrollTimer;
@end

@implementation LCBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bannerCollection];
        self.positionColor = [UIColor whiteColor];
        self.interval = 5;
        self.autoScroll = YES;
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [self timerInvalidate];
    }
}

#pragma mark - get & set
-(UICollectionView *)bannerCollection
{
    if (!_bannerCollection) {
        LCBannerFlowLayout *bannerFlowLayout = [LCBannerFlowLayout new];
        _bannerCollection = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:bannerFlowLayout];
        [_bannerCollection setDelegate:self];
        [_bannerCollection setDataSource:self];
        //隐藏横竖滚动条
        [_bannerCollection setShowsVerticalScrollIndicator:NO];
        [_bannerCollection setShowsHorizontalScrollIndicator:NO];
        //注册cell
        [_bannerCollection registerClass:[LCBannerCell class] forCellWithReuseIdentifier:cellID];
        //Configuration
        [_bannerCollection setPagingEnabled:YES];
    }
    return _bannerCollection;
}

-(void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    [self autoScrollStartAndStop];
}

-(void)setBanners:(NSArray *)banners
{
    [banners enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]] && ![obj isKindOfClass:[UIImage class]]) {
            NSLog(@"Error - Banner类型不是支持的UIImage或NSString");
            return;
        }
        if (idx == banners.count - 1) {
            _banners = banners;
            [self interfaceRefresh];
        }
    }];
}

-(void)setPositionColor:(UIColor *)positionColor
{
    _positionColor = positionColor;
    [self refreshPositionColor];
}

#pragma mark - UI
- (void)interfaceRefresh
{
    _lastCellIndex = _banners.count + 1;
    [_bannerCollection setContentSize:CGSizeMake(CGRectGetWidth(self.frame)*(_lastCellIndex+1), CGRectGetHeight(self.frame))];
    [_bannerCollection reloadData];
    [self createPositionPoint];
    [self scrollToFirstImage:NO];
}

//Position
- (void)createPositionPoint
{
    /*
     * 假设3张图,画起来就是下面这样
     * |-x-x-x-|
     * -代表间隔10,x代表圆点,宽度10
     */
    CGFloat pViewWidth = (_banners.count*2+1) * POSITION_WEIGHT;
    _positionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pViewWidth, POSITION_VIEW_HEIGHT)];
    _positionView.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)-POSITION_VIEW_HEIGHT/2);
    for (int count = 0; count < _banners.count; count++) {
        UIButton *positionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        positionBtn.backgroundColor = _positionColor;
        positionBtn.tag = POSITION_TAG + count;
        [positionBtn addTarget:self action:@selector(positionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_positionView addSubview:positionBtn];
    }
    [self addSubview:_positionView];
}

- (void)positionBtnClick:(UIButton *)sender
{
    [self autoScrollStartAndStop];
    NSInteger index = sender.tag - POSITION_TAG;
    [self scrollToCurrentImage:index andAnimate:YES];
}

- (void)refreshPositionFrameWithSelected:(NSInteger)selected
{
    [_positionView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == selected) {
            //选中的小圆点！放大！
            obj.frame = CGRectMake(POSITION_WEIGHT+POSITION_WEIGHT*idx*2-2, POSITION_WEIGHT/2-2, POSITION_WEIGHT_SELECT, POSITION_WEIGHT_SELECT);
            obj.layer.cornerRadius = POSITION_WEIGHT_SELECT/2;
        } else {
            //其他的小圆点都一样大
            obj.frame = CGRectMake(POSITION_WEIGHT+POSITION_WEIGHT*idx*2, POSITION_WEIGHT/2, POSITION_WEIGHT, POSITION_WEIGHT);
            obj.layer.cornerRadius = POSITION_WEIGHT/2;
        }
    }];
}

- (void)refreshPositionColor
{
    [_positionView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.backgroundColor = _positionColor;
    }];
}

#pragma mark - auto scroll
- (void)autoScrollStartAndStop
{
    [self timerInvalidate];
    if (_autoScroll) {
        _scrollTimer = [NSTimer timerWithTimeInterval:self.interval target:self selector:@selector(autoScrollStart) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_scrollTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)autoScrollStart
{
    if (_currentIndex == _banners.count - 1) {
        [self scrollToFirstImage:YES];
    } else {
        [self scrollToCurrentImage:_currentIndex+1 andAnimate:YES];
    }
}

/** animate:是否需要动画效果 */
- (void)scrollToFirstImage:(BOOL)animate
{
    [_bannerCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animate];
    [self refreshPositionFrameWithSelected:0];
    _currentIndex = 0;
}

- (void)scrollToLastImage:(BOOL)animate
{
    [_bannerCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_lastCellIndex-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animate];
    [self refreshPositionFrameWithSelected:_banners.count-1];
    _currentIndex = _banners.count-1;
}

- (void)scrollToCurrentImage:(NSInteger)index andAnimate:(BOOL)animate
{
    [_bannerCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animate];
    [self refreshPositionFrameWithSelected:index];
    _currentIndex = index;
}

- (void)timerInvalidate
{
    [_scrollTimer invalidate];
    _scrollTimer = nil;
}

#pragma mark - collectionView delegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return _banners.count + 2;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    LCBannerCell *cell = [_bannerCollection dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    NSInteger index = 0;
    if (indexPath.row == 0) {
        index = _banners.count - 1;//最后一个元素下标
    } else if (indexPath.row == _lastCellIndex) {
        index = 0;//第一个元素下标
    } else {
        index = indexPath.row - 1;
    }
    cell.imageObj = _banners[index];
    return cell;
}

//选中item
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != 0 && indexPath.row != _lastCellIndex) {
        if (self.clickBlock) {
            self.clickBlock(indexPath.row-1);
        }
    }
}

#pragma mark - scrollview delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self autoScrollStartAndStop];
    CGPoint cellPoint = [self convertPoint:_bannerCollection.center toView:_bannerCollection];
    NSIndexPath *indexPath = [_bannerCollection indexPathForItemAtPoint:cellPoint];
    if (indexPath.row == 0) {
        //滑到第0个cell就自动跳到倒数第二个cell
        [self scrollToLastImage:NO];
    } else if (indexPath.row == _lastCellIndex) {
        //滑到最后一个cell就自动跳到第二个cell
        [self scrollToFirstImage:NO];
    } else {
        [self refreshPositionFrameWithSelected:indexPath.row-1];
        _currentIndex = indexPath.row-1;
    }
}

//待优化。。
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x <= 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
    } else if (scrollView.contentOffset.x > CGRectGetWidth(self.frame) * _lastCellIndex) {
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.frame) * _lastCellIndex, 0);
    }
}
@end
