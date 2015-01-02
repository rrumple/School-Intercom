//
//  AdminToolsTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/5/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "AdminToolsTableViewController.h"
#import "SendAlertViewController.h"
#import "ApproveUsersTableViewController.h"
#import "LandscapeNavigationController.h"
#import "ManageUsersViewController.h"

@interface AdminToolsTableViewController ()

@property (nonatomic) NSInteger sectionCount;
@property (nonatomic) NSInteger rowCount;
@property (nonatomic ,strong) NSArray *cellsToShow;

@end

@implementation AdminToolsTableViewController

- (void)setAdminDatawithSections:(NSInteger)sectionCount andRows:(NSInteger)rowCount
{
    self.sectionCount = sectionCount;
    self.rowCount = rowCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 44;
    
    switch ([self.mainUserData.accountType intValue])
    {
        case utTeacher:
            [self setAdminDatawithSections:2 andRows:1];
            self.cellsToShow = @[CELL_SEND_ALERT];
            break;
        case utSecretary:
            [self setAdminDatawithSections:2 andRows:2];
            self.cellsToShow = @[CELL_SEND_ALERT, CELL_USER_APPROVALS];
            break;
        case utPrincipal:
            [self setAdminDatawithSections:2 andRows:2];
            self.cellsToShow = @[CELL_SEND_ALERT, CELL_USER_APPROVALS];
            break;
        case utSuperintendent:
            [self setAdminDatawithSections:2 andRows:1];
            self.cellsToShow = @[CELL_SEND_ALERT];
            break;
        case utSales:
            [self setAdminDatawithSections:1 andRows:1];
            self.cellsToShow = @[CELL_EXIT];
            break;
        case utSuperUser:
            [self setAdminDatawithSections:2 andRows:3];
            self.cellsToShow = @[CELL_SEND_ALERT, CELL_AD_STATS, CELL_USER_APPROVALS];
            break;
        case utBetaTester:
            [self setAdminDatawithSections:1 andRows:1];
            self.cellsToShow = @[CELL_EXIT];

            break;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)exitButtonPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_SEND_ALERTS_VIEW])
    {
        SendAlertViewController *SAVC = segue.destinationViewController;
        SAVC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_USER_APPROVALS])
    {
        ApproveUsersTableViewController *AUTVC = segue.destinationViewController;
        AUTVC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_AD_STATS])
    {
        LandscapeNavigationController *LSNC = segue.destinationViewController;
        LSNC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_MANAGE_USERS])
    {
        ManageUsersViewController *MUVC = segue.destinationViewController;
        MUVC.mainUserData = self.mainUserData;
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(section == 0)
        return self.rowCount;
    else
        return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Admin Tools";
    else
        return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier;
    if(indexPath.section == 0)
        identifier = [self.cellsToShow objectAtIndex:indexPath.row];
    else
        identifier = CELL_EXIT;
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
     // Configure the cell...
    
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