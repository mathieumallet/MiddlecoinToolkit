//
//  NewsController.m
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 1/19/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import "NewsController.h"
#import "StatsController.h"
#import "Constants.h"

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
    [super viewWillAppear:animated];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        self.edgesForExtendedLayout = UIRectEdgeAll;
    
    float headerSize = 20; // status bar height
    if (self.navigationController && self.navigationController.navigationBarHidden == NO)
        headerSize += self.navigationController.toolbar.frame.size.height;
    float tabBarSize = 49;
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(headerSize, 0, tabBarSize, 0);
    
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

- (IBAction)openFeedInSafari:(id)sender
{
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/middlecoinpool"]];
}

- (IBAction)refresh:(id)sender
{
    [self.webView reload];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.refresh endRefreshing];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.refresh endRefreshing];
    
    NSString* text = [NSString stringWithFormat:@"An error occurred while loading the pool news page. The received error was: %@", error.localizedDescription];
    [StatsController setCenteredTextInWebview:self.webView toText:text];
}

@end
