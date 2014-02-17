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


@property (weak, nonatomic) IBOutlet UILabel *summaryBalance;
@property (weak, nonatomic) IBOutlet UILabel *summaryPayoutForecast;
@property (weak, nonatomic) IBOutlet UILabel *summaryCurrentPerMHs;
@property (weak, nonatomic) IBOutlet UILabel *summaryExchangeRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryExchangeRate;
@property (weak, nonatomic) IBOutlet UILabel *summaryAcceptReject;

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
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    self.scrollView.delegate = (id)self;
    [self.refreshControl addTarget:self action:@selector(refreshControlTriggered:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.refreshControl];*/
    
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
    return [NSArray arrayWithObjects:self.summaryBalance, self.summaryPayoutForecast, self.summaryAcceptReject, self.summaryExchangeRate,self.currentBalance, self.currentUnexchanged, self.currentImmature, self.currentTotal, self.hashAccepted, self.hashRejected, self.hashRatio, self.hashAverage, self.recentPayoutDate, self.recentPayoutAmount, self.recentNextPayoutIn, self.recentNextForecastAmount,self.sevenAverage, self.sevenStdev, self.sevenMin, self.sevenMax, self.sevenPerMHs, self.sevenTotal, self.thirtySmartAverage, self.thirtyTrueAverage, self.thirtyStdev, self.thirtyMin, self.thirtyMax, self.thirtyPerMHs, self.thirtyTotal,self.allAverage, self.allStdev, self.allMin, self.allMax, self.allPerMHs, self.allTotal, self.miscLastDataUpdate, self.miscLastAppRefresh, self.miscSizeOfLastUpdate, self.miscExchangeRate, self.miscAddress, self.summaryCurrentPerMHs, self.recentCurrentPerMHs,
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
        NSURL* marketDataURL = [NSURL URLWithString:RATES_URL];
        
        NSString* symbol = @"???";
        double exchangeRate = -1.0;
        NSString* exchangeRateString = @"N/A";
        
        NSError *error = nil;
        if ([self.currency isEqualToString:@""])
        {
            exchangeRateString = @"No currency selected";
        }
        else
        {
            NSString *marketData = [NSString stringWithContentsOfURL:marketDataURL encoding:NSUTF8StringEncoding error:&error];
            if (marketData)
            {
                // Parse exchange rate
                NSDictionary *marketDataDict = [NSJSONSerialization JSONObjectWithData:[marketData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                if (marketDataDict == nil || error != nil)
                {
                    exchangeRateString = @"Error parsing data";
                }
                else
                {
                    NSDictionary* data = [marketDataDict valueForKey:self.currency];
                    if (data == nil)
                    {
                        exchangeRateString = @"Error locating data";
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
            }
        }
        
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
        
        // Now we fetch the HTML data from the middlecoin page.
        NSURL* htmlURL;
        if (isPool)
            htmlURL = [NSURL URLWithString:POOLS_STATS_PAGE];
        else
            htmlURL = [NSURL URLWithString:[NSString stringWithFormat:USER_STATS_PAGE, self.payoutAddress]];
        
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

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [self.webView loadHTMLString:graphHtml baseURL:nil];
            
            // Parse the JS data
            
            self.currentImmature.text = [StatsController formatBTCFromString:immatureString withExchangeRate:exchangeRate andSymbol:symbol];
            
            self.currentUnexchanged.text = [StatsController formatBTCFromString:unexchangedString withExchangeRate:exchangeRate andSymbol:symbol];
            
            self.currentBalance.text = [StatsController formatBTCFromString:balanceString withExchangeRate:exchangeRate andSymbol:symbol];
            self.summaryBalance.text = self.currentBalance.text;
            
            double accepted = [[acceptedString stringByReplacingOccurrencesOfString:@" Mh/s" withString:@""] doubleValue];
            if (accepted <= ERROR_ACCEPTED_RATE)
                [StatsController setLabelErrorText:self.hashAccepted toValue:acceptedString];
            else if (accepted <= WARNING_ACCEPTED_RATE)
                [StatsController setLabelWarningText:self.hashAccepted toValue:acceptedString];
            else
                [StatsController setLabelText:self.hashAccepted toValue:acceptedString];
            
            self.hashRejected.text = rejectedString;
            double rejected = [[rejectedString stringByReplacingOccurrencesOfString:@" Mh/s" withString:@""] doubleValue];

            double rejectRatio;
            if (accepted <= 0)
                rejectRatio = -1.0;
            else
                rejectRatio = rejected / accepted;
            
            if (rejectRatio < 0)
                [StatsController setLabelErrorText:self.hashRatio toValue:@"N/A"];
            else
            {
                NSString* formatted = [NSString stringWithFormat:@"%.3f %%", rejectRatio];
                if (rejectRatio > ERROR_REJECT_RATIO)
                    [StatsController setLabelErrorText:self.hashRatio toValue:formatted];
                else if (rejectRatio > WARNING_REJECT_RATIO)
                    [StatsController setLabelWarningText:self.hashRatio toValue:formatted];
                else
                    [StatsController setLabelText:self.hashRatio toValue:formatted];
            }
            
            {
                NSString* formatted = [NSString stringWithFormat:@"%.2f/%.2f Mh/s", accepted, rejected];
                if (accepted == 0.0 || rejected > accepted || accepted < ERROR_ACCEPTED_RATE || rejectRatio < 0.0 || rejectRatio > ERROR_REJECT_RATIO)
                    [StatsController setLabelErrorText:self.summaryAcceptReject toValue:formatted];
                else if (rejectRatio > WARNING_REJECT_RATIO || accepted < WARNING_ACCEPTED_RATE)
                    [StatsController setLabelWarningText:self.summaryAcceptReject toValue:formatted];
                else
                    [StatsController setLabelText:self.summaryAcceptReject toValue:formatted];
            }
            
            
            double averageHash = [[averageHashString stringByReplacingOccurrencesOfString:@" Mh/s" withString:@""] doubleValue];
            if (averageHash <= ERROR_ACCEPTED_RATE)
                [StatsController setLabelErrorText:self.hashAverage toValue:averageHashString];
            else if (averageHash <= WARNING_ACCEPTED_RATE)
                [StatsController setLabelWarningText:self.hashAverage toValue:averageHashString];
            else
                [StatsController setLabelText:self.hashAverage toValue:averageHashString];
            
            // Extract update date from graph
            self.miscLastDataUpdate.text = [StatsController convertToLocalDate:updateDateString withOption:true];
            
            NSDate* now = [NSDate date];
            self.miscLastAppRefresh.text = [StatsController printLocalDate:now];
            lastRefreshDate = now;

            
            // Calcualte approximate total unpaid
            double unpaid = [balanceString doubleValue] + [immatureString doubleValue] + [unexchangedString doubleValue];
            self.currentTotal.text = [StatsController formatBTCFromDouble:unpaid withExchangeRate:exchangeRate andSymbol:symbol];
            
            // Calculate simple forecast
            double timeSinceLastPayout = ABS([lastPayoutDate timeIntervalSinceNow]);
            double balance = [balanceString doubleValue];
            if (timeSinceLastPayout < 60 * 60 * 3)
                self.recentNextForecastAmount.text = @"Insufficient data";
            else
            {
                // todo: need to calculate time between last payout and 9:30pm (and use that instead of 24*60*60)
                double forecast = balance * 24 * 60 * 60 / timeSinceLastPayout;
                if (forecast < balance)
                    forecast = balance;
                self.recentNextForecastAmount.text = [StatsController formatBTCFromDouble:forecast withExchangeRate:exchangeRate andSymbol:symbol];
            }
            self.summaryPayoutForecast.text = self.recentNextForecastAmount.text;
            
            // Calculate current BTC/MH/s
            if (timeSinceLastPayout < 60 * 60 * 3)
            {
                [StatsController setLabelText:self.summaryCurrentPerMHs toValue:@"Insufficient data"];
                [StatsController setLabelText:self.recentCurrentPerMHs toValue:@"Insufficient data"];
            }
            else
            {
                double btcPerMHs;
                if (averageHash == 0.0)
                    btcPerMHs = 0.0;
                else
                    btcPerMHs = balance / timeSinceLastPayout * 60.0 * 60.0 * 24.0 / averageHash;
                
                NSString* formatted = [StatsController formatBTCFromDouble:btcPerMHs withExchangeRate:exchangeRate andSymbol:symbol];
                if (btcPerMHs > ERROR_BTC_PER_MHS)
                {
                    [StatsController setLabelText:self.summaryCurrentPerMHs toValue:formatted];
                    [StatsController setLabelText:self.recentCurrentPerMHs toValue:formatted];
                }
                else
                {
                    [StatsController setLabelErrorText:self.summaryCurrentPerMHs toValue:formatted];
                    [StatsController setLabelErrorText:self.recentCurrentPerMHs toValue:formatted];
                }
            }
            
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

+(void)setLabelText:(UILabel*)label toValue:(NSString*)text
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

@end
