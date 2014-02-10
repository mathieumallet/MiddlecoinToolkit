//
//  SettingsController.m
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 1/18/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import "SettingsController.h"
#import "Constants.h"

@interface SettingsController ()
@property (weak, nonatomic) IBOutlet UITextField *rigAddress;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


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
    //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0);
    
    self.rigAddress.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"rigAddress"];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moon_background.png"]];
    [self.tableView  setBackgroundView:imageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    float headerSize = 20; // status bar height
    if (self.navigationController && self.navigationController.navigationBarHidden == NO)
        headerSize += self.navigationController.toolbar.frame.size.height;
    float tabBarSize = 49;
    self.tableView.contentInset = UIEdgeInsetsMake(headerSize, 0, tabBarSize, 0);
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
    if ([self.rigAddress.text isEqualToString:@"test"])
        self.rigAddress.text = TEST_RIG_ADDRESS;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.rigAddress.text forKey:@"rigAddress"];
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
