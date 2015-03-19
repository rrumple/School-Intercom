//
//  SchoolStatsViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 2/14/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "SchoolStatsViewController.h"
#import "AdminModel.h"

@interface SchoolStatsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *totalGrandparentLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalUsersLabel;
@property (weak, nonatomic) IBOutlet UILabel *fundraiserPackPurchasesLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeAdvertisersLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeUsersTodayLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeTeachersTodayLabel;
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;
@property (weak, nonatomic) IBOutlet UILabel *totalTeachersLabel;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) NSArray *deviceData;
@property (weak, nonatomic) IBOutlet UILabel *teachersNotActivatedLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@end

@implementation SchoolStatsViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)getSchoolStatsFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("getSchoolStatsFromDatabase", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData getSchoolStats:self.schoolIDSelected forUserID:self.mainUserData.userID];
        
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
                        
                        self.totalUsersLabel.text = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"totalUsers"]];
                        self.totalGrandparentLabel.text = [NSString stringWithFormat:@"%@", [tempDic objectForKey:@"totalGrandparents"]];
                        self.fundraiserPackPurchasesLabel.text = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"totalFundraiserPacksPurchased"]];
                        self.activeAdvertisersLabel.text = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"totalActiveAds"]];
                        self.activeUsersTodayLabel.text = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"totalActiveUsersToday"]];
                        self.activeTeachersTodayLabel.text = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"totalActiveTeachersToday"]];
                        self.totalTeachersLabel.text = [NSString stringWithFormat:@"%@",[tempDic objectForKey:@"totalTeachers"]];
                        self.teachersNotActivatedLabel.text = [NSString stringWithFormat:@"%@", [tempDic objectForKey:@"teachersNotActivated"]];
                        
                        
                        NSMutableArray *array = [[NSMutableArray alloc]init];
                        
                        for(NSDictionary *deviceDic in [tempDic objectForKey:@"deviceData"])
                        {
                            if([[deviceDic objectForKey:@"deviceModel"]length] > 0)
                               [array addObject:deviceDic];
                        }
                        
                        self.deviceData = array;
                        [self.deviceTableView reloadData];
                    }
                });
                
                
                
                
                
            });
            
        }
    });

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerLabel.text = [NSString stringWithFormat:@"%@ Stats", self.schoolNameSelected];
    
    [self getSchoolStatsFromDatabase];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.deviceData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
        

    cell.textLabel.text = [[self.deviceData objectAtIndex:indexPath.row]objectForKey:@"deviceModel"];
    cell.detailTextLabel.text = [[self.deviceData objectAtIndex:indexPath.row]objectForKey:@"deviceCount"];
    
    
    return cell;
}


@end
