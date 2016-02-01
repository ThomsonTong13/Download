//
//  DownloadInfoModel+CoreDataProperties.m
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DownloadInfoModel+CoreDataProperties.h"

@implementation DownloadInfoModel (CoreDataProperties)

@dynamic urlString;
@dynamic totalUnitCount;
@dynamic resumeData;
@dynamic isFinished;
@dynamic filePath;
@dynamic fileName;
@dynamic completeUnitCount;

@end
