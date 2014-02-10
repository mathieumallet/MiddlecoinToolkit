//
//  MinersController.m
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 2/2/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#import "MinersController.h"
#import "UserStatsController.h"

@interface MinersController ()

@end

@implementation MinersController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moon_background.png"]];
    [self.tableView  setBackgroundView:imageView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadMinersFromDefaults];
    //[self setEditing:false animated:false];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (miners.count == 0)
        [self performSegueWithIdentifier:@"AddMiner" sender:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    //[self setEditing:false animated:false];
}

-(void) loadMinersFromDefaults
{
    miners = [NSMutableArray arrayWithArray:[Miner loadMinersFromDefaultsForKey:@"miners"]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.editing)
        return miners.count + 1;
    return miners.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    // Configure the cell...
    
    if (indexPath.row != miners.count)
    {
        Miner* miner = [miners objectAtIndex:indexPath.row];
        cell.textLabel.text = miner.name;
        cell.detailTextLabel.text = miner.address;
        if (self.editing)
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        else
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else
    {
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = @"Add new Miner...";
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        /*if (self.editing && indexPath.row == miners.count)
            cell.editingAccessoryType =UITableViewCellAccessoryDisclosureIndicator;*/
    }
    
    return cell;
}

-(void)setEditing:(BOOL)editing animated:(BOOL) animated
{
    [super setEditing:editing animated:animated];
    
    [self.tableView setEditing:editing animated:animated];
    [self.tableView reloadData];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Also remove the row from the miners array
        [miners removeObjectAtIndex:indexPath.row];
        [Miner saveMinersToDefaults:miners forKey:@"miners"];

        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //[self setEditing:false animated:false];
        [self performSegueWithIdentifier:@"AddMiner" sender:self];
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    //NSLog(@"move row from %d to %d", fromIndexPath.row, toIndexPath.row);
    
    // Update miners array
    id old = [miners objectAtIndex:fromIndexPath.row];
    [miners removeObjectAtIndex:fromIndexPath.row];
    if (toIndexPath.row >= miners.count)
        [miners addObject:old];
    else
        [miners insertObject:old atIndex:toIndexPath.row];
    
    // Store new values
    [Miner saveMinersToDefaults:miners forKey:@"miners"];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == miners.count)
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if (self.editing && indexPath.row == miners.count)
        return NO;
    return YES;
}

-(NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (self.editing && proposedDestinationIndexPath.row == miners.count)
        return [NSIndexPath indexPathForRow:(miners.count - 1) inSection:proposedDestinationIndexPath.section];
    
    return proposedDestinationIndexPath;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"StatsSegue"])
    {
        if (!self.editing)
            return true;
        
        UITableViewCell* cell = sender;
        if (cell.detailTextLabel.text != nil)
        {
            cell.selected = false;
            return false;
        }
        
        [self performSegueWithIdentifier:@"AddMiner" sender:self];
        return false;
    }
    
    return true;
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"StatsSegue"])
    {
        // Special case: when editing, send to 'add miner' page instead
        UserStatsController* newController = [segue destinationViewController];
        
        UITableViewCell* cell = sender;
        newController.title = cell.textLabel.text;
        newController.payoutAddress = cell.detailTextLabel.text;
    }
}

@end
