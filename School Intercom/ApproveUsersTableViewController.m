//
//  ApproveUsersTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/14/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "ApproveUsersTableViewController.h"
#import "AdminModel.h"

@interface ApproveUsersTableViewController ()<UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *pendingUsersData;
@property (nonatomic, strong) NSDictionary *selectedUser;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSString *approvalStatus;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) UISegmentedControl *selectedControl;
@property (nonatomic, strong) UIAlertView *customMessageAlert;
@property (nonatomic, strong) NSString *denyMessage;
@end

@implementation ApproveUsersTableViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}



- (void)getPendingNewUsersFromDatabase
{
    
    dispatch_queue_t createQueue = dispatch_queue_create("getPendingNewUsers", NULL);
    dispatch_async(createQueue, ^{
        NSArray *pendingUserData;
        pendingUserData = [self.adminData getPendingNewUsersFromDatabaseForUser:self.mainUserData.userID withSchoolID:self.mainUserData.schoolIDselected];
        
        if (pendingUserData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableArray *tempArray = [pendingUserData mutableCopy];
                [tempArray insertObject:@[@""] atIndex:0];
                
                self.pendingUsersData = tempArray;
                [self.tableView reloadData];
                
            });
            
        }
    });

    
    
}

- (void)updateUserApprovalStatusInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("updateStatus", NULL);
    dispatch_async(createQueue, ^{
        NSArray *userApprovalArray;
        userApprovalArray = [self.adminData updateApprovalStatusOfUser:[self.selectedUser objectForKey:ID] withStatus:self.approvalStatus withSchoolID:[self.selectedUser objectForKey:SCHOOL_ID]andMessage:self.denyMessage];
        
        if (userApprovalArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"%@", userApprovalArray);
                
                self.denyMessage = @"";
                self.selectedControl = nil;
            });
            
        }
    });

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.denyMessage = @"";
    self.tableView.rowHeight = 44;
    
    [self getPendingNewUsersFromDatabase];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)exitButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showDenyConfirmAlert
{
    UIAlertView *userDeniedAlert = [[UIAlertView alloc]initWithTitle:@"Deny User" message:[NSString stringWithFormat:@"Deny %@?", [[[self.pendingUsersData objectAtIndex:self.currentIndexPath.section]objectAtIndex:self.currentIndexPath.row]objectForKey:@"userName"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Use standard deny message", @"Create a custom deny message", nil];
    userDeniedAlert.tag = zAlertUserDenied;
    [userDeniedAlert show];
}

- (IBAction)approveDenyButtonPressed:(UISegmentedControl *)sender
{
    
    
    CGPoint center = [sender center];
    CGPoint rootViewPoint = [[sender superview]convertPoint:center toView:self.tableView];
    self.currentIndexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
    
    if(sender.selectedSegmentIndex == 0)
    {
        UIAlertView *userApprovedAlert = [[UIAlertView alloc]initWithTitle:@"Approve User" message:[NSString stringWithFormat:@"Approve %@?", [[[self.pendingUsersData objectAtIndex:self.currentIndexPath.section]objectAtIndex:self.currentIndexPath.row]objectForKey:@"userName"]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        userApprovedAlert.tag = zAlertUserApproved;
        [userApprovedAlert show];
    }
    else if(sender.selectedSegmentIndex == 1)
    {
        [self showDenyConfirmAlert];
    }
    
    self.selectedControl = sender;
    
    
}
#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 55;
    else
        return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"";
    else
        return [[[self.pendingUsersData objectAtIndex:section]objectAtIndex:0]objectForKey:SCHOOL_NAME];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return [self.pendingUsersData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(section == 0)
        return 1;
    else
        return [[self.pendingUsersData objectAtIndex:section]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    
    if(indexPath.section == 0)
        cell = [tableView dequeueReusableCellWithIdentifier:@"exitCell" forIndexPath:indexPath];
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"approveUserCell" forIndexPath:indexPath];
        UILabel *userLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *kidLabel = (UILabel *)[cell viewWithTag:2];
        UISegmentedControl *approveDenyControl = (UISegmentedControl *)[cell viewWithTag:3];
        
        if([[[self.pendingUsersData objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:DATE_DENIED] != (id)[NSNull null])
            [approveDenyControl setSelectedSegmentIndex:1];
        else
            [approveDenyControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
        
        userLabel.text = [[[self.pendingUsersData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]objectForKey:@"userName"];
        
        if([[[self.pendingUsersData objectAtIndex:indexPath.section ]objectAtIndex:indexPath.row]objectForKey:@"kidName"]!= (id)[NSNull null])
            kidLabel.text =[[[self.pendingUsersData objectAtIndex:indexPath.section ]objectAtIndex:indexPath.row]objectForKey:@"kidName"];
        else
            kidLabel.text = @"N/A";

    }
    
    
    
    
    return cell;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertUserApproved)
    {
        if(buttonIndex == 1)
        {
            self.selectedUser = [[self.pendingUsersData objectAtIndex:self.currentIndexPath.section] objectAtIndex:self.currentIndexPath.row];
            NSMutableArray *tempArray = [[self.pendingUsersData objectAtIndex:self.currentIndexPath.section] mutableCopy];
            [tempArray removeObjectAtIndex:self.currentIndexPath.row];
            
            NSMutableArray *tempArray2 = [self.pendingUsersData mutableCopy];
            [tempArray2 replaceObjectAtIndex:self.currentIndexPath.section withObject:tempArray];
            
            self.pendingUsersData = tempArray2;
            self.approvalStatus = @"1";
            [self.tableView reloadData];
            
            [self updateUserApprovalStatusInDatabase];
        }
        else
        {
            [self.selectedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
            [self.tableView reloadData];
        }
    }
    else if(alertView.tag == zAlertUserDenied)
    {
        if(buttonIndex == 1)
        {
            self.approvalStatus = @"0";
            self.selectedUser = [[self.pendingUsersData objectAtIndex:self.currentIndexPath.section] objectAtIndex:self.currentIndexPath.row];

            [self updateUserApprovalStatusInDatabase];
        }
        else if(buttonIndex == 2)
        {
            self.customMessageAlert = [[UIAlertView alloc]initWithTitle:@"Create Deny Message" message:@"Enter an explanation to the user of why they were denied access." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Submit", nil];
            [self.customMessageAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            self.customMessageAlert.tag = zAlertEnterMessage;
            UITextField *messageField = [self.customMessageAlert textFieldAtIndex:0];
            messageField.placeholder = @"Message";
            messageField.delegate = self;
            messageField.tag = zTextFieldMessage;
            messageField.keyboardType = UIKeyboardTypeEmailAddress;
            
            [self.customMessageAlert show];

        }
        else
        {
            [self.selectedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
            [self.tableView reloadData];
        }
        
    }
    else if(alertView.tag == zAlertEnterMessage)
    {
        if(buttonIndex == 1)
        {
            
            UITextField *tempTextfield = (UITextField *)[self.customMessageAlert textFieldAtIndex:0];
            if([tempTextfield.text length] > 5)
            {
                self.denyMessage = tempTextfield.text;
            }
            
            self.approvalStatus = @"0";
            self.selectedUser = [[self.pendingUsersData objectAtIndex:self.currentIndexPath.section] objectAtIndex:self.currentIndexPath.row];
            
            [self updateUserApprovalStatusInDatabase];

        }
        else
        {
            [self showDenyConfirmAlert];
        }
    }
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
