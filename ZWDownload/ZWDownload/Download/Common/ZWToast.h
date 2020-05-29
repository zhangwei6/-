//
//  ZWToast.h
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/19.
//  Copyright © 2020 ZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSInteger containerTag = 111;

@interface ZWToast : NSObject

+ (void)showToast:(NSString *)title;

+ (void)showToast:(NSString *)title time:(NSInteger)time;

+ (void)hiddenToast;

@end

NS_ASSUME_NONNULL_END
