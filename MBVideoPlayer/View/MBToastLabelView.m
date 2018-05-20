//
//  MBToastLabelView.m
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/14.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import "MBToastLabelView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation MBToastLabelView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)message:(NSString *)message delaySecond:(CGFloat)second {
    MBToastLabelView *noticeLabel = nil;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    label.backgroundColor = [UIColor clearColor];
    label.text = message;
    
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    CGFloat width = [label.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH / 4 * 3 - 20, 33) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size.width;
    
    CGFloat height = [label.text boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil].size.height;
    
    [label setFrame:CGRectMake(10, 10, width, height)];
    
    noticeLabel = [[MBToastLabelView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-width/2, SCREEN_HEIGHT/2-height/2+10, width + 20, height + 20)];
    [noticeLabel addSubview:label];
    noticeLabel.backgroundColor = [UIColor blackColor];
    noticeLabel.alpha = 0.7;
    noticeLabel.layer.cornerRadius = 8;
    noticeLabel.clipsToBounds = YES;
    
    [noticeLabel removeFromItsSuperView:noticeLabel second:second];
    
    return noticeLabel;
}

-(void)removeFromItsSuperView:(MBToastLabelView *)labelView second:(CGFloat)second{
    
    __weak typeof(labelView) weakSelf = labelView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf removeFromSuperview];
    });
    
}


@end
