//
//  NewsController.m
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 1/19/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import "NewsController.h"

@interface NewsController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) UIRefreshControl *refresh;

@end

@implementation NewsController

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

    self.webView.scrollView.scrollsToTop = true;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    self.refresh = refresh;
    self.webView.delegate = (id)self;
    [refresh addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.webView.scrollView addSubview:refresh];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 49+20, 0);
    
    [self.refresh beginRefreshing];
    [self loadTwitterFeed];
}

-(void)loadTwitterFeed
{
    NSURL *url = [NSURL URLWithString:@"https://twitter.com/middlecoinpool"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

-(void)handleRefresh:(UIRefreshControl *)refresh
{
    [self loadTwitterFeed];
    //[refresh endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openFeedInSafari:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/middlecoinpool"]];
}

- (IBAction)refresh:(id)sender {
    [self.webView reload];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.refresh endRefreshing];
}

@end
