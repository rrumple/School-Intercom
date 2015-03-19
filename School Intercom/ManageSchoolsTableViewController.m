//
//  ManageSchoolsTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 2/14/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "ManageSchoolsTableViewController.h"
#import "AdminModel.h"
@interface ManageSchoolsTableViewController ()

@property (nonatomic, strong) NSArray *schools;
@property (nonatomic, strong) AdminModel *adminData;

@end




@implementation ManageSchoolsTableViewController

- (AdminModel *)adminData
{
    if (!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)getSchoolsFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("queryDatabaseForSchools", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData getSchoolsFromDatabaseForAccountType:self.mainUserData.accountType andID:self.idToQuery];
        
        if (dataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                    for(NSArray *corpArray in dataArray)
                    {
                        NSMutableArray *corpArrayMutable = [corpArray mutableCopy];
                        [tempArray addObject:corpArrayMutable];
                    }
                    
                    
                    
                    if(self.existingSchools != (id)[NSNull null])
                    {
                        
                        for (int i = 0; i < [dataArray count]; i++)
                        {
                            for(int x = 0; x < [dataArray[i] count]; x++)
                            {
                                for(int c = 0; c < [self.existingSchools count]; c++ )
                                {
                                    
                                    if([[dataArray[i][x]objectForKey:ID] isEqualToString:[self.existingSchools[c] objectForKey:ID]])
                                    {
                                        [tempArray[i]removeObject:dataArray[i][x]];
                                        break;
                                    }
                                }
                            }
                        }
                        
                        
                    }
                    
                    NSMutableArray *tempArray2 = [[NSMutableArray alloc]init];
                    for(NSArray * array in tempArray)
                    {
                        if ([array count] >= 1)
                        {
                            [tempArray2 addObject:array];
                        }
                    }
                    
                    if([tempArray2 count] == 0)
                    {
                        [tempArray2 addObject:@[@{@"name":@"", @"schoolName":@"No Schools To Display"}]];
                        [tempArray2 addObject:@[@{@"name":@"",@"schoolName":CELL_EXIT}]];
                        
                    }
                    
                    self.schools = tempArray2;
                    
                    [self.tableView reloadData];
                    
                });
                
                
                
                
                
            });
            
        }
    });

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getSchoolsFromDatabase];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return [self.schools count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [[self.schools objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.schools objectAtIndex:section]objectAtIndex:0]objectForKey:@"corpName"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schoolCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[[self.schools objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]objectForKey:SCHOOL_NAME];
    
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
