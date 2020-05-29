//
//  ZWDownLoadManager.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/16.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWDownloadManager.h"
#import "ZWDownloadDefine.h"
#import "ZWMultiDownloadModel.h"
#import "ZWFileOperate.h"
#import "ZWDownloadOperate.h"

@interface ZWDownloadManager()<NSURLSessionDelegate>

// 信号量
@property (nonatomic, strong) dispatch_semaphore_t sem;

// 所有任务
@property (nonatomic, strong) NSMutableArray<ZWDownloadModel *> *downLoadQueue;

// 暂停的任务
@property (nonatomic, strong) NSMutableArray<ZWDownloadModel *> *pausedTasks;

// 进行中的任务
@property (nonatomic, strong) NSMutableArray<ZWDownloadModel *> *downLoadingTasks;

// 等待中任务
@property (nonatomic, strong) NSMutableArray<ZWDownloadModel *> *waitingTasks;

@end

@implementation ZWDownloadManager

#pragma mark - Public

+ (ZWDownloadManager *)sharedInstance {
    static ZWDownloadManager  *share = nil;
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        share = [[ZWDownloadManager alloc] init];
        share.maxConcurrentCount = 1;
    });
    return share;
}

#pragma mark - 根据模型下载单个资源
- (void)downLoadWithModel:(ZWDownloadModel *) downloadModel {
    
    // 预下载
    [[ZWDownloadOperate sharedInstance] addDownLoadWithModel:downloadModel preOperate:^{
        
        // 如果是下载单个资源，预下载完成后直接开始下载
        [[ZWDownloadOperate sharedInstance] resumeDownloadWithModel:downloadModel];
        
    } progress:downloadModel.progressBlock state:downloadModel.stateBlock];
}

#pragma mark - 根据模型下载多个资源
- (void)downLoadWithMultiModel:(ZWMultiDownloadModel *) multiDownloadModel
                      progress:(ProgressBlock) progressBlock
                  stateChanged:(StateChangedBlock) stateChangedBlock {
    
    multiDownloadModel.progressBlock = progressBlock;
    multiDownloadModel.stateChangedBlock = stateChangedBlock;
    
    // 设置定时器
    if (multiDownloadModel.isNeedSpeed) {
        multiDownloadModel.updateDownloadedLength = 0;
        [multiDownloadModel initialTimer];
        @weakify(self);
        dispatch_source_set_event_handler(multiDownloadModel.timer, ^{
            @strongify(self);
            [self updateSpeedAndTimeRemainingWithModel:multiDownloadModel];
        });
    }
    
    // 开始预下载操作
    __block NSInteger count = 0;
    
    for (ZWDownloadModel *downloadModel in multiDownloadModel.downloadCellModels) {
        
        count += 1;
        
        // 预下载
        [[ZWDownloadOperate sharedInstance] addDownLoadWithModel:downloadModel preOperate:^{
            
            count -= 1;
            
            if (count == 0) {
                
                // 说明所有的预加载都完成，计算出总的下载资源的大小
                [self calculateTotalLength:multiDownloadModel];
                
                // 开始下载
                [self resumeDownloadWithModel:multiDownloadModel];
            }
            
        } progress: downloadModel.progressBlock state: downloadModel.stateBlock];
    }
    
    [ZWDownloadOperate sharedInstance].progressChangedBlock = ^{
        
        // 遍历获取已经下载的视频大小
        [self updateTotalDownloadedLength:multiDownloadModel];
    };
    
    @weakify(self);
    [ZWDownloadOperate sharedInstance].stateChangedBlock = ^{
        @strongify(self);
        
        multiDownloadModel.stateChangedBlock(multiDownloadModel);
        
        [DownloadUtil executeOnSafeMian:^{
            
            [self operateTimerWithModel:multiDownloadModel];
        }];
        
    };
}

// 开始下载
- (void)resumeDownloadWithModel:(ZWMultiDownloadModel *) multiDownloadModel {
    
    [multiDownloadModel.downloadCellModels enumerateObjectsUsingBlock:^(ZWDownloadCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[ZWDownloadOperate sharedInstance] resumeDownloadWithModel:obj];
    }];
    
    if (multiDownloadModel.isNeedSpeed) {
        [multiDownloadModel resumeTimerWithFirstTime:true];
    }
}

// 查询所有子任务状态
- (void)operateTimerWithModel:(ZWMultiDownloadModel *) multiDownloadModel {
    
    __block NSInteger completedCount = 0;
    __block NSInteger errorCount = 0;
    __block NSInteger cancelCount = 0;
    __block NSInteger downloadingCount = 0;
    
    [multiDownloadModel.downloadCellModels enumerateObjectsUsingBlock:^(ZWDownloadCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.state == ZWDownloadStateComplete) {
            completedCount += 1;
        }

        if (obj.state == ZWDownloadStateError) {
            errorCount += 1;
        }

        if (obj.state == ZWDownloadStateCancel) {
            cancelCount += 1;
        }
        
        if (obj.state == ZWDownloadStateDownloading) {
            downloadingCount += 1;
        }
    }];
    
    if (downloadingCount == 0) {
        
        // 下载中的任务都没有了，那么暂停定时器
        [multiDownloadModel suspendTimer];
        
    } else if(multiDownloadModel.isTimerSuspend) {
        
        // 否则开启定时器
        [multiDownloadModel resumeTimerWithFirstTime:false];
    }
    
//    if ((completedCount + errorCount + cancelCount) == multiDownloadModel.downloadCellModels.count) {
//        
//        NSLog(@"重置定时器");
//        [multiDownloadModel cancelTimer];
//    }
}

// 计算下载速度与剩余时间
- (void)updateSpeedAndTimeRemainingWithModel:(ZWMultiDownloadModel *) multiDownloadModel {
    
    // 获取当前已下载文件大小
    __block NSInteger currFileLength = 0;
    
    [multiDownloadModel.downloadCellModels enumerateObjectsUsingBlock:^(ZWDownloadCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        currFileLength += [[ZWFileOperate shared] getDownloadedLengthWithUrl:obj.url];
    }];
    
    NSInteger preFileLength = multiDownloadModel.updateDownloadedLength;

    // 每秒下载的当前文件的大小
    NSInteger deltaLength = currFileLength - preFileLength;

    if (deltaLength == 0) {

        multiDownloadModel.downloadSpeed = @"0Kb/s";
        multiDownloadModel.timeRemaining = @"-";

    } else {

        // 下载速度
        multiDownloadModel.downloadSpeed = [NSString stringWithFormat:@"%@/s", [DownloadUtil formatByteCount:deltaLength]];

        // 剩余时间
        multiDownloadModel.timeRemaining = [DownloadUtil getFormatedTime:(multiDownloadModel.totalLength - currFileLength) / deltaLength];

        multiDownloadModel.updateDownloadedLength = currFileLength;
    }
    
    if (currFileLength == multiDownloadModel.totalLength) {
        multiDownloadModel.downloadSpeed = @"-";
    }
}

// 遍历获取已经下载的视频大小
- (void)updateTotalDownloadedLength:(ZWMultiDownloadModel *) multiDownloadModel {
    
    long long totalDownloadedLength = 0;
    
    for (ZWDownloadModel *downloadModel in multiDownloadModel.downloadCellModels) {
        
        totalDownloadedLength += downloadModel.downloadedLength;
    }
    
    multiDownloadModel.downloadedLength = totalDownloadedLength;
    
    CGFloat progress = (CGFloat) totalDownloadedLength / multiDownloadModel.totalLength;
    
    multiDownloadModel.progressBlock(progress, multiDownloadModel.downloadedLength, multiDownloadModel.totalLength);
}

// 计算出所有下载资源大小总和
- (void)calculateTotalLength:(ZWMultiDownloadModel *) multiDownloadModel {
    
    __block long long totalLength = 0;
    
    [multiDownloadModel.downloadCellModels enumerateObjectsUsingBlock:^(ZWDownloadCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.state == ZWDownloadStateSuspend) {
            totalLength += obj.totalLength;
        }
    }];
    
    multiDownloadModel.totalLength = totalLength;
}

#pragma mark - 多任务操作
// 全部开始
- (void)resumeAllTaskWithModel:(ZWMultiDownloadModel *) multiDownloadModel {
    
    [multiDownloadModel.downloadCellModels enumerateObjectsUsingBlock:^(ZWDownloadCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.state == ZWDownloadStateSuspend) {
            
            [[ZWDownloadOperate sharedInstance] resumeDownloadWithModel:obj];
        }
    }];
}

// 全部暂停
- (void)pauseAllTaskWithModel:(ZWMultiDownloadModel *) multiDownloadModel {
    
    [multiDownloadModel.downloadCellModels enumerateObjectsUsingBlock:^(ZWDownloadCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.state == ZWDownloadStateDownloading) {
            
            [[ZWDownloadOperate sharedInstance] pauseDownloadWithModel:obj];
        }
    }];
}

// 全部删除
- (void)deleteAllTaskWithModel:(ZWMultiDownloadModel *) multiDownloadModel {
    
    [multiDownloadModel.downloadCellModels enumerateObjectsUsingBlock:^(ZWDownloadCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[ZWDownloadOperate sharedInstance] deleteDownloadWithModel:obj];
    }];
    
    [multiDownloadModel reset];
}

// 全部取消
- (void)cancelAllTaskWithModel:(ZWMultiDownloadModel *) multiDownloadModel {
    
    [multiDownloadModel.downloadCellModels enumerateObjectsUsingBlock:^(ZWDownloadCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[ZWDownloadOperate sharedInstance] cancelDownloadWithModel:obj];
    }];
    
    [multiDownloadModel reset];
}

// 清空缓存
- (void)clearCache {
    
    [[ZWFileOperate shared] clearCache];    
}

#pragma mark - 懒加载
- (NSMutableArray <ZWDownloadModel *>*)downLoadQueue{
    if (!_downLoadQueue) {
        _downLoadQueue = [NSMutableArray new];
    }
    return _downLoadQueue;
}

- (NSMutableArray<ZWDownloadModel *> *)pausedTasks{
    if (!_pausedTasks) {
        _pausedTasks = [NSMutableArray new];
    }
    return _pausedTasks;
}

- (NSMutableArray<ZWDownloadModel *> *)downLoadingTasks{
    if (!_downLoadingTasks) {
        _downLoadingTasks = [NSMutableArray new];
    }
    return _downLoadingTasks;
}

-(NSMutableArray<ZWDownloadModel *> *)waitingTasks{
    if (!_waitingTasks) {
        _waitingTasks = [NSMutableArray new];
    }
    return _waitingTasks;
}
@end
