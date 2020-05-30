//
//  ZWMultiDownloadController+UI.h
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/18.
//  Copyright © 2020 ZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWMultiDownloadController.h"

@interface ZWMultiDownloadController (UI)

- (void)configSubview;

@end


@interface ZWMultiDownloadController()

// 总的任务进度(按照任务的下载完成个数计算进度)
@property(nonatomic, strong) UILabel *totalTaskCountProgressLab;

// 总的任务进度(按照总的任务的大小计算进度)
@property(nonatomic, strong) UILabel *totalTaskLengthProgressLab;

// 下载速度
@property(nonatomic, strong) UILabel *downloadSpeedsLab;

// 预计剩余时间
@property(nonatomic, strong) UILabel *timeRemainingLab;

// 全部开始
@property(nonatomic, strong) UIButton *startAllBtn;

// 全部删除
@property(nonatomic, strong) UIButton *deleteAllBtn;

// 全部暂停
@property(nonatomic, strong) UIButton *pauseAllBtn;

// 全部取消
@property(nonatomic, strong) UIButton *cancelAllBtn;

// 添加下载(单个)
@property(nonatomic, strong) UIButton *addTaskBtn;

// 删除下载
@property(nonatomic, strong) UIButton *deleteTaskBtn;

// 添加下载(多个)
@property(nonatomic, strong) UIButton *addTasksBtn;

// 清空缓存
@property(nonatomic, strong) UIButton *clearCacheBtn;

// 下载并发数标题
@property(nonatomic, strong) UILabel *downloadAsyncTitleLabel;

// 下载并发数个数
@property(nonatomic, strong) UITextField *downloadAsyncCountTF;

// 是否启用设置的下载并发数
@property(nonatomic, strong) UISwitch *downloadAsyncSwitch;

@property(nonatomic, strong) UITableView *tableView;

@end
