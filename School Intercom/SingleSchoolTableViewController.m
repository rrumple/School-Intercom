//
//  SingleSchoolTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/30/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "SingleSchoolTableViewController.h"
#import "AdminModel.h"
#import "UsersSchoolsTableViewController.h"

@interface SingleSchoolTableViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *cell1;
@property (weak, nonatomic) IBOutlet UISwitch *isActiveSwitch;
@property (weak, nonatomic) IBOutlet UILabel *dateAddedLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isApprovedSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hasPurchasedSwitch;
@property (weak, nonatomic) IBOutlet UILabel *purchasedDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfKidsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfLoginsLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastLoginDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *schoolNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *schoolImage;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (nonatomic, strong) AdminModel *adminData;

@end

@implementation SingleSchoolTableViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (NSDictionary *)schoolData
{
    if (!_schoolData) _schoolData = [[NSDictionary alloc]init];
    return _schoolData;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.rowHeight = 44;
    
    self.schoolNameLabel.text = [self.schoolData objectForKey:SCHOOL_NAME];
    [self.isActiveSwitch setOn:[[self.schoolData objectForKey:US_IS_ACTIVE]boolValue]];
    self.dateAddedLabel.text = [self.schoolData objectForKey:@"timestamp"];
    [self.isApprovedSwitch setOn:[[self.schoolData objectForKey:USER_APPROVED]boolValue]];
    [self.hasPurchasedSwitch setOn:[[self.schoolData objectForKey:USER_HAS_PURCHASED]boolValue]];
    self.purchasedDateLabel.text = [self.schoolData objectForKey:US_PURCHASED_DATE];
    self.numOfKidsLabel.text = [self.schoolData objectForKey:US_NUMBER_OF_KIDS];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.numOfLoginsLabel.text = [self.schoolData objectForKey:@"numLogins"];
    self.lastLoginDateLabel.text = [self.schoolData objectForKey:@"lastLogin"];
    
    
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, [self.schoolData objectForKey:SCHOOL_IMAGE_NAME]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        
        
        
        
        self.schoolImage.image = image;
        
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateUsersSchoolInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("updateUserSchool", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData updateSchoolForUser:[self.schoolData objectForKey:@"userSchoolsID"] isActive:[NSString stringWithFormat:@"%i", self.isActiveSwitch.isOn] andIsApproved:[NSString stringWithFormat:@"%i", self.isApprovedSwitch.isOn]];
        
        if (dataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *tempDic = [dataArray objectAtIndex:0];
                    
                    if([[tempDic objectForKey:@"error"] boolValue])
                    {
                        [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                        
                    }
                    else
                    {
                        for (id viewController in self.navigationController.viewControllers)
                        {
                            if([viewController isKindOfClass:[UsersSchoolsTableViewController class]])
                            {
                                UsersSchoolsTableViewController *USTVC = viewController;
                                [USTVC getSchoolsForUserSelected];
                                [self.navigationController popViewControllerAnimated:YES];
                                break;
                            }
                            
                        }
                        
                            
                        
                        
                        
                    }
                });
                
                
                
                
                
            });
            
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)isActiveSwitchChanged:(UISwitch *)sender
{
    self.updateButton.hidden = false;
}

- (IBAction)isApprovedSwitchChanged:(UISwitch *)sender
{
    self.updateButton.hidden = false;
}

- (IBAction)updateButtonPressed
{
    self.updateButton.hidden = true;
    [self updateUsersSchoolInDatabase];
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 10;
}
*/
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
