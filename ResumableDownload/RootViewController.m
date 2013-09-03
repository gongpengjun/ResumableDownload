//
//  RootViewController.m
//  ResumableDownload
//
//  Created by 巩 鹏军 on 13-9-2.
//  Copyright (c) 2013年 巩 鹏军. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] init] autorelease];
    backButton.title = @"Back";
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
