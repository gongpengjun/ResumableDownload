//
//  BTRouteAccessoryButton.m
//  Venti
//
//  Created by 巩 鹏军 on 13-9-2.
//  Copyright (c) 2013年 Beijing Zhixun Innovation Co. Ltd. All rights reserved.
//

#import "BTRouteAccessoryButton.h"
#import "DACircularProgressView.h"

NSString* const kBTDownloadStartNotification = @"kBTDownloadStartNotification";
NSString* const kBTDownloadPauseNotification = @"kBTDownloadPauseNotification";
NSString* const kBTDownloadStopNotification  = @"kBTDownloadStopNotification";
NSString* const kBTDownloadViewNotification  = @"kBTDownloadViewNotification";

@interface BTRouteAccessoryButton ()
@property IBOutlet UIButton* bgButton;
@property IBOutlet DACircularProgressView* circularProgressView;
@property IBOutlet UIImageView* actionImageView;
@end

@implementation BTRouteAccessoryButton

- (void)dealloc {
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (id)init
{
    UIImage* image = [UIImage imageNamed:@"btn_view"];
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    self = [self initWithFrame:rect];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //NSLog(@"%s,%d self:<%@ %p>",__FUNCTION__,__LINE__,NSStringFromClass([self class]),self);
    [self performSelector:@selector(configureCircularProgressView) withObject:nil afterDelay:0];
}

- (void)configureCircularProgressView {
    self.circularProgressView.trackTintColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
    self.circularProgressView.progressTintColor = [UIColor colorWithRed:90/255.0 green:203/255.0 blue:218/255.0 alpha:1.0];
    self.circularProgressView.thicknessRatio = 0.2f;
    self.circularProgressView.progress = 0.0f;
}

- (void)setStatus:(BTDownloadStatus)status {
    _status = status;
    switch (_status) {
        default:
        case BTDownloadNotStart:
            self.circularProgressView.progress = 0.0f;
            self.actionImageView.image = [UIImage imageNamed:@"btn_download"];
            break;
        case BTDownloading:
            self.actionImageView.image = [UIImage imageNamed:@"btn_pause"];
            break;
        case BTDownloadPaused:
            self.actionImageView.image = [UIImage imageNamed:@"btn_start"];
            break;
        case BTDownloadFinished:
            self.circularProgressView.progress = 0.0f;
            self.actionImageView.image = [UIImage imageNamed:@"btn_view"];
            break;
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.circularProgressView.progress = progress;
}

- (IBAction)buttonClicked:(id)sender {
    NSLog(@"%s,%d status: %d",__FUNCTION__,__LINE__,self.status);
    switch (self.status) {
        case BTDownloadNotStart:
            self.status = BTDownloading;
            [[NSNotificationCenter defaultCenter] postNotificationName:kBTDownloadStartNotification object:self.indexPath];
            break;
        case BTDownloading:
            self.status = BTDownloadPaused;
            [[NSNotificationCenter defaultCenter] postNotificationName:kBTDownloadPauseNotification object:self.indexPath];
            break;
        case BTDownloadPaused:
            self.status = BTDownloading;
            [[NSNotificationCenter defaultCenter] postNotificationName:kBTDownloadStartNotification object:self.indexPath];
            break;
        case BTDownloadFinished:
            // do notthing
            [[NSNotificationCenter defaultCenter] postNotificationName:kBTDownloadViewNotification object:self.indexPath];
            break;
            
        default:
            break;
    }
    //NSLog(@"%s,%d status: %d",__FUNCTION__,__LINE__,self.status);
}

@end
