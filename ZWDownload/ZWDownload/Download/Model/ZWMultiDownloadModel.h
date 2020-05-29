//
//  ZWMultiDownloadModel.h
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/18.
//  Copyright © 2020 ZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWDownloadCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ZWMultiDownloadModel;

typedef void(^ProgressBlock)(CGFloat progress, long long downloadedlength, long long totalLength);
typedef void(^StateChangedBlock)(ZWMultiDownloadModel *multiDownloadModel);

@interface ZWMultiDownloadModel : NSObject

// 当前下载的模型
@property (nonatomic, strong)NSMutableArray<ZWDownloadCellModel *> *downloadCellModels;

// 所有已下载的长度
@property (nonatomic, assign) long long downloadedLength;

// 所有视频总长度
@property (nonatomic, assign) long long totalLength;

// 下载进度回调
@property (nonatomic, copy) ProgressBlock _Nullable progressBlock;

// 下载状态回调
@property (nonatomic, copy) StateChangedBlock _Nullable stateChangedBlock;

/* 用于计算总的下载速度与剩余下载时间相关属性 */
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

// 获取定时器
- (void)initialTimer;

// 开始定时
- (void)resumeTimerWithFirstTime: (BOOL)isFirstTime;

// 暂停定时
- (void)suspendTimer;

// 取消定时
- (void)cancelTimer;

// reset
- (void)reset;

@end

NS_ASSUME_NONNULL_END
