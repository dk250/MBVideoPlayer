//
//  MBURLTaskModel.m
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/11.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import "MBURLTaskModel.h"
#import "MBFileManager.h"
#import "MBNetworkManager.h"

@implementation MBURLTaskModel

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        self.downloadURL = url;
        NSString *savePath = [MBFileManager savePathWithURL:self.downloadURL];
        NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:savePath] options:NSDataReadingMappedIfSafe error:nil];
        self.downloadingOffset = (long long)filedata.length ? (long long)filedata.length : 0;
        self.videoLength = [[MBNetworkManager new] totalBytesByFileURL:self.downloadURL.absoluteString];
    }
    
    return self;
}

@end
