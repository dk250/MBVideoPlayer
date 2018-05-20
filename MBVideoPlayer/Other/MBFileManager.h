//
//  MBFileManager.h
//  MBVideoPlayer
//
//  Created by chenda on 2018/5/9.
//  Copyright © 2018年 chenda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBFileManager : NSObject

/**
 对url进行md5加密
 
 @param url 文件url
 @return 返回加密结果
 */
+ (NSString *)MD5ForDownloadURL:(NSURL *)url;

/**
 判断文件是否存在

 @param path 文件路径
 @return yes or no
 */
+ (BOOL)fileExistAtPath:(NSString *)path;

/**
 返回沙盒Documents目录下自定义文件夹地址
 
 @param folderName 文件夹名称
 @return 路径
 */
+ (NSString *)pathUnderDocumentsWithName:(NSString *)folderName;

/**
 创建文件目录
 
 @param path 目录
 @return yes or no
 */
+ (BOOL)createDirectoryWithPath:(NSString *)path;


/**
 返回文件路径

 @param url 文件下载URL
 @return 文件路径
 */
+ (NSString *)savePathWithURL:(NSURL *)url;


/**
 根据文件路径创建文件

 @param path 文件路径
 @return 创建结果,yes or no
 */
+ (BOOL)createFileInPath:(NSString *)path;

/**
 获取当前缓存大小

 @return 缓存大小，单位M
 */
+ (long long)currentCacheSize;

/**
 删除缓存

 @return 删除缓存结果，成功或者失败
 */
+ (BOOL)clearCache;

@end
