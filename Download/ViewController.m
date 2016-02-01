//
//  ViewController.m
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "ViewController.h"
#import "DownloadViewController.h"

@interface ViewController ()

@property (nonatomic, strong) DownloadViewController *downloadVc;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)downloadQQ:(id)sender
{
    [self.downloadVc downloadFileWithURLString:@"http://adcdownload.apple.com/Developer_Tools/Xcode_7.3_beta_2/Xcode_7.3_beta_2.dmg" filename:@"Xcode_7.3_beta_2.dmg"];
}

- (IBAction)downloadPage:(id)sender
{
    [self.navigationController pushViewController:self.downloadVc animated:YES];
}

- (IBAction)downloadPDF:(id)sender
{
    [self.downloadVc downloadFileWithURLString:@"http://enterprise.huawei.com/en/static/HW-376150.pdf" filename:@"HW-376150.pdf"];
}

- (DownloadViewController *)downloadVc
{
    if (!_downloadVc)
    {
        _downloadVc = [DownloadViewController sharedInstance];
    }

    return _downloadVc;
}

@end
