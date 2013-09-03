//
//  TDNetworkQueue.m
//  TestDownload
//
//  Created by ChenYu Xiao on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TDNetworkQueue.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

NSString* const kBTDownloadFinishedNotification  = @"kBTDownloadFinishedNotification";
NSString* const kBTDownloadFailedNotification  = @"kBTDownloadFailedNotification";

@interface TDNetworkQueue() <ASIHTTPRequestDelegate>
@end

@implementation TDNetworkQueue 

@synthesize asiNetworkQueue = _asiNettworkQueue;
@synthesize requestArray = _requestArray;

+ (id)sharedTDNetworkQueue {
    static dispatch_once_t pred;
    static TDNetworkQueue * tdNetworkQueue= nil;
    dispatch_once(&pred, ^{ tdNetworkQueue = [[self alloc] init];});
    return tdNetworkQueue;
}

- (void)dealloc {
    NSLog(@"%s,%d",__FUNCTION__, __LINE__);
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        self.asiNetworkQueue = [[ASINetworkQueue alloc] init];
        [self.asiNetworkQueue setShowAccurateProgress:YES];
        [self.asiNetworkQueue go];
        
        self.requestArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addDownloadRequestInQueue:(NSURL *)paramURL 
                     withTempPath:(NSString *)paramTempPath 
                 withDownloadPath:(NSString *)paramDownloadPath 
                 withProgressView:(UIProgressView *)paramProgressView {
    //创建请求
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:paramURL];
    request.delegate = self;//代理
    [request setDownloadDestinationPath:paramDownloadPath];//下载路径
    [request setTemporaryFileDownloadPath:paramTempPath];//缓存路径
    [request setAllowResumeForFileDownloads:YES];//断点续传
    request.downloadProgressDelegate = paramProgressView;
    [self.asiNetworkQueue addOperation:request];//添加到队列，队列启动后不需重新启动
    if ([[NSFileManager defaultManager] fileExistsAtPath:paramTempPath]) {
        NSLog(@"%s,%d %@ 有了",__FUNCTION__, __LINE__,paramTempPath);
    } else {
        NSLog(@"%s,%d %@ 没有",__FUNCTION__, __LINE__,paramTempPath);
    }
}

- (void)cancelAllRequests {
    for (ASIHTTPRequest *request in self.requestArray) {
        [request clearDelegatesAndCancel];
    }
}

- (void)clearAllRequestsDelegate {
    for (ASIHTTPRequest *request in self.requestArray) {
        [request setDownloadProgressDelegate:nil];
    }
}

- (void)clearOneRequestDelegateWithURL:(NSString *)paramURL {
    for (ASIHTTPRequest *request in self.requestArray) {
        if ([[request.url absoluteString] isEqualToString:paramURL]) {
            [request setDownloadProgressDelegate:nil];
        }
    }
    
}

- (void)requestsDelegateSettingWithDictonary:(NSDictionary *) paramDictonary {
    NSLog(@"%s,%d paramDictonary: %@",__FUNCTION__,__LINE__,paramDictonary);
    for (ASIHTTPRequest *request in self.requestArray) {
        for (id key in paramDictonary) {
            if ([[request.url absoluteString] isEqualToString:(NSString *)key]) {
                [request setDownloadProgressDelegate:[paramDictonary objectForKey:key]];
            }
        }
    }
}

- (void)pauseDownload:(NSString *)paramPauseURL {
    NSLog(@"%s,%d url: %@",__FUNCTION__,__LINE__,paramPauseURL);
    NSArray* tempArray = [[self.requestArray copy] autorelease];
    for (ASIHTTPRequest *request in tempArray) {
        if ([[request.url absoluteString] isEqualToString:paramPauseURL]) {
            [request clearDelegatesAndCancel];
            [self.requestArray removeObject:request];
        }
    }
}

#pragma mark ASIHTTPRequestDelegate

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    NSLog(@"%s,%d 收到头部！",__FUNCTION__, __LINE__);
    NSLog(@"%s,%d %f MB",__FUNCTION__, __LINE__,request.contentLength/1024.0/1024.0);
    NSLog(@"%s,%d %@",__FUNCTION__, __LINE__,responseHeaders);
}

- (void)requestStarted:(ASIHTTPRequest *)request {
    NSLog(@"%s,%d 下载开始！",__FUNCTION__, __LINE__);
    [self.requestArray addObject:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"%s,%d %@ 下载成功！",__FUNCTION__, __LINE__,[request.url absoluteString]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kBTDownloadFinishedNotification object:[request.url absoluteString]];
    NSArray* tempArray = [[self.requestArray copy] autorelease];
    for (ASIHTTPRequest *aRequest in tempArray) {
        //NSLog(@"%s,%d sURL:%@",__FUNCTION__, __LINE__, [aRequest.url absoluteString]);
        if ([[aRequest.url absoluteString] isEqualToString:[request.url absoluteString]]) {
            [self.requestArray removeObject:request];
        }
    }
    
    for (ASIHTTPRequest *aRequest in self.requestArray) {
        NSLog(@"%s,%d ongoing URL:%@",__FUNCTION__, __LINE__, [aRequest.url absoluteString]);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%s,%d %@ 下载失败！",__FUNCTION__, __LINE__,[request.url absoluteString]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kBTDownloadFailedNotification object:[request.url absoluteString]];
    NSArray* tempArray = [[self.requestArray copy] autorelease];
    for (ASIHTTPRequest *aRequest in tempArray) {
        if ([[aRequest.url absoluteString] isEqualToString:[request.url absoluteString]]) {
            [self.requestArray removeObject:request];
        }
    }
}

@end
