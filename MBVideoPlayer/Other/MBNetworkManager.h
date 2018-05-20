//
//  MBNetworkManager.h
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/8.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBURLTaskModel;

@protocol MBNetworkManagerDelegate<NSObject>

- (void)didReceiveDataWithTaskModel:(MBURLTaskModel *)taskModel;
- (void)didCompleteWithTaskModel:(MBURLTaskModel *)taskModel error:(NSError *)error;

@end

/**
 网络下载管理类
 */
@interface MBNetworkManager : NSObject

@property (nonatomic, weak) id<MBNetworkManagerDelegate> delegate;
@property (nonatomic, assign, readonly) long long  downLoadingOffset;

+ (instancetype)shareInstance;

/**
 返回当前的taskModel

 @param url url链接
 @return taskmodel
 */
- (MBURLTaskModel *)urlTaskModelWithURL:(NSURL *)url;

/**
 开始任务

 @param task 任务
 */
- (void)startDownloadTask:(MBURLTaskModel *)task;

/**
 获取下载资源的长度

 @param fileURLString 资源下载链接
 @return 返回资源长度
 */
- (long  long)totalBytesByFileURL:(NSString *)fileURLString;


/**
 当删除文件缓存的时候，要把当前下载进度清为0
 */
- (void)clearDownloadingOffset;

@end
