//
//  ZWFileOperate.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/26.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWFileOperate.h"
#import "NSString+MD5.h"


@implementation ZWFileOperate

#pragma mark - Public

+ (instancetype)shared {
    static ZWFileOperate  *share = nil;
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        share = [[ZWFileOperate alloc] init];
    });
    return share;
}

// 判断该文件是否下载完成
- (BOOL)isCompletion:(NSString *)url {
    
    if ([self fileTotalLength:url] && [self getDownloadedLengthWithUrl:url] == [self fileTotalLength:url]) {
        return YES;
    }
    return NO;
}

// 获取已下载文件大小
- (NSInteger) getDownloadedLengthWithUrl:(NSString *)url {
    
    NSInteger fileLength = 0;
    
    NSString *path = [self getCurrFilePath:url];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:path]) {
        
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileLength = [fileDict fileSize];
        }
    }
    
    return fileLength;
}

// 获取该资源总大小
- (NSInteger)fileTotalLength:(NSString *)url {
    
    NSString *fileName = [self getCurrDownloadFileName:url];
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self getDownloadPlistPath]][fileName];
    
    return [dict[@"totalLength"] integerValue];
}

// 获取当前文件存放路径
- (NSString *)getCurrDownloadPath {
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *downloadPath = [cachePath stringByAppendingPathComponent:@"Download"];
    
    return downloadPath;
}

// 获取下载文件对应的plist路径
- (NSString *)getDownloadPlistPath {
    
    return [[self getCurrDownloadPath] stringByAppendingPathComponent: @"download.plist"];
}

// 获取当前文件名,不带后缀
- (NSString *)getCurrDownloadFileName: (NSString *)url {
    
    return [url md5];
}

// 获取当前文件名,带后缀
- (NSString *)getCurrDownloadFileTotalName: (NSString *)url {
    
    return [NSString stringWithFormat:@"%@.%@", [url md5], [url pathExtension]];
}

// 获取当前文件的路径
- (NSString *)getCurrFilePath: (NSString *)url {
    
    return [[self getCurrDownloadPath] stringByAppendingPathComponent: [self getCurrDownloadFileTotalName:url]];
}

// 创建缓存目录文件
- (void)createCacheDirectory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[self getCurrDownloadPath]]) {
        
        [fileManager createDirectoryAtPath:[self getCurrDownloadPath] withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

// 清空缓存
- (void)clearCache {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[self getCurrDownloadPath]]) {
        
        [fileManager removeItemAtPath:[self getCurrDownloadPath] error:nil];
    }
}

// 保存文件总大小到plist
- (void)setPlistValue:(id)value forKey:(NSString *)key {
    
    NSString *plistPath = [self createPlistIfNotExist];
    
    // 获取plist字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    [dict setValue:value forKey:key];
    
    [dict writeToFile:plistPath atomically:YES];
}

// 创建plist文件
- (NSString *)createPlistIfNotExist {
    
    NSString *path = [self getDownloadPlistPath];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if (![fileManager fileExistsAtPath:path]) {
        
        // 创建下载目录
        [self createCacheDirectory];
        
        // 立即在沙盒中创建一个空plist文件
        [fileManager createFileAtPath:path contents:nil attributes:nil];
        
         // 将空字典写入plist文件
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict writeToFile:path atomically:YES];
    }
    
    return path;
}

// 获取当前课件的plist信息
- (NSDictionary *)getPlistInfoWithFileName: (NSString *)fileName {
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *plistPath = [cachePath stringByAppendingPathComponent:@"Download/download.plist"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if (![fileManager fileExistsAtPath:plistPath]) { return nil; }
    
    // 获取plist字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    return dict;
}

// 删除该资源
- (void)deleteFile:(ZWDownloadModel *)downloadModel fromDict:(NSMutableDictionary *)downloadModelDicts {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self getCurrFilePath:downloadModel.url]]) {

        // 删除沙盒中的资源
        [fileManager removeItemAtPath:[self getCurrFilePath:downloadModel.url] error:nil];
        
        // 删除任务
        [downloadModel.task cancel];
        [downloadModel.stream close];
        
        [downloadModelDicts removeObjectForKey:@(downloadModel.taskIdentifier).stringValue];
        
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:[self getDownloadPlistPath]]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self getDownloadPlistPath]];
            
            [dict removeObjectForKey:[self getCurrDownloadFileName:downloadModel.url]];
            [dict writeToFile:[self getDownloadPlistPath] atomically:YES];
        }
    }
}

// 清空当前课件所有下载资源
- (void)deleteAllFileFromDict:(NSMutableDictionary *)downloadModelDicts {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[self getCurrDownloadPath]]) {
        
        // 删除沙盒中所有资源
        [fileManager removeItemAtPath:[self getCurrDownloadPath] error:nil];
        
        // 删除任务
        [downloadModelDicts enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ZWDownloadModel * _Nonnull obj, BOOL * _Nonnull stop) {
            
            [obj.task cancel];
            [obj.stream close];
        }];
        
        [downloadModelDicts removeAllObjects];
        
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:[self getDownloadPlistPath]]) {
            [fileManager removeItemAtPath:[self getDownloadPlistPath] error:nil];
        }
    }
}

@end
