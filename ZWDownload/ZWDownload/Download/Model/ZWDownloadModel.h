//
//  ZWDownloadModel.h
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/16.
//  Copyright © 2020 ZW. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZWDownloadState) {
    ZWDownloadStateWaiting,      // 等待下载
    ZWDownloadStateDownloading,  // 下载中
    ZWDownloadStateComplete,     // 完成
    ZWDownloadStateError,        // 错误
    ZWDownloadStateSuspend,      // 暂停
    ZWDownloadStateCancel        // 取消
};

typedef void(^PreOperateBlock)(void);
typedef void(^ProgressBlock)(CGFloat progress, long long downloadedlength, long long totalLength);
typedef void(^StateBlock)(ZWDownloadState state, NSError * _Nullable error);


@interface ZWDownloadModel : NSObject

// 下载地址
@property(nonatomic, copy) NSString *url;

// 本地保存名称
@property(nonatomic, copy) NSString *fileName;

// 本地路径
@property(nonatomic, copy) NSString *filePath;

// 开始下载时间
@property(nonatomic, strong) NSDate * _Nullable startDate;

// 结束下载时间
@property(nonatomic, strong) NSDate * _Nullable endDate;

// 当前资源总大小
@property (nonatomic, assign) long long totalLength;

// 已下载大小
@property (nonatomic, assign) long long downloadedLength;

// 对应的任务
@property (nonatomic, strong) NSURLSessionDataTask * _Nullable task;

// taskIdentifier
@property (nonatomic, assign) NSUInteger taskIdentifier;

// 输出流
@property (nonatomic, strong) NSOutputStream * _Nullable stream;

// 当前状态
@property (nonatomic, assign) ZWDownloadState state;

// 下载进度回调
@property (nonatomic, copy) PreOperateBlock _Nullable preOperateBlock;

// 下载进度回调
@property (nonatomic, copy) ProgressBlock _Nullable progressBlock;

// 下载状态回调
@property (nonatomic, copy) StateBlock _Nullable stateBlock;

/* 用于计算下载速度与剩余下载时间相关属性 */
// 是否需要下载速度，计算下载速度需要定时器，默认不需要（非通用属性，根据自己需要设置）
@property(nonatomic, assign) BOOL isNeedSpeed;

// 定时器，用来计算下载速度和剩余时间
@property (nonatomic, strong) dispatch_source_t _Nullable timer;

// 判断当前定时器是否处于挂起状态
@property (nonatomic, assign) BOOL isTimerSuspend;

// 上次更新已下载大小（非通用属性，根据自己需要设置）
@property(nonatomic, assign) long long updateDownloadedLength;

// 下载速度（非通用属性，根据自己需要设置）
@property (nonatomic, copy) NSString *downloadSpeed;

// 预计剩余时间（非通用属性，根据自己需要设置）
@property (nonatomic, copy) NSString *timeRemaining;

// 取消下载
- (void)cancel;

// 初始化定时器
- (void)initialTimer;

// 开始定时
- (void)resumeTimerWithFirstTime: (BOOL)isFirstTime;

// 暂停定时
- (void)suspendTimer;

// 取消定时
- (void)cancelTimer;

@end

NS_ASSUME_NONNULL_END
