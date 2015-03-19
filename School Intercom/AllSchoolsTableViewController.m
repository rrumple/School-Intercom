//
//  AllSchoolsTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 1/4/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "AllSchoolsTableViewController.h"
#import "AdminModel.h"
#import "AddNewUserTableViewController.h"
#import "UsersSchoolsTableViewController.h"
#import "SchoolStatsViewController.h"

@interface AllSchoolsTableViewController ()

@property (nonatomic, strong) NSArray *schools;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) NSString *idToQuery;
@property (nonatomic, strong) NSString *schoolIDSelected;
@property (nonatomic, strong) NSString *schoolNameSelected;

@end

@implementation AllSchoolsTableViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)queryCorporationsFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("queryDatabaseForCorps", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData getAllCorpsForAccountType:self.mainUserData.accountType];
        if (dataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.schools = dataArray;
                    
                    [self.tableView reloadData];
                });
                
                
                
                
                
            });
            
        }
    });

}

-(void)querySchoolsFromDatabase
{
    
    switch ([self.mainUserData.accountType intValue])
    {
        case 4:self.idToQuery = [self.mainUserData.schoolData objectForKey:@"corpID"];
            break;
        case 6:self.idToQuery = @"";
            break;
            
    }
    
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
                    if(self.isManagingSchools)
                    {
                        [tempArray2 addObject:@[@{@"name":@"",@"schoolName":CELL_EXIT}]];
                    }

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
                        if(!self.isManagingSchools)
                            [tempArray2 addObject:@[@{@"name":@"",@"schoolName":CELL_EXIT}]];
                         
                    }
                    
                    self.schools = tempArray2;
                   
                    [self.tableView reloadData];
                    
                   });
                
                
                
                
                
            });
            
        }
    });

}
- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    if(self.isCorporationSearch)
        [self queryCorporationsFromDatabase];
    else
        [self querySchoolsFromDatabase];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_SCHOOL_STATS])
    {
        SchoolStatsViewController *SSVC = segue.destinationViewController;
        SSVC.mainUserData = self.mainUserData;
        SSVC.schoolIDSelected = self.schoolIDSelected;
        SSVC.schoolNameSelected = self.schoolNameSelected;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [self.schools count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [[self.schools objectAtIndex:section]count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.isCorporationSearch)
        return @"";
    else
        return [[[self.schools objectAtIndex:section] objectAtIndex:0] objectForKey:@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    UITableViewCell *cell;
    
    if([[[[self.schools objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:SCHOOL_NAME]isEqualToString:CELL_EXIT])
    {
        identifier = CELL_EXIT;
         cell = [tableView dequeueReusableCellWithIdentifier:CELL_EXIT forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"schoolCell" forIndexPath:indexPath];
        
        if(self.isCorporationSearch)
            cell.textLabel.text = [[[self.schools objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:@"name"];
        else
            cell.textLabel.text = [[[self.schools objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:SCHOOL_NAME];

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
  
    
    if(self.isManagingSchools)
    {
        if(indexPath.section == 0 && indexPath.row == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            self.schoolIDSelected = [[[self.schools objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:ID];
            self.schoolNameSelected = [[[self.schools objectAtIndex:indexPath.section]objectAtIndex:indexPath.row]objectForKey:SCHOOL_NAME];
            [self performSegueWithIdentifier:SEGUE_TO_SCHOOL_STATS sender:self];
        }
    }
    else
    {
        for (id viewController in self.navigationController.viewControllers)
        {
            if([viewController isKindOfClass:[AddNewUserTableViewController class]])
            {
                AddNewUserTableViewController *ANUTVC = viewController;
                
                if(self.isCorporationSearch)
                    ANUTVC.corpSelected = [[self.schools objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
                else
                    ANUTVC.schoolSelected = [[self.schools objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            else if([viewController isKindOfClass:[UsersSchoolsTableViewController class]])
            {
                UsersSchoolsTableViewController *USTVC = viewController;
                USTVC.schoolSelected = [[self.schools objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            
            
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
