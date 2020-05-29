//
//  ZWFileOperate.h
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/26.
//  Copyright © 2020 ZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWDownloadModel.h"
#import "DownloadUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWFileOperate : NSObject

+ (instancetype)shared;

// 判断该文件是否下载完成
- (BOOL)isCompletion:(NSString *)url;

// 获取已下载文件大小
- (NSInteger) getDownloadedLengthWithUrl:(NSString *)url;

// 获取该资源总大小
- (NSInteger)fileTotalLength:(NSString *)url;

// 获取当前文件存放路径
- (NSString *)getCurrDownloadPath;

// 获取下载文件对应的plist路径
- (NSString *)getDownloadPlistPath;

// 获取当前文件名,不带后缀
- (NSString *)getCurrDownloadFileName: (NSString *)url;

// 获取当前文件名,带后缀
- (NSString *)getCurrDownloadFileTotalName: (NSString *)url;

// 获取当前文件的路径
- (NSString *)getCurrFilePath: (NSString *)url;

// 创建缓存目录文件
- (void)createCacheDirectory;

// 清空缓存
- (void)clearCache;

// 保存文件总大小到plist
- (void)setPlistValue:(id)value forKey:(NSString *)key;

// 创建plist文件
- (NSString *)createPlistIfNotExist;

// 获取当前课件的plist信息
- (NSDictionary *)getPlistInfoWithFileName: (NSString *)fileName;

// 删除该资源
- (void)deleteFile:(ZWDownloadModel *)downloadModel fromDict:(NSMutableDictionary *)downloadModelDicts;

// 清空当前课件所有下载资源
- (void)deleteAllFileFromDict:(NSMutableDictionary *)downloadModelDicts;

@end

NS_ASSUME_NONNULL_END
