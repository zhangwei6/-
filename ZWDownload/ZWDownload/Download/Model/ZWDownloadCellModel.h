//
//  ZWDownloadCellModel.h
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/16.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWDownloadModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ZWDownloadCellModel;
typedef void(^TapControlBtnBlock)(ZWDownloadCellModel *);

@interface ZWDownloadCellModel : ZWDownloadModel

// 当前Cell的位置
@property (nonatomic, strong) NSIndexPath *indexPath;

// 是否被选中，用于删除某个任务
@property (nonatomic, assign) BOOL isChoosed;

// 点击控制按钮事件
@property (nonatomic, strong) TapControlBtnBlock tapControlBtnAction;

@end

NS_ASSUME_NONNULL_END
