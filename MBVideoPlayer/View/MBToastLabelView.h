//
//  MBToastLabelView.h
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/14.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 提示类
 */
@interface MBToastLabelView : UIView

+ (instancetype)message:(NSString *)message delaySecond:(CGFloat)second;

@end
