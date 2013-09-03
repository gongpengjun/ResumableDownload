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
#import "TDNetworkQueue.h"

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
    //NSLog(@"%s,%d self:<%@ %p>",__FUNCTION__,__LINE__,NSStringFromClass([self class]),self);
}

- (void)dealloc
{
    [_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] init] autorelease];
    backButton.title = @"Back";
    self.navigationItem.backBarButtonItem = backButton;

    [self createDownloadRootPath];
    [self createTempRootPath];
    [self refeshObjects];
}

- (void)refeshObjects {
    [_objects removeAllObjects];
    [_objects release];
    
    NSMutableDictionary* objectDict = nil;
    BTDownloadStatus status = 0;
    _objects = [[NSMutableArray alloc] init];
    
    objectDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [objectDict setValue:test1URL forKey:@"url"];
    status = [self downloadStatusOfURL:test1URL];
    [objectDict setValue:@(status) forKey:@"state"];
    [_objects addObject:objectDict];
    
    objectDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [objectDict setValue:test2URL forKey:@"url"];
    status = [self downloadStatusOfURL:test2URL];
    [objectDict setValue:@(status) forKey:@"state"];
    
    [_objects addObject:objectDict];
    NSLog(@"%s,%d _objects: %@",__FUNCTION__,__LINE__,_objects);    
}

- (NSString*)urlOfObjectDict:(NSDictionary*)objectDict {
    //NSLog(@"%s,%d objectDict: %@",__FUNCTION__,__LINE__,objectDict);
    return [objectDict valueForKey:@"url"];
}

- (NSString*)nameOfObjectDict:(NSDictionary*)objectDict {
    //NSLog(@"%s,%d objectDict: %@",__FUNCTION__,__LINE__,objectDict);
    return [[objectDict valueForKey:@"url"] lastPathComponent];
}

- (BTDownloadStatus)statusOfObjectDict:(NSDictionary*)objectDict {
    //NSLog(@"%s,%d objectDict: %@",__FUNCTION__,__LINE__,objectDict);
    return [[objectDict valueForKey:@"state"] unsignedIntegerValue];
}

- (NSIndexPath*)indexPathOfURL:(NSString*)urlString {
    for(NSUInteger i = 0; i < _objects.count; i++) {
        id objectDict = [_objects objectAtIndex:i];
        if([[objectDict valueForKey:@"url"] isEqualToString:urlString]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

- (NSString*)tempRootPath {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/offlinemap/downloading"];
    //NSLog(@"%s,%d path: %@",__FUNCTION__,__LINE__,path);
    return path;
}

- (void)createTempRootPath {
    NSString *path = [self tempRootPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)deleteTempRootPath {
    NSString *path = [self tempRootPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
}

- (NSString*)tempPathOfURL:(NSString*)urlString {
    NSString* nameString = [urlString lastPathComponent];
    NSString *tempPath = [[self tempRootPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.tmp",nameString]];
    return tempPath;
}

- (NSString*)downloadRootPath {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/offlinemap/downloaded"];
    //NSLog(@"%s,%d path: %@",__FUNCTION__,__LINE__,path);
    return path;
}

- (void)createDownloadRootPath {
    NSString *path = [self downloadRootPath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)deleteDownloadRootPath {
    NSString *path = [self downloadRootPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
}

- (NSString*)downloadPathOfURL:(NSString*)urlString {
    NSString* nameString = [urlString lastPathComponent];
    NSString *downloadPath = [[self downloadRootPath] stringByAppendingPathComponent:nameString];
    return downloadPath;
}

- (BTDownloadStatus)downloadStatusOfURL:(NSString*)urlString {
    // already downloaded
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:[self downloadPathOfURL:urlString]];
    if(fileExist) {
        return BTDownloadFinished;
    }
    
    // already start download, but paused
    BOOL tempExist = [[NSFileManager defaultManager] fileExistsAtPath:[self tempPathOfURL:urlString]];
    if(tempExist) {
        return BTDownloadPaused;
    }

    // not start at all
    return BTDownloadNotStart;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProcessNofy:) name:kBTDownloadFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProcessNofy:) name:kBTDownloadFailedNotification object:nil];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBTDownloadStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBTDownloadPauseNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBTDownloadStopNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBTDownloadViewNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBTDownloadFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kBTDownloadFailedNotification object:nil];
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
    cell.status = [self statusOfObjectDict:objectDict];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* objectDict = _objects[indexPath.row];
    NSString* urlString = [self urlOfObjectDict:objectDict];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if([self downloadStatusOfURL:urlString] == BTDownloadFinished) {
        [self performSegueWithIdentifier:@"showDetail" sender:nil];
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Haven't downloaded" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"%s,%d delete",__FUNCTION__,__LINE__);
        [self stopDownloadOfflineMapAtIndexPath:indexPath];
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

#pragma mark - Download Action Notification

- (void)accsseryButtonNofy:(NSNotification*)notification {
    NSLog(@"%s,%d notification: %@",__FUNCTION__,__LINE__,[notification name]);
    NSIndexPath* indexPath = [notification object];
    if([[notification name] isEqualToString:kBTDownloadStartNotification]) {
        //NSLog(@"%s,%d start download",__FUNCTION__,__LINE__);
        [self startDownloadOfflineMapAtIndexPath:indexPath];
    } else if([[notification name] isEqualToString:kBTDownloadPauseNotification]) {
        //NSLog(@"%s,%d pause download",__FUNCTION__,__LINE__);
        [self pauseDownloadOfflineMapAtIndexPath:indexPath];
    } else if([[notification name] isEqualToString:kBTDownloadViewNotification]) {
        [self viewOfflineMapAtIndexPath:indexPath];
    } else {
        [self stopDownloadOfflineMapAtIndexPath:indexPath];
    }
}

- (void)startDownloadOfflineMapAtIndexPath:(NSIndexPath*)indexPath {
    NSDictionary* objectDict = _objects[indexPath.row];
    NSString* urlString = [self urlOfObjectDict:objectDict];
    BTRouteCell* cell = (BTRouteCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%s,%d indexPath: %@",__FUNCTION__,__LINE__,indexPath);
//    NSLog(@"%s,%d urlString: %@",__FUNCTION__,__LINE__,urlString);
    NSString *downloadPath = [self downloadPathOfURL:urlString];
    NSString *tempPath = [self tempPathOfURL:urlString];
    NSLog(@"%s,%d tempPath: %@",__FUNCTION__,__LINE__,tempPath);
    NSLog(@"%s,%d downloadPath: %@",__FUNCTION__,__LINE__,downloadPath);
    NSURL *url = [NSURL URLWithString:urlString];
    [[TDNetworkQueue sharedTDNetworkQueue] addDownloadRequestInQueue:url withTempPath:tempPath withDownloadPath:downloadPath withProgressView:(UIProgressView*)cell];
}

- (void)pauseDownloadOfflineMapAtIndexPath:(NSIndexPath*)indexPath {
    NSDictionary* objectDict = _objects[indexPath.row];
    NSString* urlString = [self urlOfObjectDict:objectDict];
    NSLog(@"%s,%d indexPath: %@",__FUNCTION__,__LINE__,indexPath);
//    NSLog(@"%s,%d urlString: %@",__FUNCTION__,__LINE__,urlString);
//    NSString *downloadPath = [self downloadPathOfURL:urlString];
//    NSString *tempPath = [self tempPathOfURL:urlString];
//    NSLog(@"%s,%d tempPath: %@",__FUNCTION__,__LINE__,tempPath);
//    NSLog(@"%s,%d downloadPath: %@",__FUNCTION__,__LINE__,downloadPath);
    [[TDNetworkQueue sharedTDNetworkQueue] pauseDownload:urlString];
}

- (void)stopDownloadOfflineMapAtIndexPath:(NSIndexPath*)indexPath {
    NSDictionary* objectDict = _objects[indexPath.row];
    NSString* urlString = [self urlOfObjectDict:objectDict];
    NSLog(@"%s,%d indexPath: %@",__FUNCTION__,__LINE__,indexPath);
//    NSLog(@"%s,%d urlString: %@",__FUNCTION__,__LINE__,urlString);
//    NSString *downloadPath = [self downloadPathOfURL:urlString];
//    NSString *tempPath = [self tempPathOfURL:urlString];
//    NSLog(@"%s,%d tempPath: %@",__FUNCTION__,__LINE__,tempPath);
//    NSLog(@"%s,%d downloadPath: %@",__FUNCTION__,__LINE__,downloadPath);
    [[TDNetworkQueue sharedTDNetworkQueue] pauseDownload:urlString];
}

- (void)viewOfflineMapAtIndexPath:(NSIndexPath*)indexPath {
    NSLog(@"%s,%d indexPath: %@",__FUNCTION__,__LINE__,indexPath);
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
}

#pragma mark - Download Progress Notification

- (void)downloadProcessNofy:(NSNotification*)notification {
    NSLog(@"%s,%d notification: %@",__FUNCTION__,__LINE__,[notification name]);
    NSString* urlString = [notification object];
    NSIndexPath* indexPath = [self indexPathOfURL:urlString];
    BTRouteCell* cell = (BTRouteCell*)[self.tableView cellForRowAtIndexPath:indexPath];
//    NSString *downloadPath = [self downloadPathOfURL:urlString];
//    NSString *tempPath = [self tempPathOfURL:urlString];
//    NSLog(@"%s,%d tempPath: %@",__FUNCTION__,__LINE__,tempPath);
//    NSLog(@"%s,%d downloadPath: %@",__FUNCTION__,__LINE__,downloadPath);
    if([[notification name] isEqualToString:kBTDownloadFinishedNotification]) {
        NSLog(@"%s,%d download finished",__FUNCTION__,__LINE__);
        cell.progress = 1.0;
        cell.status = BTDownloadFinished;
    } else if([[notification name] isEqualToString:kBTDownloadFailedNotification]) {
        NSLog(@"%s,%d download failed",__FUNCTION__,__LINE__);
        cell.status = BTDownloadPaused;
    }
}

#pragma mark - Debug Helper Bar Button

- (IBAction)clearData:(id)sender {
    [[TDNetworkQueue sharedTDNetworkQueue] cancelAllRequests];
    [self deleteDownloadRootPath];
    [self deleteTempRootPath];
    [self createDownloadRootPath];
    [self createTempRootPath];
    [self refeshObjects];
    [self.tableView reloadData];
}

@end
