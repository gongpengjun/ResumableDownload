//
//  BTRouteAccessoryButton.m
//  Venti
//
//  Created by 巩 鹏军 on 13-9-2.
//  Copyright (c) 2013年 Beijing Zhixun Innovation Co. Ltd. All rights reserved.
//

#import "BTRouteAccessoryButton.h"

NSString* const kBTDownloadStartNotification = @"kBTDownloadStartNotification";
NSString* const kBTDownloadPauseNotification = @"kBTDownloadPauseNotification";
NSString* const kBTDownloadStopNotification  = @"kBTDownloadStopNotification";
NSString* const kBTDownloadViewNotification  = @"kBTDownloadViewNotification";

@interface BTRouteAccessoryButton ()
@property IBOutlet UIButton* bgButton;
@property IBOutlet UIImageView* progressImageView;
@property IBOutlet UIImageView* actionImageView;
@property (nonatomic, retain) NSArray* animationImages;
@end

@implementation BTRouteAccessoryButton

- (void)dealloc {
    [_animationImages release];
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
    NSLog(@"%s,%d self:<%@ %p>",__FUNCTION__,__LINE__,NSStringFromClass([self class]),self);
    [self.bgButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

// lazy loading
- (NSArray*)animationImages {
    if(_animationImages) return _animationImages;
    _animationImages = [[NSArray arrayWithObjects:[UIImage imageNamed:@"round_progress_bar_1"],
                       [UIImage imageNamed:@"round_progress_bar_2"],
                       [UIImage imageNamed:@"round_progress_bar_3"],
                       [UIImage imageNamed:@"round_progress_bar_4"],nil] retain];
    return _animationImages;
}

- (void)setStatus:(BTDownloadStatus)status {
    _status = status;
    switch (_status) {
        default:
        case BTDownloadNotStart:
            [self.progressImageView stopAnimating];
            self.progressImageView.image = [UIImage imageNamed:@"btn_bg_normal"];
            self.progressImageView.animationImages = nil;
            self.actionImageView.image = [UIImage imageNamed:@"btn_download"];
            break;
        case BTDownloading:
            self.progressImageView.image = [UIImage imageNamed:@"btn_bg_ongoing"];
            self.progressImageView.animationImages = self.animationImages;
            self.progressImageView.animationDuration = 1.5;
            self.progressImageView.animationRepeatCount = 0;
            [self.progressImageView startAnimating];
            self.actionImageView.image = [UIImage imageNamed:@"btn_pause"];
            break;
        case BTDownloadPaused:
            [self.progressImageView stopAnimating];
            self.progressImageView.image = [UIImage imageNamed:@"btn_bg_ongoing"];
            self.progressImageView.animationImages = nil;
            self.actionImageView.image = [UIImage imageNamed:@"btn_start"];
            break;
        case BTDownloadFinished:
            [self.progressImageView stopAnimating];
            self.progressImageView.image = [UIImage imageNamed:@"btn_bg_normal"];
            self.progressImageView.animationImages = nil;
            self.actionImageView.image = [UIImage imageNamed:@"btn_view"];
            break;
    }
}

- (void)buttonClicked:(id)sender {
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
            NSLog(@"%s,%d go to view page",__FUNCTION__,__LINE__);
            [[NSNotificationCenter defaultCenter] postNotificationName:kBTDownloadViewNotification object:self.indexPath];
            break;
            
        default:
            break;
    }
    NSLog(@"%s,%d status: %d",__FUNCTION__,__LINE__,self.status);
}

@end
