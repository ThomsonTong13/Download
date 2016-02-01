//
//  DownloadInfoModel+CoreDataProperties.h
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DownloadInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadInfoModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *urlString;
@property (nullable, nonatomic, retain) NSString *totalUnitCount;
@property (nullable, nonatomic, retain) NSData *resumeData;
@property (nullable, nonatomic, retain) NSNumber *isFinished;
@property (nullable, nonatomic, retain) NSString *filePath;
@property (nullable, nonatomic, retain) NSString *fileName;
@property (nullable, nonatomic, retain) NSString *completeUnitCount;

@end

NS_ASSUME_NONNULL_END
