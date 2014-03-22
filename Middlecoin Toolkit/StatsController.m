//
//  StatsController.m
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 2/4/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import "StatsController.h"
#import "Constants.h"

@interface StatsController ()

@property UIRefreshControl* refreshControl;
@property (strong, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UIView* innerView;
@property UIBarButtonItem* refreshButton;

@property CGPoint scrollPosition;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property NSString* payoutAddress;
@property NSString* currency;
@property NSDate* lastRefreshDate;
@property NSTimer* updateTimer;

@property (weak, nonatomic) IBOutlet UILabel *summaryBalance;
@property (weak, nonatomic) IBOutlet UILabel *summaryPayoutForecast;
@property (weak, nonatomic) IBOutlet UILabel *summaryCurrentPerMHs;
@property (weak, nonatomic) IBOutlet UILabel *summaryExchangeRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryExchangeRate;
@property (weak, nonatomic) IBOutlet UILabel *summaryAcceptReject;
@property (weak, nonatomic) IBOutlet UILabel *summaryTotalUnpaid;
@property (weak, nonatomic) IBOutlet UILabel *summaryLastUpdate;

@property (weak, nonatomic) IBOutlet UILabel *currentBalance;
@property (weak, nonatomic) IBOutlet UILabel *currentUnexchanged;
@property (weak, nonatomic) IBOutlet UILabel *currentImmature;
@property (weak, nonatomic) IBOutlet UILabel *currentTotal;

@property (weak, nonatomic) IBOutlet UILabel *hashAccepted;
@property (weak, nonatomic) IBOutlet UILabel *hashRejected;
@property (weak, nonatomic) IBOutlet UILabel *hashRatio;
@property (weak, nonatomic) IBOutlet UILabel *hashAverage;

@property (weak, nonatomic) IBOutlet UILabel *recentPayoutDate;
@property (weak, nonatomic) IBOutlet UILabel *recentPayoutAmount;
@property (weak, nonatomic) IBOutlet UILabel *recentNextPayoutIn;
@property (weak, nonatomic) IBOutlet UILabel *recentNextForecastAmount;
@property (weak, nonatomic) IBOutlet UILabel *recentCurrentPerMHs;

@property (weak, nonatomic) IBOutlet UILabel *sevenAverage;
@property (weak, nonatomic) IBOutlet UILabel *sevenStdev;
@property (weak, nonatomic) IBOutlet UILabel *sevenMin;
@property (weak, nonatomic) IBOutlet UILabel *sevenMax;
@property (weak, nonatomic) IBOutlet UILabel *sevenPerMHs;
@property (weak, nonatomic) IBOutlet UILabel *sevenTotal;

@property (weak, nonatomic) IBOutlet UILabel *thirtyAverage;
@property (weak, nonatomic) IBOutlet UILabel *thirtyStdev;
@property (weak, nonatomic) IBOutlet UILabel *thirtyMin;
@property (weak, nonatomic) IBOutlet UILabel *thirtyMax;
@property (weak, nonatomic) IBOutlet UILabel *thirtyPerMHs;
@property (weak, nonatomic) IBOutlet UILabel *thirtyTotal;

@property (weak, nonatomic) IBOutlet UILabel *allAverage;
@property (weak, nonatomic) IBOutlet UILabel *allStdev;
@property (weak, nonatomic) IBOutlet UILabel *allMin;
@property (weak, nonatomic) IBOutlet UILabel *allMax;
@property (weak, nonatomic) IBOutlet UILabel *allPerMHs;
@property (weak, nonatomic) IBOutlet UILabel *allTotal;

@property (weak, nonatomic) IBOutlet UILabel *miscLastDataUpdate;
@property (weak, nonatomic) IBOutlet UILabel *miscLastAppRefresh;
@property (weak, nonatomic) IBOutlet UILabel *miscSizeOfLastUpdate;
@property (weak, nonatomic) IBOutlet UILabel *miscExchangeRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *miscExchangeRate;
@property (weak, nonatomic) IBOutlet UILabel *miscAddress;

@end

@implementation StatsController

@synthesize payoutAddress;

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
    
    self.webView.scrollView.scrollsToTop = false;
    self.scrollView.scrollsToTop = true;
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    
    [self setCenteredTextInWebviewTo:@"Loading data, please wait..."];
    [self setAllLabelsTo:@"Loading..." withErrorMode:false];    
    
    // Set initial value for exchange rate labels (only when first loading)
    self.currency = [[NSUserDefaults standardUserDefaults] valueForKey:@"currency"];
    if (self.currency == nil)
        self.currency = @"USD";
    if ([self.currency isEqualToString:@""])
    {
        // 'None' selected
        self.summaryExchangeRateLabel.text = @"Exchange rate";
    }
    else
    {
        self.summaryExchangeRateLabel.text = [@"BTC/" stringByAppendingFormat:@"%@ rate", self.currency];
    }
    self.miscExchangeRateLabel.text = self.summaryExchangeRateLabel.text;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Read currency and update currency labels
    self.currency = [[NSUserDefaults standardUserDefaults] valueForKey:@"currency"];
    if (self.currency == nil)
        self.currency = @"USD";
    
    if (self.lastRefreshDate == nil || [self.lastRefreshDate timeIntervalSinceNow] < -AUTO_REFRESH_INTERVAL)
        [self tryRefresh];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.updateTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerTriggered:) userInfo:nil repeats:YES];
    [runloop addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.updateTimer forMode:UITrackingRunLoopMode];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        self.webView.frame = CGRectMake(0, 0, 320, 240);
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.scrollPosition = self.scrollView.contentOffset;
    
    [self.updateTimer invalidate];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        self.edgesForExtendedLayout = UIRectEdgeAll;
    float headerSize = 20; // status bar height
    if (self.navigationController && self.navigationController.navigationBarHidden == NO)
        headerSize += self.navigationController.toolbar.frame.size.height;
    float tabBarSize = 49;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        self.scrollView.contentInset = UIEdgeInsetsMake(headerSize, 0, tabBarSize, 0);
    
    self.scrollView.contentSize = self.innerView.frame.size;
    
    if (self.scrollPosition.x != 0 || self.scrollPosition.y != 0)
        self.scrollView.contentOffset = self.scrollPosition;
    
    [self.webView layoutIfNeeded];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.innerView;
}

-(NSArray*)getAllLabels
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    if (self.summaryBalance) [array addObject:self.summaryBalance];
    if (self.summaryPayoutForecast) [array addObject:self.summaryPayoutForecast];
    if (self.summaryAcceptReject) [array addObject:self.summaryAcceptReject];
    if (self.summaryExchangeRate) [array addObject:self.summaryExchangeRate];
    if (self.summaryTotalUnpaid) [array addObject:self.summaryTotalUnpaid];
    if (self.summaryLastUpdate) [array addObject:self.summaryLastUpdate];
    if (self.currentBalance) [array addObject:self.currentBalance];
    if (self.currentUnexchanged) [array addObject:self.currentUnexchanged];
    if (self.currentImmature) [array addObject:self.currentImmature];
    if (self.currentTotal) [array addObject:self.currentTotal];
    if (self.hashAccepted) [array addObject:self.hashAccepted];
    if (self.hashRejected) [array addObject:self.hashRejected];
    if (self.hashRatio) [array addObject:self.hashRatio];
    if (self.hashAverage) [array addObject:self.hashAverage];
    if (self.recentPayoutDate) [array addObject:self.recentPayoutDate];
    if (self.recentPayoutAmount) [array addObject:self.recentPayoutAmount];
    if (self.recentNextPayoutIn) [array addObject:self.recentNextPayoutIn];
    if (self.recentNextForecastAmount) [array addObject:self.recentNextForecastAmount];
    if (self.sevenAverage) [array addObject:self.sevenAverage];
    if (self.sevenStdev) [array addObject:self.sevenStdev];
    if (self.sevenMin) [array addObject:self.sevenMin];
    if (self.sevenMax) [array addObject:self.sevenMax];
    if (self.sevenPerMHs) [array addObject:self.sevenPerMHs];
    if (self.sevenTotal) [array addObject:self.sevenTotal];
    if (self.thirtyAverage) [array addObject:self.thirtyAverage];
    if (self.thirtyStdev) [array addObject:self.thirtyStdev];
    if (self.thirtyMin) [array addObject:self.thirtyMin];
    if (self.thirtyMax) [array addObject:self.thirtyMax];
    if (self.thirtyPerMHs) [array addObject:self.thirtyPerMHs];
    if (self.thirtyTotal) [array addObject:self.thirtyTotal];
    if (self.allAverage) [array addObject:self.allAverage];
    if (self.allStdev) [array addObject:self.allStdev];
    if (self.allMin) [array addObject:self.allMin];
    if (self.allMax) [array addObject:self.allMax];
    if (self.allPerMHs) [array addObject:self.allPerMHs];
    if (self.allTotal) [array addObject:self.allTotal];
    if (self.miscLastDataUpdate) [array addObject:self.miscLastDataUpdate];
    if (self.miscLastAppRefresh) [array addObject:self.miscLastAppRefresh];
    if (self.miscSizeOfLastUpdate) [array addObject:self.miscSizeOfLastUpdate];
    if (self.miscExchangeRate) [array addObject:self.miscExchangeRate];
    if (self.miscAddress) [array addObject:self.miscAddress];
    if (self.summaryCurrentPerMHs) [array addObject:self.summaryCurrentPerMHs];
    if (self.recentCurrentPerMHs) [array addObject:self.recentCurrentPerMHs];
    
    return array;
}

-(void)setAllLabelsTo:(NSString*)text withErrorMode:(bool)isError
{
    for (UILabel* label in [self getAllLabels])
    {
        label.text = text;
        if (isError)
            label.textColor = [UIColor redColor];
        else
            label.textColor = self.summaryExchangeRateLabel.textColor;
    }
}

-(void)setTBDLabels
{
    for (UILabel* label in [self getAllLabels])
        if ([label.text isEqualToString:@"Loading..."])
        {
            label.text = @"NYI";
            label.textColor = self.summaryExchangeRateLabel.textColor;
        }
}

-(void)refreshControlTriggered:(UIRefreshControl *)refresh
{
    NSLog(@"refresh control triggered");
    if (self.refreshButton.enabled)
    {
        [self tryRefresh];
    }
    else
        [self.refreshControl endRefreshing];
}

-(void)refreshButtonPressed:(id)sender
{
    [self tryRefresh];
}

-(void)tryRefresh
{
    if (self.refreshButton.enabled == true)
        [self refresh];
}

-(void)beginRefreshing
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.refreshButton.enabled = false;
}

-(void)finishRefreshing
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.refreshButton.enabled = true;
    [self.refreshControl endRefreshing];
    [self setTBDLabels]; // TODO remove this
}

-(void)refresh
{
    if ([self.summaryBalance.text isEqualToString:@"Error"])
    {
        [self setCenteredTextInWebviewTo:@"Loading data, please wait..."];
        [self setAllLabelsTo:@"Loading..." withErrorMode:false];
    }
    
    [self beginRefreshing];
    
    self.miscAddress.text = self.payoutAddress;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        
        // Start by loading the blockchain.info data (for exchange rates)
        NSURL* marketDataURL = [NSURL URLWithString:RATES_URL];
        
        NSString* symbol = @"???";
        double exchangeRate = -1.0;
        NSString* exchangeRateString = @"N/A";
        
        long long downloadedBytes = 0;
        
        NSError *error = nil;
        if ([self.currency isEqualToString:@""])
        {
            exchangeRateString = @"No currency selected";
        }
        else
        {
            //NSString *marketData = [NSString stringWithContentsOfURL:marketDataURL encoding:NSUTF8StringEncoding error:&error];
            NSString* marketData = [StatsController downloadURL:marketDataURL error:&error downloadSize:&downloadedBytes];
            if (marketData)
            {
                // Parse exchange rate
                NSDictionary *marketDataDict = [NSJSONSerialization JSONObjectWithData:[marketData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                if (marketDataDict == nil || error != nil)
                {
                    exchangeRateString = @"Error parsing data";
                    NSLog(@"Error parsing market data: %@", [error localizedDescription]);
                }
                else
                {
                    NSDictionary* data = [marketDataDict valueForKey:self.currency];
                    if (data == nil)
                    {
                        exchangeRateString = @"Error locating data";
                        NSLog(@"Error locating market data: %@", [error localizedDescription]);
                    }
                    else
                    {
                        exchangeRate = [[data valueForKey:@"15m"] doubleValue];
                        exchangeRateString = [StatsController formatExchangeRate:exchangeRate];
                        symbol = [data valueForKey:@"symbol"];
                    }
                }
            }
            else
            {
                exchangeRateString = @"Error loading data";
                NSLog(@"Error loading market data: %@", [error localizedDescription]);
            }
        }
        error = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            UIColor* textColor;
            if (exchangeRate <= 0)
                textColor = [UIColor redColor];
            else
                textColor = [UIColor blackColor];
            
            if ([self.currency isEqualToString:@""])
            {
                // 'None' selected
                self.summaryExchangeRateLabel.text = @"Exchange rate";
            }
            else
            {
                self.summaryExchangeRateLabel.text = [@"BTC/" stringByAppendingFormat:@"%@ rate", self.currency];
            }
            self.miscExchangeRateLabel.text = self.summaryExchangeRateLabel.text;
            
            self.summaryExchangeRate.text = exchangeRateString;
            self.summaryExchangeRate.textColor = textColor;
            
            self.miscExchangeRate.text = exchangeRateString;
            self.miscExchangeRate.textColor = textColor;
        });

        
        bool isPool = (self.payoutAddress == nil);
        
        // Now we fetch the Javascript data
        NSURL* jsUrl;
        if (isPool)
            jsUrl = [NSURL URLWithString:POOL_GRAPH_PAGE];
        else
            jsUrl = [NSURL URLWithString:[NSString stringWithFormat:USER_GRAPH_PAGE, payoutAddress]];
        //NSString* jsData = [NSString stringWithContentsOfURL:jsUrl encoding:NSUTF8StringEncoding error:&error];
        NSString* jsData = [StatsController downloadURL:jsUrl error:&error downloadSize:&downloadedBytes];
        
        if ([@"" isEqualToString:jsData])
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self setCenteredTextInWebviewTo:@"Failed to load graph data."];
                [self setAllLabelsTo:@"Error" withErrorMode:true];
                [self finishRefreshing];
            });
            return;
        }
        
        if (!jsData)
        {
            // Hmm. Maybe our hard-coded URL is frelled. Try fallback.
            NSURL *fallbackUrl;
            if (isPool)
                fallbackUrl = [NSURL URLWithString:FALLBACK_POOL_GRAPH_URL_PAGE];
            else
                fallbackUrl = [NSURL URLWithString:FALLBACK_GRAPH_URL_PAGE];
            error = nil;
            //NSString *fallbackData = [NSString stringWithContentsOfURL:fallbackUrl encoding:NSUTF8StringEncoding error:&error];
            NSString* fallbackData = [StatsController downloadURL:fallbackUrl error:&error downloadSize:&downloadedBytes];
            if (fallbackData)
            {
                NSString* correctLink;
                if (isPool)
                {
                    // Extract the Javascript URL from the HTML data
                    correctLink = [StatsController extractStringFromHTML:fallbackData usingRegex:@".*<script .*\"(http://.*)\"></script>.*" getLast:false];
                }
                else
                {
                    // Try to extract Javascript URL from there
                    NSString* wrongLink = [StatsController extractStringFromHTML:fallbackData usingRegex:@".*<script .*\"(http://.*)\"></script>.*" getLast:false];
                    
                    // We need to replace the 'wrong' address with our own address
                    correctLink = [wrongLink stringByReplacingOccurrencesOfString:FALLBACK_GRAPH_ADDRESS withString:payoutAddress];
                }
                
                // Now try to fetch data again
                jsUrl = [NSURL URLWithString:correctLink];
                jsData = [NSString stringWithContentsOfURL:jsUrl encoding:NSUTF8StringEncoding error:&error];

                if (jsData)
                {
                    NSLog(@"Failed to load Javascript data from hard-coded URL, but fallback URL worked fine.");
                }
            }
            
            if (!jsData)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self setCenteredTextInWebviewTo:[NSString stringWithFormat:@"Failed to load graph data due to error: %@", error.localizedDescription]];
                    [self setAllLabelsTo:@"Error" withErrorMode:true];
                    [self finishRefreshing];
                });
                return;
            }
        }
        error = nil;
        
        // Generate filtered Javascript data (for web page)
        NSString* filteredJavascript = [StatsController filterJavascript:jsData];
        
        // Make a 'fake' web page and include JS data in it
        NSString* graphHtml = [StatsController generateGraphDataFrom:filteredJavascript];
        
        // Extract the 'hard to get' data from this thread so that main thread doesn't hang momentarily
        NSString *immatureString = [StatsController extractStringFromHTML:filteredJavascript usingRegex:@"Immature:.*?txt=' (.*?) *'" getLast:false];
        NSString *unexchangedString = [StatsController extractStringFromHTML:filteredJavascript usingRegex:@"Unexchanged:.*?txt=' (.*?) *'" getLast:false];
        NSString *balanceString = [StatsController extractStringFromHTML:filteredJavascript usingRegex:@"Balance:.*?txt=' (.*?) *'" getLast:false];
        NSString *acceptedString = [StatsController extractStringFromHTML:filteredJavascript usingRegex:@"Accepted:.*?txt=' (.*?) *'" getLast:false];
        NSString *rejectedString = [StatsController extractStringFromHTML:filteredJavascript usingRegex:@"Rejected:.*?txt=' (.*?) *'" getLast:false];
        NSString *averageHashString = [StatsController extractStringFromHTML:filteredJavascript usingRegex:@"Six Hour Moving Average:.*?txt=' (.*?) *'" getLast:false];
        NSString *updateDateString = [StatsController extractStringFromHTML:filteredJavascript usingRegex:@"Latest Values in BTC at (.*?) UTC" getLast:false];

        NSDate* lastDataUpdate = [StatsController readDate:updateDateString withOption:true];
        double averageHash = [[averageHashString stringByReplacingOccurrencesOfString:@" Mh/s" withString:@""] doubleValue];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [self.webView loadHTMLString:graphHtml baseURL:nil];
            
            // Parse the JS data
            
            self.currentImmature.text = [StatsController formatBTCFromString:immatureString withExchangeRate:exchangeRate andSymbol:symbol];
            
            self.currentUnexchanged.text = [StatsController formatBTCFromString:unexchangedString withExchangeRate:exchangeRate andSymbol:symbol];
            
            self.currentBalance.text = [StatsController formatBTCFromString:balanceString withExchangeRate:exchangeRate andSymbol:symbol];
            self.summaryBalance.text = self.currentBalance.text;
            
            double accepted = [[acceptedString stringByReplacingOccurrencesOfString:@" Mh/s" withString:@""] doubleValue];
            self.hashAccepted.text = acceptedString;
            [StatsController colorizeLabel:self.hashAccepted setOrange:(accepted <= WARNING_ACCEPTED_RATE) setRed:(accepted <= ERROR_ACCEPTED_RATE)];
            
            self.hashRejected.text = rejectedString;
            double rejected = [[rejectedString stringByReplacingOccurrencesOfString:@" Mh/s" withString:@""] doubleValue];
            
            double rejectRatio;
            if (accepted <= 0)
                rejectRatio = -1.0;
            else
                rejectRatio = rejected / accepted;
            
            if (rejectRatio < 0)
            {
                self.hashRatio.text = @"N/A";
                self.hashRatio.textColor = [UIColor redColor];
            }
            else
            {
                NSString* formatted = [NSString stringWithFormat:@"%.2f %%", rejectRatio * 100.0];
                self.hashRatio.text = formatted;
                
                [StatsController colorizeLabel:self.hashRatio setOrange:(rejectRatio >= WARNING_REJECT_RATIO) setRed:(rejectRatio >= ERROR_REJECT_RATIO)];            }
            
            {
                NSString* formatted = [NSString stringWithFormat:@"%.2f/%.2f Mh/s", accepted, rejected];
                
                bool error = (accepted == 0.0 || rejected > accepted || accepted < ERROR_ACCEPTED_RATE || rejectRatio < 0.0 || rejectRatio > ERROR_REJECT_RATIO);
                bool warn = (rejectRatio > WARNING_REJECT_RATIO || accepted < WARNING_ACCEPTED_RATE);
                self.summaryAcceptReject.text = formatted;
                [StatsController colorizeLabel:self.summaryAcceptReject setOrange:warn setRed:error];
            }
            
            self.hashAverage.text = averageHashString;
            [StatsController colorizeLabel:self.hashAverage setOrange:(averageHash <= WARNING_ACCEPTED_RATE) setRed:(averageHash <= ERROR_ACCEPTED_RATE)];
            
            // Extract update date from graph
            //self.miscLastDataUpdate.text = [StatsController convertToLocalDate:updateDateString withOption:true];
            self.miscLastDataUpdate.text = [StatsController printIntervalFor:lastDataUpdate];
            self.summaryLastUpdate.text = self.miscLastDataUpdate.text;
            
            // Calcualte approximate total unpaid
            double unpaid = [balanceString doubleValue] + [immatureString doubleValue] + [unexchangedString doubleValue];
            self.currentTotal.text = [StatsController formatBTCFromDouble:unpaid withExchangeRate:exchangeRate andSymbol:symbol];
            self.summaryTotalUnpaid.text = self.currentTotal.text;
        });
        
        
        // Now we fetch the HTML data from the middlecoin page.
        NSURL* htmlURL;
        if (isPool)
            htmlURL = [NSURL URLWithString:POOLS_STATS_PAGE];
        else
            //htmlURL = [NSURL URLWithString:[NSString stringWithFormat:USER_STATS_PAGE, self.payoutAddress]];
            htmlURL = [NSURL URLWithString:[NSString stringWithFormat:USER_JSON_PAGE, self.payoutAddress]];
        
        //NSString *htmlData = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
        NSString* htmlData = [StatsController downloadURL:htmlURL error:&error downloadSize:&downloadedBytes];
        
        if (!htmlData)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self setCenteredTextInWebviewTo:[NSString stringWithFormat:@"Failed to load HTML data for statistics due to error: %@", error.localizedDescription]];
                [self setAllLabelsTo:@"Error" withErrorMode:true];
                [self finishRefreshing];
            });
            return;
        }
        
        // Parse all the data into a single array (where each entry is an array containing the payout date and the payout amount)
        NSArray* payouts = [StatsController parsePayoutsDataFrom:htmlData isPool:isPool];

        // Now parse the other stuff on the HTML page (e.g. last payout amount and last update date)
        NSDate* lastPayoutDate = [[payouts lastObject] objectAtIndex:0];
        double lastPayoutAmount = [[[payouts lastObject] objectAtIndex:1] doubleValue];
        
        // Calculate stats
        NSDictionary* stats7 = [StatsController calculateStatsFrom:payouts forDays:7 andHashRate:averageHash];
        NSDictionary* stats30 = [StatsController calculateStatsFrom:payouts forDays:30 andHashRate:averageHash];
        NSDictionary* statsAll = [StatsController calculateStatsFrom:payouts forDays:(365*50) andHashRate:averageHash];
        
        double balance = [balanceString doubleValue];
        double timeSinceLastPayout = ABS([lastPayoutDate timeIntervalSinceNow]);
        double payoutForecast;
        if (timeSinceLastPayout < 60 * 60 * 3)
            payoutForecast = -1.0;
        else
        {
            payoutForecast = balance * 24 * 60 * 60 / timeSinceLastPayout;
            if (payoutForecast < balance)
                payoutForecast = balance;
        }
            
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            // Get last payout amount
            //NSString *lastPayoutAmountString = [StatsController extractStringFromHTML:htmlData usingRegex:@"m.</td>\n<td>(.*)</td>\n</tr>" getLast:true];
            self.recentPayoutAmount.text = [StatsController formatBTCFromDouble:lastPayoutAmount withExchangeRate:exchangeRate andSymbol:symbol];
            self.recentPayoutDate.text = [StatsController printIntervalFor:lastPayoutDate];
            
            // Calculate simple forecast
            if (payoutForecast < 0)
                self.recentNextForecastAmount.text = @"Insufficient data";
            else
            {
                // TODO: need to calculate time between last payout and 9:30pm (and use that instead of 24*60*60)
                self.recentNextForecastAmount.text = [StatsController formatBTCFromDouble:payoutForecast withExchangeRate:exchangeRate andSymbol:symbol];
            }
            self.summaryPayoutForecast.text = self.recentNextForecastAmount.text;
            
            // Calculate current BTC/MH/s
            double btcPerMHs;
            if (timeSinceLastPayout < 60 * 60 * 3)
            {
                self.summaryCurrentPerMHs.text = @"Insufficient data";
                self.recentCurrentPerMHs.text = @"Insufficient data";
                btcPerMHs = 0.0/0.0;
            }
            else
            {
                if (averageHash == 0.0)
                    btcPerMHs = 0.0;
                else
                    btcPerMHs = balance / timeSinceLastPayout * 60.0 * 60.0 * 24.0 / averageHash;
                
                NSString* formatted = [StatsController formatBTCFromDouble:btcPerMHs withExchangeRate:exchangeRate andSymbol:symbol];
                self.summaryCurrentPerMHs.text = formatted;
                self.recentCurrentPerMHs.text = formatted;
            }
            
            // Display stats
            self.sevenAverage.text = [StatsController formatBTCFromDouble:[[stats7 valueForKey:@"average"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.sevenStdev.text = [StatsController formatBTCFromDouble:[[stats7 valueForKey:@"stdev"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.sevenMin.text = [StatsController formatBTCFromDouble:[[stats7 valueForKey:@"min"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.sevenMax.text = [StatsController formatBTCFromDouble:[[stats7 valueForKey:@"max"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.sevenPerMHs.text = [StatsController formatBTCFromDouble:[[stats7 valueForKey:@"perMHs"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.sevenTotal.text = [StatsController formatBTCFromDouble:[[stats7 valueForKey:@"total"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];

            self.thirtyAverage.text = [StatsController formatBTCFromDouble:[[stats30 valueForKey:@"average"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.thirtyStdev.text = [StatsController formatBTCFromDouble:[[stats30 valueForKey:@"stdev"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.thirtyMin.text = [StatsController formatBTCFromDouble:[[stats30 valueForKey:@"min"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.thirtyMax.text = [StatsController formatBTCFromDouble:[[stats30 valueForKey:@"max"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.thirtyPerMHs.text = [StatsController formatBTCFromDouble:[[stats30 valueForKey:@"perMHs"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.thirtyTotal.text = [StatsController formatBTCFromDouble:[[stats30 valueForKey:@"total"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];

            self.allAverage.text = [StatsController formatBTCFromDouble:[[statsAll valueForKey:@"average"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.allStdev.text = [StatsController formatBTCFromDouble:[[statsAll valueForKey:@"stdev"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.allMin.text = [StatsController formatBTCFromDouble:[[statsAll valueForKey:@"min"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.allMax.text = [StatsController formatBTCFromDouble:[[statsAll valueForKey:@"max"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.allPerMHs.text = [StatsController formatBTCFromDouble:[[statsAll valueForKey:@"perMHs"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            self.allTotal.text = [StatsController formatBTCFromDouble:[[statsAll valueForKey:@"total"] doubleValue] withExchangeRate:exchangeRate andSymbol:symbol];
            
            // Next payout stats
            NSDate* nextPayoutDate = [StatsController calculateNextPayoutDateFrom:payouts];
            self.recentNextPayoutIn.text = [StatsController formatNextPayoutDate:nextPayoutDate];
            
            // Colorize all the things!
            double averagePayout7 = [[stats7 valueForKey:@"average"] doubleValue];
            double btcPerMHs7 = [[stats7 valueForKey:@"perMHs"] doubleValue];
            [StatsController colorizeLabel:self.recentPayoutAmount setOrange:(!isnan(averagePayout7) && lastPayoutAmount < averagePayout7) setRed:(lastPayoutAmount == 0.0)];
            [StatsController colorizeLabel:self.recentNextPayoutIn setOrange:(nextPayoutDate == nil) setRed:false];
            [StatsController colorizeLabel:self.recentCurrentPerMHs setOrange:(isnan(btcPerMHs)) setRed:(!isnan(btcPerMHs) && btcPerMHs < ERROR_BTC_PER_MHS)];
            [StatsController colorizeLabel:self.summaryCurrentPerMHs setOrange:(isnan(btcPerMHs) || (!isnan(btcPerMHs7) && btcPerMHs < btcPerMHs7)) setRed:(!isnan(btcPerMHs) && btcPerMHs < ERROR_BTC_PER_MHS)];
            [StatsController colorizeLabel:self.recentPayoutDate setOrange:(timeSinceLastPayout > 60 * 60 * 24 + INSUFFICIENT_DATA_INTERVAL) setRed:(timeSinceLastPayout > 60 * 60 * 48 + INSUFFICIENT_DATA_INTERVAL)];
            
            [StatsController colorizeLabel:self.summaryPayoutForecast setOrange:(payoutForecast < 0 || (!isnan(averagePayout7) && payoutForecast < averagePayout7)) setRed:(payoutForecast == 0.0)];

            [StatsController colorizeLabel:self.sevenStdev setOrange:([[stats7 valueForKey:@"stdev"] doubleValue] > [[stats7 valueForKey:@"average"] doubleValue]) setRed:false];
            [StatsController colorizeLabel:self.thirtyStdev setOrange:([[stats30 valueForKey:@"stdev"] doubleValue] > [[stats30 valueForKey:@"average"] doubleValue]) setRed:false];
            [StatsController colorizeLabel:self.allStdev setOrange:([[statsAll valueForKey:@"stdev"] doubleValue] > [[statsAll valueForKey:@"average"] doubleValue]) setRed:false];
            
            [StatsController colorizeLabel:self.miscLastDataUpdate setOrange:([lastDataUpdate timeIntervalSinceNow] < -WARNING_DATA_UPDATE_INTERVAL) setRed:([lastDataUpdate timeIntervalSinceNow] < -ERROR_DATA_UPDATE_INTERVAL)];
            [StatsController colorizeLabel:self.summaryLastUpdate setOrange:([lastDataUpdate timeIntervalSinceNow] < -WARNING_DATA_UPDATE_INTERVAL) setRed:([lastDataUpdate timeIntervalSinceNow] < -ERROR_DATA_UPDATE_INTERVAL)];
            
            self.miscSizeOfLastUpdate.text = [StatsController formatBytes:downloadedBytes];
            [StatsController colorizeLabel:self.miscSizeOfLastUpdate setOrange:(downloadedBytes > 1024 * 100) setRed:(downloadedBytes > 1024 * 1024)];
            
            NSDate* now = [NSDate date];
            self.miscLastAppRefresh.text = [StatsController printIntervalFor:now];
            self.lastRefreshDate = now;
            
            [self finishRefreshing];
        });
    });
}

+(NSString*) formatBytes:(long long)bytes
{
    if (bytes < 1024)
        return [NSString stringWithFormat:@"%lld bytes", bytes];
    
    if (bytes < 1024 * 1024)
        return [NSString stringWithFormat:@"%.1f kB", (double)bytes / 1024.0];
    
    return [NSString stringWithFormat:@"%.1f MB", (double)bytes / (1024.0 * 1024.0)];
}

+(NSString*) downloadURL:(NSURL*)url error:(NSError **)error downloadSize:(long long*)size
{
    // Build request
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:DATA_DOWNLOAD_TIMEOUT];
    NSURLResponse* response = nil;
    
    // Download data
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    if (!data)
        return nil;
    
    // Convert downloaded to String
    NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Now get downloaded data size
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString* contentLength = [[httpResponse allHeaderFields] valueForKey:@"Content-Length"];
    long long mySize;
    if (contentLength == nil)
    {
        // Some sites don't return a content length. We assume those don't use compression, and fallback to the 'expected content length' property from NSURLResponse.
        mySize = [response expectedContentLength];
    }
    else
    {
        // We have the content lenght!
        mySize = [contentLength longLongValue];
    }
    if (size != nil)
        *size += mySize;
    //NSLog(@"bytes for url %@ = %lld", url, mySize);
    
    return string;
}

+(void)colorizeLabel:(UILabel*)label setOrange:(bool)orange setRed:(bool)red
{
    if (red)
        label.textColor = [UIColor redColor];
    else if (orange)
        label.textColor = [UIColor orangeColor];
    else
        label.textColor = [UIColor blackColor];
}

+(NSDate*)calculateNextPayoutDateFrom:(NSArray*)payouts
{
    NSDate* lastPayoutTime = [[payouts lastObject] objectAtIndex:0];
    if (abs([lastPayoutTime timeIntervalSinceNow]) < INSUFFICIENT_DATA_INTERVAL)
        return nil;
    
    // Calculate date of next '2:30am' from last payout date
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone* utc = [NSTimeZone timeZoneWithName:@"UTC"];
    [gregorian setTimeZone:utc];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* components = [gregorian components:unitFlags fromDate:lastPayoutTime];
    [components setHour:2];
    [components setMinute:30];
    NSDate* nextPayout = [gregorian dateFromComponents:components];
    NSDate* now = [[NSDate alloc] init];
    
    if ([nextPayout compare:now] == NSOrderedAscending)
        nextPayout = [nextPayout dateByAddingTimeInterval:(60 * 60 * 24)];
    
    if ([nextPayout compare:now] == NSOrderedAscending)
    {
        // Hm next payout calculated from previous payout is before current date. Calculate new payout date from current date instead.
        components = [gregorian components:unitFlags fromDate:now];
        [components setHour:2];
        [components setMinute:30];
        nextPayout = [gregorian dateFromComponents:components];
        
        if (abs([nextPayout timeIntervalSinceNow]) < INSUFFICIENT_DATA_INTERVAL)
            return nil;
        
        if ([nextPayout compare:now] == NSOrderedAscending)
            nextPayout = [nextPayout dateByAddingTimeInterval:(60 * 60 * 24)];
    }
    
    if (abs([nextPayout timeIntervalSinceNow]) < INSUFFICIENT_DATA_INTERVAL)
        return nil;
    
    return nextPayout;
}

+(NSString*)formatNextPayoutDate:(NSDate*)nextPayoutDate
{
    if (nextPayoutDate == nil)
        return @"Any moment now";
    
    long seconds = (long)abs([nextPayoutDate timeIntervalSinceNow]);
    if (seconds <= 60)
        return @"Any moment now";
    
    seconds = seconds / 60;
    if (seconds <= 60)
        return [NSString stringWithFormat:@"%ld minutes", seconds];
    
    long hours = seconds / 60;
    long minutes = seconds % 60;
    
    return [NSString stringWithFormat:@"%ld hours %ld mins", hours, minutes];
}

+(NSArray*) parsePayoutsDataFrom:(NSString*)data isPool:(bool)isPool
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    if (!isPool)
    {
        // Easy case: we just need to parse the JSON and add to the array.
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&localError];
        
        NSArray *items = [parsedObject valueForKey:@"report"];
        for (NSDictionary *groupDic in items)
        {
            NSNumber* amount = [groupDic valueForKey:@"amount"];
            long time = [[groupDic valueForKey:@"time"] longValue];
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];
            NSArray* entry = [NSArray arrayWithObjects:date, amount, nil];
            [result addObject:entry];
        }
    }
    else
    {
        // Here we do a bit of a hack: we add a single entry with a nil date that has the total paid out amount (so that when we go to calculate the total paid out value it still works)
        NSString* totalPaidOutString = [StatsController extractStringFromHTML:data usingRegex:@"<td>(.*)</td>\n</tr>" getLast:true];
        
        NSNumber* amount = [NSNumber numberWithDouble:[totalPaidOutString doubleValue]];
        NSDate* date = [[NSDate alloc] init];
        NSArray* entry = [NSArray arrayWithObjects:date, amount, nil];
        [result addObject:entry];
    }
    
    //NSLog(@"Values:");
    //for (id value in result)
    //    NSLog(@" %@", value);
    
    return result;
}

+(NSDate*) readDate:(NSString*)utcDate withOption:(bool)useAltFormat
{
    // Start by converting date to something we can work with
    NSString *date = [utcDate stringByReplacingOccurrencesOfString:@"." withString:@""];
    //NSLog(@"String to work with: %@", date);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    if (useAltFormat)
        [formatter setDateFormat:@"MM/dd/yy HH:mm"];
    else
        [formatter setDateFormat:@"MMM d, yyyy, h:mm a"];
    
    return [formatter dateFromString:date];
}

+(NSString*) convertToLocalDate:(NSString*)utcDate withOption:(bool)useAltFormat
{
    NSDate* parsed = [StatsController readDate:utcDate withOption:useAltFormat];
    
    //NSLog(@"parsed date: %@", parsed);
    return [StatsController printLocalDate:parsed];
}

+(NSString*) printIntervalFor:(NSDate*)date
{
    //NSLog(@"printing interval for %@", date);
    NSTimeInterval seconds = [date timeIntervalSinceNow];
    bool isAfterNow = seconds > 0;
    seconds = abs(seconds);
    
    NSString* fragment;
    if (seconds < 60)
        fragment = [NSString stringWithFormat:@"%.0f seconds", seconds];
    else if (seconds < 60 * 60)
        fragment = [NSString stringWithFormat:@"%.0f minutes", (seconds / 60.0)];
    else if (seconds < 60 * 60 * 30)
    {
        long tmp = seconds / 60;
        long hours = tmp / 60;
        long minutes = tmp % 60;
        fragment = [NSString stringWithFormat:@"%ldh %ldm", hours, minutes];
    }
    else
        return [StatsController printLocalDate:date];
    
    if (isAfterNow)
        return [NSString stringWithFormat:@"in %@", fragment];
    return [NSString stringWithFormat:@"%@ ago", fragment];
}

+(NSString*) printLocalDate:(NSDate*) date
{
    NSDateFormatter* outputFormatter = [[NSDateFormatter alloc] init];
    //[outputFormatter setDateStyle:NSDateFormatterMediumStyle];
    //[outputFormatter setTimeStyle:NSDateFormatterShortStyle];
    [outputFormatter setDateFormat:@"MMM d 'at' h:mm a"];
    NSString* myString = [outputFormatter stringFromDate:date];
    
    return myString;
}

+(NSString*) extractStringFromHTML:(NSString*)html usingRegex:(NSString*)regex getLast:(bool)useLast
{
    NSError *error = nil;
    NSRegularExpression *jsExpr = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [jsExpr matchesInString:html options:0 range:NSMakeRange(0, [html length])];
    NSString *result = nil;
    for (NSTextCheckingResult *match in matches)
    {
        NSRange groupRange = [match rangeAtIndex:1];
        result = [html substringWithRange:groupRange];
        if (!useLast)
            return result;
    }
    
    return result;
}

+(NSString*)formatExchangeRate:(double)rate
{
    if (rate > 10000)
        return [NSString stringWithFormat:@"%.0f", rate];
    if (rate > 100)
        return [NSString stringWithFormat:@"%.2f", rate];
    return [NSString stringWithFormat:@"%.4f", rate];
}

/*+(void)setLabelText:(UILabel*)label toValue:(NSString*)text
{
    [StatsController setLabelText:label toValue:text withColor:[UIColor blackColor]];
}

+(void)setLabelWarningText:(UILabel*)label toValue:(NSString*)text
{
    [StatsController setLabelText:label toValue:text withColor:[UIColor orangeColor]];
}

+(void)setLabelErrorText:(UILabel*)label toValue:(NSString*)text
{
    [StatsController setLabelText:label toValue:text withColor:[UIColor redColor]];
}

+(void)setLabelText:(UILabel*)label toValue:(NSString*)text withColor:(UIColor*) color
{
    label.textColor = color;
    label.text = text;
}*/

+(NSString*)formatBTCFromString:(NSString*)amount withExchangeRate:(double)rate andSymbol:(NSString*)symbol
{
    return [StatsController formatBTCFromDouble:[amount doubleValue] withExchangeRate:rate andSymbol:symbol];
}

+(NSString*)formatBTCFromDouble:(double)amount withExchangeRate:(double)rate andSymbol:(NSString*)symbol
{
    if (isnan(amount))
        return @"N/A";
    
    NSString* btc;
    if (amount > 100.0)
        btc = [NSString stringWithFormat:@"%.0f %@", amount, BITCOIN_SYMBOL];
    else if (amount > 1.0)
        btc = [NSString stringWithFormat:@"%.2f %@", amount, BITCOIN_SYMBOL];
    else
        btc = [NSString stringWithFormat:@"%.4f %@", amount, BITCOIN_SYMBOL];
    
    if (rate <= 0.0)
        return btc;
    
    double converted = rate * amount;
    
    if (converted > 100.0)
        return [NSString stringWithFormat:@"%@ (%.0f %@)", btc, converted, symbol];
    
    return [NSString stringWithFormat:@"%@ (%.2f %@)", btc, converted, symbol];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(void)setCenteredTextInWebview:(UIWebView*)webview toText:(NSString*)text
{
    NSString* prepend = @"<html><head><meta name=\"viewport\" content=\"width=device-width\" /></head><body style=\"display: table; height: 100%; width: 100%; font-family: Arial, Helvetica, sans-serif;\"><div style=\"display: table-cell; vertical-align: middle; text-align: center\">";
    NSString* append = @"</div></body></html>";
    NSString* html = [[prepend stringByAppendingString:text] stringByAppendingString:append];
    [webview loadHTMLString:html baseURL:nil];
}

-(void)setCenteredTextInWebviewTo:(NSString*)text
{
    [StatsController setCenteredTextInWebview:self.webView toText:text];
}

+(NSString*)filterJavascript:(NSString*)data
{
    NSString* prepend = @"var newWidth = 520; ctx.translate(newWidth - 1000, 0);";
    NSString* append = @"var imgData=ctx.getImageData(0,296,newWidth-50,120);ctx.putImageData(imgData,0,281);var imgData=ctx.getImageData(newWidth-50,306,50,120);ctx.putImageData(imgData,newWidth-50,291);ctx.clearRect(940+1,0,1000,20-4);ctx.clearRect(1000-newWidth, 0, 5, 400);ctx.clearRect(1000-newWidth, 367, newWidth-150, 20);";
    NSString* result = [[data stringByReplacingCharactersInRange:NSMakeRange(78, 0)withString:prepend] stringByAppendingString:append];
    result = [result stringByReplacingOccurrencesOfString:@"ctx.fillStyle='white';ctx.fillRect(940+1,0,1000,20-4);" withString:@""];
    
    return result;
}

+(NSString*) generateGraphDataFrom:(NSString*)javascriptData
{
    NSString* myHTML = [NSString stringWithFormat:@"%@%@%@", @"<html><head><meta name=\"viewport\" content=\"width=device-width\" /><style type=\"text/css\">body { margin:5px }</style></head><body><div style=\"width:520px; height:378px; overflow:hidden;\"><canvas id=\"mc_data\" width=\"520\" height=\"400\">Hm no HTML canvas graphics support??</canvas><script type=\"text/javascript\">", javascriptData, @"</script></html></body>"];
    return myHTML;
}

+(NSDictionary*) calculateStatsFrom:(NSArray*)payouts forDays:(int)days andHashRate:(double)hashRate
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    double total = 0.0;
    double squaresTotal = 0.0;
    double min = 1.0E100;
    double max = -1.0;
    int count = 0;
    //int usedDays = 0;

    NSDate* startDate = [NSDate dateWithTimeIntervalSinceNow:(-1 * days * 24 * 60 * 60)];
    //NSLog(@"start date: %@", startDate);
    
    //NSDate* previousDate = [[[payouts objectAtIndex:0] objectAtIndex:0] dateByAddingTimeInterval:(-1 * 24 * 60 * 60)];
    
    for (NSArray* entry in payouts)
    {
        NSDate* date = [entry objectAtIndex:0];
        
        if ([date compare:startDate] == NSOrderedDescending)
        {
            // Date is after our start date! We can use this data.
            //NSLog(@"Considered data: %@", entry);
            
            count++;
            double amount = [[entry objectAtIndex:1] doubleValue];
            total += amount;
            squaresTotal += amount * amount;
            min = MIN(min, amount);
            max = MAX(max, amount);
        }
        
        //previousDate = date;
    }
    
    // Now calculate average and stddev.
    double average;
    if (count == 0)
        average = 0.0/0.0;
    else
        average = total / count;
    
    double stdev;
    if (count <= 2)
        stdev = 0.0/0.0;
    else
        stdev = sqrt((count * squaresTotal - total * total) / (count * (count - 1)));
    
    double perMHs;
    if (hashRate <= 0.0)
        perMHs = 0.0/0.0;
    else
        perMHs = average / hashRate;
    
    // Special cases
    if (min == 1.0E100)
        min = 0.0/0.0;
    if (max < 0.0)
        max = 0.0/0.0;
    
    // Now put all values in the dictionnary.
    [result setObject:[NSNumber numberWithDouble:average] forKey:@"average"];
    [result setObject:[NSNumber numberWithDouble:total] forKey:@"total"];
    [result setObject:[NSNumber numberWithDouble:stdev] forKey:@"stdev"];
    [result setObject:[NSNumber numberWithDouble:min] forKey:@"min"];
    [result setObject:[NSNumber numberWithDouble:max] forKey:@"max"];
    [result setObject:[NSNumber numberWithDouble:perMHs] forKey:@"perMHs"];
    [result setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    
    return result;
}

-(void)timerTriggered:(NSTimer*)timer
{
    NSDate* lastUpdate = self.lastRefreshDate;
    if (lastUpdate != nil)
    {
        //NSLog(@"timer fired at %@", [[NSDate alloc] init]);
        self.miscLastAppRefresh.text = [StatsController printIntervalFor:lastUpdate];
    }
}

@end
