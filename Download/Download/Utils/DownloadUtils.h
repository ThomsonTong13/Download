//
//  DownloadUtils.h
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CACHED_PLIST_NAME @"resumeData.plist"
#define MB (1024 * 1024)

@interface DownloadUtils : NSObject

+ (NSString *)documentPath;

+ (NSString *)prepareDirectoryForFile:(NSString *)filePath;

+ (BOOL)prepareDirectory:(NSString *)dir;

@end
