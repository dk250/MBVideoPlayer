//
//  MBURLTaskModel.h
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/11.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 视频下载任务类
 */
@interface MBURLTaskModel : NSObject

/**
 下载URL
 */
@property (nonatomic, strong) NSURL *downloadURL;

/**
 视频总长度
 */
@property (nonatomic, assign) long long videoLength;

/**
 当次任务起始位置
 */
@property (nonatomic, assign) long long offset;

/**
 当次任务已经完成下载的长度
 */
@property (nonatomic, assign) long long downloadingOffset;


- (instancetype)initWithURL:(NSURL *)url;


@end
