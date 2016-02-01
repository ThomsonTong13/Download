//
//  DownloadManager.h
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class DownloadInfoModel;

@interface DownloadManager : AFURLSessionManager

///---------------------
/// @name Initialization
///---------------------

/**
 Creates and returns an `DownloadManager` object.
 */
+ (instancetype)manager;

///-----------------------------
/// @name Running Download Tasks
///-----------------------------

/**
 Creates a `DownloadInfoEntity` object with the specified URLString
 
 @param URLString The HTTP URLString for the request.
 @param identifier An identifier to sign the downloadTask object.
 @param destination A block object to be executed in order to determine the destination of the downloaded file. This block takes two arguments, the target path & the server response, and returns the desired file URL of the resulting download. The temporary file used during the download will be automatically deleted after being moved to the returned URL.
 @param completionHandler A block to be executed when a task finishes. This block has no return value and takes three arguments: the server response, the path of the downloaded file, and the error describing the network or parsing error that occurred, if any.
 
 @warning If using a background `NSURLSessionConfiguration` on iOS, these blocks will be lost when the app is terminated. Background sessions may prefer to use `-setDownloadTaskDidFinishDownloadingBlock:` to specify the URL for saving the downloaded file, rather than the destination block of this method.
 */
- (DownloadInfoModel *)downloadTaskWithURLString:(NSString *)URLString
                                      identifier:(id)identifier
                                     destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                               completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

/**
 Creates an `NSURLSessionDownloadTask` with the specified resume data.
 
 @param resumeData The data used to resume downloading.
 @param identifier An identifier to sign the downloadTask object.
 @param destination A block object to be executed in order to determine the destination of the downloaded file. This block takes two arguments, the target path & the server response, and returns the desired file URL of the resulting download. The temporary file used during the download will be automatically deleted after being moved to the returned URL.
 @param completionHandler A block to be executed when a task finishes. This block has no return value and takes three arguments: the server response, the path of the downloaded file, and the error describing the network or parsing error that occurred, if any.
 */
- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                              identifier:(id)identifier
                                             destination:(NSURL *(^)(NSURL *, NSURLResponse *))destination
                                       completionHandler:(void (^)(NSURLResponse *, NSURL *, NSError *))completionHandler;

///-----------------------
/// @name Database Handler
///-----------------------

/**
 Returns the entity of DB.
 
 @param URLString The key which search from DB.
 
 @return An `DownloadInfoModel` object describe downloadInfo.
 */
- (DownloadInfoModel *)modelWithURLString:(NSString *)URLString;

/**
 Returns the unFinished tasks from DB.
 */
- (NSArray *)allDownloadInfo;

/**
 Gets all memory tasks and save it to DB.
 */
- (void)saveData;

///-----------------------------------------------
/// @name Setting Download Task Delegate Callbacks
///-----------------------------------------------

/**
 Sets a block to be executed periodically to track download progress, as handled by the `NSURLSessionDownloadDelegate` method `URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesWritten:totalBytesExpectedToWrite:`.
 
 @param block A block object to be called when an undetermined number of bytes have been downloaded from the server. This block has no return value and takes five arguments: the session, the download task, the progress, the totalBytesWritten, the totalBytesExpectedToWrite, as initially determined by the expected content size of the `NSHTTPURLResponse` object. This block may be called multiple times, and will execute on the session manager operation queue.
 */
- (void)setDownloadTaskProgressBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, CGFloat progress, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block;

/**
 Pause downloadTask and save it to DB.
 
 @param downloadTask The session download task. Must not be `nil`.
 @param block A block object to be called when `cancelByProducingResumeData:` Callbacks arrived. This block has no return value and takes one arguments: the resumeData.
 */
- (void)setDownloadTaskPause:(NSURLSessionDownloadTask *)downloadTask completionBlock:(void (^)(NSData *resumeData))block;

/**
 Returns the downloadTask of the specified task.
 
 @param identifier An identifier to sign the downloadTask object.
 
 @return An `NSURLSessionDownloadTask` object execute downloading tasks.
 */
- (NSURLSessionDownloadTask *)downloadTaskWithIdentifier:(id)identifier;

/**
 Returns the identifier of the specified task.
 
 @param downloadTask The session download task. Must not be `nil`.
 
 @return An `id` object from `mutableTasksKeyedByIdentifier` dictionary.
 */
- (id)identifierWithTask:(NSURLSessionDownloadTask *)downloadTask;

@end
