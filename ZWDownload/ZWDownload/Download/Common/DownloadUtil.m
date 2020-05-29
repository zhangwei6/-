//
//  DownloadUtil.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/18.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "DownloadUtil.h"

@implementation DownloadUtil

// 日期格式转换
+ (NSString *)getFormatedDate:(NSDate *)date {
    
    if (!date) { return @"-"; }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormatter stringFromDate:date];
}

// 将秒数转换成时分秒形式
+ (NSString *)getFormatedTime:(NSInteger)seconds {
    
    if (seconds >= 3600) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",seconds/3600, (seconds%3600)/60, seconds%60];
    }

    return [NSString stringWithFormat:@"%02ld:%02ld",seconds/60, seconds%60];
//    if (seconds >= 60) {
//        return [NSString stringWithFormat:@"%02ld:%02ld",seconds/60, seconds%60];
//    }
//
//    return [NSString stringWithFormat:@"%ld s",seconds%60];
}

// 主线程执行block
+ (void)executeOnSafeMian:(void(^)(void)) block {
    
    if([[NSThread currentThread] isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

+ (void)executeOnSafeGlobal:(void(^)(void)) block {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        block();
    });
}

// 将字节转化为Kb或者M
+ (NSString*)formatByteCount:(long long)size {
    
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

@end
