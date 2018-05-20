//
//  MBPlayerView.h
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/10.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol MBPlayerViewDelegate<NSObject>

- (void)playerViewDidPrepareToShowVideo;

@end

@interface MBPlayerView : UIView

@property (nonatomic, weak) id<MBPlayerViewDelegate> playDelegate;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) BOOL isPlaying;

- (instancetype)initWithFrame:(CGRect)frame;

@end
