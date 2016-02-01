//
//  DownloadViewController.h
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadViewController : UIViewController

+ (instancetype)sharedInstance;

- (void)downloadFileWithURLString:(NSString *)URLString filename:(NSString *)filename;

@end
