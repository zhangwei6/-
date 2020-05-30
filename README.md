# 多任务下载

实现多任务下载，展示实时进度、下载速度、剩余时间等

![图片](https://upload-images.jianshu.io/upload_images/21257950-8e090b099350b3eb.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/748/format/webp)

## 单资源下载：一个个下载资源，只能展示当前资源的所有下载信息
    NSString *url = @"";
    NSIndexPath *indexPath;
    
    if (self.index == 1) {
        url = @"https://cdnvip.meishubao.com/videowbimage/2020-04/25/8037de81b67fc4e151f0cc94e8a15f80.mp4";
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if(self.index == 2) {
        url = @"https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg";
        indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    } else if(self.index == 3) {
        url = @"https://qd.myapp.com/myapp/qqteam/pcqq/QQ9.0.8_2.exe";
        indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    } else {
        return;
    }
    
    self.index += 1;
    
    ZWDownloadModel *downloadModel = [self getDownloadCellModelWithUrl:url indexPath:indexPath];
    [self.downloadModels addObject:downloadModel];
    
    [self.downloadViewModelDelegate reloadWithIndexPath:nil];
    
    // 设置最大并发数量
    [ZWDownloadManager sharedInstance].maxConcurrentCount = 2;
    
    // 开始下载
    [[ZWDownloadManager sharedInstance] downLoadWithModel:downloadModel];
## 多资源下载：即可以一个个下载资源，也可以同时下载多个资源，可以展示每个资源的下载信息和总的资源下载信息
    NSString *url1 = @"https://cdnvip.meishubao.com/videowbimage/2020-04/25/8037de81b67fc4e151f0cc94e8a15f80.mp4";
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.multiDownloadModel.downloadCellModels addObject:[self getDownloadCellModelWithUrl:url1 indexPath:indexPath1]];
    
    NSString *url2 = @"https://dldir1.qq.com/qqfile/QQforMac/QQ_V6.5.2.dmg";
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.multiDownloadModel.downloadCellModels addObject:[self getDownloadCellModelWithUrl:url2 indexPath:indexPath2]];
    
    NSString *url3 = @"https://qd.myapp.com/myapp/qqteam/pcqq/QQ9.0.8_2.exe";
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.multiDownloadModel.downloadCellModels addObject:[self getDownloadCellModelWithUrl:url3 indexPath:indexPath3]];
    
    // 设置多任务下载需要显示下载速度
    self.multiDownloadModel.isNeedSpeed = true;
    
    [self.downloadViewModelDelegate reloadWithIndexPath:nil];
    
    // 设置最大并发数量
    [ZWDownloadManager sharedInstance].maxConcurrentCount = 2;
    
    // 开始下载
    [[ZWDownloadManager sharedInstance] downLoadWithMultiModel:self.multiDownloadModel progress:^(CGFloat progress, long long downloadedlength, long long totalLength) {
        
        // 更新总的任务大小进度
        [self.downloadViewModelDelegate totalDownloadLengthChanged:self.multiDownloadModel];
        
    } stateChanged:^(ZWMultiDownloadModel * _Nonnull multiDownloadModel) {
        
        // 下载完成，改变总的下载个数进度
        [self.downloadViewModelDelegate downloadCountChanged:multiDownloadModel];
    }];

简书地址：https://www.jianshu.com/p/e87a5730b2cb
