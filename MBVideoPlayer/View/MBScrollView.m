//
//  MBScrollView.m
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/9.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import "MBScrollView.h"

#import <AVFoundation/AVFoundation.h>

#import "UIImageView+WebCache.h"

#import "MBVideoModel.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define IMAGEVIEW_COUNT 3

@interface MBScrollView() <UIScrollViewDelegate, MBPlayerViewDelegate>

@property (nonatomic, strong) UIImageView *firstImageView, *secondImageView, *thirdImageView, *tempImageView;
//@property (nonatomic, strong)  MBPlayerView *firstPlayerView, *secondPlayerView, *thirdPlayerView;
//@property (nonatomic, strong) MBPlayerView *playerView;

@property (nonatomic, strong) NSMutableArray<MBVideoModel *> *dataArray;
@property (nonatomic, strong) MBVideoModel *firstVideoModel, *secondVideoModel, *thirdVideoModel;

@property (nonatomic, assign) NSInteger currentIndexOfImageView;
@property (nonatomic, assign) NSInteger currentIndexOfShowView;

@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic) NSMutableArray<UIImageView *> *tempArray;

@end

@implementation MBScrollView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.pagingEnabled = YES;
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        self.delegate = self;
        self.firstVideoModel = [[MBVideoModel alloc] init];
        self.secondVideoModel = [[MBVideoModel alloc] init];
        self.thirdVideoModel = [[MBVideoModel alloc] init];
    }
    
    return self;
}

#pragma mark - Custom Accessors

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

- (MBPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[MBPlayerView alloc] init];
    }
    
    return _playerView;
}

#pragma mark - IBActions

#pragma mark - Public

- (void)setupData:(NSArray<MBVideoModel *> *)data {
    if (data.count == 0) {
        return;
    }
    
    if (self.dataArray.count == 0) {//还没有数据
        self.dataArray = [NSMutableArray arrayWithArray:data];
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * self.dataArray.count);
        
        self.firstVideoModel = self.dataArray.firstObject;
        CGRect firstFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.firstImageView  = [[UIImageView alloc] initWithFrame: firstFrame];
        [self.firstImageView sd_setImageWithURL: self.firstVideoModel.imageURL];
        [self addSubview:self.firstImageView];
        self.currentIndexOfImageView = 0;
        
        if (self.dataArray.count > 1) {
            CGRect secondFrame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
            self.secondImageView = [[UIImageView alloc] initWithFrame:secondFrame];
            
            self.secondVideoModel = self.dataArray[1];
            [self.secondImageView sd_setImageWithURL:self.secondVideoModel.imageURL];
            [self addSubview:self.secondImageView];
            self.currentIndexOfImageView++;
        }
        
        if (self.dataArray.count > 2) {
            CGRect thirdFrame = CGRectMake(0, self.frame.size.height * 2, self.frame.size.width, self.frame.size.height);
            self.thirdImageView = [[UIImageView alloc] initWithFrame:thirdFrame];
            
            self.thirdVideoModel = self.dataArray[2];
            [self.thirdImageView sd_setImageWithURL:self.thirdVideoModel.imageURL];
            [self addSubview:self.thirdImageView];
            self.currentIndexOfImageView++;
        }
        
        [self playVideo];
    }else {
        for (MBVideoModel *model in data) {
            [self.dataArray addObject:model];
        }
        
        if (data.count > 0) {//如果获取到新的数据，则自动上滑显示
            self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * self.dataArray.count);
            self.contentOffset = CGPointMake(0, self.frame.size.height * self.currentIndexOfImageView);
        }
        
        self.isLoading = NO;
    }
}

#pragma mark - Private

- (void)playVideo {
    if (self.firstImageView.frame.origin.y == self.contentOffset.y) {
        self.playerView.frame = self.firstImageView.frame;
    }
    
    if (self.secondImageView.frame.origin.y == self.contentOffset.y) {
        self.playerView.frame = self.secondImageView.frame;
    }
    
    if (self.thirdImageView.frame.origin.y == self.contentOffset.y) {
        self.playerView.frame = self.thirdImageView.frame;
    }
    
    MBVideoModel *videoModel = [self.dataArray objectAtIndex:self.currentIndexOfShowView];
    
    [self.playerView setUrlString:videoModel.videoURL.absoluteString];
    self.playerView.playDelegate = self;
    [self addSubview:self.playerView];
    [self.playerView setHidden:YES];
}

#pragma mark - Protocol conformance

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset_y = scrollView.contentOffset.y;
    
    CGPoint translatePoint = [scrollView.panGestureRecognizer translationInView:scrollView];
    if (self.dataArray.count == 0) {
        return;
    }
    
    if (offset_y > (self.frame.size.height * (self.dataArray.count - 1))) {
        if (self.isLoading) {
            return;
        }
        NSLog(@"拉到底部了");
        
        self.isLoading = YES;
        [self.dataDelegate pullNewData]; //如果拉到了底部，则去拉取新数据
        return;
    }

    if (self.currentIndexOfImageView > self.dataArray.count - 1) {
        return;
    }

    //向下滑动。
    if (offset_y > (self.frame.size.height * self.currentIndexOfImageView) && translatePoint.y < 0) {
        self.currentIndexOfImageView++;
        NSLog(@"lalalalalal");

        if (self.currentIndexOfImageView == self.dataArray.count) {
            return;
        }

        self.firstImageView.frame = self.secondImageView.frame;
        self.firstImageView.image = self.secondImageView.image;
        self.secondImageView.frame = self.thirdImageView.frame;
        self.firstImageView.image = self.secondImageView.image;
        self.secondImageView.image = self.thirdImageView.image;

        CGRect frame = self.thirdImageView.frame;
        frame.origin.y += self.frame.size.height;
        self.thirdImageView.frame = frame;
        self.thirdVideoModel = [self.dataArray objectAtIndex:self.currentIndexOfImageView];
        [self.thirdImageView sd_setImageWithURL:self.thirdVideoModel.imageURL];
    }
    
    if (offset_y >= self.frame.size.height * (self.currentIndexOfShowView + 1) && translatePoint.y < 0) {
        self.currentIndexOfShowView++;
        NSLog(@"should Play");
        [self playVideo];
    }
    
    if (offset_y < 0) {
        NSLog(@"已经到顶部了");
        return;
    }
    
    //向上滑动
    if (translatePoint.y > 0 && offset_y < self.secondImageView.frame.origin.y) {
        if (self.currentIndexOfImageView >= 3) {
            self.thirdImageView.frame = self.secondImageView.frame;
            self.thirdImageView.image = self.secondImageView.image;
            self.secondImageView.frame = self.firstImageView.frame;
            self.secondImageView.image = self.firstImageView.image;
            
            CGRect frame = self.firstImageView.frame;
            frame.origin.y -= self.frame.size.height;
            self.firstImageView.frame = frame;
            self.firstVideoModel = [self.dataArray objectAtIndex:self.currentIndexOfImageView - IMAGEVIEW_COUNT];
            [self.firstImageView sd_setImageWithURL:self.firstVideoModel.imageURL];
            
            self.currentIndexOfImageView--;
        }
    }
    
    if (translatePoint.y > 0 && offset_y <= self.frame.size.height * (self.currentIndexOfShowView - 1) ) {
        self.currentIndexOfShowView--;
        NSLog(@"should back play");
        [self playVideo];
    }
}

- (void)playerViewDidPrepareToShowVideo {
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self addSubview:self.playerView];
        self.playerView.hidden = NO;
    });
}



@end
