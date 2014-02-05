//
//  AddMinerController.m
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 2/2/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import "AddMinerController.h"

#define TEST_ADDRESS @"1DLkgH9K7dFaT2y2wuUDDvX9EzbSeoraNS"
#define TEST_ADDRESS2 @"17MyQX9derjSHcveyXPYrSRra67DmWtRfy";

@interface AddMinerController ()
@property (weak, nonatomic) IBOutlet UITextField *minerName;
@property (weak, nonatomic) IBOutlet UITextField *minerAddress;

@end

@implementation AddMinerController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editingDidEndForMinerAddress:(id)sender {
    if ([self.minerAddress.text isEqualToString:@"test"])
        self.minerAddress.text = TEST_ADDRESS;
    if ([self.minerAddress.text isEqualToString:@"test2"])
        self.minerAddress.text = TEST_ADDRESS2;
}

- (IBAction)addMiner:(id)sender {
    NSString* address = self.minerAddress.text;
    if ([address isEqualToString:@"test"])
        address = TEST_ADDRESS;
    if ([address isEqualToString:@"test2"])
        address = TEST_ADDRESS2;
    if (![Miner isValidAddress:address])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"A valid 34-character payout address must be entered." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
        
    NSString* name = self.minerName.text;
    if (name == nil || [name isEqualToString:@""])
        name = @"My Miner";
    
    Miner* miner = [[Miner alloc] init];
    miner.name = name;
    miner.address = address;
    
    // All good! Add new minier to defaults
    NSArray* miners = [Miner loadMinersFromDefaultsForKey:@"miners"];
    if (miners == nil)
        miners = [NSArray arrayWithObject:miner];
    else
        miners = [miners arrayByAddingObject:miner];
    [Miner saveMinersToDefaults:miners forKey:@"miners"];
    
    // Close this view and return to parent.
    [self.navigationController popViewControllerAnimated:true];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
