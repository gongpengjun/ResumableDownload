//
//  MasterViewController.m
//  ResumableDownload
//
//  Created by 巩 鹏军 on 13-9-2.
//  Copyright (c) 2013年 巩 鹏军. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "BTRouteCell.h"
#import "BTRouteAccessoryButton.h"

static NSString *test1URL = @"http://breadtrip-offlinemap.qiniudn.com/tiles_forbidden_city_route.mbtiles";
static NSString *test2URL = @"http://breadtrip-offlinemap.qiniudn.com/tiles_control-room-0.2.0.mbtiles";

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"%s,%d self:<%@ %p>",__FUNCTION__,__LINE__,NSStringFromClass([self class]),self);
}

- (void)dealloc
{
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    NSMutableDictionary* objectDict = nil;
    _objects = [[NSMutableArray alloc] init];
    
    objectDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [objectDict setValue:test1URL forKey:@"url"];
    [objectDict setValue:@(BTDownloadNotStart) forKey:@"state"];
    [_objects addObject:objectDict];
    
    objectDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [objectDict setValue:test2URL forKey:@"url"];
    [objectDict setValue:@(BTDownloadNotStart) forKey:@"state"];
    
    [_objects addObject:objectDict];
    
    NSLog(@"%s,%d _objects: %@",__FUNCTION__,__LINE__,_objects);
}

- (NSString*)nameOfObjectDict:(NSDictionary*)objectDict {
    //NSLog(@"%s,%d objectDict: %@",__FUNCTION__,__LINE__,objectDict);
    return [[objectDict valueForKey:@"url"] lastPathComponent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accsseryButtonNofy:) name:kBTDownloadStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accsseryButtonNofy:) name:kBTDownloadPauseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accsseryButtonNofy:) name:kBTDownloadStopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accsseryButtonNofy:) name:kBTDownloadViewNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s,%d count: %i",__FUNCTION__,__LINE__,_objects.count);
    return _objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BTRouteCell *cell = (BTRouteCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary* objectDict = _objects[indexPath.row];
    //NSLog(@"%s,%d objectDict: %@",__FUNCTION__,__LINE__,objectDict);
    cell.label.text = [self nameOfObjectDict:objectDict];
    cell.indexPath = indexPath;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"%s,%d delete",__FUNCTION__,__LINE__);
        return;
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        id objectDict = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:[self nameOfObjectDict:objectDict]];
    }
}

- (void)accsseryButtonNofy:(NSNotification*)notification {
    NSLog(@"%s,%d notification: %@",__FUNCTION__,__LINE__,notification);
    if([[notification name] isEqualToString:kBTDownloadStartNotification]) {
        NSLog(@"%s,%d start download",__FUNCTION__,__LINE__);
    } else if([[notification name] isEqualToString:kBTDownloadPauseNotification]) {
        NSLog(@"%s,%d pause download",__FUNCTION__,__LINE__);
    } else if([[notification name] isEqualToString:kBTDownloadViewNotification]) {
        [self.tableView selectRowAtIndexPath:[notification object] animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
    } else {
        // stop
    }
}

@end
