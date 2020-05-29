//
//  ZWMultiDownloadController+UI.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/18.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWMultiDownloadController+UI.h"
#import <Masonry/Masonry.h>
#import "ZWDownloadTaskCell.h"

@implementation ZWMultiDownloadController (UI)

- (void)configSubview {
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.tableView registerClass:ZWDownloadTaskCell.class forCellReuseIdentifier:downloadTaskCellIdentifier];
    self.tableView.rowHeight = 130;
    
    self.totalTaskCountProgressLab = [[UILabel alloc] init];
    self.totalTaskCountProgressLab.text = @"任务个数进度: -/-";
    self.totalTaskCountProgressLab.font = [UIFont systemFontOfSize:14];
    
    self.totalTaskLengthProgressLab = [[UILabel alloc] init];
    self.totalTaskLengthProgressLab.text = @"任务大小进度: -/-";
    self.totalTaskLengthProgressLab.font = [UIFont systemFontOfSize:14];
    
    self.downloadSpeedsLab = [[UILabel alloc] init];
    self.downloadSpeedsLab.text = @"下载速度: -";
    self.downloadSpeedsLab.font = [UIFont systemFontOfSize:14];
    
    self.timeRemainingLab = [[UILabel alloc] init];
    self.timeRemainingLab.text = @"预计剩余时间: -";
    self.timeRemainingLab.font = [UIFont systemFontOfSize:14];
    
    self.startAllBtn = [[UIButton alloc] init];
    [self.startAllBtn setTitle:@"全部开始" forState:UIControlStateNormal];
    self.startAllBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.startAllBtn setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    
    self.deleteAllBtn = [[UIButton alloc] init];
    [self.deleteAllBtn setTitle:@"全部删除" forState:UIControlStateNormal];
    self.deleteAllBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.deleteAllBtn setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    
    self.pauseAllBtn = [[UIButton alloc] init];
    [self.pauseAllBtn setTitle:@"全部暂停" forState:UIControlStateNormal];
    self.pauseAllBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.pauseAllBtn setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    
    self.cancelAllBtn = [[UIButton alloc] init];
    [self.cancelAllBtn setTitle:@"全部取消" forState:UIControlStateNormal];
    self.cancelAllBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.cancelAllBtn setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    
    self.addTaskBtn = [[UIButton alloc] init];
    [self.addTaskBtn setTitle:@"添加下载" forState:UIControlStateNormal];
    self.addTaskBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.addTaskBtn setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    
    self.deleteTaskBtn = [[UIButton alloc] init];
    [self.deleteTaskBtn setTitle:@"删除下载" forState:UIControlStateNormal];
    self.deleteTaskBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.deleteTaskBtn setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    
    self.clearCacheBtn = [[UIButton alloc] init];
    [self.clearCacheBtn setTitle:@"清空缓存" forState:UIControlStateNormal];
    self.clearCacheBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.clearCacheBtn setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    
    self.sortBtn = [[UIButton alloc] init];
    [self.sortBtn setTitle:@"开始时间排序" forState:UIControlStateNormal];
    self.sortBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.sortBtn setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    
    self.downloadAsyncTitleLabel = [UILabel new];
    self.downloadAsyncTitleLabel.text = @"下载并发数:";
    self.downloadAsyncTitleLabel.font = [UIFont systemFontOfSize:14];
    
    self.downloadAsyncCountTF = [UITextField new];
    self.downloadAsyncCountTF.font = [UIFont systemFontOfSize:14];
    self.downloadAsyncCountTF.borderStyle = UITextBorderStyleRoundedRect;
    
    self.downloadAsyncSwitch = [[UISwitch alloc] init];
    self.downloadAsyncSwitch.on = false;
    
    [self.view addSubview:self.totalTaskCountProgressLab];
    [self.view addSubview:self.totalTaskLengthProgressLab];
    [self.view addSubview:self.downloadSpeedsLab];
    [self.view addSubview:self.timeRemainingLab];
    [self.view addSubview:self.startAllBtn];
    [self.view addSubview:self.deleteAllBtn];
    [self.view addSubview:self.pauseAllBtn];
    [self.view addSubview:self.cancelAllBtn];
    [self.view addSubview:self.addTaskBtn];
    [self.view addSubview:self.deleteTaskBtn];
    [self.view addSubview:self.clearCacheBtn];
    [self.view addSubview:self.sortBtn];
    [self.view addSubview:self.downloadAsyncTitleLabel];
    [self.view addSubview:self.downloadAsyncCountTF];
    [self.view addSubview:self.downloadAsyncSwitch];
    [self.view addSubview:self.tableView];
    
    [self.totalTaskCountProgressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(10);
        make.top.mas_equalTo(self.view).mas_offset(80);
    }];
    
    [self.totalTaskLengthProgressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).mas_offset(-10);
        make.top.mas_equalTo(self.view).mas_offset(80);
    }];
    
    [self.downloadSpeedsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.totalTaskCountProgressLab);
        make.top.mas_equalTo(self.totalTaskCountProgressLab.mas_bottom).mas_offset(10);
    }];
    
    [self.timeRemainingLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.totalTaskLengthProgressLab);
        make.top.mas_equalTo(self.totalTaskLengthProgressLab.mas_bottom).mas_offset(10);
    }];
    
    [self.startAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.downloadSpeedsLab);
        make.top.mas_equalTo(self.downloadSpeedsLab.mas_bottom).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(70, 30));
    }];
    
    [self.deleteAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.startAllBtn.mas_right).mas_offset(20);
        make.top.mas_equalTo(self.startAllBtn);
        make.size.mas_equalTo(CGSizeMake(70, 30));
    }];
    
    [self.pauseAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.startAllBtn);
        make.top.mas_equalTo(self.startAllBtn.mas_bottom).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(70, 30));
    }];
    
    [self.cancelAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.pauseAllBtn.mas_right).mas_offset(20);
        make.top.mas_equalTo(self.pauseAllBtn);
        make.size.mas_equalTo(CGSizeMake(70, 30));
    }];
    
    [self.deleteTaskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.timeRemainingLab);
        make.top.mas_equalTo(self.timeRemainingLab.mas_bottom).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(70, 30));
    }];
    
    [self.addTaskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.deleteTaskBtn.mas_left).mas_offset(-20);
        make.top.mas_equalTo(self.deleteTaskBtn);
        make.size.mas_equalTo(CGSizeMake(70, 30));
    }];
    
    [self.clearCacheBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.deleteTaskBtn);
        make.top.mas_equalTo(self.deleteTaskBtn.mas_bottom).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(70, 30));
    }];
    
    [self.downloadAsyncTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.pauseAllBtn);
        make.top.mas_equalTo(self.pauseAllBtn.mas_bottom).mas_offset(10);
    }];
    
    [self.downloadAsyncCountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.downloadAsyncTitleLabel.mas_right).mas_offset(20);
        make.centerY.mas_equalTo(self.downloadAsyncTitleLabel);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    [self.downloadAsyncSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.downloadAsyncCountTF.mas_right).mas_offset(10);
        make.centerY.mas_equalTo(self.downloadAsyncCountTF);
        make.size.mas_equalTo(CGSizeMake(40, 30));
    }];
    
    [self.sortBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.clearCacheBtn);
        make.top.mas_equalTo(self.clearCacheBtn.mas_bottom).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.downloadAsyncCountTF.mas_bottom).mas_offset(10);
    }];
}
@end
