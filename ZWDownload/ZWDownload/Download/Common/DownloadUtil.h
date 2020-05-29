//
//  DownloadUtil.h
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/18.
//  Copyright © 2020 ZW. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadUtil : NSObject

// 日期格式转换
+ (NSString *)getFormatedDate:(NSDate *)date;

// 将秒数转换成时分秒形式
+ (NSString *)getFormatedTime:(NSInteger)seconds;

// 主线程执行block
+ (void)executeOnSafeMian:(void(^)(void)) block;

+ (void)executeOnSafeGlobal:(void(^)(void)) block;

// 将字节转化为Kb或者M
+ (NSString*)formatByteCount:(long long)size;
@end

NS_ASSUME_NONNULL_END
