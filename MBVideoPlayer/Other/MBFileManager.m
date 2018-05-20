//
//  MBFileManager.m
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/9.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import "MBFileManager.h"

#import <CommonCrypto/CommonDigest.h>

@implementation MBFileManager

/**
 对URL进行MD5加密作为临时文件的名称
 
 @param url 文件下载链接
 @return 加密后的文件名
 */
+ (NSString *)MD5ForDownloadURL:(NSURL *)url {
    NSData *data = [[url absoluteString] dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return [output copy];
}

+ (BOOL)fileExistAtPath:(NSString *)path {
    BOOL isDir = NO;
    
    BOOL exist =  [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    
    return exist && !isDir;
}

+ (NSString *)pathUnderDocumentsWithName:(NSString *)folderName {
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *downloadFolder = [documents stringByAppendingPathComponent:folderName];
    //    [self handleDownloadFolder:downloadFolder];
    return downloadFolder;
}

+ (BOOL)createDirectoryWithPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    BOOL isExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    
    if (!isExist || !isDir) {//如果路径不存在，或者不是一个目录则重新创建
        NSError *error;
        
        [fileManager createDirectoryAtPath:path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        
        if (error) {
            NSLog(@"create Path fail");
            return NO;
        }else {
            return YES;
        }
    }else {
        return YES;
    }
}

+ (NSString *)savePathWithURL:(NSURL *)url {
    NSString *fileDocumentName = [self MD5ForDownloadURL:url];//md5
    NSString *documentPath = [self pathUnderDocumentsWithName:@"MBVideoPlayer"];//xxx/Documents/MBVideoPlayer
    NSString *path = [documentPath stringByAppendingPathComponent:fileDocumentName];
    [self createDirectoryWithPath:path];
    
    return [path stringByAppendingPathComponent:@"play.mp4"];
}

+ (BOOL)createFileInPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }

    return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
}

+ (long long)currentCacheSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentPath = [self pathUnderDocumentsWithName:@"MBVideoPlayer"];//xxx/Documents/MBVideoPlayer
    
    if (![fileManager fileExistsAtPath:documentPath]) {
        return 0;
    }
    
    NSEnumerator *childFilesEnumerator = [[fileManager subpathsAtPath:documentPath] objectEnumerator];
    NSString *fileName;
    
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject])) {
        NSString *fileAbsolutePath = [documentPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    
    return folderSize / (1024 * 1024);
}

+ (long long)fileSizeAtPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:nil];
        
        NSNumber *fileSize = [attributes objectForKey:NSFileSize];
        if (fileSize != nil) {
            return [fileSize longLongValue];
        }
    }
    
    return 0;
}

+ (BOOL)clearCache {
    NSString *documentPath = [self pathUnderDocumentsWithName:@"MBVideoPlayer"];//xxx/Documents/MBVideoPlayer
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:documentPath error:&error];
    
    if (error) {
        return NO;
    }else {
        return YES;
    }
}

@end
