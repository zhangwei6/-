//
//  ZWMultiDownloadViewModel.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/18.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWMultiDownloadViewModel.h"
#import "ZWDownloadOperate.h"
#import "DownloadUtil.h"
#import "ZWToast.h"
#import "ZWDownloadManager.h"

@implementation ZWMultiDownloadViewModel

+ (instancetype)init: (id<ArtDownloadViewModelProtocol>)delegate {
    
    ZWMultiDownloadViewModel *viewModel = [ZWMultiDownloadViewModel new];
    
    viewModel.downloadViewModelDelegate = delegate;
    
    return viewModel;
}

// 初始化下载模型
- (void)getMultiDownloadModel {
    
    ZWMultiDownloadModel *multiDownloadModel = [ZWMultiDownloadModel new];
    
    multiDownloadModel.downloadCellModels = [NSMutableArray array];
    
    self.multiDownloadModel = multiDownloadModel;
}

- (void)addNewTask {
    
    NSString *url1 = @"https://cdnvip.meishubao.com/videowbimage/2020-04/25/8037de81b67fc4e151f0cc94e8a15f80.mp4";
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.multiDownloadModel.downloadCellModels addObject:[self getDownloadCellModelWithUrl:url1 indexPath:indexPath1]];
    
    NSString *url2 = @"https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg";
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.multiDownloadModel.downloadCellModels addObject:[self getDownloadCellModelWithUrl:url2 indexPath:indexPath2]];
    
    // 设置多任务下载需要显示下载速度
    self.multiDownloadModel.isNeedSpeed = true;
    
    [self.downloadViewModelDelegate reloadWithIndexPath:nil];
    
    [[ZWDownloadManager sharedInstance] downLoadWithMultiModel:self.multiDownloadModel progress:^(CGFloat progress, long long downloadedlength, long long totalLength) {
        
        // 更新总的任务大小进度
        [self.downloadViewModelDelegate totalDownloadLengthChanged:self.multiDownloadModel];
        
    } stateChanged:^(ZWMultiDownloadModel * _Nonnull multiDownloadModel) {
        
        // 下载完成，改变总的下载个数进度
        [self.downloadViewModelDelegate downloadCountChanged:multiDownloadModel];
    }];
}

- (void)deleteChooseTask {
    
    @weakify(self);
    [self.multiDownloadModel.downloadCellModels enumerateObjectsUsingBlock:^(ZWDownloadCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        
        if (obj.isChoosed) {
            
            [[ZWDownloadOperate sharedInstance] deleteDownloadWithModel:obj];
            [self.multiDownloadModel.downloadCellModels removeObject:obj];
            [self.downloadViewModelDelegate reloadWithIndexPath:nil];
            *stop = true;
        }
        
        if (idx == (self.multiDownloadModel.downloadCellModels.count - 1)) {
            [ZWToast showToast:@"请选择需要删除的cell"];
        }
    }];
}

// 清空缓存
- (void)clearCache {
    [[ZWDownloadManager sharedInstance] clearCache];
}

// 全部开始
- (void)resumeAllTask {
    [[ZWDownloadManager sharedInstance] resumeAllTaskWithModel:self.multiDownloadModel];
}

// 全部暂停
- (void)pauseAllTask {
    [[ZWDownloadManager sharedInstance] pauseAllTaskWithModel:self.multiDownloadModel];
}

// 全部删除
- (void)deleteAllTask {
    [[ZWDownloadManager sharedInstance] deleteAllTaskWithModel:self.multiDownloadModel];
    [self.downloadViewModelDelegate reloadWithIndexPath:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 更新总的任务大小进度
        [self.downloadViewModelDelegate totalDownloadLengthChanged:self.multiDownloadModel];
        
        // 下载完成，改变总的下载个数进度
        [self.downloadViewModelDelegate downloadCountChanged:self.multiDownloadModel];
    });
}

// 全部取消
- (void)cancelAllTask {
    [[ZWDownloadManager sharedInstance] cancelAllTaskWithModel:self.multiDownloadModel];
    [self.downloadViewModelDelegate reloadWithIndexPath:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 更新总的任务大小进度
        [self.downloadViewModelDelegate totalDownloadLengthChanged:self.multiDownloadModel];
        
        // 下载完成，改变总的下载个数进度
        [self.downloadViewModelDelegate downloadCountChanged:self.multiDownloadModel];
    });
}

- (ZWDownloadCellModel *)getDownloadCellModelWithUrl:(NSString *)url indexPath:(NSIndexPath *)indexPath {
    
    ZWDownloadCellModel *downloadCellModel = [[ZWDownloadCellModel alloc] init];
    
    downloadCellModel.url = url;
    downloadCellModel.taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
    downloadCellModel.state = ZWDownloadStateWaiting;
    downloadCellModel.isNeedSpeed = true;
    downloadCellModel.isChoosed = false;
    downloadCellModel.indexPath = indexPath;
    
    @weakify(downloadCellModel);
    @weakify(self);
    downloadCellModel.tapControlBtnAction = ^(ZWDownloadCellModel * _Nonnull currModel) {
        @strongify(self);
        
        switch (currModel.state) {
                
            case ZWDownloadStateDownloading:
                {
                    // 下载中，点击暂停下载
                    [[ZWDownloadOperate sharedInstance] pauseDownloadWithModel:currModel];
                    [self.downloadViewModelDelegate reloadWithIndexPath:currModel.indexPath];
                }
                break;
                
            case ZWDownloadStateComplete:
                [ZWToast showToast:@"该资源已下载完成"];
                break;
                
            case ZWDownloadStateSuspend:
                {
                    // 暂停下载，点击继续下载
                    [[ZWDownloadOperate sharedInstance] resumeDownloadWithModel:currModel];
                    [self.downloadViewModelDelegate reloadWithIndexPath:currModel.indexPath];
                }
                break;
                
            default:
                {
                    // 等待下载中、下载错误、取消下载，点击都重新开始下载
                    [[ZWDownloadManager sharedInstance] downLoadWithModel:currModel];
                }
                break;
        }
    };
    
    downloadCellModel.progressBlock = ^(CGFloat progress, long long downloadedlength, long long totalLength) {
        @strongify(downloadCellModel);
        @strongify(self);
        
        [self.downloadViewModelDelegate reloadWithIndexPath:downloadCellModel.indexPath];
    };
    
    downloadCellModel.stateBlock = ^(ZWDownloadState state, NSError * _Nullable error) {
        @strongify(downloadCellModel);
        @strongify(self);
        
        if (state == ZWDownloadStateComplete) {
            [self.downloadViewModelDelegate reloadWithIndexPath:downloadCellModel.indexPath];
        }
    };
    
    return downloadCellModel;
}

@end
