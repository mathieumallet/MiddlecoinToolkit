//
//  StatsController.h
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 2/4/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsController : UIViewController
{
    NSString* payoutAddress;
    NSDate* lastRefreshDate;

}

+(void)setCenteredTextInWebview:(UIWebView*)webview toText:(NSString*)text;

@end

