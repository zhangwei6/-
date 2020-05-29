
//
//  ViewController.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/7.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWMainViewController.h"
#import "ZWMultiDownloadController.h"

#define TableviewCellIdentify @"TableviewCellIdentify"

@interface ZWMainViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSArray *dataSource;

@end

@implementation ZWMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", NSHomeDirectory());
    
    self.dataSource = @[@"多任务下载"];
    
    [self configSubView];
}

- (void) configSubView {
    
    [self.view addSubview:self.tableView];
}

#pragma mark - 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableviewCellIdentify forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZWMultiDownloadController *multiVc = [[ZWMultiDownloadController alloc] init];
    [self.navigationController pushViewController:multiVc animated:true];
}

#pragma mark - 子控件
- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:TableviewCellIdentify];
        
        _tableView.rowHeight = 44;
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}


@end
