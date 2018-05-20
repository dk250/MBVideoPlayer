//
//  MBScrollView.h
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/9.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBPlayerView.h"

@class MBPlayerManager;
@class MBVideoModel;

@protocol  MBSrcollViewDataDelegate <NSObject>

- (void)pullNewData;  //拉取新的额消息

@end

@interface MBScrollView : UIScrollView

@property (nonatomic, weak) id<MBSrcollViewDataDelegate> dataDelegate;
@property (nonatomic, strong) MBPlayerView *playerView;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setupData:(NSArray<MBVideoModel *> *)data;


@end
