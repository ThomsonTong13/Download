//
//  DownloadViewController.m
//  Download
//
//  Created by Thomson on 16/1/29.
//  Copyright © 2016年 Thomson. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadUtils.h"
#import "DownloadCell.h"
#import "DownloadInfoModel.h"
#import "DownloadManager.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString * const kCellIdentifier = @"cellIdentifier";

@interface DownloadViewController () <UITableViewDataSource, UITableViewDelegate>
{
    DownloadManager     *_manager;
    NSMutableArray      *_itemsArray;

    UITableView         *_tableView;
}

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumeData;

@end

@implementation DownloadViewController

#pragma mark - Lifecycle

+ (instancetype)sharedInstance
{
    static DownloadViewController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DownloadViewController alloc] init];
    });

    return instance;
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        _manager = [DownloadManager manager];
        _itemsArray = [[NSMutableArray alloc] initWithArray:[_manager allDownloadInfo]];
    }

    return self;
}

- (void)loadView
{
    [super loadView];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60.0;

    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DownloadCell class]) bundle:[NSBundle mainBundle]]
     forCellReuseIdentifier:kCellIdentifier];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configViews];

    [self setupActionBinds];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadCell *targetCell = (DownloadCell *)cell;
    DownloadInfoModel *model = _itemsArray[indexPath.row];

    targetCell.completeUnitCount.text = model.completeUnitCount;
    targetCell.totalUnitCount.text = model.totalUnitCount;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSURLSessionDownloadTask *downloadTask = [_manager downloadTaskWithIdentifier:@(indexPath.row)];

    DownloadCell *cell = (DownloadCell *)[tableView cellForRowAtIndexPath:indexPath];

    BOOL isDownloading = !cell.downloadingView.hidden;

    if (isDownloading) // 正在下载，点击停止下载
    {
        [cell.downloadingView setHidden:isDownloading];
        [cell.stopDownloadView setHidden:!isDownloading];

        if (downloadTask)
        {
            [_manager setDownloadTaskPause:downloadTask
                               completionBlock:^(NSData *resumeData) {
                               }];
        }
    }
    else // 继续下载
    {
        [cell.downloadingView setHidden:isDownloading];
        [cell.stopDownloadView setHidden:!isDownloading];

        DownloadInfoModel *model = _itemsArray[indexPath.row];

        NSData *resumeData = model.resumeData;

        if (resumeData)
        {
            @weakify(self);
            [_manager downloadTaskWithResumeData:resumeData
                                      identifier:@(indexPath.row)
                                     destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {

                                         @strongify(self);

                                         dispatch_async(dispatch_get_main_queue(), ^{

                                             NSString *URLString = [[response URL] absoluteString];

                                             [self->_itemsArray removeObject:[self->_manager modelWithURLString:URLString]];
                                             [self->_tableView reloadData];
                                         });

                                         NSDate *now = [NSDate date];
                                         NSDateFormatter *format = [[NSDateFormatter alloc] init];
                                         format.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
                                         format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                                         NSString *dateString = [format stringFromDate:now];

                                         return [NSURL URLWithString:[DownloadUtils prepareDirectoryForFile:dateString]];
                                     }
                               completionHandler:nil];
        }
    }
}

#pragma mark - Public Methods

- (void)downloadFileWithURLString:(NSString *)URLString filename:(NSString *)filename
{
    @weakify(self);
    DownloadInfoModel *model = [_manager downloadTaskWithURLString:URLString
                                                        identifier:@([_itemsArray count])
                                                       destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {

                                                           @strongify(self);

                                                           dispatch_async(dispatch_get_main_queue(), ^{

                                                               NSString *URLString = [[response URL] absoluteString];

                                                               [self->_itemsArray removeObject:[self->_manager modelWithURLString:URLString]];
                                                               [self->_tableView reloadData];
                                                           });

                                                           return [NSURL URLWithString:[DownloadUtils prepareDirectoryForFile:filename]];
                                                       }
                                                 completionHandler:nil];

    [_itemsArray addObject:model];
    [_tableView reloadData];
}

#pragma mark - Private Methods

- (void)configViews
{
    [self.view addSubview:_tableView];

    [_tableView reloadData];
}

- (void)setupActionBinds
{
    @weakify(self);
    [_manager setDownloadTaskProgressBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, CGFloat progress, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {

        @strongify(self);

        NSLog(@"%f", progress);

        NSNumber *row = (NSNumber *)[self->_manager identifierWithTask:downloadTask];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[row unsignedIntValue] inSection:0];
        DownloadCell *cell = (DownloadCell *)[self->_tableView cellForRowAtIndexPath:indexPath];

        dispatch_async(dispatch_get_main_queue(), ^{

            cell.progressView.progress = progress;

            double written = (double)totalBytesWritten / MB;
            double total = (double)totalBytesExpectedToWrite / MB;

            cell.completeUnitCount.text = [NSString stringWithFormat:@"%.2fMB", written];
            cell.totalUnitCount.text = [NSString stringWithFormat:@"%.2fMB", total];
        });
    }];
}

@end
