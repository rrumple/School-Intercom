//
//  SendAlertViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/5/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "SendAlertViewController.h"
#import <Google/Analytics.h>


@interface SendAlertViewController () <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *groupTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextview;

@property (weak, nonatomic) IBOutlet UITextField *secondGroupTextField;
@property (weak, nonatomic) IBOutlet UITextField *thirdGroupTextField;
@property (weak, nonatomic) IBOutlet UITextField *fourthGroupTextField;
@property (weak, nonatomic) IBOutlet UITextField *fifthGroupTextField;
@property (nonatomic, strong) NSArray *groupPickerValues;
@property (nonatomic, strong) NSArray *alertGroupsData;
@property (nonatomic, strong) NSArray *secondAlertGroupsData;
@property (nonatomic, strong) NSArray *thirdAlertGroupsData;
@property (nonatomic, strong) NSArray *fourthAlertGroupsData;
@property (nonatomic, strong) NSArray *fifthAlertGroupsData;
@property (nonatomic, strong) AdminModel *adminData;
@property (nonatomic, strong) NSDictionary *groupSelected;
@property (nonatomic, strong) NSDictionary *secondGroupSelected;
@property (nonatomic, strong) NSDictionary *thirdGroupSelected;
@property (nonatomic, strong) NSDictionary *fourthGroupSelected;
@property (nonatomic, strong) NSDictionary *fifthGroupSelected;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (nonatomic, strong) NSString *teacherSelected;
@property (nonatomic, strong) NSString *destinationPicker;
@property (nonatomic, strong) NSString *queryType;
@property (nonatomic, strong) NSString *idToSendToDatabase;
@property (weak, nonatomic) IBOutlet UIButton *sendAlertButton;
@property (nonatomic, strong) NSString *alertIDToInsert;
@property (weak, nonatomic) IBOutlet UILabel *groupHeaderLabel;

@end

@implementation SendAlertViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (void)getAlertGroupsFromDatabase
{
  

    dispatch_queue_t createQueue = dispatch_queue_create("groups", NULL);
    dispatch_async(createQueue, ^{
        NSArray *alertGroupsArray;
        alertGroupsArray = [self.adminData getAlertGroupsFromDatabase];
        
        if (alertGroupsArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.alertGroupsData = alertGroupsArray;
 
                    [self setupGroupPicker];
                    self.destinationPicker = [NSString stringWithFormat:@"%i", zPickerSecondGroup];
                    UIPickerView *tempPicker = (UIPickerView *) [self.groupTextField.inputView viewWithTag:zPickerGroup];
                    [tempPicker reloadAllComponents];
                    [tempPicker selectRow:0 inComponent:0 animated:NO];
               
            });
            
        }
    });
   
}

- (void)updateAlertInDatabase
{

        dispatch_queue_t createQueue = dispatch_queue_create("updateAlert", NULL);
        dispatch_async(createQueue, ^{
            NSArray *databaseData;
            databaseData = [self.adminData updateAlert:[self.alertToEdit objectForKey:ID] withText:self.messageTextview.text userMakingChange:self.mainUserData.userID];
            
            if (databaseData)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *tempDic = [databaseData objectAtIndex:0];
                    
                    if([[tempDic objectForKey:@"error"] boolValue])
                    {
                        [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                        
                    }
                    else
                    {

                        UIAlertView *success = [[UIAlertView alloc]initWithTitle:@"Update Alert" message:@"Alert was updated successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        success.tag = zAlertAddEventSuccess;
                        [success show];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"LOAD_DATA" object:nil userInfo:nil];
                    }
                });
                
            }
        });
        
    

}


-(void)setupGroupPicker
{
    
    
    switch ([self.mainUserData.accountType intValue])
    {
        case utTeacher://teacher is logged in
            self.groupPickerValues = @[@"7",@"4", @"6"];
            break;
        case utSecretary://schoolAdmin is logged in
        case utPrincipal:
            self.groupPickerValues = @[@"3", @"6"];
              break;
        case utSuperintendent://Corp Admin is logged in
            self.groupPickerValues = @[@"2", @"3"];
            break;
        case utSales:
            //sales are not allowed to send alerts
            break;
        case utSuperUser://Super User is logged in
            self.groupPickerValues = @[@"1", @"2", @"3", @"5", @"6"];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Send_Alert_Screen"];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    if(self.isEditing)
    {
        self.headerLabel.text = @"Update Alert";
        self.groupHeaderLabel.text = @"Message was sent to:";
        [self.groupTextField setEnabled:false];
        
        [self.sendAlertButton setTitle:@"Update" forState:UIControlStateNormal];
        self.messageTextview.text = [self.alertToEdit objectForKey:ALERT_TEXT];
        self.sendAlertButton.hidden = false;
        
        NSString *text;
        
        switch([[self.alertToEdit objectForKey:ALERT_TYPE] intValue])
        {
            case 1:
            case 6: text = [NSString stringWithFormat:@"User: %@", [self.alertToEdit objectForKey:@"userName"]];
                break;
            case 2: text = @"Entire Corporation";
                break;
            case 3: text = @"Entire School";
                break;
            case 4: text = @"Entire Class";
                break;
            case 5: text = @"All School Intercom Users";
                break;
            case 7: text = @"News Alert to Entire Corporatioin";
                break;
            case 8: text = @"News Alert to Entire School";
                break;
            case 9: text = @"News Alert to Entire Class";
                break;
            
                
        }
        
        self.groupTextField.text = text;
        [self updateCharacterCount:self.messageTextview.text];
    }
    else if(self.isUserAlert)
    {
        self.groupHeaderLabel.text = @"Send Alert to User:";
        [self.groupTextField setEnabled:false];
        self.groupTextField.text = [self.userAlertData objectForKey:@"name"];
        self.sendAlertButton.hidden = false;
        self.alertIDToInsert = [self.userAlertData objectForKey:ID];
    }
    else
    {
         [self getAlertGroupsFromDatabase];
        self.groupTextField.inputView = [self createPickerWithTag:zPickerGroup];
        self.secondGroupTextField.inputView = [self createPickerWithTag:zPickerSecondGroup];
        self.thirdGroupTextField.inputView = [self createPickerWithTag:zPickerThirdGroup];
        self.fourthGroupTextField.inputView = [self createPickerWithTag:zPickerFourthGroup];
        self.fifthGroupTextField.inputView = [self createPickerWithTag:zPickerFifthGroup];
        
       

    }
    
    
    self.messageTextview.delegate = self;
    [self setupTapGestures];
    
    [self.messageTextview.layer setCornerRadius:10.0f];
    [self.messageTextview.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.messageTextview.layer setBorderWidth:1.5f];
    [self.messageTextview.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.messageTextview.layer setShadowOpacity:0.8];
    [self.messageTextview.layer setShadowRadius:3.0];
    [self.messageTextview.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    
    
}

-(UIView *)createPickerWithTag:(NSInteger)tag
{
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    pickerView.tag = tag;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(hideKeyboard)];
    
    toolBar.barTintColor = [UIColor colorWithRed:0.820f green:0.835f blue:0.859f alpha:1.00f];
    
    toolBar.items = [[NSArray alloc] initWithObjects:barButtonDone,nil];
    barButtonDone.tintColor=[UIColor blackColor];
    
    
    UIView *pickerParentView = [[UIView alloc]initWithFrame:CGRectMake(0, 60, 320, 216)];
    [pickerParentView addSubview:pickerView];
    [pickerParentView addSubview:toolBar];
    
    
    /*UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickerViewTapped)];
    tapGR.cancelsTouchesInView = NO;
    
    [tapGR setNumberOfTapsRequired:1];
    
    [tapGR setDelegate:self];
    [pickerView addGestureRecognizer:tapGR];*/
    
    return pickerParentView;
}


- (void)checkToSeeIfAButtonShouldBeUnhidden
{
   /* if([self.messageTextfield.text length] > 0 && [self.messageTextfield.text length] <= 140 )
    {
        //self..hidden = NO;
    }
    else
        //self.addSchoolSendButton.hidden = YES;
    */
}

- (void)pickerViewTapped
{
    if(self.groupTextField.isFirstResponder)
    {
    
        [self hideKeyboard];
        
    }
    else if(self.secondGroupTextField.isFirstResponder)
    {
        [self hideKeyboard];
    }
    else if(self.thirdGroupTextField.isFirstResponder)
    {
        [self hideKeyboard];
    }
    else if(self.fourthGroupTextField.isFirstResponder)
    {
        [self hideKeyboard];
    }
    else if(self.fifthGroupTextField.isFirstResponder)
    {
        [self hideKeyboard];
    }


    
}


-(void)hideKeyboard
{
    [self checkToSeeIfAButtonShouldBeUnhidden];
    
    [self.messageTextview resignFirstResponder];
    [self.groupTextField resignFirstResponder];
    [self.secondGroupTextField resignFirstResponder];
    [self.thirdGroupTextField resignFirstResponder];
    [self.fourthGroupTextField resignFirstResponder];
    [self.fifthGroupTextField resignFirstResponder];

    
    
   }

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;

    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
   
    
    
    
    
}


- (void)sendAlertOfType:(NSString *)alertType
{
    NSString *schoolID = [self.mainUserData.userInfo objectForKey:@"worksAtSchoolID"];
    if(self.mainUserData.accountType.intValue > 0 && self.mainUserData.accountType.intValue < 4)
        schoolID = [self.mainUserData.userInfo objectForKey:@"worksAtSchoolID"];
    
    dispatch_queue_t createQueue = dispatch_queue_create("insertAlert", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData insertAlert:self.alertIDToInsert withMessage:self.messageTextview.text ofType:alertType fromSchool:schoolID fromUser:self.mainUserData.userID];
        
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
                        //[Flurry logEvent:@"Alert Sent"];
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Alerts"
                                                                              action:@"Alert_Sent"
                                                                               label:@"Alerts"
                                                                               value:@1] build]];
                        UIAlertView *alertSent = [[UIAlertView alloc]initWithTitle:@"Alert Sent" message:@"The alert will arrive shortly." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        [alertSent show];
                        if(self.autoClose)
                            alertSent.tag = zAlertAddEventSuccess;
                        [self resetAlertScreen];

                    }
                });
                
                
                
                
                
            });
            
        }
    });

}


- (void)setupDatabaseQuery
{
    
    BOOL runQuery = NO;
    
    switch ([[self.groupSelected objectForKey:ID] integerValue])
    {
        case agAllUsers:
            self.sendAlertButton.hidden = false;
            self.alertIDToInsert = @"";
            break;
        case agSchoolCorporation:
            switch ([self.mainUserData.accountType intValue])
        {
            case utSuperintendent:
                self.sendAlertButton.hidden = false;
                self.alertIDToInsert = [self.mainUserData.schoolData objectForKey:CORP_ID];
                break;
                case utSuperUser:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllCorps];
                    self.idToSendToDatabase = @"";
                    break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.secondGroupSelected objectForKey:ID];
                    break;
            }
                break;
                
        }
            
            break;
        case agOneSchool:
            switch ([self.mainUserData.accountType intValue])
        {
            case utSecretary:
            case utPrincipal://enable send alert button
                self.sendAlertButton.hidden = false;
                self.alertIDToInsert = [self.mainUserData.userInfo objectForKey:@"worksAtSchoolID"];
                break;
            case utSuperintendent:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllSchools];
                    self.idToSendToDatabase = [self.mainUserData.schoolData objectForKey:CORP_ID];
                    break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.secondGroupSelected objectForKey:ID];
                    break;
            }

                break;
            case utSuperUser:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllCorps];
                    self.idToSendToDatabase = @"";
                    break;
                case zPickerThirdGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllSchools];
                    self.idToSendToDatabase = [self.secondGroupSelected objectForKey:ID];
                    break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.thirdGroupSelected objectForKey:ID];
                    break;
            }

                break;
        }
            
            break;
        case agOneClassroom:
            switch ([self.mainUserData.accountType intValue])
        {
            case utTeacher:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllClasses];
                    self.idToSendToDatabase = self.mainUserData.userID;
                    break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.secondGroupSelected objectForKey:ID];
                    break;
            }
                break;
            case utSecretary:
            case utPrincipal:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllTeachers];
                    self.idToSendToDatabase = [self.mainUserData.userInfo objectForKey:@"worksAtSchoolID"];
                break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.secondGroupSelected objectForKey:ID];
                    break;
            }
                break;
            case utSuperintendent:
                break;
            case utSuperUser:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllCorps];
                    self.idToSendToDatabase = @"";
                    break;
                case zPickerThirdGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllSchools];
                    self.idToSendToDatabase = [self.secondGroupSelected objectForKey:ID];
                    break;
                case zPickerFourthGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllTeachers];
                    self.idToSendToDatabase = [self.thirdGroupSelected objectForKey:ID];
                    break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.fourthGroupSelected objectForKey:ID];
                    break;
            }

                break;
        }
            
            break;
        case agOneTeacher:
            switch ([self.mainUserData.accountType intValue])
        {
            case utSecretary:
            case utPrincipal:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllTeachers];
                    self.idToSendToDatabase = self.mainUserData.userID;
                    break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.secondGroupSelected objectForKey:ID];
                    break;
            }
                break;
            case utSuperUser:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllCorps];
                    self.idToSendToDatabase = @"";
                    break;
                case zPickerThirdGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllSchools];
                    self.idToSendToDatabase = [self.secondGroupSelected objectForKey:ID];
                    break;
                case zPickerFourthGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllTeachers];
                    self.idToSendToDatabase = [self.thirdGroupSelected objectForKey:ID];
                    break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.fourthGroupSelected objectForKey:ID];
                    break;
            }

                break;
                
        }
            break;
        case agOneParent:
            switch ([self.mainUserData.accountType intValue])
        {
            case utTeacher:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllClasses];
                    self.idToSendToDatabase = self.mainUserData.userID;
                    
                    break;
                case zPickerThirdGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllParentsInClass];
                    self.idToSendToDatabase = [self.secondGroupSelected objectForKey:ID];
                    break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.thirdGroupSelected objectForKey:ID];
                    break;
            }

                break;
            case utSecretary:
            case utPrincipal:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllTeachers];
                    self.idToSendToDatabase = [self.mainUserData.userInfo objectForKey:@"worksAtSchoolID"];
                    
                    break;
                case zPickerThirdGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllParent];
                    self.idToSendToDatabase = [self.secondGroupSelected objectForKey:ID];
                    break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.thirdGroupSelected objectForKey:ID];
                    break;
            }
                break;
            case utSuperintendent:
                break;
            case utSuperUser:
                switch([self.destinationPicker intValue])
            {
                case zPickerSecondGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllCorps];
                    self.idToSendToDatabase = @"";
                    break;
                case zPickerThirdGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllSchools];
                    self.idToSendToDatabase = [self.secondGroupSelected objectForKey:ID];
                    break;
                case zPickerFourthGroup:
                    runQuery = YES;
                    self.queryType = [NSString stringWithFormat:@"%i", quGetAllParentsForOneSchool];
                    self.idToSendToDatabase = [self.thirdGroupSelected objectForKey:ID];
                    break;
                default:
                    self.sendAlertButton.hidden = false;
                    self.alertIDToInsert = [self.fourthGroupSelected objectForKey:ID];
                    break;
            }

                break;
            
                
        }
            break;
        case agAllClasses:
            switch ([self.mainUserData.accountType intValue])
        {
            case utTeacher:
                self.sendAlertButton.hidden = false;
                self.alertIDToInsert = self.mainUserData.userID;
                break;
        }
            
    }
    if(runQuery)
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(makeSecondaryRequestFromDatabase) userInfo:nil repeats:NO];
    
    switch ([self.destinationPicker intValue])
    {
        case zPickerSecondGroup:
            break;
        case zPickerThirdGroup: self.secondGroupTextField.text = [self.secondGroupSelected objectForKey:@"name"];
            break;
        case zPickerFourthGroup: self.thirdGroupTextField.text = [self.thirdGroupSelected objectForKey:@"name"];
            break;
        case zPickerFifthGroup: self.fourthGroupTextField.text = [self.fourthGroupSelected objectForKey:@"name"];
            break;
            
        default:
            break;
    }
}

- (void)setupSearch
{
    self.destinationPicker = [NSString stringWithFormat:@"%i",zPickerSecondGroup];
    self.groupTextField.text = [self.groupSelected objectForKey:ALERT_GROUP_NAME];
    switch ([[self.groupSelected objectForKey:ID] integerValue])
    {
        case agAllUsers:
            break;
        case agSchoolCorporation:
            switch ([self.mainUserData.accountType intValue])
            {
                case utSuperUser:
                    //self.secondGroupTextField.hidden = false;
                    
                    self.secondGroupTextField.placeholder = @"Select Corporation";
                    break;
            }

            break;
        case agOneSchool:
            switch ([self.mainUserData.accountType intValue])
            {
                case utSuperintendent:
                    //self.secondGroupTextField.hidden = false;
                    self.secondGroupTextField.placeholder = @"Select School";
                    break;
                case utSuperUser:
                    //self.secondGroupTextField.hidden = false;
                    self.secondGroupTextField.placeholder = @"Select Corporation";
                    //self.thirdGroupTextField.hidden = false;
                    self.thirdGroupTextField.placeholder = @"Select School";
                    break;
            }

            break;
        case agOneClassroom:
            switch ([self.mainUserData.accountType intValue])
            {
                case utTeacher:
                    self.secondGroupTextField.placeholder = @"Select Class";
                    self.teacherSelected = @"";
                    break;
                case utSecretary:
                case utPrincipal:
                    //self.secondGroupTextField.hidden = false;
                    self.secondGroupTextField.placeholder = @"Select Teacher";
                    self.teacherSelected = @"";
                    

                    break;
                case utSuperintendent:
                   // self.secondGroupTextField.hidden = false;
                    self.secondGroupTextField.placeholder = @"Select School";
                    //self.thirdGroupTextField.hidden = false;
                    self.thirdGroupTextField.placeholder = @"Select Teacher";
                    break;
                case utSuperUser:
                    //self.secondGroupTextField.hidden = false;
                    self.secondGroupTextField.placeholder = @"Select Corporation";
                    //self.thirdGroupTextField.hidden = false;
                    self.thirdGroupTextField.placeholder = @"Select School";
                    //self.fourthGroupTextField.hidden = false;
                    self.fourthGroupTextField.placeholder = @"Select Teacher";
                    break;
            }

            break;
        case agOneTeacher:
            switch ([self.mainUserData.accountType intValue])
            {
                case utSecretary:
                case utPrincipal:
                    self.secondGroupTextField.placeholder = @"Select Teacher";
                    self.teacherSelected = @"";
                    break;
                case utSuperUser:
                    //self.secondGroupTextField.hidden = false;
                    self.secondGroupTextField.placeholder = @"Select Corporation";
                    //self.thirdGroupTextField.hidden = false;
                    self.thirdGroupTextField.placeholder = @"Select School";
                    //self.fourthGroupTextField.hidden = false;
                    self.fourthGroupTextField.placeholder = @"Select Teacher";
                    break;
            }
            break;
        case agOneParent:
            switch ([self.mainUserData.accountType intValue])
            {
                case utTeacher:
                    //self.secondGroupTextField.hidden = false;
                    self.secondGroupTextField.placeholder = @"Select Class";
                    self.thirdGroupTextField.placeholder = @"Select Parent";
                    break;
                case utSecretary:
                case utPrincipal:
                    //self.secondGroupTextField.hidden = false;
                    self.secondGroupTextField.placeholder = @"Select Teacher";
                    //self.thirdGroupTextField.hidden = false;
                    self.thirdGroupTextField.placeholder = @"Select Parent";
                    break;
                case utSuperintendent:
                    //self.secondGroupTextField.hidden = false;
                    self.secondGroupTextField.placeholder = @"Select School";
                    //self.thirdGroupTextField.hidden = false;
                    self.thirdGroupTextField.placeholder = @"Select Teacher";
                    //self.fourthGroupTextField.hidden = false;
                    self.fourthGroupTextField.placeholder = @"Select Parent";
                    break;
                case utSuperUser:
                    //self.secondGroupTextField.hidden = false;
                    self.secondGroupTextField.placeholder = @"Select Corporation";
                    //self.thirdGroupTextField.hidden = false;
                    self.thirdGroupTextField.placeholder = @"Select School";
                    //self.fourthGroupTextField.hidden = false;
                    self.fourthGroupTextField.placeholder = @"Select Parent";
                    break;
            }
            break;
            
    }
}

- (void)resetAlertScreen
{
   
    self.messageTextview.text = @"";
    self.groupTextField.text = @"";
    self.sendAlertButton.hidden = true;
    self.secondGroupTextField.hidden = true;
    self.thirdGroupTextField.hidden = true;
    self.fourthGroupTextField.hidden = true;
    self.fifthGroupTextField.hidden = true;
    self.secondGroupTextField.enabled = false;
    self.thirdGroupTextField.enabled = false;
    self.fourthGroupTextField.enabled = false;
    self.fifthGroupTextField.enabled = false;
    self.secondGroupTextField.text = @"";
    self.thirdGroupTextField.text = @"";
    self.fourthGroupTextField.text = @"";
    self.fifthGroupTextField.text = @"";
    self.destinationPicker = [NSString stringWithFormat:@"%i",zPickerSecondGroup];

    UIPickerView * tempPicker = (UIPickerView *)[self.groupTextField.inputView viewWithTag:zPickerGroup];
    [tempPicker selectRow:0 inComponent:0 animated:NO];

    
}


- (void)makeSecondaryRequestFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("second_groups", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData getSecondaryAlertGroupsFromDatabase:self.idToSendToDatabase andQueryType:self.queryType];
        
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
                       
                       
                        UIPickerView *tempPicker;
                        switch ([self.destinationPicker intValue])
                        {
                            case zPickerSecondGroup:
                                self.secondAlertGroupsData = [tempDic objectForKey:DATA];
                                self.secondGroupTextField.enabled = true;
                                self.secondGroupTextField.hidden = false;
                                self.destinationPicker = [NSString stringWithFormat:@"%i", zPickerThirdGroup];
                                tempPicker = (UIPickerView *)[self.secondGroupTextField.inputView viewWithTag:zPickerSecondGroup];
                                break;
                            case zPickerThirdGroup:
                                self.thirdAlertGroupsData = [tempDic objectForKey:DATA];
                                self.thirdGroupTextField.enabled = true;
                                self.thirdGroupTextField.hidden = false;
                                self.destinationPicker = [NSString stringWithFormat:@"%i", zPickerFourthGroup];
                                tempPicker = (UIPickerView *)[self.thirdGroupTextField.inputView viewWithTag:zPickerThirdGroup];
                                break;
                            case zPickerFourthGroup:
                                self.fourthAlertGroupsData = [tempDic objectForKey:DATA];
                                self.fourthGroupTextField.enabled = true;
                                self.fourthGroupTextField.hidden = false;
                                self.destinationPicker = [NSString stringWithFormat:@"%i", zPickerFifthGroup];
                                tempPicker = (UIPickerView *)[self.fourthGroupTextField.inputView viewWithTag:zPickerFourthGroup];
                                break;
                            case zPickerFifthGroup:
                                self.fifthAlertGroupsData = [tempDic objectForKey:DATA];
                                self.fifthGroupTextField.enabled = true;
                                self.fifthGroupTextField.hidden = false;
                                self.destinationPicker = @"999";
                                tempPicker = (UIPickerView *)[self.fifthGroupTextField.inputView viewWithTag:zPickerFifthGroup];
                                break;
                                
                        }
                        
                        [tempPicker reloadAllComponents];
                        [tempPicker selectRow:0 inComponent:0 animated:NO];
                        
                        
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

- (IBAction)sendAlertButtonPressed:(UIButton *)sender
{
    [self hideKeyboard];
    if([sender.titleLabel.text isEqualToString:@"Update"])
    {
        [self updateAlertInDatabase];
    }
    else
    {
        UIAlertView *sendAlertConfirmation = [[UIAlertView alloc]initWithTitle:@"Send Alert" message:@"Are you sure you want to send this alert?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        sendAlertConfirmation.tag = zAlertConfirmSendAlert;
        
        [sendAlertConfirmation show];
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

#pragma mark Delegate Section


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerGroup)
        return [self.groupPickerValues count];
    else if(pickerView.tag == zPickerSecondGroup)
        return [self.secondAlertGroupsData count];
    else if(pickerView.tag == zPickerThirdGroup)
        return [self.thirdAlertGroupsData count];
    else if(pickerView.tag == zPickerFourthGroup)
        return [self.fourthAlertGroupsData count];
    else if(pickerView.tag == zPickerFifthGroup)
        return [self.fifthAlertGroupsData count];

    
    
    
    return 0;
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerGroup)
    {
        
        for(NSDictionary *tempDic in self.alertGroupsData)
        {
            if([[tempDic objectForKey:ID]isEqualToString:[self.groupPickerValues objectAtIndex:row]])
            {
                return [tempDic objectForKey:ALERT_GROUP_NAME];
            }
        }
        
        
    }
    else if (pickerView.tag == zPickerSecondGroup)
    {
        return [[self.secondAlertGroupsData objectAtIndex:row]objectForKey:@"name"];
    }
    else if (pickerView.tag == zPickerThirdGroup)
    {
        return [[self.thirdAlertGroupsData objectAtIndex:row]objectForKey:@"name"];
    }
    else if (pickerView.tag == zPickerFourthGroup)
    {
        return [[self.fourthAlertGroupsData objectAtIndex:row]objectForKey:@"name"];
    }
    else if (pickerView.tag == zPickerFifthGroup)
    {
        return [[self.fifthAlertGroupsData objectAtIndex:row]objectForKey:@"name"];
    }
    
    return @"";
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerGroup)
    {
        for(NSDictionary *tempDic in self.alertGroupsData)
        {
            if([[tempDic objectForKey:ID]isEqualToString:[self.groupPickerValues objectAtIndex:row]])
            {
                self.groupTextField.text = [tempDic objectForKey:ALERT_GROUP_NAME];
                self.groupSelected = tempDic;
            }
        }
    }
    else if(pickerView.tag == zPickerSecondGroup)
    {
        self.secondGroupTextField.text = [[self.secondAlertGroupsData objectAtIndex:row] objectForKey:@"name"];
        self.secondGroupSelected = [self.secondAlertGroupsData objectAtIndex:row];
    }
    else if(pickerView.tag == zPickerThirdGroup)
    {
        self.thirdGroupTextField.text = [[self.thirdAlertGroupsData objectAtIndex:row] objectForKey:@"name"];
        self.thirdGroupSelected = [self.thirdAlertGroupsData objectAtIndex:row];
    }
    else if(pickerView.tag == zPickerFourthGroup)
    {
        self.fourthGroupTextField.text = [[self.fourthAlertGroupsData objectAtIndex:row] objectForKey:@"name"];
        self.fourthGroupSelected = [self.fourthAlertGroupsData objectAtIndex:row];
    }
    else if(pickerView.tag == zPickerFifthGroup)
    {
        self.fifthGroupTextField.text = [[self.fifthAlertGroupsData objectAtIndex:row] objectForKey:@"name"];
        self.fifthGroupSelected = [self.fifthAlertGroupsData objectAtIndex:row];
    }




    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}


-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(self.groupTextField.isFirstResponder)
    {
        if ([self.groupTextField.text isEqualToString:@""])
        {
            for(NSDictionary *tempDic in self.alertGroupsData)
            {
                if([[tempDic objectForKey:ID]isEqualToString:[self.groupPickerValues objectAtIndex:0]])
                {
                    self.groupTextField.text = [tempDic objectForKey:ALERT_GROUP_NAME];
                    self.groupSelected = tempDic;
                }
            }

        }
        
        self.sendAlertButton.hidden = true;
        self.secondGroupTextField.hidden = true;
        self.thirdGroupTextField.hidden = true;
        self.fourthGroupTextField.hidden = true;
        self.fifthGroupTextField.hidden = true;
        self.secondGroupTextField.enabled = false;
        self.thirdGroupTextField.enabled = false;
        self.fourthGroupTextField.enabled = false;
        self.fifthGroupTextField.enabled = false;
        self.secondGroupTextField.text = @"";
        self.thirdGroupTextField.text = @"";
        self.fourthGroupTextField.text = @"";
        self.fifthGroupTextField.text = @"";
        self.destinationPicker = [NSString stringWithFormat:@"%i",zPickerSecondGroup];
    }
    else if(self.secondGroupTextField.isFirstResponder)
    {
        if ([self.secondGroupTextField.text isEqualToString:@""])
        {
            self.secondGroupTextField.text = [[self.secondAlertGroupsData objectAtIndex:0] objectForKey:@"name"];
            self.secondGroupSelected = [self.secondAlertGroupsData objectAtIndex:0];
            
        }

        self.sendAlertButton.hidden = true;
        self.thirdGroupTextField.hidden = true;
        self.fourthGroupTextField.hidden = true;
        self.fifthGroupTextField.hidden = true;
        self.thirdGroupTextField.enabled = false;
        self.fourthGroupTextField.enabled = false;
        self.fifthGroupTextField.enabled = false;
        self.thirdGroupTextField.text = @"";
        self.fourthGroupTextField.text = @"";
        self.fifthGroupTextField.text = @"";
        self.destinationPicker = [NSString stringWithFormat:@"%i",zPickerThirdGroup];
    }
    else if(self.thirdGroupTextField.isFirstResponder)
    {
        if ([self.thirdGroupTextField.text isEqualToString:@""])
        {
           
            self.thirdGroupTextField.text = [[self.thirdAlertGroupsData objectAtIndex:0]objectForKey:@"name"];
            self.thirdGroupSelected = [self.thirdAlertGroupsData objectAtIndex:0];
           
            
        }

        self.sendAlertButton.hidden = true;
        self.fourthGroupTextField.hidden = true;
        self.fifthGroupTextField.hidden = true;
        self.fourthGroupTextField.enabled = false;
        self.fifthGroupTextField.enabled = false;
        self.fourthGroupTextField.text = @"";
        self.fifthGroupTextField.text = @"";
        self.destinationPicker = [NSString stringWithFormat:@"%i",zPickerFourthGroup];
    }
    else if(self.fourthGroupTextField.isFirstResponder)
    {
        if ([self.fourthGroupTextField.text isEqualToString:@""])
        {
            self.fourthGroupTextField.text = [[self.fourthAlertGroupsData objectAtIndex:0] objectForKey:@"name"];
            self.fourthGroupSelected = [self.fourthAlertGroupsData objectAtIndex:0];
            
        }

        self.sendAlertButton.hidden = true;
        self.fifthGroupTextField.hidden = true;
        self.fifthGroupTextField.enabled = false;
        self.fifthGroupTextField.text = @"";
        self.destinationPicker = [NSString stringWithFormat:@"%i",zPickerFifthGroup];
    }
    else if(self.fifthGroupTextField.isFirstResponder)
    {
        if([self.fifthGroupTextField.text isEqualToString:@""])
        {
            self.sendAlertButton.hidden = false;
            self.fifthGroupTextField.text = [[self.fifthAlertGroupsData objectAtIndex:0]objectForKey:@"name"];
            self.fifthGroupSelected = [self.fifthAlertGroupsData objectAtIndex:0];
        }
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case groupTextbox1: if([textField.text length] > 0)
        {
            
            //[self.cityIndicatorView startAnimating];
            [self setupSearch];
            [self setupDatabaseQuery];
            
            
            
        }
            break;
        case groupTextbox2:
            if([textField.text length] > 0 )
            {
                [self setupDatabaseQuery];
                //[self.schoolIndicatorView startAnimating];
                //self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getSchoolsFromDatabase) userInfo:nil repeats:NO];
            }
            break;
        case groupTextbox3:
            if ([textField.text length] > 0)
            {
                [self setupDatabaseQuery];
            }
            break;
        case groupTextbox4:
            if ([textField.text length] > 0)
            {
                [self setupDatabaseQuery];
            }

            break;
        case groupTextbox5:
            if ([textField.text length] > 0)
            {
                [self setupDatabaseQuery];
            }

            break;
    }
    
    [self checkToSeeIfAButtonShouldBeUnhidden];
}

- (BOOL)updateCharacterCount:(NSString *)text
{
    NSInteger characterCount = 140 - ([self.messageTextview.text length]+[text length]) ;
    
    self.characterCountLabel.text = [NSString stringWithFormat:@"%ld Characters Left", (long)characterCount ];
    
    
    if (characterCount == 0)
    {
        return false;
    }
    else
    {
        
        return true;
    }

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL shouldChange = true;
    
    if (textView.tag == 10)
    {
        shouldChange = [self updateCharacterCount:text];
    }
    
    return shouldChange;

}


- (IBAction)testAlertButtonPressed:(id)sender
{
   /*
    NSDictionary *testNotification = [NSJSONSerialization JSONObjectWithData:[@"{'aps':{'messageID':'NS-7641f0372f823a5d66d6a2cc00df26ce746595753245958656', 'alert':'Test Alert','sound':'default'}}" dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication] didReceiveRemoteNotification:testNotification];
    */
    
    NSString *messageID = @"7641f0372f823a5d66d6a2cc00df26ce746595753245958656";
    NSString *newStr = [messageID substringToIndex:3];
    if([newStr isEqualToString:@"NS-"])
    {
        NSString *schoolID = [messageID substringToIndex:35];
        schoolID = [schoolID substringFromIndex:3];
        
       // NSLog(@"%@", schoolID);
        
    }
    else
    {
        //NSString *schoolID = [messageID substringToIndex:32];
    
          // NSLog(@"%@", schoolID);
        
    }

    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:true];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertConfirmSendAlert)
    {
        if(buttonIndex == 1)
        {
            if(self.isUserAlert)
            {
                [self sendAlertOfType:@"1"];
            }
            else
            {
            
                switch ([[self.groupSelected objectForKey:ID]integerValue])
                {
                    case agAllUsers: [self sendAlertOfType:@"5"];
                        break;
                    case agSchoolCorporation: [self sendAlertOfType:@"2"];
                        break;
                    case agOneSchool: [self sendAlertOfType:@"3"];
                        break;
                    case agOneClassroom: [self sendAlertOfType:@"4"];
                        break;
                    case agOneTeacher: [self sendAlertOfType:@"1"];
                        break;
                    case agOneParent: [self sendAlertOfType:@"1"];
                        break;
                    case agAllClasses: [self sendAlertOfType:@"10"];
                        break;
                        
                }
            }

        }
    }
    else if(alertView.tag == zAlertAddEventSuccess)
        [self.navigationController popViewControllerAnimated:YES];
    

}

@end
