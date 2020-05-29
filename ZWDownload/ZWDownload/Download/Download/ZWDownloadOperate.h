//
//  ZWDownloadOperate.h
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/18.
//  Copyright © 2020 ZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWDownloadModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ProgressChangeBlock)(void);
typedef void(^StateChangeBlock)(void);

@interface ZWDownloadOperate : NSObject

// 进度改变的时候回调，用于辅助更新多任务下载的总进度
@property (nonatomic, copy) ProgressChangeBlock progressChangedBlock;

// 状态改变的时候回调，用于辅助更新多任务下载的状态
@property (nonatomic, copy) StateChangeBlock stateChangedBlock;

// 单例
+ (instancetype)sharedInstance;

// 添加下载
- (void)addDownLoadWithModel:(ZWDownloadModel *) model
                  preOperate:(void(^)(void)) preOperateBlock
                    progress:(ProgressBlock) progressBlock
                       state:(void (^)(ZWDownloadState, NSError * _Nullable))stateBlock;

// 暂停下载
- (void)pauseDownloadWithModel:(ZWDownloadModel *)model;

// 恢复下载
- (void)resumeDownloadWithModel:(ZWDownloadModel *)model;

// 删除下载
- (void)deleteDownloadWithModel:(ZWDownloadModel *)model;

// 取消下载
- (void)cancelDownloadWithModel:(ZWDownloadModel *)model;

@end

NS_ASSUME_NONNULL_END
