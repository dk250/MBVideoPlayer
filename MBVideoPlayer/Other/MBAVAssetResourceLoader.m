//
//  MBAVAssetResourceLoaderDelegate.m
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/8.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import "MBAVAssetResourceLoader.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "MBNetworkManager.h"
#import "MBURLTaskModel.h"
#import "MBFileManager.h"

@interface MBAVAssetResourceLoader()<MBNetworkManagerDelegate>

@property (nonatomic, strong) NSMutableArray *loadingRequests;
@property (nonatomic, strong) MBURLTaskModel *taskModel;
@property (nonatomic, strong) MBNetworkManager *networkManager;
@property (nonatomic) BOOL hasStartDownloadFromServer;

@end

@implementation MBAVAssetResourceLoader

#pragma mark - Lifecycle

#pragma mark - Custom Accessors

- (NSMutableArray *)loadingRequests {
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray array];
    }
    
    return _loadingRequests;
}

- (MBNetworkManager *)networkManager {
    if (!_networkManager) {
        _networkManager = [MBNetworkManager shareInstance];
    }
    
    return _networkManager;
}

#pragma mark - IBActions

#pragma mark - Public

- (NSURL *)getSchemeVideoURL:(NSURL *)url
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

#pragma mark - Private

- (void)processPendingRquest {
    NSMutableArray *requestCompletedArray = [NSMutableArray array];
    
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest]; //判断此次请求的数据是否处理完全
        
        if (didRespondCompletely) {
            [requestCompletedArray addObject:loadingRequest];  //如果完整，把此次请求放进 请求完成的数组
            [loadingRequest finishLoading];
        }
    }
    
    if (requestCompletedArray.count > 0) {
        [self.loadingRequests removeObjectsInArray:requestCompletedArray];   //在所有请求的数组中移除已经完成的
    }
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest {
    //这个配置非常的重要
    NSString *mimeType = @"video/mp4";
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = self.taskModel.videoLength; //length如果为空，则player不会继续开始发请求
}

- (void)dealLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *interceptedURL = [loadingRequest.request URL];

    if (!self.taskModel) {
        self.taskModel = [self.networkManager urlTaskModelWithURL:interceptedURL];
    }
    
    if (self.taskModel.downloadingOffset > 0) { //如果本地存在，则先读取本地的数据
        [self processPendingRquest];
    }else { //如果本地不存在则直接进行网络访问
        self.hasStartDownloadFromServer = YES;
        self.networkManager.delegate = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.networkManager startDownloadTask:self.taskModel];
        });
    }
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest {
    long long startOffset = dataRequest.requestedOffset;
    
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    
    NSString *savePath = [MBFileManager savePathWithURL:self.taskModel.downloadURL];
    NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:savePath] options:NSDataReadingMappedIfSafe error:nil];
    
    if (filedata.length <= 0) {
        return NO;
    }
    
//    if (startOffset >= filedata.length) { //如果当前请求的数据超过本地的保存，则返回no
//        return NO;
//    }

    long long unreadBytes = filedata.length - (NSInteger)startOffset; //本地存在的未读取数据

    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    
    if (numberOfBytesToRespondWith > 0 && unreadBytes > 0) {
        [dataRequest respondWithData:[filedata subdataWithRange:NSMakeRange((NSUInteger)startOffset, (NSUInteger)numberOfBytesToRespondWith)]]; //把本地存在的数据返回到播放器
    }
    
    if (dataRequest.requestedLength > unreadBytes && !self.hasStartDownloadFromServer) {  //如果请求的数据超过了本地的请求，则去网络获取数据
        self.hasStartDownloadFromServer = YES;
        self.networkManager.delegate = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.networkManager startDownloadTask:self.taskModel];
        });
    }
    
    long long endOffset = startOffset + dataRequest.requestedLength;
    BOOL didRespondFully = filedata.length >= endOffset; //判断当前请求数据是否加载完成。
    
    return didRespondFully;
}

#pragma mark - AVAssetResourceLoader Protocol

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"dk----%@", loadingRequest);
    [self.loadingRequests addObject:loadingRequest];
    [self dealLoadingRequest:loadingRequest];
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"removeResourceLoader");
    [self.loadingRequests removeObject:loadingRequest];
}

#pragma mark - MBNetworkManagerDelegate Protocol

- (void)didReceiveDataWithTaskModel:(MBURLTaskModel *)taskModel {
    [self processPendingRquest];
}

- (void)didCompleteWithTaskModel:(MBURLTaskModel *)taskModel error:(NSError *)error {
    self.hasStartDownloadFromServer = NO;
    if (error) {
        if ([self.delegate respondsToSelector:@selector(didCompleteWithError:)]) {
            [self.delegate didCompleteWithError:error];
        }
    }
}

@end
