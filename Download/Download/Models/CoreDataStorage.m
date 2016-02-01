//
//  CoreDataStorage.m
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "CoreDataStorage.h"
#import "DownloadUtils.h"
#import "DownloadInfoModel.h"

@interface CoreDataStorage ()
{
    NSPersistentStoreCoordinator    *_coordinator;
    
    NSManagedObjectContext          *_mainThreadContext;
    
    NSManagedObjectContext          *_rootContext;
}

@end

@implementation CoreDataStorage

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        _rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        _rootContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    }

    return self;
}

- (void)dealloc
{
    if (![NSThread mainThread]) return;

    if ([self.mainThreadContext hasChanges])
    {
        [self.mainThreadContext save:nil];

        [_rootContext performBlockAndWait:^{
            [_rootContext save:nil];
        }];
    }
}

- (void)saveContext
{
    [self.mainThreadContext save:nil];

    [_rootContext performBlock:^{
        [_rootContext save:nil];
    }];
}

#pragma mark - Public Methods

- (NSManagedObjectContext *)privateThreadContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

    context.parentContext = self.mainThreadContext;
    
    return context;
}

- (DownloadInfoModel *)saveInfoWithURLString:(NSString *)URLString
{
    DownloadInfoModel *model = [self modelWithURLString:URLString];

    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([DownloadInfoModel class]) inManagedObjectContext:self.mainThreadContext];

        model.isFinished = [NSNumber numberWithBool:NO];
        model.urlString = URLString;

        [self saveContext];
    }

    return model;
}

- (void)updateInfoWithURLString:(NSString *)URLString
                     resumeData:(NSData *)resumeData
              completeUnitCount:(NSString *)completeUnitCount
                 totalUnitCount:(NSString *)totalUnitCount
{
    DownloadInfoModel *model = [self modelWithURLString:URLString];

    if (model)
    {
        model.urlString = URLString;
        model.resumeData = [[NSData alloc] initWithData:resumeData];
        model.isFinished = [NSNumber numberWithBool:NO];
        model.filePath = nil;
        model.completeUnitCount = completeUnitCount;
        model.totalUnitCount = totalUnitCount;

        [self saveContext];
    }
}

- (void)updateInfoWithURLString:(NSString *)URLString
                       filePath:(NSString *)filePath
{
    DownloadInfoModel *model = [self modelWithURLString:URLString];

    if (model)
    {
        model.urlString = URLString;
        model.resumeData = nil;
        model.isFinished = [NSNumber numberWithBool:YES];
        model.filePath = filePath;
        model.completeUnitCount = nil;

        [self saveContext];
    }
}

- (NSArray *)allModels
{
    if (![NSThread isMainThread]) return nil;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFinished == %@", @(NO)];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([DownloadInfoModel class])];
    fetchRequest.predicate = predicate;
    fetchRequest.returnsObjectsAsFaults = NO;

    NSError *error = nil;

    NSArray *modelList = [self.mainThreadContext executeFetchRequest:fetchRequest error:&error];

    if (modelList)
    {
        return modelList;
    }

    return nil;
}

- (DownloadInfoModel *)modelWithURLString:(NSString *)URLString
{
    if (![NSThread isMainThread]) return nil;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlString == %@", URLString];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([DownloadInfoModel class])];
    fetchRequest.predicate = predicate;
    fetchRequest.returnsObjectsAsFaults = NO;

    NSError *error = nil;

    NSArray *modelList = [self.mainThreadContext executeFetchRequest:fetchRequest error:&error];

    if (modelList)
    {
        return [modelList firstObject];
    }

    return nil;
}

#pragma mark - Private Methods

- (NSString *)momResource
{
    return @"DownloadDataModel";
}

- (NSManagedObjectModel *)objectModel
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];

    NSString *momPath = [bundle pathForResource:[self momResource] ofType:@"momd"];
    if(!momPath)
    {
        momPath = [bundle pathForResource:[self momResource] ofType:@"mom"];
    }

    return [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:momPath]];
}

- (NSString *)databaseFileName
{
    return @"DownloadInfo.sqlite";
}

- (NSString *)persistentStoreDirectory
{
    NSString *relativePath = [[DownloadUtils documentPath] stringByAppendingString:@"/Database"];

    [DownloadUtils prepareDirectory:relativePath];

    return relativePath;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_coordinator) return _coordinator;

    NSManagedObjectModel *mom = [self objectModel];

    if (!mom) return nil;

    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];

    NSString *docsPath = [self persistentStoreDirectory];

    NSString *storePath = [docsPath stringByAppendingPathComponent:[self databaseFileName]];

    NSError         *error = nil;
    NSDictionary    *options = @{ NSMigratePersistentStoresAutomaticallyOption: @(YES),
                                  NSInferMappingModelAutomaticallyOption : @(YES) };
    NSURL           *storeURL = [NSURL fileURLWithPath:storePath];

    if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                    configuration:nil
                                              URL:storeURL
                                          options:options
                                            error:&error])
    {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

        if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:storeURL
                                              options:options
                                                error:&error])
        {
            [_coordinator addPersistentStoreWithType:NSInMemoryStoreType
                                       configuration:nil
                                                 URL:storeURL
                                             options:nil
                                               error:&error];
        }
    }

    return _coordinator;
}

- (NSManagedObjectContext *)mainThreadContext
{
    if (_mainThreadContext) return _mainThreadContext;

    _mainThreadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

    _mainThreadContext.parentContext = _rootContext;

    return _mainThreadContext;
}

@end
