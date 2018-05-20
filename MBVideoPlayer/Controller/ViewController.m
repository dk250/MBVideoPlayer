//
//  ViewController.m
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/8.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "Masonry.h"

#import "MBAVAssetResourceLoader.h"
#import "MBScrollView.h"
#import "MBVideoModel.h"

@interface ViewController ()<MBSrcollViewDataDelegate>

@property (nonatomic, strong) MBScrollView *scrollView;

@property (nonatomic, assign) BOOL didPausePlay;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    
    self.didPausePlay = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGoBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appResume) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.didPausePlay) {
        [self.scrollView.playerView.player play];
        self.didPausePlay = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.scrollView.playerView.isPlaying) {
        [self.scrollView.playerView.player pause];
        self.didPausePlay = YES;
    }

    NSLog(@"viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Custom Accessors

- (MBScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[MBScrollView alloc] initWithFrame:self.view.frame];
    }
    
    return _scrollView;
}

#pragma mark - IBActions

#pragma mark - Public

#pragma mark - Private

- (void)initUI {
    MBVideoModel *videoModel1 = [[MBVideoModel alloc] init];
    videoModel1.videoURL = [NSURL URLWithString:@"https://aweme.snssdk.com/aweme/v1/play/?video_id=v0200ff70000bbpq77egnco3gem1cbo0&line=0&ratio=720p&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0"];
    videoModel1.imageURL = [NSURL URLWithString:@"http://pb3.pstatp.com/large/82010007db639677c13a.jpeg"];

    MBVideoModel *videoModel2 = [[MBVideoModel alloc] init];
    videoModel2.videoURL = [NSURL URLWithString:@"https://aweme.snssdk.com/aweme/v1/play/?video_id=v0200fe70000bbpbja2kr6gep84pagp0&line=0&ratio=720p&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0"];
    videoModel2.imageURL = [NSURL URLWithString:@"http://pb3.pstatp.com/large/81db000e8706eaa0f924.jpeg"];
    
    MBVideoModel *videoModel3 = [[MBVideoModel alloc] init];
    videoModel3.videoURL = [NSURL URLWithString:@"https://aweme.snssdk.com/aweme/v1/play/?video_id=v0200f180000bbpq77aepr17h5mljosg&line=0&ratio=720p&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0"];
    videoModel3.imageURL = [NSURL URLWithString:@"http://pb3.pstatp.com/large/820000099b44b23afad2.jpeg"];
    
    MBVideoModel *videoModel4 = [[MBVideoModel alloc] init];
    videoModel4.videoURL = [NSURL URLWithString:@"https://aweme.snssdk.com/aweme/v1/play/?video_id=v0200fe70000bbpei1sm7fie8i194img&line=0&ratio=720p&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0"];
    videoModel4.imageURL = [NSURL URLWithString:@"http://pb3.pstatp.com/large/81eb000c20963982d2e7.jpeg"];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView setupData:@[videoModel1, videoModel2, videoModel3, videoModel4]];
    self.scrollView.dataDelegate = self;
}

- (void)appGoBackground {
    if (self.scrollView.playerView.isPlaying) {
        [self.scrollView.playerView.player pause];
        self.didPausePlay = YES;
    }
}

- (void)appResume {
    if (self.didPausePlay) {
        [self.scrollView.playerView.player play];
        self.didPausePlay = NO;
    }
}

#pragma mark - Protocol conformance

- (void)pullNewData {
    MBVideoModel *videoModel1 = [[MBVideoModel alloc] init];
    videoModel1.videoURL = [NSURL URLWithString:@"https://aweme.snssdk.com/aweme/v1/play/?video_id=v0200ff70000bbpq77egnco3gem1cbo0&line=0&ratio=720p&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0"];
    videoModel1.imageURL = [NSURL URLWithString:@"http://pb3.pstatp.com/large/82010007db639677c13a.jpeg"];
    
    MBVideoModel *videoModel2 = [[MBVideoModel alloc] init];
    videoModel2.videoURL = [NSURL URLWithString:@"https://aweme.snssdk.com/aweme/v1/play/?video_id=v0200fe70000bbpbja2kr6gep84pagp0&line=0&ratio=720p&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0"];
    videoModel2.imageURL = [NSURL URLWithString:@"http://pb3.pstatp.com/large/81db000e8706eaa0f924.jpeg"];
    
    MBVideoModel *videoModel3 = [[MBVideoModel alloc] init];
    videoModel3.videoURL = [NSURL URLWithString:@"https://aweme.snssdk.com/aweme/v1/play/?video_id=v0200f180000bbpq77aepr17h5mljosg&line=0&ratio=720p&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0"];
    videoModel3.imageURL = [NSURL URLWithString:@"http://pb3.pstatp.com/large/820000099b44b23afad2.jpeg"];
    
    [self.scrollView setupData:@[videoModel1, videoModel2, videoModel3]];
}

@end
