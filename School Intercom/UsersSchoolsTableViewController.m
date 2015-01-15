//
//  UsersSchoolsTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/29/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "UsersSchoolsTableViewController.h"
#import "AdminModel.h"
#import "AllSchoolsTableViewController.h"
#import "ManageSingleUserTableViewController.h"

@interface UsersSchoolsTableViewController ()

@property (nonatomic, strong) NSArray *schoolData;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic) BOOL addingSchool;


@end

@implementation UsersSchoolsTableViewController

@synthesize schoolSelected = _schoolSelected;

- (NSDictionary *)schoolSelected
{
    if (!_schoolSelected) _schoolSelected  = [[NSDictionary alloc]init];
    return _schoolSelected;
}

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)setSchoolSelected:(NSDictionary *)schoolSelected
{
    _schoolSelected = schoolSelected;
    
    if(self.addingSchool)
    {
        [self addschoolToUserInDatabase];
        self.addingSchool = NO;
    }
}


- (void)getSchoolsForUserSelected
{
    dispatch_queue_t createQueue = dispatch_queue_create("queryDatabaseForUsers", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData getSchoolsForSelectedUser:self.userIDSelected];
        
        if (dataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    
                }
                else
                {
                    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithObjects:@[@""], nil];
                    [tempArray addObjectsFromArray:[tempDic objectForKey:@"data"]];
                    
                    for(NSDictionary * school in [tempDic objectForKey:@"data"])
                    {
                        
                        [HelperMethods downloadSingleImageFromBaseURL:SCHOOL_LOGO_PATH withFilename:[NSString stringWithFormat:@"%@",[school objectForKey:SCHOOL_IMAGE_NAME]] saveToDisk:YES replaceExistingImage:NO];
                    }
                    
                    self.schoolData = tempArray;
                    [self.tableView reloadData];
                    
                }
            });
            
            
        }
    });

}

- (void)deleteSchoolFromUserInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("deleteSchoolFromUser", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData deleteSchoolFromUser:self.userIDSelected withSchoolID:[self.schoolSelected objectForKey:ID]];
        
        if (dataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    
                }
                else
                {
                    self.schoolSelected = nil;
                    UIAlertView *addSuccess = [[UIAlertView alloc]initWithTitle:@"Remove School" message:@"The school has been removed from user successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    
                    [addSuccess show];
                    [self getSchoolsForUserSelected];
                    
                    for (id viewController in self.navigationController.viewControllers)
                    {
                        if([viewController isKindOfClass:[ManageSingleUserTableViewController class]])
                        {
                            ManageSingleUserTableViewController *MSUTVC = viewController;
                            [MSUTVC subtractOneFromSchoolLabel];
                            break;
                        }
                        
                    }

                }
            });
            
            
        }
    });

}

- (void)addschoolToUserInDatabase
{
    
    dispatch_queue_t createQueue = dispatch_queue_create("addSchooltoUser", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData addSchoolToUser:self.userIDSelected withSchoolID:[self.schoolSelected objectForKey:ID]];
        
        if (dataArray)
        {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *tempDic = [dataArray objectAtIndex:0];
                    
                    if([[tempDic objectForKey:@"error"] boolValue])
                    {
                        [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                        
                    }
                    else
                    {
                        self.schoolSelected = nil;
                        UIAlertView *addSuccess = [[UIAlertView alloc]initWithTitle:@"Add School" message:@"The school has been added successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        
                        [addSuccess show];
                        [self getSchoolsForUserSelected];
                        for (id viewController in self.navigationController.viewControllers)
                        {
                            if([viewController isKindOfClass:[ManageSingleUserTableViewController class]])
                            {
                                ManageSingleUserTableViewController *MSUTVC = viewController;
                                [MSUTVC addOneToSchoolLabel];
                                break;
                            }
                            
                        }

                    }
                });
            
            
        }
    });
    

}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:HelperMethodsImageDownloadCompleted object:nil];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getSchoolsForUserSelected];
    self.addingSchool = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)ExitButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_TO_SINGLE_SCHOOL])
    {
        SingleSchoolTableViewController *SSTVC = segue.destinationViewController;
        SSTVC.schoolData = self.schoolSelected;
        SSTVC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_LIST_ALL_SCHOOLS])
    {
        NSMutableArray *tempArray = [self.schoolData mutableCopy];
        [tempArray removeObjectAtIndex:0];
        self.addingSchool = YES;
        AllSchoolsTableViewController *ASTVC = segue.destinationViewController;
        ASTVC.mainUserData = self.mainUserData;
        ASTVC.existingSchools = tempArray;
    }

}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == 0)
        return 55.0f;
    else
        return 50.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return [self.schoolData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   NSString *CellIdentifier = @"schoolCell";
    UITableViewCell *cell;
 
    
    if(indexPath.row == 0)
    {
        CellIdentifier = CELL_EXIT;
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    else
    {
    

        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UILabel *cellLabel = (UILabel *)[tableView viewWithTag:2];
        cellLabel.text = [[self.schoolData objectAtIndex:indexPath.row] objectForKey:SCHOOL_NAME];
        
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        
        
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, [[self.schoolData objectAtIndex:indexPath.row] objectForKey:SCHOOL_IMAGE_NAME]];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
        {
            
            UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
            
            
            UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
            
            
            imageView.image = image;
            
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        self.schoolSelected = [self.schoolData objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:SEGUE_TO_SINGLE_SCHOOL sender:self];
        
    
    
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    if(indexPath.row == 0)
        return NO;
    else
    {
        if([self.schoolData count] > 2)
        {
            if([[[self.schoolData objectAtIndex:indexPath.row]objectForKey:US_PURCHASED_DATE] isEqualToString:@"0000-00-00 00:00:00"])
                return YES;
            else
                return NO;
        }
        else
            return NO;

    }
    
    
    
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        self.schoolSelected = [self.schoolData objectAtIndex:indexPath.row];
        
        UIAlertView *deleteConfrimAlert = [[UIAlertView alloc]initWithTitle:@"Remove School" message:[NSString stringWithFormat:@"You are about to remove %@ from this user. Are you sure?", [self.schoolSelected objectForKey:SCHOOL_NAME]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        deleteConfrimAlert.tag = zAlertDeleteUserSchool;
        [deleteConfrimAlert show];

    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertDeleteUserSchool)
    {
        if(buttonIndex == 1)
        {
            [self deleteSchoolFromUserInDatabase];
            
            if([self.mainUserData.userID isEqualToString:self.userIDSelected])
            {
                [self.mainUserData removeSchoolFromPhone:[self.schoolSelected objectForKey:ID]];
            }
        }
    }
}


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
