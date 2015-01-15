//
//  SelectUsertypeTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/29/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "SelectUsertypeTableViewController.h"
#import "ManageSingleUserTableViewController.h"
#import "AddNewUserTableViewController.h"

@interface SelectUsertypeTableViewController ()

@property (nonatomic, strong) NSArray *userTypes;

@end

@implementation SelectUsertypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.userTypes = [HelperMethods getDictonaryOfUserTypes];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.userTypes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userTypeCell" forIndexPath:indexPath];
    
    if(indexPath.row == [self.usertypeSelected intValue])
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [self.userTypes objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    for (id viewController in self.navigationController.viewControllers)
    {
        if([viewController isKindOfClass:[ManageSingleUserTableViewController class]])
        {
            ManageSingleUserTableViewController *MSUTVC = viewController;
            if([self.usertypeSelected intValue] != indexPath.row)
                MSUTVC.saveChangesButton.hidden = false;
            MSUTVC.userTypeSelected = [NSString stringWithFormat:@"%li",(long)indexPath.row];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        else if([viewController isKindOfClass:[AddNewUserTableViewController class]])
        {
            AddNewUserTableViewController *ANUTVC = viewController;
            ANUTVC.userTypeSelected = [NSString stringWithFormat:@"%li",(long)indexPath.row];
            [self.navigationController popViewControllerAnimated:YES];
            break;
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
