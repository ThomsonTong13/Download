//
//  DownloadCell.h
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *topicText;
@property (weak, nonatomic) IBOutlet UIView *downloadingView;
@property (weak, nonatomic) IBOutlet UILabel *stopDownloadView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *completeUnitCount;
@property (weak, nonatomic) IBOutlet UILabel *totalUnitCount;

@end
