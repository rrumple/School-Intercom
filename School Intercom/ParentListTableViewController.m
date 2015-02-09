//
//  ParentListTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 2/4/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "ParentListTableViewController.h"

@interface ParentListTableViewController ()

@property (nonatomic, strong) NSArray *parentData;
@property (nonatomic, strong) AdminModel *adminData;
@property (strong, nonatomic) IBOutlet UITableView *parentListTableView;
@end

@implementation ParentListTableViewController

- (AdminModel *)adminData
{
    if (!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)getParentsOfTeacherInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("getParents", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData getParentsOfTeacher:self.mainUserData.userID];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.parentData = databaseData;
                [self.parentListTableView reloadData];
                ;
                
            });
            
        }
    });
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getParentsOfTeacherInDatabase];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0)
        return 75;
    else
        return 0.01f;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
        return @"This is a list of Parents that have signed up and follow you on School Intercom.  They will see all calendar, news, and alerts that you send out for your class.";
    else
        return @"";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    else
        return [self.parentData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"parentCell";
    UITableViewCell *cell;
    
    
    if(indexPath.section == 0)
    {
        CellIdentifier = CELL_EXIT;
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UILabel *totalParentsLabel = (UILabel *)[cell viewWithTag:1];
        totalParentsLabel.text = [NSString stringWithFormat:@"Total Parents : %lu", (unsigned long)[self.parentData count]];
    }
    else
    {
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = [[self.parentData objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.detailTextLabel.text = [[self.parentData objectAtIndex:indexPath.row]objectForKey:@"kidName"];
        
    }
    return cell;
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
