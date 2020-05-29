//
//  ZWToast.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/19.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWToast.h"
#import <AVFoundation/AVFoundation.h>

@implementation ZWToast

+ (void)showToast:(NSString *)title {
    
    [self showToast:title time:1];
}

+ (void)showToast:(NSString *)title time:(NSInteger)time {
    
    [self hiddenToast];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.backgroundColor = UIColor.greenColor;
    if (!window) { return; }

    // 全屏view
    UIView *containerView = [UIView new];
    containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    containerView.frame = [UIScreen mainScreen].bounds;
    containerView.tag = containerTag;     // 这里添加tag是为了手动删除toast
    [window addSubview:containerView];
    [window bringSubviewToFront:containerView];

    // 提示内容的容器view
    UIView *subContainerView = [UIView new];
    [containerView addSubview:subContainerView];
    subContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    subContainerView.layer.cornerRadius = 5;
    
    CGFloat subContainerViewW = 210;
    CGFloat subContainerViewH = 40;
    CGFloat subContainerViewX = ([UIScreen mainScreen].bounds.size.width - subContainerViewW) / 2;
    CGFloat subContainerViewY = ([UIScreen mainScreen].bounds.size.height - subContainerViewH) / 2;
    subContainerView.frame = CGRectMake(subContainerViewX, subContainerViewY, subContainerViewW, subContainerViewH);

    UILabel *titleLabel = [UILabel new];
    [subContainerView addSubview:titleLabel];
    titleLabel.text = title;
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.frame = CGRectMake(10, 10, subContainerViewW - (2 * 10), 20);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [containerView removeFromSuperview];
    });
}

/// 手动删除toast
+ (void)hiddenToast {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (!window) { return; }
    
    for (UIView *view in window.subviews) {
        
        if (view.tag == containerTag) {
            
            [view removeFromSuperview];
        }
    }
}

@end
