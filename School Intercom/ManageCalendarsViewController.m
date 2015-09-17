//
//  ManageCalendarsViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 1/30/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "ManageCalendarsViewController.h"
#import "ManageCalendarTableViewController.h"

@interface ManageCalendarsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AdminModel *adminData;
@property (weak, nonatomic) IBOutlet UITableView *calendarTableView;
@property (nonatomic, strong) NSArray *calendarData;
@property (nonatomic, strong) NSDictionary *eventSelected;
@property (nonatomic) BOOL isNewEvent;

@end

@implementation ManageCalendarsViewController

- (NSArray *)calendarData
{
    if (!_calendarData) _calendarData = [[NSArray alloc]init];
    return _calendarData;
}

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)getUsersCalendarEventsFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("getCalendarEvents", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData getCalendarEventsForUser:self.mainUserData.userID];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.calendarData = databaseData;
                [self.calendarTableView reloadData];
                
            });
            
        }
    });

}

- (void)deleteEventFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("deleteCalendarEvent", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData deleteEvent:[self.eventSelected objectForKey:ID]];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
              
              
              [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_DATA" object:nil userInfo:nil];
                
            });
            
        }
    });

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getUsersCalendarEventsFromDatabase];
    

        
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Manage_Calendar_Screen"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];


    self.eventSelected = nil;
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

- (void)viewDidLoad {
    [super viewDidLoad];
       self.isNewEvent = false;
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
- (IBAction)addEventButtonPressed
{
     self.isNewEvent = true;
    [self performSegueWithIdentifier:SEGUE_TO_MANAGE_EVENT sender:self];
   
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_MANAGE_EVENT])
    {
        ManageCalendarTableViewController *MCTVC = segue.destinationViewController;
        MCTVC.mainUserData = self.mainUserData;
        MCTVC.backgroundColor = self.view.backgroundColor;

        if(self.isNewEvent)
        {
            self.isNewEvent = false;
            MCTVC.isNewEvent = true;
        }
        else
        {
            MCTVC.eventData = self.eventSelected;
            MCTVC.isNewEvent = false;

        }
        
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.calendarData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"calendarCell" forIndexPath:indexPath];

    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[[self.calendarData objectAtIndex:indexPath.row] objectForKey:CAL_TITLE]];
    
    //NSLog(@"%@", [[self.calendarData objectAtIndex:indexPath.row]objectForKey:CAL_START_DATE]);
    
    NSArray *startTimeArray = [HelperMethods getDateArrayFromString:[[self.calendarData objectAtIndex:indexPath.row ] objectForKey:CAL_START_DATE]];
    startTimeArray = [HelperMethods ConvertHourUsingDateArray:startTimeArray];

    NSString *className = @"";
    if([[[self.calendarData objectAtIndex:indexPath.row]objectForKey:@"classID"] isEqualToString:@"0"])
        className = @"All Classes";
    else
        className = [self.mainUserData getClassName:[[self.calendarData objectAtIndex:indexPath.row]objectForKey:@"classID"]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@, %@ @ %@:%@%@ - %@", [HelperMethods getMonthWithInt:[startTimeArray[1] integerValue]shortName:NO], startTimeArray[2], startTimeArray[0], startTimeArray[3], startTimeArray[4], startTimeArray[5],className];

    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isNewEvent = false;
    self.eventSelected = [self.calendarData objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:SEGUE_TO_MANAGE_EVENT sender:self];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        self.eventSelected = [self.calendarData objectAtIndex:indexPath.row];
        NSMutableArray *array = [self.calendarData mutableCopy];
        [array removeObjectAtIndex:indexPath.row];
        self.calendarData = array;
        [self deleteEventFromDatabase];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


@end
