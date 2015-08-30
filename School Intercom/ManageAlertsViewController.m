//
//  ManageAlertsViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 2/19/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "ManageAlertsViewController.h"
#import "SendAlertViewController.h"
#import "AdminModel.h"
#import <Google/Analytics.h>

@interface ManageAlertsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *alertsTableView;
@property (nonatomic, strong) NSArray *alertData;
@property (nonatomic, strong) NSDictionary *alertSelected;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ManageAlertsViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getAlertsFromDatabase];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Manage_Alert_Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deleteAlertFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("deleteAlert", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData deleteAlert:[self.alertSelected objectForKey:ID]];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_DATA" object:nil userInfo:nil];
                
            });
            
        }
    });

}

- (void)getAlertsFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("getAlertsForUser", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData getAlertsSubmittedByUser:self.mainUserData.userID];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.alertData = databaseData;
                [self.alertsTableView reloadData];
                
            });
            
        }
    });

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SendAlertViewController *SAVC = segue.destinationViewController;
    SAVC.mainUserData = self.mainUserData;
    
    if([segue.identifier isEqualToString:SEGUE_TO_SEND_ALERTS_VIEW])
    {
        SAVC.isEditing = false;
        SAVC.autoClose = false;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_EDIT_ALERT])
    {
        SAVC.isEditing = true;
        SAVC.alertToEdit = self.alertSelected;
        SAVC.autoClose = false;
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0f;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.alertData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alertCell" forIndexPath:indexPath];
    
    UILabel *mainLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *sentLabel = (UILabel *)[cell viewWithTag:2];
    
    mainLabel.text = [[self.alertData objectAtIndex:indexPath.row] objectForKey:ALERT_TEXT];
    
  
    if([[self.alertData objectAtIndex:indexPath.row]objectForKey:ALERT_TIME_SENT] != (id)[NSNull null])
    {
        NSArray *startTimeArray = [HelperMethods getDateArrayFromString:[[self.alertData objectAtIndex:indexPath.row ] objectForKey:ALERT_TIME_SENT]];
        startTimeArray = [HelperMethods ConvertHourUsingDateArray:startTimeArray];
    
    
        sentLabel.text = [NSString stringWithFormat:@"Sent: %@ %@, %@", [HelperMethods getMonthWithInt:[startTimeArray[1] integerValue]shortName:NO], startTimeArray[2], startTimeArray[0]];
    }
    else
    {
        sentLabel.text = @"Sent: Pending...";
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(getAlertsFromDatabase) userInfo:nil repeats:NO];
    }
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.alertSelected = [self.alertData objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SEGUE_TO_EDIT_ALERT sender:self];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        self.alertSelected = [self.alertData objectAtIndex:indexPath.row];
        NSMutableArray *array = [self.alertData mutableCopy];
        [array removeObjectAtIndex:indexPath.row];
        self.alertData = array;
        [self deleteAlertFromDatabase];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

@end
