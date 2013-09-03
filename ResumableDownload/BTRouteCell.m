//
//  BTRouteCell.m
//  ResumableDownload
//
//  Created by 巩 鹏军 on 13-9-2.
//  Copyright (c) 2013年 巩 鹏军. All rights reserved.
//

#import "BTRouteCell.h"
#import "BTRouteAccessoryButton.h"

@interface BTRouteCell ()
@property IBOutlet BTRouteAccessoryButton* accessoryButton;
@end

@implementation BTRouteCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    NSLog(@"%s,%d self:<%@ %p> decoder: %@",__FUNCTION__,__LINE__,NSStringFromClass([self class]),self,aDecoder);
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"%s,%d self:<%@ %p>",__FUNCTION__,__LINE__,NSStringFromClass([self class]),self);
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    [indexPath retain];
    [_indexPath release];
    _indexPath = indexPath;
    self.accessoryButton.indexPath = indexPath;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
