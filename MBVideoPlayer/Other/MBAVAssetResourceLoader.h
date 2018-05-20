//
//  MBAVAssetResourceLoaderDelegate.h
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/8.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@protocol MBAVAssetResourceLoaderDelegate<NSObject>

- (void)didCompleteWithError:(NSError *)error;

@end

/**
 AVAssetResource代理类，用于拦截AVURLAssert的资源请求
 */
@interface MBAVAssetResourceLoader : NSObject<AVAssetResourceLoaderDelegate>

@property(nonatomic, weak) id<MBAVAssetResourceLoaderDelegate> delegate;
/**
 更换下载链接的URL scheme

 @param url 下载链接
 @return 新的URL
 */
- (NSURL *)getSchemeVideoURL:(NSURL *)url;

@end
