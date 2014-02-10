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
@property NSString *payoutAddress;


@property (weak, nonatomic) IBOutlet UILabel *summaryBalance;
@property (weak, nonatomic) IBOutlet UILabel *summaryPayoutForecast;
@property (weak, nonatomic) IBOutlet UILabel *summaryAcceptReject;
@property (weak, nonatomic) IBOutlet UILabel *summaryExchangeRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryExchangeRate;

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

@property (weak, nonatomic) IBOutlet UILabel *sevenAverage;
@property (weak, nonatomic) IBOutlet UILabel *sevenStdev;
@property (weak, nonatomic) IBOutlet UILabel *sevenMin;
@property (weak, nonatomic) IBOutlet UILabel *sevenMax;
@property (weak, nonatomic) IBOutlet UILabel *sevenPerMHs;
@property (weak, nonatomic) IBOutlet UILabel *sevenTotal;

@property (weak, nonatomic) IBOutlet UILabel *thirtySmartAverage;
@property (weak, nonatomic) IBOutlet UILabel *thirtyTrueAverage;
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
    
    /*self.refreshControl = [[UIRefreshControl alloc] init];
    self.scrollView.delegate = (id)self;
    [self.refreshControl addTarget:self action:@selector(refreshControlTriggered:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.refreshControl];*/
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    
    [self setCenteredTextInWebviewTo:@"Loading data, please wait..."];
    [self setAllLabelsTo:@"Loading..." withErrorMode:false];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (lastRefreshDate == nil || [lastRefreshDate timeIntervalSinceNow] < -AUTO_REFRESH_INTERVAL)
        [self tryRefresh];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.scrollPosition = self.scrollView.contentOffset;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    float headerSize = 20; // status bar height
    if (self.navigationController && self.navigationController.navigationBarHidden == NO)
        headerSize += self.navigationController.toolbar.frame.size.height;
    float tabBarSize = 49;
    self.scrollView.contentInset = UIEdgeInsetsMake(headerSize, 0, tabBarSize, 0);
    self.scrollView.contentSize = self.innerView.frame.size;
    
    if (self.scrollPosition.x != 0 || self.scrollPosition.y != 0)
        self.scrollView.contentOffset = self.scrollPosition;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.innerView;
}

-(NSArray*)getAllLabels
{
    return [NSArray arrayWithObjects:self.summaryBalance, self.summaryPayoutForecast, self.summaryAcceptReject, self.summaryExchangeRate,self.currentBalance, self.currentUnexchanged, self.currentImmature, self.currentTotal, self.hashAccepted, self.hashRejected, self.hashRatio, self.hashAverage, self.recentPayoutDate, self.recentPayoutAmount, self.recentNextPayoutIn, self.recentNextForecastAmount,self.sevenAverage, self.sevenStdev, self.sevenMin, self.sevenMax, self.sevenPerMHs, self.sevenTotal, self.thirtySmartAverage, self.thirtyTrueAverage, self.thirtyStdev, self.thirtyMin, self.thirtyMax, self.thirtyPerMHs, self.thirtyTotal,self.allAverage, self.allStdev, self.allMin, self.allMax, self.allPerMHs, self.allTotal, self.miscLastDataUpdate, self.miscLastAppRefresh, self.miscSizeOfLastUpdate, self.miscExchangeRate, self.miscAddress,
            nil];
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
        NSString* currency = @"CAD"; // TODO replace by value from settings
        NSURL* marketDataURL = [NSURL URLWithString:RATES_URL];
        
        NSError *error = nil;
        NSString *marketData = [NSString stringWithContentsOfURL:marketDataURL encoding:NSUTF8StringEncoding error:&error];
        
        if (!marketData)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self setCenteredTextInWebviewTo:[NSString stringWithFormat:@"Failed to load HTML data for exchange rate due to error: %@", error.localizedDescription]];
                [self setAllLabelsTo:@"Error" withErrorMode:true];
                [self finishRefreshing];
            });
            return;
        }
        
        // Parse exchange rate
        NSDictionary *marketDataDict = [NSJSONSerialization JSONObjectWithData:[ marketData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSString* exchangeRateString = @"???";
        double exchangeRate = -1;
        NSString* symbol = @"???";
        if (marketDataDict == nil || error != nil)
        {
            self.summaryExchangeRate.text = @"Error loading";
            self.miscExchangeRate.text = @"Error loading";
        }
        else
        {
            NSDictionary* data = [marketDataDict valueForKey:currency];
            if (data == nil)
            {
                self.summaryExchangeRate.text = @"Error loading";
                self.miscExchangeRate.text = @"Error loading";
            }
            else
            {
                exchangeRate = [[data valueForKey:@"15m"] doubleValue];
                exchangeRateString = [StatsController formatExchangeRate:exchangeRate];
                symbol = [data valueForKey:@"symbol"];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.summaryExchangeRate.text = exchangeRateString;
            self.miscExchangeRate.text = exchangeRateString;
        });
        
        bool isPool = (self.payoutAddress == nil);
        
        // Now we fetch the HTML data from the middlecoin page.
        NSURL* htmlURL;
        if (isPool)
            htmlURL = [NSURL URLWithString:@"http://www.middlecoin.com"];
        else
            htmlURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://middlecoin2.s3-website-us-west-2.amazonaws.com/reports/%@.html", self.payoutAddress]];
        
        NSString *htmlData = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:&error];
        
        if (!htmlData)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self setCenteredTextInWebviewTo:[NSString stringWithFormat:@"Failed to load HTML data for statistics due to error: %@", error.localizedDescription]];
                [self setAllLabelsTo:@"Error" withErrorMode:true];
                [self finishRefreshing];
            });
            return;
        }
        
        // Get Javascript URL
        NSURL *jsUrl = [NSURL URLWithString:[StatsController extractStringFromHTML:htmlData usingRegex:@".*<script .*\"(http://.*)\"></script>.*" getLast:false]];
        if (jsUrl == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self setCenteredTextInWebviewTo:@"Failed to parse received HTML data."];
                [self setAllLabelsTo:@"N/A" withErrorMode:true];
                [self finishRefreshing];
            });
            return;
        }

        // Now parse the other stuff on the HTML page (e.g. last payout amount and last update date)
        NSString *lastPayoutDateString = [StatsController extractStringFromHTML:htmlData usingRegex:@"</td>\n<td>(.*)</td>\n<td>" getLast:true];
        NSDate* lastPayoutDate = [StatsController readDate:lastPayoutDateString withOption:false];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            // Get last payout amount
            NSString *lastPayoutAmountString = [StatsController extractStringFromHTML:htmlData usingRegex:@"m.</td>\n<td>(.*)</td>\n</tr>" getLast:true];
            self.recentPayoutAmount.text = [StatsController formatBTCFromString:lastPayoutAmountString withExchangeRate:exchangeRate andSymbol:symbol];
            
            self.recentPayoutDate.text = [StatsController printLocalDate:lastPayoutDate];
            
            NSString *totalPaidOutString;
            if (isPool)
            {
                totalPaidOutString = [StatsController extractStringFromHTML:htmlData usingRegex:@"<td>(.*)</td>\n</tr>" getLast:true];
            }
            else
            {
                totalPaidOutString = [StatsController extractStringFromHTML:htmlData usingRegex:@"<td>(.*)</a></td>\n</tr>" getLast:true];
            }
            self.allTotal.text = [StatsController formatBTCFromString:totalPaidOutString withExchangeRate:exchangeRate andSymbol:symbol];
        });
        
        
        // Now download the javascript data.
        NSString *jsData = [NSString stringWithContentsOfURL:jsUrl encoding:NSUTF8StringEncoding error:&error];
        
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
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self setCenteredTextInWebviewTo:[NSString stringWithFormat:@"Failed to load graph data due to error: %@", error.localizedDescription]];
                [self setAllLabelsTo:@"Error" withErrorMode:true];
                [self finishRefreshing];
            });
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            // Make a 'fake' web page and include JS data in it
            [self setGraphDataInWebview:jsData];
            
            // Parse the JS data
            
            NSString *immatureString = [StatsController extractStringFromHTML:jsData usingRegex:@"Immature:.*?txt=' (.*?) *'" getLast:false];
            self.currentImmature.text = [StatsController formatBTCFromString:immatureString withExchangeRate:exchangeRate andSymbol:symbol];
            
            NSString *unexchangedString = [StatsController extractStringFromHTML:jsData usingRegex:@"Unexchanged:.*?txt=' (.*?) *'" getLast:false];
            self.currentUnexchanged.text = [StatsController formatBTCFromString:unexchangedString withExchangeRate:exchangeRate andSymbol:symbol];

            
            NSString *balanceString = [StatsController extractStringFromHTML:jsData usingRegex:@"Balance:.*?txt=' (.*?) *'" getLast:false];
            self.currentBalance.text = [StatsController formatBTCFromString:balanceString withExchangeRate:exchangeRate andSymbol:symbol];
            self.summaryBalance.text = self.currentBalance.text;
            
            NSString *acceptedString = [StatsController extractStringFromHTML:jsData usingRegex:@"Accepted:.*?txt=' (.*?) *'" getLast:false];
            self.hashAccepted.text = acceptedString;
            double accepted = [[acceptedString stringByReplacingOccurrencesOfString:@" Mh/s" withString:@""] doubleValue];
            
            NSString *rejectedString = [StatsController extractStringFromHTML:jsData usingRegex:@"Rejected:.*?txt=' (.*?) *'" getLast:false];
            self.hashRejected.text = rejectedString;
            double rejected = [[rejectedString stringByReplacingOccurrencesOfString:@" Mh/s" withString:@""] doubleValue];
            
            self.summaryAcceptReject.text = [NSString stringWithFormat:@"%.2f/%.2f Mh/s", accepted, rejected];
            
            if (accepted <= 0)
                self.hashRatio.text = @"N/A";
            else
                self.hashRatio.text = [NSString stringWithFormat:@"%.3f %%", rejected / accepted];
            
            NSString *averageHashString = [StatsController extractStringFromHTML:jsData usingRegex:@"Three Hour Moving Average:.*?txt=' (.*?) *'" getLast:false];
            self.hashAverage.text = averageHashString;
            
            // Extract update date from graph
            NSString *updateDateString = [StatsController extractStringFromHTML:jsData usingRegex:@"Latest Values in BTC at (.*?) UTC" getLast:false];
            self.miscLastDataUpdate.text = [StatsController convertToLocalDate:updateDateString withOption:true];
            
            NSDate* now = [NSDate date];
            self.miscLastAppRefresh.text = [StatsController printLocalDate:now];
            lastRefreshDate = now;

            
            // Calcualte approximate total unpaid
            double unpaid = [balanceString doubleValue] + [immatureString doubleValue] + [unexchangedString doubleValue];
            self.currentTotal.text = [StatsController formatBTCFromDouble:unpaid withExchangeRate:exchangeRate andSymbol:symbol];
            
            // Calculate simple forecast
            double timeSinceLastPayout = ABS([lastPayoutDate timeIntervalSinceNow]);
            if (timeSinceLastPayout < 60 * 60)
                self.recentNextForecastAmount.text = @"Insufficient data";
            else
            {
                // todo: need to calculate time between last payout and 9:30pm (and use that instead of 24*60*60)
                double balance = [balanceString doubleValue];
                double forecast = balance * 24 * 60 * 60 / timeSinceLastPayout;
                if (forecast < balance)
                    forecast = balance;
                self.recentNextForecastAmount.text = [StatsController formatBTCFromDouble:forecast withExchangeRate:exchangeRate andSymbol:symbol];
            }
            self.summaryPayoutForecast.text = self.recentNextForecastAmount.text;
            
            [self finishRefreshing];
        });

    });
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

+(NSString*)formatBTCFromString:(NSString*)amount withExchangeRate:(double)rate andSymbol:(NSString*)symbol
{
    return [StatsController formatBTCFromDouble:[amount doubleValue] withExchangeRate:rate andSymbol:symbol];
}

+(NSString*)formatBTCFromDouble:(double)amount withExchangeRate:(double)rate andSymbol:(NSString*)symbol
{
    NSString* btc;
    if (amount > 100.0)
        btc = [NSString stringWithFormat:@"%.0f %@", amount, BITCOIN_SYMBOL];
    else if (amount > 1.0)
        btc = [NSString stringWithFormat:@"%.2f %@", amount, BITCOIN_SYMBOL];
    else
        btc = [NSString stringWithFormat:@"%.4f %@", amount, BITCOIN_SYMBOL];
    
    if (rate < 0.0)
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

-(void)setGraphDataInWebview:(NSString*)rawJavascriptData
{
    NSString* filtered = [StatsController filterJavascript:rawJavascriptData];
    NSString *myHTML = [[@"<html><head><meta name=\"viewport\" content=\"width=device-width\" /><style type=\"text/css\">body { margin:5px }</style></head><body><div style=\"width:520px; height:378px; overflow:hidden;\"><canvas id=\"mc_data\" width=\"520\" height=\"400\">Hm no HTML canvas graphics support??</canvas><script type=\"text/javascript\">" stringByAppendingString:filtered] stringByAppendingString:@"</script></html></body>"];
    [self.webView loadHTMLString:myHTML baseURL:nil];
}

// if useSmallFormat is true, the returned javascript will be
+(NSString*)filterJavascript:(NSString*)data
{
    NSString* prepend = @"var newWidth = 520; ctx.translate(newWidth - 1000, 0);";
    NSString* append = @"var imgData=ctx.getImageData(0,296,newWidth-50,120);ctx.putImageData(imgData,0,281);var imgData=ctx.getImageData(newWidth-50,306,50,120);ctx.putImageData(imgData,newWidth-50,291);ctx.clearRect(940+1,0,1000,20-4);ctx.clearRect(1000-newWidth, 0, 5, 400);ctx.clearRect(1000-newWidth, 367, newWidth-150, 20);";
    NSString* result = [[data stringByReplacingCharactersInRange:NSMakeRange(78, 0)withString:prepend] stringByAppendingString:append];
    result = [result stringByReplacingOccurrencesOfString:@"ctx.fillStyle='white';ctx.fillRect(940+1,0,1000,20-4);" withString:@""];
    
    return result;
}

@end
