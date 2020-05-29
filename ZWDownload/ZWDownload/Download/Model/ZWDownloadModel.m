//
//  ZWDownloadModel.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/16.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWDownloadModel.h"

@implementation ZWDownloadModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isNeedSpeed = false;
    }
    return self;
}

- (void)initialTimer {
    // 获取定时器
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
}

// 开始定时
- (void)resumeTimerWithFirstTime: (BOOL)isFirstTime {
    
    if (isFirstTime || self.isTimerSuspend) {
        dispatch_resume(self.timer);
        self.isTimerSuspend = false;
        return;
    }
}

// 暂停定时
- (void)suspendTimer {
    if (!self.isTimerSuspend) {
        dispatch_suspend(self.timer);
        self.isTimerSuspend = true;
    }
}

// 取消定时
- (void)cancelTimer {
    
    if (self.timer) {
        if (self.isTimerSuspend) {
            dispatch_resume(self.timer);
        }
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)cancel {
    
    self.fileName = @"";
    self.filePath = @"";
    self.startDate = nil;
    self.endDate = nil;
    self.totalLength = 0;
    self.downloadedLength = 0;
    self.task = nil;
    self.stream = nil;
    self.state = ZWDownloadStateCancel;
    self.progressBlock = nil;
    self.stateBlock = nil;
}

@end
