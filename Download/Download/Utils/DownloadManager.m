//
//  DownloadManager.m
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "DownloadManager.h"
#import "CoreDataStorage.h"
#import "DownloadInfoModel.h"
#import "DownloadUtils.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

typedef void (^AFURLSessionDownloadTaskProgressBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, CGFloat progress, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);

@interface DownloadManager ()

/**
 The progress block.
 */
@property (readwrite, nonatomic, copy) AFURLSessionDownloadTaskProgressBlock downloadTaskDidProgress;
/**
 The execute tasks which it save to memory.
 */
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableTasksKeyedByIdentifier;

/**
 The database handler.
 */
@property (nonatomic, strong) CoreDataStorage *storage;

@end

@implementation DownloadManager

#pragma mark - Lifecycle

+ (instancetype)manager
{
    static DownloadManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[[self class] alloc] init];
    });

    return _manager;
}

- (instancetype)init
{
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.thomson.download"]];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super initWithSessionConfiguration:configuration];

    if (!self)
    {
        return nil;
    }

    _mutableTasksKeyedByIdentifier = [[NSMutableDictionary alloc] initWithCapacity:0];
    _storage = [[CoreDataStorage alloc] init];

    return self;
}

#pragma mark - Download Tasks

- (DownloadInfoModel *)downloadTaskWithURLString:(NSString *)URLString
                                      identifier:(id)identifier
                                     destination:(NSURL *(^)(NSURL *, NSURLResponse *))destination
                               completionHandler:(void (^)(NSURLResponse *, NSURL *, NSError *))completionHandler
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];

    NSURLSessionDownloadTask *task = [self downloadTaskWithRequest:request progress:nil destination:destination completionHandler:completionHandler];
    [task resume];

    self.mutableTasksKeyedByIdentifier[identifier] = task;

    // start download, save information to db.
    DownloadInfoModel *model = [_storage saveInfoWithURLString:URLString];

    return model;
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                              identifier:(id)identifier destination:(NSURL *(^)(NSURL *, NSURLResponse *))destination
                                       completionHandler:(void (^)(NSURLResponse *, NSURL *, NSError *))completionHandler
{
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithResumeData:resumeData
                                                                     progress:nil
                                                                  destination:destination
                                                            completionHandler:completionHandler];

    self.mutableTasksKeyedByIdentifier[identifier] = downloadTask;

    [downloadTask resume];

    return downloadTask;
}

#pragma mark - Override

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [super URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];

    __block DownloadManager *blockSelf = self;

    [self.mutableTasksKeyedByIdentifier enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, NSURLSessionDownloadTask *task, BOOL *stop) {

        if (downloadTask == task)
        {
            [blockSelf.mutableTasksKeyedByIdentifier removeObjectForKey:identifier];
        }
    }];

    [_storage updateInfoWithURLString:[[[downloadTask currentRequest] URL] absoluteString] filePath:[location absoluteString]];
}

- (NSArray *)downloadTasks
{
    NSArray *downloadTasks = [self.mutableTasksKeyedByIdentifier allValues];

    return downloadTasks;
}

#pragma mark - Public Methods

- (DownloadInfoModel *)modelWithURLString:(NSString *)URLString
{
    return [_storage modelWithURLString:URLString];
}

- (NSArray *)allDownloadInfo
{
    NSArray *allDownloading = [_storage allModels];

    return allDownloading;
}

- (void)saveData
{
    NSArray *allDownloadTasks = [self downloadTasks];

    for (NSURLSessionDownloadTask *downloadTask in allDownloadTasks)
    {
        [self setDownloadTaskPause:downloadTask completionBlock:nil];
    }
}

- (void)setDownloadTaskPause:(NSURLSessionDownloadTask *)downloadTask completionBlock:(void (^)(NSData *))block
{
    [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {

        double written = (double)downloadTask.countOfBytesReceived / MB;
        double total = (double)downloadTask.countOfBytesExpectedToReceive / MB;

        [_storage updateInfoWithURLString:[[[downloadTask currentRequest] URL] absoluteString]
                               resumeData:resumeData
                        completeUnitCount:[NSString stringWithFormat:@"%.2fMB", written]
                           totalUnitCount:[NSString stringWithFormat:@"%.2fMB", total]];
    }];
}

- (void)setDownloadTaskProgressBlock:(void (^)(NSURLSession *, NSURLSessionDownloadTask *, CGFloat, int64_t, int64_t))block
{
    self.downloadTaskDidProgress = block;

    @weakify(self);
    [self setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {

        @strongify(self);

        // calculate precent
        CGFloat precent = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;

        if (self.downloadTaskDidProgress)
        {
            self.downloadTaskDidProgress(session, downloadTask, precent, totalBytesWritten, totalBytesExpectedToWrite);
        }
    }];
}

- (id)identifierWithTask:(NSURLSessionDownloadTask *)downloadTask
{
    __block id obtainKey = nil;

    [self.mutableTasksKeyedByIdentifier enumerateKeysAndObjectsUsingBlock:^(id key, NSURLSessionDownloadTask *item, BOOL *stop) {
        if (item == downloadTask)
        {
            obtainKey = key;
            *stop = YES;
        }
    }];

    return obtainKey;
}

- (NSURLSessionDownloadTask *)downloadTaskWithIdentifier:(id)identifier
{
    return self.mutableTasksKeyedByIdentifier[identifier];
}

@end
