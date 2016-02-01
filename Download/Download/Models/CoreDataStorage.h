//
//  CoreDataStorage.h
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DownloadInfoModel;

@interface CoreDataStorage : NSObject

- (NSManagedObjectContext *)privateThreadContext;

- (NSManagedObjectContext *)mainThreadContext;

- (DownloadInfoModel *)saveInfoWithURLString:(NSString *)URLString;
- (void)updateInfoWithURLString:(NSString *)URLString
                     resumeData:(NSData *)resumeData
              completeUnitCount:(NSString *)completeUnitCount
                 totalUnitCount:(NSString *)totalUnitCount;
- (void)updateInfoWithURLString:(NSString *)URLString
                       filePath:(NSString *)filePath;
- (DownloadInfoModel *)modelWithURLString:(NSString *)URLString;
- (NSArray *)allModels;

@end
