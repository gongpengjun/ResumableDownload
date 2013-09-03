//
//  BTRouteAccessoryButton.h
//  Venti
//
//  Created by 巩 鹏军 on 13-9-2.
//  Copyright (c) 2013年 Beijing Zhixun Innovation Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const kBTDownloadStartNotification;
extern NSString* const kBTDownloadPauseNotification;
extern NSString* const kBTDownloadStopNotification;
extern NSString* const kBTDownloadViewNotification;

typedef enum BTDownloadStatus {
    BTDownloadNotStart = 0,
    BTDownloading,
    BTDownloadPaused,
    BTDownloadFinished
} BTDownloadStatus;

@interface BTRouteAccessoryButton : UIView

@property (nonatomic, assign) BTDownloadStatus status;
@property (retain, nonatomic) NSIndexPath* indexPath;
@property (assign, nonatomic) CGFloat progress;

@end
