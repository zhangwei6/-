//
//  ZWDownloadOperate.m
//  ZWDownloadDemo
//
//  Created by Admin on 2020/5/18.
//  Copyright © 2020 ZW. All rights reserved.
//

#import "ZWDownloadOperate.h"
#import "ZWDownloadDefine.h"
#import "ZWFileOperate.h"

@interface ZWDownloadOperate()<NSURLSessionDelegate>

// 保存下载模型的键值对字典，方便通过taskIdentifier直接获取模型
@property (nonatomic, strong) NSMutableDictionary *downloadModelDicts;

@end

@implementation ZWDownloadOperate

#pragma mark - Public

+ (instancetype)sharedInstance {
    static ZWDownloadOperate  *share = nil;
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        share = [[ZWDownloadOperate alloc] init];
    });
    
    return share;
}

// 根据模型下载
- (void)addDownLoadWithModel:(ZWDownloadModel *) model
                  preOperate:(void(^)(void)) preOperateBlock
                    progress:(ProgressBlock) progressBlock
                       state:(void (^)(ZWDownloadState, NSError * _Nullable))stateBlock {
    
    if (!model.url) return;
     
    if ([[ZWFileOperate shared] isCompletion:model.url]) {
        model.state = ZWDownloadStateComplete;
        if (model.stateBlock) { model.stateBlock(ZWDownloadStateComplete, nil); }
        stateBlock(ZWDownloadStateComplete, nil);
        if (self.stateChangedBlock) { self.stateChangedBlock(); }
        return;
    }
    
    // 创建缓存目录文件
    [[ZWFileOperate shared] createCacheDirectory];
    
    // 保存当前下载模型
    [self.downloadModelDicts setValue:model forKey:@(model.taskIdentifier).stringValue];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];

    // 下载文件保存路径
    NSString *filePath = [[ZWFileOperate shared] getCurrFilePath:model.url];
    model.filePath = filePath;
    
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];

    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:model.url]];

    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%ld-", [[ZWFileOperate shared] getDownloadedLengthWithUrl:model.url]];
    [request setValue:range forHTTPHeaderField:@"Range"];

    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    
    // 根据taskIdentifier保存任务的字典的key
    [task setValue:@(model.taskIdentifier) forKeyPath:@"taskIdentifier"];

    model.task = task;
    model.preOperateBlock = preOperateBlock;
    model.progressBlock = progressBlock;
    model.stateBlock = stateBlock;
    model.stream = stream;
    
    [self start:model];
}

// 开始下载
- (void)start:(ZWDownloadModel *)model {
    
    [model.task resume];
    
    if (model.isNeedSpeed) {
        model.updateDownloadedLength = 0;
        [model initialTimer];
        dispatch_source_set_event_handler(model.timer, ^{
            [self updateSpeedAndTimeRemainingWithModel:model];
        });
        [model resumeTimerWithFirstTime:true];
    }
    model.state = ZWDownloadStateDownloading;
    if (model.stateBlock) { model.stateBlock(ZWDownloadStateDownloading, nil); }
    model.startDate = [NSDate date];
    if (self.stateChangedBlock) { self.stateChangedBlock(); }
}

// 暂停下载
- (void)pauseDownloadWithModel:(ZWDownloadModel *)model {
    
    [model.task suspend];
    if (model.isNeedSpeed) { [model suspendTimer]; }
    model.state = ZWDownloadStateSuspend;
    if (model.stateBlock) { model.stateBlock(ZWDownloadStateSuspend, nil); }
    if (self.stateChangedBlock) { self.stateChangedBlock(); }
}

// 恢复下载
- (void)resumeDownloadWithModel:(ZWDownloadModel *)model {
    
    [model.task resume];
    if (model.isNeedSpeed) { [model resumeTimerWithFirstTime:false]; }
    model.state = ZWDownloadStateDownloading;
    if (model.stateBlock) { model.stateBlock(ZWDownloadStateDownloading, nil); }
    if (self.stateChangedBlock) { self.stateChangedBlock(); }
}

// 删除下载
- (void)deleteDownloadWithModel:(ZWDownloadModel *)model {
    
    // 删除相关下载文件以及资源
    [[ZWFileOperate shared] deleteFile:model fromDict:self.downloadModelDicts];
    
    // 删除定时器
    if (model.isNeedSpeed) {
        [DownloadUtil executeOnSafeMian:^{
            
            [model cancelTimer];
        }];
    }
}

// 取消下载
- (void)cancelDownloadWithModel:(ZWDownloadModel *)model {
    
    // 删除下载相关资源，但是已经下载的文件任然进行保存
    [model.task cancel];
    [model.stream close];
    
    [self.downloadModelDicts removeObjectForKey:@(model.taskIdentifier).stringValue];
    
    // 删除资源总长度
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[[ZWFileOperate shared] getDownloadPlistPath]]) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[[ZWFileOperate shared] getDownloadPlistPath]];
        
        [dict removeObjectForKey:[[ZWFileOperate shared] getCurrDownloadFileName:model.url]];
        [dict writeToFile:[[ZWFileOperate shared] getDownloadPlistPath] atomically:YES];
    }
    
    // 删除定时器
    if (model.isNeedSpeed) {
        [DownloadUtil executeOnSafeMian:^{
            
            [model cancelTimer];
        }];
    }
}

// 计算下载速度与剩余时间
- (void)updateSpeedAndTimeRemainingWithModel:(ZWDownloadModel *)model {
    
    // 获取当前文件大小
    NSInteger currFileLength = [[ZWFileOperate shared] getDownloadedLengthWithUrl:model.url];
    NSInteger preFileLength = model.updateDownloadedLength;
    
    // 每秒下载的当前文件的大小
    NSInteger deltaLength = currFileLength - preFileLength;
    
    if (deltaLength == 0) {
        
        model.downloadSpeed = @"0Kb/s";
        model.timeRemaining = @"-";
        
    } else {
        
        // 下载速度
        model.downloadSpeed = [NSString stringWithFormat:@"%@/s", [DownloadUtil formatByteCount:deltaLength]];
        
        // 剩余时间
        model.timeRemaining = [DownloadUtil getFormatedTime:(model.totalLength - currFileLength) / deltaLength];
        
        model.updateDownloadedLength = currFileLength;
    }
}

// 获取当前下载的模型
- (ZWDownloadModel *)getDownloadModel:(NSUInteger)taskIdentifier {
    
    return (ZWDownloadModel *)[self.downloadModelDicts valueForKey:@(taskIdentifier).stringValue];
}

#pragma mark - NSURLSessionDataDelegate 代理

// 接收到响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    ZWDownloadModel *downloadModel = [self getDownloadModel:dataTask.taskIdentifier];
    
    // 打开流
    [downloadModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + [[ZWFileOperate shared] getDownloadedLengthWithUrl:downloadModel.url];
    downloadModel.totalLength = totalLength;
    
    NSString *fileName = [[ZWFileOperate shared] getCurrDownloadFileTotalName:downloadModel.url];
    downloadModel.fileName = fileName;
    
    // 存储总长度
    NSDictionary *dict = @{
                            @"totalLength" : @(totalLength),
                            @"url" : downloadModel.url,
                            @"fileName" : fileName
                         };
    
    [[ZWFileOperate shared] setPlistValue:dict forKey:[[ZWFileOperate shared] getCurrDownloadFileName:downloadModel.url]];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
    
    // 当打通后立即暂停,并且通知已经获取到当前下载的文件的相关资源
    [self pauseDownloadWithModel:downloadModel];
    
    downloadModel.preOperateBlock();
}

// 接收到服务器返回的数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    ZWDownloadModel *downloadModel = [self getDownloadModel:dataTask.taskIdentifier];
    
    // 写入数据
    [downloadModel.stream write:data.bytes maxLength:data.length];
    
    // 已经下载长度
    NSUInteger receivedSize = [[ZWFileOperate shared] getDownloadedLengthWithUrl:downloadModel.url];
    downloadModel.downloadedLength = receivedSize;
    
    // 下载进度
    NSUInteger expectedSize = downloadModel.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    downloadModel.progressBlock(progress, receivedSize, expectedSize);
    
    // 如果是多任务下载，那么及时通知总的进度发生改变
    if (self.progressChangedBlock) { self.progressChangedBlock(); }
}

// 请求完毕（成功|失败
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    ZWDownloadModel *downloadModel = [self getDownloadModel:task.taskIdentifier];
    if (!downloadModel) return;
    
    downloadModel.endDate = [NSDate date];
    
    if ([[ZWFileOperate shared] isCompletion:downloadModel.url]) {
        // 下载完成
        downloadModel.state = ZWDownloadStateComplete;
        if (downloadModel.stateBlock) { downloadModel.stateBlock(ZWDownloadStateComplete, nil); }
    } else if (error){
        // 下载失败
        downloadModel.state = ZWDownloadStateError;
        if (downloadModel.stateBlock) { downloadModel.stateBlock(ZWDownloadStateError, nil); }
    }
    
    downloadModel.downloadSpeed = @"-";
    
    // 关闭流
    [downloadModel.stream close];
    downloadModel.stream = nil;
    
    // 清除任务
    [self.downloadModelDicts removeObjectForKey:@(task.taskIdentifier).stringValue];
    
    // 删除定时器
    if (downloadModel.isNeedSpeed) {
        [DownloadUtil executeOnSafeMian:^{
            
            [downloadModel cancelTimer];
        }];
    }
    
    if (self.stateChangedBlock) { self.stateChangedBlock(); }
}

#pragma mark - 懒加载
- (NSMutableDictionary *)downloadModelDicts {
    if (!_downloadModelDicts) {
        _downloadModelDicts = [NSMutableDictionary dictionary];
    }
    return _downloadModelDicts;
}

@end
