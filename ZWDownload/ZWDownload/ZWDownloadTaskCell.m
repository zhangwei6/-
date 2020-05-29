//
//  ZWDownloadTaskCell.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/16.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWDownloadTaskCell.h"
#import <Masonry/Masonry.h>

@implementation ZWDownloadTaskCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [self configSubview];
    return self;
}

- (void)setDownloadCellModel:(ZWDownloadCellModel *)downloadCellModel {
    _downloadCellModel = downloadCellModel;
    
    self.titleLabel.text = @(downloadCellModel.taskIdentifier).stringValue;//[downloadCellModel.url lastPathComponent];
    self.timeRemainingLabel.text = downloadCellModel.timeRemaining;
    self.startDateLabel.text = [NSString stringWithFormat:@"开始时间: %@", [DownloadUtil getFormatedDate:downloadCellModel.startDate]];
    self.endDateLabel.text = [NSString stringWithFormat:@"结束时间: %@", [DownloadUtil getFormatedDate:downloadCellModel.endDate]];
    self.progressLabel.text = [NSString stringWithFormat:@"%@/%@", [DownloadUtil formatByteCount:downloadCellModel.downloadedLength], [DownloadUtil formatByteCount:downloadCellModel.totalLength]];
    self.speedLabel.text = downloadCellModel.downloadSpeed;
    if (downloadCellModel.totalLength == 0) {
        self.progressView.progress = 0;
    } else {
        self.progressView.progress = 1.0 * downloadCellModel.downloadedLength / downloadCellModel.totalLength;
    }
    [self setState:downloadCellModel.state];
}

- (void)setState:(ZWDownloadState)state {
    
    NSString *stateText = @"-";
    BOOL controlButtonSelected = false;
    
    switch (state) {
        case ZWDownloadStateWaiting:
            stateText = @"等待下载";
            break;
        case ZWDownloadStateDownloading:
            stateText = @"下载中";
            controlButtonSelected = true;
            break;
        case ZWDownloadStateComplete:
            stateText = @"下载完成";
            break;
        case ZWDownloadStateError:
            stateText = @"下载失败";
            break;
        case ZWDownloadStateSuspend:
            stateText = @"下载暂停";
            break;
        case ZWDownloadStateCancel:
            stateText = @"取消下载";
            break;
    }
    
    self.stateLabel.text = stateText;
    self.controlButton.selected = controlButtonSelected;
}

- (void)tapControlBtnAction: (UIButton *)btn {
    
    if (self.downloadCellModel.tapControlBtnAction) {
        self.downloadCellModel.tapControlBtnAction(self.downloadCellModel);
    }
}

- (void)configSubview {
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.timeRemainingLabel];
    [self.contentView addSubview:self.startDateLabel];
    [self.contentView addSubview:self.endDateLabel];
    [self.contentView addSubview:self.progressLabel];
    [self.contentView addSubview:self.speedLabel];
    [self.contentView addSubview:self.controlButton];
    [self.contentView addSubview:self.stateLabel];
    [self.contentView addSubview:self.progressView];
    
    [self.controlButton addTarget:self action:@selector(tapControlBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.contentView).mas_offset(10);
        make.width.mas_equalTo(150);
    }];
    
    [self.timeRemainingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(10);
        make.right.mas_equalTo(self.contentView).mas_offset(-10);
    }];
    
    [self.startDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(10);
    }];
    
    [self.endDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.startDateLabel);
        make.top.mas_equalTo(self.startDateLabel.mas_bottom).mas_offset(10);
    }];
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.endDateLabel);
        make.top.mas_equalTo(self.endDateLabel.mas_bottom).mas_offset(10);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).mas_offset(-10);
        make.top.mas_equalTo(self.progressLabel);
    }];
    
    [self.speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.stateLabel.mas_left).mas_offset(-20);
        make.top.mas_equalTo(self.stateLabel);
    }];
    
    [self.controlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).mas_offset(-10);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressLabel.mas_bottom).mas_offset(3);
        make.left.mas_equalTo(self.contentView).mas_offset(10);
        make.right.mas_equalTo(self.contentView).mas_offset(-10);
        make.height.mas_equalTo(2);
    }];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"-";
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _titleLabel;
}

- (UILabel *)timeRemainingLabel {
    if (!_timeRemainingLabel) {
        _timeRemainingLabel = [[UILabel alloc] init];
        _timeRemainingLabel.text = @"剩余时间: -";
        _timeRemainingLabel.font = [UIFont systemFontOfSize:14];
    }
    return _timeRemainingLabel;
}

- (UILabel *)startDateLabel {
    if (!_startDateLabel) {
        _startDateLabel = [[UILabel alloc] init];
        _startDateLabel.text = @"开始时间: -";
        _startDateLabel.font = [UIFont systemFontOfSize:14];
    }
    return _startDateLabel;
}

- (UILabel *)endDateLabel {
    if (!_endDateLabel) {
        _endDateLabel = [[UILabel alloc] init];
        _endDateLabel.text = @"结束时间: -";
        _endDateLabel.font = [UIFont systemFontOfSize:14];
    }
    return _endDateLabel;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.text = @"-/-";
        _progressLabel.font = [UIFont systemFontOfSize:14];
    }
    return _progressLabel;
}

- (UILabel *)speedLabel {
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc] init];
        _speedLabel.text = @"-";
        _speedLabel.font = [UIFont systemFontOfSize:14];
    }
    return _speedLabel;
}

- (UIButton *)controlButton {
    if (!_controlButton) {
        _controlButton = [[UIButton alloc] init];
        [_controlButton setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
        [_controlButton setImage:[UIImage imageNamed:@"resume"] forState:UIControlStateSelected];
    }
    return _controlButton;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.text = @"-";
        _stateLabel.font = [UIFont systemFontOfSize:14];
    }
    return _stateLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
    }
    return _progressView;
}

@end
