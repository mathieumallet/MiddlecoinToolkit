//
//  SettingsController.m
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 1/18/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import "SettingsController.h"

#define DONATE_ADDRESS @"1KxZwnp8GrKFoPZ828Wagg9TSpUhvYEZUF"
#define TEST_ADDRESS @"1DLkgH9K7dFaT2y2wuUDDvX9EzbSeoraNS"

@interface SettingsController ()
@property (weak, nonatomic) IBOutlet UITextField *addressField;

@end

@implementation SettingsController

/*- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
        
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49+20, 0);
    
    self.addressField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPayoutAddress"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)addressEditingDidEnd:(id)sender {
    if ([self.addressField.text isEqualToString:@"test"])
        self.addressField.text = TEST_ADDRESS;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.addressField.text forKey:@"userPayoutAddress"];
}

- (IBAction)donateUsingWallet:(id)sender {
    NSString *string = [NSString stringWithFormat:@"bitcoin://%@?amount=0.01", DONATE_ADDRESS];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}

- (IBAction)copyDonationAddress:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = DONATE_ADDRESS;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"Donation address copied to clipboard." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)sendFeedback:(id)sender {
    NSString *string = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@", @"emhmark3@gmail.com", [@"Feedback for Middlecoin Toolkit" stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}

@end
