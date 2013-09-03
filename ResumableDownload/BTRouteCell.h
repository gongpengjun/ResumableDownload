//
//  BTRouteCell.h
//  ResumableDownload
//
//  Created by 巩 鹏军 on 13-9-2.
//  Copyright (c) 2013年 巩 鹏军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTRouteAccessoryButton.h"

@interface BTRouteCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel* label;
@property (retain, nonatomic) NSIndexPath* indexPath;
@property (assign, nonatomic) BTDownloadStatus status;
@end
