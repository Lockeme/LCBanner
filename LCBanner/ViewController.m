//
//  ViewController.m
//  LCBanner
//
//  Created by Lockeme on 2017/12/30.
//  Copyright © 2017年 Lockeme. All rights reserved.
//

#import "ViewController.h"
#import "LCBannerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self initBannerView];
}

- (void)initBannerView
{
    LCBannerView *banner = [[LCBannerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    banner.center = self.view.center;
    banner.banners = @[@"banner0",
                       @"banner1",
                       [UIImage imageNamed:@"banner2"],
                       [NSURL URLWithString:@"https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png"]];
    banner.positionColor = [UIColor redColor];
    banner.clickBlock = ^(NSInteger idx) {
        NSLog(@"%ld", (long)idx);
    };
    [self.view addSubview:banner];
}
@end
