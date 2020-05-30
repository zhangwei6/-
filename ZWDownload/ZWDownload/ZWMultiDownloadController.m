//
//  ZWMultiDownloadController.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/15.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWMultiDownloadController.h"
#import "ZWDownloadTaskCell.h"
#import "ZWDownloadManager.h"
#import "ZWMultiDownloadModel.h"
#import "ZWMultiDownloadController+UI.h"
#import "ZWMultiDownloadViewModel.h"
#import "DownloadUtil.h"

@interface ZWMultiDownloadController ()<UITableViewDelegate, UITableViewDataSource, ArtDownloadViewModelProtocol>

@property(nonatomic, strong) ZWMultiDownloadViewModel *viewModel;

@property(nonatomic, strong) ZWDownloadManager *downloadManager;

@end

@implementation ZWMultiDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [ZWMultiDownloadViewModel init:self];
    
    self.title = @"多任务下载";
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self configSubview];
    [self configValue];
    
    NSInteger randomValue = arc4random_uniform(3);
    NSLog(@"1");
}

- (void)configValue {
    
    // 添加事件
    [self.addTaskBtn addTarget:self action:@selector(addTaskAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.addTasksBtn addTarget:self action:@selector(addTasksAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteTaskBtn addTarget:self action:@selector(deleteTaskAction) forControlEvents:UIControlEventTouchUpInside];
    [self.startAllBtn addTarget:self action:@selector(resumeAllTaskAction) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseAllBtn addTarget:self action:@selector(pauseAllTaskAction) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteAllBtn addTarget:self action:@selector(deleteAllTaskAction) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelAllBtn addTarget:self action:@selector(cancelAllTaskAction) forControlEvents:UIControlEventTouchUpInside];
    [self.clearCacheBtn addTarget:self action:@selector(clearCacheAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.viewModel getMultiDownloadModel];
}

// 添加新的下载任务（单个）
- (void)addTaskAction: (UIButton *)btn {
    [self.viewModel addNewTask];
}

// 添加新的下载任务（多个）
- (void)addTasksAction: (UIButton *)btn {
    [self.viewModel addNewTasks];
}

// 删除选中下载任务
- (void)deleteTaskAction {
    [self.viewModel deleteChooseTask];
}

// 删除选中下载任务
- (void)clearCacheAction {
    [self.viewModel clearCache];
}

// 全部开始
- (void)resumeAllTaskAction {
    [self.viewModel resumeAllTask];
}

// 全部暂停
- (void)pauseAllTaskAction {
    [self.viewModel pauseAllTask];
}

// 全部删除
- (void)deleteAllTaskAction {
    [self.viewModel deleteAllTask];
}

// 全部取消
- (void)cancelAllTaskAction {
    [self.viewModel cancelAllTask];
}

#pragma mark - viewModel代理
// 刷新指定索引，当 indexPath == nil 时，直接reloadData
- (void)reloadWithIndexPath: (NSIndexPath * _Nullable)indexPath {
    
    @weakify(self);
    [DownloadUtil executeOnSafeMian:^{
        @strongify(self);
        
        if (indexPath) {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [self.tableView reloadData];
        }
    }];
}

// 总任务大小发生改变
- (void)totalDownloadLengthChanged:(ZWMultiDownloadModel *) multiDownloadModel {
    
    @weakify(self);
    [DownloadUtil executeOnSafeMian:^{
        @strongify(self);
        
        NSString *downloadedLength = multiDownloadModel.downloadedLength ? [DownloadUtil formatByteCount:multiDownloadModel.downloadedLength] : @"-";
        NSString *totalLength = multiDownloadModel.totalLength ? [DownloadUtil formatByteCount:multiDownloadModel.totalLength] : @"-";
        
        self.totalTaskLengthProgressLab.text = [NSString stringWithFormat:@"任务大小进度: %@/%@", downloadedLength, totalLength];
        self.timeRemainingLab.text = [NSString stringWithFormat:@"预计剩余时间: %@", multiDownloadModel.timeRemaining];
        self.downloadSpeedsLab.text = [NSString stringWithFormat:@"下载速度: %@", multiDownloadModel.downloadSpeed];
    }];
}

// 总任务个数发生改变
- (void)downloadCountChanged:(ZWMultiDownloadModel *) multiDownloadModel {
    
    NSInteger totalTask = multiDownloadModel.downloadCellModels.count;
    __block NSInteger completedTask = 0;
    
    [multiDownloadModel.downloadCellModels enumerateObjectsUsingBlock:^(ZWDownloadCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.state == ZWDownloadStateComplete) {
            completedTask += 1;
        }
    }];
    
    @weakify(self);
    [DownloadUtil executeOnSafeMian:^{
        @strongify(self);
        if (totalTask == 0) {
            self.totalTaskCountProgressLab.text = @"任务个数进度: -";
        } else {
            self.totalTaskCountProgressLab.text = [NSString stringWithFormat:@"任务个数进度: %ld/%ld", completedTask, totalTask];
        }
    }];
}

#pragma mark - tableview代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.viewModel.flag == 1) {
        return self.viewModel.downloadModels.count;
    } else {
        return self.viewModel.multiDownloadModel.downloadCellModels.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZWDownloadTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:downloadTaskCellIdentifier forIndexPath:indexPath];
    
    if (self.viewModel.flag == 1) {
        
        ZWDownloadCellModel *downloadModel = (ZWDownloadCellModel *)self.viewModel.downloadModels[indexPath.row];
        downloadModel.indexPath = indexPath;
        
        cell.downloadCellModel = downloadModel;
        
    } else {
        
        ZWDownloadCellModel *downloadModel = self.viewModel.multiDownloadModel.downloadCellModels[indexPath.row];
        downloadModel.indexPath = indexPath;
        
        cell.downloadCellModel = downloadModel;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.viewModel.flag == 1) {
        
        ZWDownloadCellModel *downloadModel = (ZWDownloadCellModel *)self.viewModel.downloadModels[indexPath.row];
        downloadModel.isChoosed = true;
        
    } else {
        
        ZWDownloadCellModel *downloadModel = self.viewModel.multiDownloadModel.downloadCellModels[indexPath.row];
        downloadModel.isChoosed = true;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.viewModel.flag == 1) {
        
        ZWDownloadCellModel *downloadModel = (ZWDownloadCellModel *)self.viewModel.downloadModels[indexPath.row];
        downloadModel.isChoosed = false;
        
    } else {
        
        ZWDownloadCellModel *downloadModel = self.viewModel.multiDownloadModel.downloadCellModels[indexPath.row];
        downloadModel.isChoosed = false;
    }
}

@end
