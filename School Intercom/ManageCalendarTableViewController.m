//
//  ManageCalendarTableViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 1/30/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "ManageCalendarTableViewController.h"

@interface ManageCalendarTableViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *addupdateButton;
@property (weak, nonatomic) IBOutlet UITextField *eventTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextField *startDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *endDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *classRoomTextfield;
@property (weak, nonatomic) IBOutlet UISwitch *allDaySwitch;
@property (weak, nonatomic) IBOutlet UITextView *moreInfoTextView;
@property (nonatomic, strong) UIDatePicker *startDatePicker;
@property (nonatomic, strong) UIDatePicker *endDatePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *toPickerDateFormat;
@property (nonatomic, strong) NSString *startDateUnaltered;
@property (nonatomic, strong) NSString *endDateUnaltered;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSString *classSelected;

@end

@implementation ManageCalendarTableViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Flurry logEvent:@"ADD_UPDATE_CALENDAR_EVENT_ACCESSED"];
    
    if(self.isNewEvent)
    {
        self.titleLabel.text = @"Add Event";
        [self.addupdateButton setTitle:@"Add" forState:UIControlStateNormal];
    }
}

- (void)updateEventInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("updateEvent", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData updateEvent:[self.eventData objectForKey:ID] withCalendarTitle:self.eventTitleTextField.text andLocation:self.locationTextField.text andStartDate:self.startDateUnaltered andEndDate:self.endDateUnaltered andIsAllDay:[NSString stringWithFormat:@"%i",self.allDaySwitch.on] andMoreInfo:self.moreInfoTextView.text];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *success = [[UIAlertView alloc]initWithTitle:@"Update Event" message:@"Event was updated successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                success.tag = zAlertAddEventSuccess;
                [success show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_DATA" object:nil userInfo:nil];
                
            });
            
        }
    });

}

- (void)addNewEventInDatabase
{
    BOOL isAllDay = false;
    
    if([self isSameDayWithDate1:self.startDatePicker.date date2:self.endDatePicker.date])
    {
        isAllDay = self.allDaySwitch.on;
    }
    else
    {
        isAllDay = true;
    }
    
    dispatch_queue_t createQueue = dispatch_queue_create("addEvent", NULL);
    dispatch_async(createQueue, ^{
        NSArray *databaseData;
        databaseData = [self.adminData addEventForUser:self.mainUserData.userID withCalendarTitle:self.eventTitleTextField.text andLocation:self.locationTextField.text andStartDate:self.startDateUnaltered andEndDate:self.endDateUnaltered andIsAllDay:[NSString stringWithFormat:@"%i", isAllDay] andMoreInfo:self.moreInfoTextView.text forClassID:self.classSelected];
        
        if (databaseData)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *success = [[UIAlertView alloc]initWithTitle:@"Add Event" message:@"Event was added successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                success.tag = zAlertAddEventSuccess;
                [success show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_DATA" object:nil userInfo:nil];
            });
            
        }
    });

}

- (NSString *)convertDate:(NSString *)date
{
    
    //NSLog(@"%@", date);
    NSArray *startTimeArray = [HelperMethods getDateArrayFromString:date];
    startTimeArray = [HelperMethods ConvertHourUsingDateArray:startTimeArray];
    
    
    return [NSString stringWithFormat:@"%@ %@, %@  %@:%@%@", [HelperMethods getMonthWithInt:[startTimeArray[1] integerValue]shortName:YES], startTimeArray[2], startTimeArray[0], startTimeArray[3], startTimeArray[4], startTimeArray[5]];

}

- (NSString *)formatDate:(NSDate *)date
{
    
    return [self.dateFormatter stringFromDate:date];
}

- (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2 {
    
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [self.calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [self.calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    NSLog(@"%ld", (long)[difference day]);
    return [difference day];
}

- (void)startDatePickerValueChanged
{
    
    self.startDateUnaltered = [self.dateFormatter stringFromDate:self.startDatePicker.date];
    self.startDateTextField.text = [self convertDate:[self formatDate:self.startDatePicker.date]];
}

- (void)endDatePickerValueChanged
{
    self.endDateUnaltered = [self.dateFormatter stringFromDate:self.endDatePicker.date];
    self.endDateTextField.text = [self convertDate:[self formatDate:self.endDatePicker.date]];
    
    [self.allDaySwitch setOn:![self isSameDayWithDate1:self.startDatePicker.date date2:self.endDatePicker.date]];
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
    
    
    
}


- (void)hideKeyboard
{
    [self.startDateTextField resignFirstResponder];
    [self.endDateTextField resignFirstResponder];
    [self.eventTitleTextField resignFirstResponder];
    [self.locationTextField resignFirstResponder];
    [self.moreInfoTextView resignFirstResponder];
    [self.classRoomTextfield resignFirstResponder];
}

-(UIPickerView *)createPickerWithTag:(NSInteger)tag
{
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    pickerView.tag = tag;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [pickerView setShowsSelectionIndicator:YES];
    
    
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickerViewTapped)];
    
    [tapGR setNumberOfTapsRequired:1];
    [tapGR setDelegate:self];
    [pickerView addGestureRecognizer:tapGR];
    
    return pickerView;
}

- (void)pickerViewTapped
{
    if(self.classRoomTextfield.isFirstResponder)
    {
        [self hideKeyboard];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.calendar = [NSCalendar currentCalendar];
    NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setLocale:usLocale];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
   
    self.classRoomTextfield.inputView = [self createPickerWithTag:zPickerClassRoom];
    [self setupTapGestures];
    
    NSLocale *locale = [NSLocale currentLocale];
    
    if([self.mainUserData.classData count] > 0)
    {
        self.classRoomTextfield.text = [[self.mainUserData.classData objectAtIndex:0] objectForKey:@"className"];
        self.classSelected = [[self.mainUserData.classData objectAtIndex:0]objectForKey:ID];
    }
    else
    {
        self.classRoomTextfield.text = @"No Classes Found";
        self.classSelected = @"0";
        [self.classRoomTextfield setEnabled:false];
    }
    
    
    self.startDatePicker = [[UIDatePicker  alloc]init];
    self.startDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.startDatePicker.locale = locale;
    self.startDatePicker.timeZone = [NSTimeZone localTimeZone];
    self.startDatePicker.minuteInterval = 15;
    [self.startDatePicker addTarget:self action:@selector(startDatePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(hideKeyboard)];
   
    toolBar.barTintColor = [UIColor colorWithRed:0.820f green:0.835f blue:0.859f alpha:1.00f];
    
    toolBar.items = [[NSArray alloc] initWithObjects:barButtonDone,nil];
    barButtonDone.tintColor=[UIColor whiteColor];
    

    UIView *pickerParentView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 320, 216)];
    [pickerParentView addSubview:self.startDatePicker];
    [pickerParentView addSubview:toolBar];
    self.startDateTextField.inputView = pickerParentView;
    
    
    self.endDatePicker = [[UIDatePicker  alloc]init];
    self.endDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.endDatePicker.locale = locale;
    self.endDatePicker.timeZone = [NSTimeZone localTimeZone];
    self.endDatePicker.minuteInterval = 15;
    [self.endDatePicker addTarget:self action:@selector(endDatePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    
    UIToolbar *toolBar2= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar2 setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone2 = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(hideKeyboard)];
    
    toolBar2.barTintColor = [UIColor colorWithRed:0.820f green:0.835f blue:0.859f alpha:1.00f];
    
    toolBar2.items = [[NSArray alloc] initWithObjects:barButtonDone2,nil];
    barButtonDone2.tintColor=[UIColor whiteColor];
    
    
    UIView *pickerParentView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 320, 216)];
    [pickerParentView2 addSubview:self.endDatePicker];
    [pickerParentView2 addSubview:toolBar2];
    self.endDateTextField.inputView = pickerParentView2;
    
    
    self.eventTitleTextField.text = [self.eventData objectForKey:CAL_TITLE];
    self.locationTextField.text = [self.eventData objectForKey:CAL_LOCATION];
    [self.allDaySwitch setOn:[[self.eventData objectForKey:CAL_IS_ALL_DAY]boolValue]];
    if(!self.isNewEvent)
    {
        self.startDateTextField.text = [self convertDate:[self.eventData objectForKey:CAL_START_DATE]];
        self.endDateTextField.text = [self convertDate:[self.eventData objectForKey:CAL_END_DATE]];
        self.startDateUnaltered = [self.eventData objectForKey:CAL_START_DATE];
        self.endDateUnaltered =[self.eventData objectForKey:CAL_END_DATE];
    }
    self.moreInfoTextView.text = [self.eventData objectForKey:CAL_MORE_INFO];
    
    
    
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

- (IBAction)addUpdateButtonClicked:(UIButton *)sender
{
    if([[HelperMethods prepStringForValidation:self.eventTitleTextField.text] length] > 0 && self.startDateUnaltered && self.endDateUnaltered && [[self.dateFormatter dateFromString:self.endDateUnaltered]timeIntervalSinceDate:[self.dateFormatter dateFromString:self.startDateUnaltered]] >
       0.0)
    {
        if([sender.titleLabel.text isEqualToString:@"Add"])
        {
            [self addNewEventInDatabase];
        }
        else if([sender.titleLabel.text isEqualToString:@"Update"])
        {
            [self updateEventInDatabase];
        }
    }
    else
    {
        UIAlertView *moreInfo = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Events must have a title and valid start and stop dates." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [moreInfo show];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

    
    if(self.startDateTextField.isFirstResponder)
    {
        if([self.startDateTextField.text length] > 0)
            [self.startDatePicker setDate:[self.dateFormatter dateFromString:self.startDateUnaltered]];
        else
            [self startDatePickerValueChanged];
    }
    else if(self.endDateTextField.isFirstResponder)
    {
        if([self.endDateTextField.text length] > 0 && [[self.dateFormatter dateFromString:self.endDateUnaltered]timeIntervalSinceDate:[self.dateFormatter dateFromString:self.startDateUnaltered]] >
           0.0)
        {
            [self.endDatePicker setDate:[self.dateFormatter dateFromString:self.endDateUnaltered]];
        }
        else
        {
            [self.endDatePicker setDate:[self.dateFormatter dateFromString:self.startDateUnaltered]];
            [self endDatePickerValueChanged];
        }
        
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}

#pragma mark - Table view data source


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:  forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional edi          ting of the table view.
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertAddEventSuccess)
        [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if(pickerView.tag == zPickerClassRoom)
        return [self.mainUserData.classData count];
    
    
    return 0;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if(pickerView.tag == zPickerClassRoom)
    {
        return [[self.mainUserData.classData objectAtIndex:row] objectForKey:@"className"];
        
    }
    
    return nil;
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerClassRoom)
    {
        self.classSelected = [[self.mainUserData.classData objectAtIndex:row] objectForKey:ID];
        self.classRoomTextfield.text = [[self.mainUserData.classData objectAtIndex:row] objectForKey:@"className"];
       
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}


@end
