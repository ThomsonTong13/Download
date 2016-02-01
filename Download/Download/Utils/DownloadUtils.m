//
//  DownloadUtils.m
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "DownloadUtils.h"

@implementation DownloadUtils

+ (NSString *)documentPath
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

    return documentPath;
}

+ (NSString *)prepareDirectoryForFile:(NSString *)filePath
{
    NSString *docPath = [DownloadUtils documentPath];
    NSString *fullFilePath = [docPath stringByAppendingPathComponent:filePath];

    NSRange docRange = [filePath rangeOfString:docPath];
    if (docRange.location != NSNotFound)
    {
        fullFilePath = filePath;
    }

    NSString *subDirPath = [filePath stringByDeletingLastPathComponent];

    BOOL succeeded = [self prepareDirectory:subDirPath];

    if (!succeeded)
    {
        return nil;
    }

    return fullFilePath;
}

+ (BOOL)prepareDirectory:(NSString *)dir
{
    NSString *docPath = [DownloadUtils documentPath];
    NSString *fullDirPath = [docPath stringByAppendingPathComponent:dir];

    NSRange docRange = [dir rangeOfString:docPath];
    if (docRange.location != NSNotFound)
    {
        fullDirPath = dir;
    }

    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:fullDirPath isDirectory:nil])
    {
        [fileManager createDirectoryAtPath:fullDirPath withIntermediateDirectories:YES attributes:nil error:&error];

        if (error)
        {
            NSLog(@"Failed to create dir: %@, with error: %@", fullDirPath, [error localizedDescription]);

            return NO;
        }
    }

    return YES;
}

@end
