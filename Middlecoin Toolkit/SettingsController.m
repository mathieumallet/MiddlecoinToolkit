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
@property (weak, nonatomic) IBOutlet UIPickerView *currencyPicker;
@property NSArray* currencies;

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
    
    self.currencies = [SettingsController createCurrencies];

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
    
    // Need to figure which index is selected in the currencies array
    NSString* currency = [[NSUserDefaults standardUserDefaults] valueForKey:@"currency"];
    int row;
    if (currency == nil)
        row = 1; // default value is USD
    else
    {
        row = 1; // this sets up fallback to USD in case a currency is removed
        for (int i = 0; i < self.currencies.count; i++)
        {
            NSString* test = [[self.currencies objectAtIndex:i] objectAtIndex:1];
            if ([currency isEqualToString:test])
            {
                row = i;
                break;
            }
        }
    }
    
    [self.currencyPicker selectRow:row inComponent:0 animated:false];
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
    [[NSUserDefaults standardUserDefaults] synchronize];
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

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.currencies.count;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [[NSUserDefaults standardUserDefaults] setValue:[[self.currencies objectAtIndex:row] objectAtIndex:1] forKey:@"currency"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString* text = [[self.currencies objectAtIndex:row] objectAtIndex:0];
    if ([text isEqualToString:@"None"])
        return text;
    NSString* currency = [[self.currencies objectAtIndex:row] objectAtIndex:1];
    return [text stringByAppendingFormat:@" (%@)", currency];
}

+(NSArray*)createCurrencies
{
    NSArray* result = [NSArray arrayWithObjects:
                       [NSArray arrayWithObjects:@"None", @"", nil],
                       [NSArray arrayWithObjects:@"United States dollar", @"USD", nil],
                       [NSArray arrayWithObjects:@"Australian dollar", @"AUD", nil],
                       [NSArray arrayWithObjects:@"Brazilian real", @"BRL", nil],
                       [NSArray arrayWithObjects:@"Canadian dollar", @"CAD", nil],
                       [NSArray arrayWithObjects:@"Swiss franc", @"CHF", nil],
                       [NSArray arrayWithObjects:@"Chilean peso", @"CLP", nil],
                       [NSArray arrayWithObjects:@"Chinese renminbi", @"CNY", nil],
                       [NSArray arrayWithObjects:@"Danish krone", @"DKK", nil],
                       [NSArray arrayWithObjects:@"Euro", @"EUR", nil],
                       [NSArray arrayWithObjects:@"Pound sterling", @"GBP", nil],
                       [NSArray arrayWithObjects:@"Hong Kong dollar", @"HKD", nil],
                       [NSArray arrayWithObjects:@"South Korean won", @"KRW", nil],
                       [NSArray arrayWithObjects:@"New Zealand dollar", @"NZD", nil],
                       [NSArray arrayWithObjects:@"Polish złoty", @"PLN", nil],
                       [NSArray arrayWithObjects:@"Russian ruble", @"RUB", nil],
                       [NSArray arrayWithObjects:@"Swedish krona", @"SEK", nil],
                       [NSArray arrayWithObjects:@"Singapore dollar", @"SGD", nil],
                       [NSArray arrayWithObjects:@"Thai baht", @"THB", nil],
                       nil];
    return result;
}

@end
