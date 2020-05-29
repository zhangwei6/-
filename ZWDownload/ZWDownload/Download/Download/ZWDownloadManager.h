//
//  ZWDownLoadManager.h
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/16.
//  Copyright © 2020 ZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWDownloadModel.h"
#import "ZWMultiDownloadModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWDownloadManager : NSObject

//最大的并发数量 (默认是:1)
@property (nonatomic,assign) NSUInteger maxConcurrentCount;

+ (ZWDownloadManager *)sharedInstance;

// 根据模型下载多个资源
- (void)downLoadWithMultiModel:(ZWMultiDownloadModel *) multiDownloadModel
                      progress:(ProgressBlock) progressBlock
                  stateChanged:(StateChangedBlock) stateChangedBlock;

// 根据模型下载单个资源
- (void)downLoadWithModel:(ZWDownloadModel *) downloadModel;

// 全部开始
- (void)resumeAllTaskWithModel:(ZWMultiDownloadModel *) multiDownloadModel;

// 全部暂停
- (void)pauseAllTaskWithModel:(ZWMultiDownloadModel *) multiDownloadModel;

// 全部删除
- (void)deleteAllTaskWithModel:(ZWMultiDownloadModel *) multiDownloadModel;

// 全部取消
- (void)cancelAllTaskWithModel:(ZWMultiDownloadModel *) multiDownloadModel;

// 清空缓存
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
