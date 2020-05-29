//
//  ZWDownloadTaskCell.h
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/16.
//  Copyright © 2020 ZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWDownloadCellModel.h"
#import "DownloadUtil.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *downloadTaskCellIdentifier = @"downloadTaskCellIdentifier";

@interface ZWDownloadTaskCell : UITableViewCell

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *timeRemainingLabel;
@property(nonatomic, strong) UILabel *startDateLabel;
@property(nonatomic, strong) UILabel *endDateLabel;
@property(nonatomic, strong) UILabel *progressLabel;
@property(nonatomic, strong) UILabel *speedLabel;
@property(nonatomic, strong) UIButton *controlButton;
@property(nonatomic, strong) UILabel *stateLabel;
@property(nonatomic, strong) UIProgressView *progressView;

@property(nonatomic, strong) ZWDownloadCellModel *downloadCellModel;

@end

NS_ASSUME_NONNULL_END
