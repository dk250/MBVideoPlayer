//
//  MBNetworkManager.m
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/8.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import "MBNetworkManager.h"
#import "MBURLTaskModel.h"

#import "MBFileManager.h"

@interface MBNetworkManager()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *taskDic;//任务数组
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSURLSessionDataTask *currentTask;
@property (nonatomic, strong) MBURLTaskModel *currentTaskModel;
@property (nonatomic, assign) long long downLoadingOffset;

@end

@implementation MBNetworkManager

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.taskDic = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - Custom Accessors

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return _session;
}

#pragma mark - IBActions

#pragma mark - Public

+ (instancetype)shareInstance {
    static MBNetworkManager *networkManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[MBNetworkManager alloc] init];
    });
    
    return networkManager;
}

- (MBURLTaskModel *)urlTaskModelWithURL:(NSURL *)url {
    MBURLTaskModel *task =  [self.taskDic objectForKey:url.absoluteString];
    if (task) {
        return task;
    }
    
    MBURLTaskModel *newTask = [[MBURLTaskModel alloc] initWithURL:url];
    
    return newTask;
}

- (void)startDownloadTask:(MBURLTaskModel *)taskModel {
    if ([self.currentTaskModel.downloadURL.absoluteString isEqualToString:taskModel.downloadURL.absoluteString]) {//有相同的任务开始下载了
        return;
    }
    
    if (![self.taskDic objectForKey:taskModel.downloadURL.absoluteString]) {
        [self.taskDic setObject:taskModel forKey:taskModel.downloadURL.absoluteString];
    }
    
    self.currentTaskModel = taskModel;
    
    if (self.currentTask) {
        [self.currentTask cancel];
    }
    
    self.downLoadingOffset = taskModel.downloadingOffset;
    
    NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:taskModel.downloadURL resolvingAgainstBaseURL:NO];
    actualURLComponents.scheme = @"https";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[actualURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    request.timeoutInterval = 10;
    
    if (taskModel.downloadingOffset > 0) {
        if (taskModel.videoLength > 0) {
            [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld", (long)taskModel.downloadingOffset, (long)taskModel.videoLength] forHTTPHeaderField:@"Range"];
        }else {
            [request addValue:[NSString stringWithFormat:@"bytes=%ld-", (long)taskModel.downloadingOffset] forHTTPHeaderField:@"Range"];
        }
    }
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request];
    
    self.currentTask = dataTask;
    
    [dataTask resume];
}


/**
 返回本地保存的视频的总长度

 @param fileURLString url为key
 @return 返回视频总长度
 */
- (long long)totalBytesByFileURL:(NSString *)fileURLString {
    NSString *key = [fileURLString stringByAppendingString:@"_totalBytes"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [[userDefault objectForKey:key] longLongValue];
}

- (void)clearDownloadingOffset {
    if (self.taskDic.count > 0) {
        for (NSString *key in self.taskDic) {
            MBURLTaskModel *model = [self.taskDic objectForKey:key];
            model.downloadingOffset = 0;
        }
    }
}

#pragma mark - Private

//保存任务的总字节数
- (void)saveTotalBytes:(NSString *)totalBytes forKey:(NSString *)fileURLString {
    if (totalBytes.length == 0 || fileURLString.length == 0) {
        return;
    }
    
    NSString *key = [fileURLString stringByAppendingString:@"_totalBytes"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:totalBytes forKey:key];
    [userDefault synchronize];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *dic = (NSDictionary *)[httpResponse allHeaderFields];
    
    NSString *content = [dic objectForKey:@"Content-Range"];
    NSArray *array = [content componentsSeparatedByString:@"/"];
    NSString *length = array.lastObject;
    
    long long videoLength;
    
    if ([length integerValue] == 0) {
        videoLength = httpResponse.expectedContentLength;
    }else {
        videoLength = [length longLongValue];
    }
    
    self.currentTaskModel.videoLength = videoLength;
    
//    NSLog(@"videoLength: %ld", videoLength);
    
    //保存当前下载任务video的总长度，用于断点续传。
    [self saveTotalBytes:[NSString stringWithFormat:@"%lld", videoLength] forKey:self.currentTaskModel.downloadURL.absoluteString];
    
    NSString *savePath = [MBFileManager savePathWithURL:self.currentTaskModel.downloadURL];
    NSLog(@"savePath: %@", savePath);
    [MBFileManager createFileInPath:savePath];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:savePath];
    
    completionHandler(NSURLSessionResponseAllow);//没有这个代码，不会调用下面的didReceiveData方法
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"receiveData: %ld",data.length);
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];
    
    self.currentTaskModel.downloadingOffset += data.length;
    self.downLoadingOffset += data.length;
    
    NSLog(@"in NEtwork %lld", self.currentTaskModel.downloadingOffset);
    
    if ([self.delegate respondsToSelector:@selector(didReceiveDataWithTaskModel:)]) {
        [self.delegate didReceiveDataWithTaskModel:self.currentTaskModel];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //TODO 代码错误处理
    NSLog(@"error : %@", error);
    if (error) {
        if ([self.delegate respondsToSelector:@selector(didCompleteWithTaskModel:error:)]) {
            [self.delegate didCompleteWithTaskModel:self.currentTaskModel error:error];
        }
    }
}

@end
