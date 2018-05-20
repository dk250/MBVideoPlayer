//
//  MBVideoModel.h
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/9.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 视频model类
 */
@interface MBVideoModel : NSObject

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSString *videoName;
@property (nonatomic, strong) NSString *videoDescription;
@property (nonatomic, strong) NSURL *imageURL;

@end
