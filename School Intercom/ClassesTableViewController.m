//
//  ClassesTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 8/14/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "ClassesTableViewController.h"
#import <Google/Analytics.h>
#import "AddUpdateClassTableViewController.h"

@interface ClassesTableViewController ()

@property (nonatomic, strong) NSMutableArray *classRoomArray;
@property (nonatomic) BOOL isNewClass;
@property (nonatomic, strong) NSDictionary *classSelected;
@property (nonatomic) NSInteger rowSelected;
@property (nonatomic, strong) AdminModel *adminData;

@end

@implementation ClassesTableViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    


   
    
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
- (IBAction)addClassButtonPressed
{
    self.isNewClass = YES;
    [self performSegueWithIdentifier:SEGUE_TO_ADD_UPDATE_CLASS sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.classRoomArray = [self.mainUserData.classData mutableCopy];
    [self.tableView reloadData];
    
    self.isNewClass = NO;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Show_Classes_Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPushAlert:) name:@"DisplayAlert" object:nil];
    
    
}

- (void)showPushAlert:(NSNotification *)notification
{
    NSDictionary *data = [notification userInfo];
    
    [HelperMethods CreateAndDisplayOverHeadAlertInView:self.view withMessage:[data objectForKey:@"message"] andSchoolID:[data objectForKey:SCHOOL_ID]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_ADD_UPDATE_CLASS])
    {
        AddUpdateClassTableViewController *AUCTVC = segue.destinationViewController;
        AUCTVC.mainUserData = self.mainUserData;
        AUCTVC.isNewClass = self.isNewClass;
        AUCTVC.classData = self.classSelected;
        
 
        
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if(section == 0)
        return 1;
    else
        return [self.classRoomArray count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"classCell";
    UITableViewCell *cell;
    
    
    if(indexPath.section == 0)
    {
        CellIdentifier = CELL_EXIT;
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
    }
    else if(indexPath.section == 1 && indexPath.row == [self.classRoomArray count])
    {
        CellIdentifier = CELL_ADD_CLASS;
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    }
    else
    {
        
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = [[self.classRoomArray objectAtIndex:indexPath.row] objectForKey:@"className"];
        //cell.detailTextLabel.text = [[self.parentData objectAtIndex:indexPath.row]objectForKey:@"kidName"];
        
    }
    return cell;

}

- (void)deleteClassFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("deleteClass", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData deleteClass:[self.classSelected objectForKey:ID]];
        
        if (databaseData)
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDictionary *tempDic = [databaseData objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    
                    UIAlertView *deleteConfrimAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:[tempDic objectForKey:@"msg"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                   
                    [deleteConfrimAlert show];
                    [self.tableView reloadData];

                    
                }
                else
                {

                
                    NSMutableArray *array = [self.classRoomArray mutableCopy];
                    [array removeObjectAtIndex:self.rowSelected];
                    self.classRoomArray = array;
                    [self.tableView reloadData];

                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GET_TEACHER_CLASSES" object:nil userInfo:nil];
                
                }
            });
            
        }
    });

    
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.classSelected = [self.classRoomArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SEGUE_TO_ADD_UPDATE_CLASS sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        self.classSelected = [self.classRoomArray objectAtIndex:indexPath.row];
        self.rowSelected = indexPath.row;
        
        UIAlertView *deleteConfrimAlert = [[UIAlertView alloc]initWithTitle:@"Delete Class" message:[NSString stringWithFormat:@"You are about to delete %@ from your profile, are you sure?", [self.classSelected objectForKey:@"className"]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        deleteConfrimAlert.tag = zAlertDeleteKid;
        [deleteConfrimAlert show];

        
            } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case zAlertDeleteKid:
        {
            switch (buttonIndex)
            {
                case 0:
                    break;
                case 1:
                    [self deleteClassFromDatabase];

                    break;
            }
        }
            break;
            
    }
    
    
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self.classRoomArray count] == 1)
        return NO;
    else
        return YES;
}


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
