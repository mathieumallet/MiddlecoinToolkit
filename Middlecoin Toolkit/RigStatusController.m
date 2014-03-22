//
//  RigStatusController.m
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 2/3/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import "RigStatusController.h"
#import "StatsController.h"
#import "Constants.h"

@interface RigStatusController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) UIRefreshControl *refresh;
@end

@implementation RigStatusController

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

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    self.refresh = refresh;
    self.webView.delegate = (id)self;
    [refresh addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.webView.scrollView addSubview:refresh];
    
    self.webView.scrollView.scrollsToTop = true;
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        self.edgesForExtendedLayout = UIRectEdgeAll;
    
    float headerSize = 20; // status bar height
    if (self.navigationController && self.navigationController.navigationBarHidden == NO)
        headerSize += self.navigationController.toolbar.frame.size.height;
    float tabBarSize = 49;
    
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(headerSize, 0, tabBarSize, 0);
    
    [self.refresh beginRefreshing];
    [self loadRigStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleRefresh:(UIRefreshControl *)refresh
{
    [self loadRigStatus];
}

-(void)loadRigStatus
{
    NSString* rigAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"rigAddress"];
    if (rigAddress == nil || [rigAddress isEqualToString:@""])
    {
        NSString* text = @"A rig website address must first be configured in the settings tab to view rig status.";
        [StatsController setCenteredTextInWebview:self.webView toText:text];
    }
    else
    {
        NSURL* url = [NSURL URLWithString:rigAddress];
        NSURLRequest* request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.refresh endRefreshing];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.refresh endRefreshing];
    
    NSString* text = [NSString stringWithFormat:@"An error occurred while loading the rig status page. Are you sure you entered a valid URL? The received error was: %@", error.localizedDescription];
    [StatsController setCenteredTextInWebview:self.webView toText:text];
}

@end
