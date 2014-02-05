//
//  RigStatusController.m
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 2/3/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import "RigStatusController.h"

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
}

- (void)viewWillAppear:(BOOL)animated
{
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 49+20, 0);
    
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
    if (rigAddress == nil)
    {
        // TODO
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

@end
