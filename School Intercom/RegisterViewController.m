//
//  RegisterViewController.m
//  School Intercom
//
//  Created by RandallRumple on 11/21/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "RegisterViewController.h"
//#import "Flurry.h"
#import <Google/Analytics.h>

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (weak, nonatomic) IBOutlet UIView *schoolInputView;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *schoolTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *stateIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *requestSchoolView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *cityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *schoolIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *addSchoolSendButton;

@property (weak, nonatomic) IBOutlet UIView *userInputView;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *numberOfChildrenTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (weak, nonatomic) IBOutlet UIView *childInputView;
@property (weak, nonatomic) IBOutlet UITextField *childFirstname;
@property (weak, nonatomic) IBOutlet UITextField *childLastName;
@property (weak, nonatomic) IBOutlet UITextField *childGradeLevel;
@property (weak, nonatomic) IBOutlet UIButton *addChildButton;
@property (nonatomic) BOOL gradeTFready;
@property (nonatomic) BOOL numberOfChildrenTFready;
@property (weak, nonatomic) IBOutlet UIButton *finshedButton;


@property (weak, nonatomic) IBOutlet UIButton *addMyschoolButton;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (weak, nonatomic) IBOutlet UILabel *step1Label;
@property (weak, nonatomic) IBOutlet UILabel *step2Label;
@property (weak, nonatomic) IBOutlet UILabel *step3Label;
@property (weak, nonatomic) IBOutlet UILabel *step4Label;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *addChildActivityView;

//@property (nonatomic, strong) DatabaseRequest *databaseRequest;
@property (nonatomic, strong) RegistrationModel *registerData;
@property (nonatomic, strong) IntroModel *introData;
@property (nonatomic, strong) NSString *schoolIDSelected;
@property (nonatomic) NSInteger stateSelected;
@property (nonatomic) NSInteger citySelected;
@property (nonatomic) NSInteger schoolSelected;
@property (nonatomic) int kidCounter;

@property (nonatomic, strong) NSArray *teachers;
@property (nonatomic, strong) NSDictionary *teacherData;
@property (nonatomic, strong) NSString *teacherSelected;
@property (nonatomic) NSInteger teacherSelectedRow;
@property (nonatomic, strong) NSString *classSelected;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation RegisterViewController

/*-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}
*/
- (IntroModel *)introData
{
    if (!_introData) _introData = [[IntroModel alloc]init];
    return  _introData;
}
-(RegistrationModel *)registerData
{
    if(!_registerData) _registerData = [[RegistrationModel alloc]init];
    return _registerData;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Register_Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[Flurry logEvent:@"New_User_Screen_Accessed"];
    
    [self.stateTextField setDelegate:self];
    [self.cityTextField setDelegate:self];
    [self.schoolTextField setDelegate:self];
    self.childFirstname.delegate = self;
    self.childLastName.delegate = self;
    self.childGradeLevel.delegate = self;
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.emailAddressTextField.delegate = self;
    self.passwordTextField.delegate =self;
    self.numberOfChildrenTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    self.gradeTFready = NO;
    self.numberOfChildrenTFready = NO;
    self.teacherSelectedRow = 0;
    
    self.stateTextField.inputView = [self createPickerWithTag:zPickerState];
    self.cityTextField.inputView = [self createPickerWithTag:zPickerCity];
    self.schoolTextField.inputView = [self createPickerWithTag:zPickerSchool];
    self.childGradeLevel.inputView = [self createPickerWithTag:zPickerTeacher];

	self.cityTextField.enabled = NO;
    self.schoolTextField.enabled = NO;
    
    [self getStatesFromDatabase];
    [self setupTapGestures];
    
    
}

- (void)checkToSeeIfAButtonShouldBeUnhidden
{
    if([[HelperMethods prepStringForValidation:self.firstNameTextField.text] length] > 0 && [[HelperMethods prepStringForValidation:self.lastNameTextField.text] length] > 0 && [self.emailAddressTextField.text length] > 0 && [self.passwordTextField.text length] > 0 && [self.confirmPasswordTextField.text length] > 0 && self.numberOfChildrenTFready && [HelperMethods isEmailValid:self.emailAddressTextField.text])
    {
        [self.createButton setEnabled:true];
    }
    else
    {
        
        self.createButton.enabled = NO;
    }
    
    if ([[HelperMethods prepStringForValidation:self.childFirstname.text] length] > 0 && [[HelperMethods prepStringForValidation:self.childLastName.text] length] > 0 && [self.childGradeLevel.text length] > 0)
    {
        self.addChildButton.enabled = YES;
    }
    else
        self.addChildButton.enabled = NO;
    
        
}

-(void)hideKeyboard
{
    [self checkToSeeIfAButtonShouldBeUnhidden];
    
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.emailAddressTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.numberOfChildrenTextField resignFirstResponder];
    [self.childGradeLevel resignFirstResponder];
    [self.childFirstname resignFirstResponder];
    [self.childLastName resignFirstResponder];
    [self.stateTextField resignFirstResponder];
    [self.cityTextField resignFirstResponder];
    [self.schoolTextField resignFirstResponder];
   
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
    
    
    
}

- (void)getTeachersFromDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("teachers", NULL);
    dispatch_async(createQueue, ^{
        NSArray *teachersArray;
        teachersArray = [self.registerData queryDatabaseForTeachersAtSchool:self.schoolIDSelected];
        
        if (teachersArray)
        {
            NSDictionary *teacherDic = [teachersArray objectAtIndex:0];
            NSArray *teacherNames = [teacherDic objectForKey:@"teachers"];
            NSDictionary *teacherData = [teacherDic objectForKey:@"teacherData"];
            dispatch_async(dispatch_get_main_queue(), ^{
              
                NSMutableArray *tempArray = [[NSMutableArray alloc]initWithObjects:@{TEACHER_FIRST_NAME: @"Don't Know"}, nil];
                
                [tempArray addObjectsFromArray:teacherNames];
                
                self.teachers = tempArray;
                self.teacherData = teacherData;
            });
            
        }
    });

}

- (void)getStatesFromDatabase
{
    self.stateTextField.enabled = NO;
    [self.stateIndicatorView startAnimating];
    
    dispatch_queue_t createQueue = dispatch_queue_create("states", NULL);
    dispatch_async(createQueue, ^{
        NSArray *statesArray;
        statesArray = [self.registerData queryDatabaseForStates];
        
        if (statesArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.registerData.stateArray = statesArray;
                //NSLog(@"%@", self.registerData.stateArray);
                self.stateTextField.enabled = YES;
                self.stateTextField.placeholder = @"Select State";
                self.step2Label.hidden = YES;
                self.step3Label.hidden = YES;

                [self.stateIndicatorView stopAnimating];
                UIPickerView *tempPicker = (UIPickerView *)[self.stateTextField.inputView viewWithTag:zPickerState];
                [tempPicker reloadAllComponents];
            });

        }
    });
}

- (void)getCitiesFromDatabase
{
 
    NSString *state = self.stateTextField.text;
    
    if([state length] > 0)
    {
        
        dispatch_queue_t createQueue = dispatch_queue_create("cities", NULL);
        dispatch_async(createQueue, ^{
            NSArray *cityArray;
            cityArray = [self.registerData queryDatabaseForCitiesUsingState:state];
            
            if (cityArray)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.registerData.cityArray = cityArray;
                    //NSLog(@"%@", self.registerData.cityArray);
                    self.cityTextField.enabled = YES;
                    self.step2Label.hidden = NO;
                    self.step3Label.hidden = YES;
    
                    self.cityTextField.placeholder = @"Select City";
                    [self.cityIndicatorView stopAnimating];
                    UIPickerView *tempPicker = (UIPickerView *)[self.cityTextField.inputView viewWithTag:zPickerCity];
                    [tempPicker reloadAllComponents];
                });
                
            }
        });
    }
    else
        [self.cityIndicatorView stopAnimating];
}

- (void)getSchoolsFromDatabase
{
    self.schoolTextField.enabled = NO;
    
    NSString *state = self.stateTextField.text;
    NSString *city = self.cityTextField.text;
    
    if([state length] > 0 && [city length] > 0)
    {
        

        dispatch_queue_t createQueue = dispatch_queue_create("schools", NULL);
        dispatch_async(createQueue, ^{
            NSArray *schoolArray;
            schoolArray = [self.registerData queryDatabaseForSchoolsUsingState:state andCity:city];
            
            if (schoolArray)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.registerData.schoolArray = schoolArray;
                    //NSLog(@"%@", self.registerData.schoolArray);
                    self.schoolTextField.enabled = YES;
                    self.step3Label.hidden = NO;
             
                    self.schoolTextField.placeholder = @"Select School";
                    [self.schoolIndicatorView stopAnimating];
                    UIPickerView *tempPicker = (UIPickerView *)[self.schoolTextField.inputView viewWithTag:zPickerSchool];
                    [tempPicker reloadAllComponents];
                });
                
            }
        });
    }
    else
        [self.schoolIndicatorView stopAnimating];

}

- (void)pickerViewTapped
{
    if(self.stateTextField.isFirstResponder)
    {
        //start DB query to load cities
        //[self getCitiesFromDatabase];
        
        [self.stateTextField resignFirstResponder];
        
        
    }
    else if(self.childGradeLevel.isFirstResponder)
    {
        [self hideKeyboard];
    }
    else if(self.cityTextField.isFirstResponder)
    {
        //[self getSchoolsFromDatabase];
        
        [self.cityTextField resignFirstResponder];
    }
    else if(self.schoolTextField.isFirstResponder)
    {
        
        
                /* do this later
        
        NSLog(@"%@", self.schoolIDselected);
        if([[self.addMoreDictionary objectForKey:SCHOOL_ID] integerValue] == [self.schoolIDselected integerValue])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"You already have an account with this school" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
            alert.tag = zAlertAddMoreError;
            [alert show];
        }
        else
        {
            if([[self.registerData.schoolSelected objectForKey:SCHOOL_NEEDS_TO_VERIFY] boolValue])
            {
                //notify user that this school requires verification before the app can be used or purchased.
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"In-App Purchase" message:[NSString stringWithFormat:@"Great!!, %@ uses School Intercom, Press the Buy button to purchase your account $9.99",self.schoolTextField.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", @"More Info", nil];
                alert.tag = zAlertPurchase;
                [alert show];
                
            }
        
        }
        */  //take out all these comments when you implement adding multiple schools
        
         [self.schoolTextField resignFirstResponder];
        
    }
}
/*
- (IBAction)addMySchoolButtonPressed
{
 
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         self.requestSchoolView.hidden = false;
     }completion:^(BOOL finished)
     {
         NSLog(@"Animation Completed");
     }];

}
*/
- (void)getUserData
{
    self.schoolInputView.hidden = YES;
    self.userInputView.hidden = NO;
    self.headerLabel.text = [NSString stringWithFormat:@"%@",self.schoolTextField.text];
}

-(UIView *)createPickerWithTag:(NSInteger)tag
{
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    pickerView.tag = tag;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [pickerView setShowsSelectionIndicator:YES];
    
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
/*
    
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickerViewTapped)];
    
    [tapGR setNumberOfTapsRequired:1];
    [tapGR setDelegate:self];
    [pickerView addGestureRecognizer:tapGR];
 */
    
    return pickerParentView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloadImages
{
    [HelperMethods downloadAndSaveImagesToDiskWithFilename:[self.mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME]];
}

- (void)downloadLogo
{
    [HelperMethods downloadSingleImageFromBaseURL:SCHOOL_LOGO_PATH withFilename:[NSString stringWithFormat:@"%@",[self.mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME]] saveToDisk:YES replaceExistingImage:NO];
}

- (void)addUserToDatabase
{
    
    dispatch_queue_t createQueue = dispatch_queue_create("addUser", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.registerData addUserToDatabase];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    if([[tempDic objectForKey:@"errorCode"] integerValue] == 200)
                    {
                        UIAlertView *emailInUseAlert = [[UIAlertView alloc]initWithTitle:@"Error 200" message:@"Email already in use, if you are a previous School Intercom user please Restore your Account" delegate:self cancelButtonTitle:@"Try Different Email" otherButtonTitles:@"Restore Account", nil];
                        emailInUseAlert.tag = zAlertEmailInUseAlert;
                        [emailInUseAlert show];
                    }
                    else
                        [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    self.emailAddressTextField.text = @"";
                                        
                }
                else
                {
                    self.mainUserData.userID = [tempDic objectForKey:USER_ID];
                    self.mainUserData.schoolIDselected = self.schoolIDSelected;
                    self.mainUserData.isPendingVerification = [[tempDic objectForKey:IS_PENDING_APPROVAL] boolValue];
                    [self.mainUserData addSchoolIDtoArray:self.schoolIDSelected];
                    [self.mainUserData addschoolDataToArray:[[tempDic objectForKey:SCHOOL_DATA] objectAtIndex:0]];
                    [self.mainUserData setActiveSchool:self.schoolIDSelected];
                    
                    for(NSDictionary *teacherData in [tempDic objectForKey:@"teacherNames"])
                    {
                        [self.mainUserData addTeacherName:teacherData];
                    }
                    //[self downloadImages];
                    //[self downloadLogo];
                    
                    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PUSH_NOTIFICATION_PIN];
                    
                    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
                    NSString *deviceModel = [HelperMethods getDeviceModel];
                    
                    dispatch_queue_t createQueue = dispatch_queue_create("updateIOSVersion", NULL);
                    dispatch_async(createQueue, ^{
                        NSArray *dataArray;
                        dataArray = [self.registerData updateUserVersionAndModelUserID:[[NSUserDefaults standardUserDefaults]objectForKey:USER_ID] withVersion:iosVersion andModel:deviceModel];
                        if ([dataArray count] == 1)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                                
                                if([[tempDic objectForKey:@"error"] boolValue])
                                {
                                    NSLog(@"%@", tempDic);
                                }
                            });
                            
                        }
                    });

                    
                    if(deviceToken)
                        {
                            dispatch_queue_t createQueue = dispatch_queue_create("updatePin", NULL);
                            dispatch_async(createQueue, ^{
                                NSArray *dataArray;
                                dataArray = [self.registerData updateUserPushNotificationPinForUserID:self.mainUserData.userID withPin:deviceToken];
                                if ([dataArray count] == 1)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSDictionary *tempDic = [dataArray objectAtIndex:0];
                                        
                                        if([[tempDic objectForKey:@"error"] boolValue])
                                        {
                                           [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                                            
                                        }
                                    });
                                    
                                }
                            });

                        }
                    [self showKidsInputView];
                    
                    
                    
                }
            });
            
        }
    });
}

- (void)showKidsInputView
{
    self.userInputView.hidden = YES;
    self.childInputView.hidden = NO;

    //self.addmySchoolLabel.hidden = YES;
    self.addMyschoolButton.hidden = YES;
    self.goBackButton.hidden = YES;
    
    self.kidCounter = 1;
    self.headerLabel.text = [NSString stringWithFormat:@"Add Child # %i", self.kidCounter];
    
}



- (IBAction)addChildPressed
{
    [self.addChildActivityView startAnimating];
    self.registerData.childFirstName = self.childFirstname.text;
    self.registerData.childLastName = self.childLastName.text;
    self.registerData.childGradeLevel = self.classSelected;
    self.kidCounter++;
    self.addChildButton.enabled = NO;
    if([self.numberOfChildrenTextField.text intValue] > 1)
        self.finshedButton.hidden = NO;
    self.classSelected = @"0";
    self.teacherSelected = @"0";
    self.teacherSelectedRow = 0;
    
    UIPickerView *tempPicker = (UIPickerView *)[self.childGradeLevel.inputView viewWithTag:zPickerTeacher];
    [tempPicker selectRow:0 inComponent:0 animated:false];
    [tempPicker reloadAllComponents];
    [self addChildToDatabase];
}



- (void)addChildToDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("addChild", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.registerData addChildToDatabaseWithUserID:self.mainUserData.userID];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    
                }
                else
                {
                    for(NSDictionary *teacherData in [tempDic objectForKey:@"teacherNames"])
                    {
                        [self.mainUserData addTeacherName:teacherData];
                    }
                    if(self.kidCounter <= [self.numberOfChildrenTextField.text intValue])
                    {
                        self.headerLabel.text = [NSString stringWithFormat:@"Add Child # %i", self.kidCounter];
                        [self.addChildActivityView stopAnimating];
                        self.childFirstname.text = @"";
                        self.childLastName.text = @"";
                        self.childGradeLevel.text = @"";
                    }
                    else
                    {
                        
                        //[self updateTeacherNames];
                        //-- Set Notification
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
                        {
                            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                            [[UIApplication sharedApplication] registerForRemoteNotifications];
                        }
                        else
                        {
                            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
                             (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
                        }

                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    
                    
                }
            });
            
        }
    });

}

- (void)updateTeacherNames
{
    dispatch_queue_t createQueue = dispatch_queue_create("updateTeacherNames", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.introData updateTeacherNamesForUser:self.mainUserData.userID];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertExistingUserIncorrectPassword andDelegate:self];
                    
                    
                }
                else
                {
                    [self.mainUserData resetTeacherNamesAndUserClasses];
                    
                    //if([self.mainUserData.accountType intValue] > 0)
                    [self.mainUserData addTeacherName:@{ID:self.mainUserData.userID, TEACHER_NAME:[NSString stringWithFormat:@"%@ %@",[self.mainUserData.userInfo objectForKey:@"prefix"], [self.mainUserData.userInfo objectForKey:USER_LAST_NAME]]}];
                    
                    
                    
                    for(NSDictionary *teacherData in [tempDic objectForKey:@"teacherNames"])
                    {
                        [self.mainUserData addTeacherName:teacherData];
                    }
                    
                    for(NSDictionary *userClassData in [tempDic objectForKey:@"usersClassData"])
                    {
                        [self.mainUserData addUserClass:userClassData];
                    }
                    
                    
                }
            });
            
        }
    });
    
}


- (IBAction)privacyPolicyButtonPressed
{
    
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.myschoolintercom.com/privacy.php"]];
    
   
}

- (IBAction)tryDemoPressed
{
    //[Flurry logEvent:@"Demo_School_Loaded"];
    if([self.delegate respondsToSelector:@selector(loginToDemoAccount)])
    {
        self.mainUserData.isAccountCreated = YES;
        self.mainUserData.isPendingVerification = NO;
        
        self.mainUserData.isDemoInUse = YES;
        [self.delegate loginToDemoAccount];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)createAccountButtonPressed
{
    //[Flurry logEvent:@"Create_Account_Button_Pressed"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"New User"
                                                          action:@"Create_Account_Button_Pressed"
                                                           label:@"New User"
                                                           value:@1] build]];
    
    
    [self.createButton setEnabled:false];
    if([self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text])
    {
        self.registerData.userFirstName = self.firstNameTextField.text;
        self.registerData.userLastName = self.lastNameTextField.text;
        self.registerData.userEmailAddress = self.emailAddressTextField.text;
        self.registerData.userPassword = self.passwordTextField.text;
        self.registerData.numberOfChildren = self.numberOfChildrenTextField.text;
        
        self.mainUserData.userInfo = [self.registerData getUserInfoAsDictionary];
        
        [self addUserToDatabase];
    }
    else
    {
        self.confirmPasswordTextField.text = @"";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Password Error!" message:@"The confirm password does not match the password!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
   
    
    
}

- (IBAction)signUpButttonPressed
{
    self.addMyschoolButton.hidden = true;
    //self.addmySchoolLabel.hidden = true;
    [self getTeachersFromDatabase];
    [self getUserData];
   
}
- (IBAction)finshedButtonPressed:(UIButton *)sender
{
    if(self.addChildButton.enabled)
    {
        self.kidCounter = [self.numberOfChildrenTextField.text intValue];
        [self addChildPressed];
        
    }
    else
        [self goBackButtonPressed];
}

- (IBAction)goBackButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addSchoolBackButtonPressed
{
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         self.requestSchoolView.hidden = true;
     }completion:^(BOOL finished)
     {
         NSLog(@"Animation Completed");
     }];

}

#pragma mark Delegate Section

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        if(pickerView.tag == zPickerState)
            return [self.registerData.stateArray count];
        else if(pickerView.tag == zPickerCity)
            return [self.registerData.cityArray count];
        else if(pickerView.tag == zPickerSchool)
            return [self.registerData.schoolArray count];
        else if(pickerView.tag == zPickerTeacher)
            return [self.teachers count];
    }
    else
    {
        NSArray *tempArray = [self.teacherData objectForKey:self.teacherSelected];
        if(tempArray)
            return [tempArray count];
        else
            return 0;
    }
    
    
    return 0;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView.tag == zPickerTeacher)
    {
        NSArray *tempArray = [self.teacherData objectForKey:self.teacherSelected];
        if(tempArray)
        {
            if([tempArray count] > 1)
            {
                self.classSelected = [[[self.teacherData objectForKey:self.teacherSelected]objectAtIndex:0]objectForKey:ID];
                return 2;
            }
            else
            {
                self.classSelected = [[[self.teacherData objectForKey:self.teacherSelected]objectAtIndex:0]objectForKey:ID];
                return 1;
            }
        }
        else
        {
            self.classSelected = @"0";
            return 1;
        }
    }
    else
        return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == zPickerState)
        return [self.registerData.stateArray objectAtIndex:row];
    else if(pickerView.tag == zPickerCity)
        return [self.registerData.cityArray objectAtIndex:row];
    else if(pickerView.tag == zPickerSchool)
        return [self.registerData.schoolArray objectAtIndex:row];
    else if(pickerView.tag == zPickerTeacher)
    {
        if(component == 0)
        {
            if (row == 0)
            {
                return @"Don't Know";
            }
            else
            {
                
                return [NSString stringWithFormat:@"%@", [[self.teachers objectAtIndex:row] objectForKey:@"teacherName"]];
                /*if([[[self.teachers objectAtIndex:row]objectForKey:@"className"]isEqualToString:@""])
                {
                    return [NSString stringWithFormat:@"%@ %@", [[self.teachers objectAtIndex:row] objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:row] objectForKey:TEACHER_LAST_NAME]];
                }
                else
                {
                    return [NSString stringWithFormat:@"%@ %@ - %@", [[self.teachers objectAtIndex:row] objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:row] objectForKey:TEACHER_LAST_NAME], [HelperMethods convertGradeLevel:[[self.teachers objectAtIndex:row] objectForKey:@"grade"] appendGrade:YES]];
                }*/
            }
        }
        else
        {
            return [NSString stringWithFormat:@"%@", [[[self.teacherData objectForKey:self.teacherSelected]objectAtIndex:row] objectForKey:@"className"]];
        }
    }
    
    return nil;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *retval = (id)view;
    if (!retval) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    }
    
    if(pickerView.tag == zPickerState)
        retval.text = [self.registerData.stateArray objectAtIndex:row];
    else if(pickerView.tag == zPickerCity)
        retval.text = [self.registerData.cityArray objectAtIndex:row];
    else if(pickerView.tag == zPickerSchool)
        retval.text = [self.registerData.schoolArray objectAtIndex:row];
    else if(pickerView.tag == zPickerTeacher)
    {
        if(component == 0)
        {
            if (row == 0)
            {
                retval.text = @"Don't Know";
            }
            else
            {
                retval.text = [NSString stringWithFormat:@"%@", [[self.teachers objectAtIndex:row] objectForKey:@"teacherName"]];
                /*if([[[self.teachers objectAtIndex:row]objectForKey:@"className"]isEqualToString:@""])
                 {
                 return [NSString stringWithFormat:@"%@ %@", [[self.teachers objectAtIndex:row] objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:row] objectForKey:TEACHER_LAST_NAME]];
                 }
                 else
                 {
                 return [NSString stringWithFormat:@"%@ %@ - %@", [[self.teachers objectAtIndex:row] objectForKey:TEACHER_PREFIX], [[self.teachers objectAtIndex:row] objectForKey:TEACHER_LAST_NAME], [HelperMethods convertGradeLevel:[[self.teachers objectAtIndex:row] objectForKey:@"grade"] appendGrade:YES]];
                 }*/
            }
        }
        else
        {
            retval.text = [NSString stringWithFormat:@"%@", [[[self.teacherData objectForKey:self.teacherSelected]objectAtIndex:row] objectForKey:@"className"]];
        }
    }

    
    retval.textAlignment = NSTextAlignmentCenter;
    retval.font = [UIFont systemFontOfSize:22];
    retval.adjustsFontSizeToFitWidth = YES;
    return retval;
}




-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        if(pickerView.tag == zPickerState)
        {
            if([self.registerData.stateArray count] == 0)
                [self.stateIndicatorView startAnimating];
            else
            {
                self.stateTextField.text = [self.registerData.stateArray objectAtIndex:row];
                self.stateSelected = row;
                [self.stateIndicatorView stopAnimating];

            }
        }
        else if(pickerView.tag == zPickerCity)
        {
            if([self.registerData.cityArray count] == 0)
                [self.cityIndicatorView startAnimating];
            else
            {
                [self.cityIndicatorView stopAnimating];
                self.cityTextField.text = [self.registerData.cityArray objectAtIndex:row];
                self.citySelected = row;
            }
        }
        else if(pickerView.tag == zPickerSchool)
        {
            if([self.registerData.schoolArray count] == 0)
                [self.schoolIndicatorView startAnimating];
            else
            {
                [self.schoolIndicatorView stopAnimating];
                self.schoolIDSelected = [[self.registerData.schoolDicsArray objectAtIndex:row] objectForKey:ID];
                self.schoolTextField.text = [self.registerData.schoolArray objectAtIndex:row];
                self.registerData.schoolSelected = [self.registerData.schoolDicsArray objectAtIndex:row];
                self.schoolSelected = row;
              
            }
        }
        else if(pickerView.tag == zPickerTeacher)
        {
            if(row == 0)
            {
                self.teacherSelected = @"0";
                self.teacherSelectedRow = 0;
                self.classSelected = @"0";
                self.childGradeLevel.text = @"Don't Know";
            }
            else
            {
                //self.childGradeLevel.text = [NSString stringWithFormat:@"%@", [[self.teachers objectAtIndex:row]objectForKey:@"teacherName"]];
                if(pickerView.numberOfComponents == 2)
                {
                    [pickerView selectRow:0 inComponent:1 animated:NO];
                }
                
                self.teacherSelected = [[self.teachers objectAtIndex:row] objectForKey:ID];
                self.teacherSelectedRow = row;
                if([[self.teacherData objectForKey:self.teacherSelected]count] > 1)
                {
                    self.childGradeLevel.text = [NSString stringWithFormat:@"%@ - %@", [[self.teachers objectAtIndex:self.teacherSelectedRow]objectForKey:@"teacherName"],
                                                 [[[self.teacherData objectForKey:self.teacherSelected] objectAtIndex:0]objectForKey:@"className"]];
                }
                else
                    self.childGradeLevel.text = [NSString stringWithFormat:@"%@", [[self.teachers objectAtIndex:row]objectForKey:@"teacherName"]] ;

            
                

            }
            [pickerView reloadAllComponents];
            
        }
    }
    else
    {
        self.classSelected = [[[self.teacherData objectForKey:self.teacherSelected] objectAtIndex:row]objectForKey:ID];
        //self.childGradeLevel.text = [NSString stringWithFormat:@"%@", [[self.teachers objectAtIndex:row]objectForKey:@"teacherName"]];
        self.childGradeLevel.text = [NSString stringWithFormat:@"%@ - %@", [[self.teachers objectAtIndex:self.teacherSelectedRow]objectForKey:@"teacherName"],
                             [[[self.teacherData objectForKey:self.teacherSelected] objectAtIndex:row]objectForKey:@"className"]];
        //[pickerView reloadAllComponents];

    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(self.schoolTextField.isFirstResponder)
    {
        self.addMyschoolButton.hidden = NO;
        //self.addmySchoolLabel.hidden = NO;
        if([self.registerData.schoolArray count] > 0)
        {
            self.schoolIDSelected = [[self.registerData.schoolDicsArray objectAtIndex:self.schoolSelected] objectForKey:ID];
            self.schoolTextField.text = [self.registerData.schoolArray objectAtIndex:self.schoolSelected];
            self.registerData.schoolSelected = [self.registerData.schoolDicsArray objectAtIndex:self.schoolSelected];
            

        }
        else
        {
            [self.schoolIndicatorView startAnimating];
            [textField resignFirstResponder];
        }
    }
    else if(self.stateTextField.isFirstResponder)
    {
        self.cityTextField.text = @"";
        self.schoolTextField.text = @"";
        self.step2Label.hidden = YES;
        self.step3Label.hidden = YES;
        self.signUpButton.hidden = YES;
        self.step4Label.hidden = YES;
        [self.cityTextField setEnabled:false];
        [self.schoolTextField setEnabled:false];
        
        if([self.registerData.stateArray count] > 0)
        {
            self.stateTextField.text = [self.registerData.stateArray objectAtIndex:self.stateSelected];
        }
        else
        {
            [self.stateIndicatorView startAnimating];
            [textField resignFirstResponder];
        }
        
    }
    else if(self.cityTextField.isFirstResponder)
    {
        self.schoolTextField.text = @"";
        [self.schoolTextField setEnabled:false];
        self.step3Label.hidden = YES;
        self.signUpButton.hidden = YES;
        self.step4Label.hidden = YES;
        if([self.registerData.cityArray count] > 0)
        {
            self.cityTextField.text = [self.registerData.cityArray objectAtIndex:self.citySelected];
        }
        else
        {
            [self.cityIndicatorView startAnimating];
            [textField resignFirstResponder];
        }
        
        
    }
    else if(self.childGradeLevel.isFirstResponder && [self.childGradeLevel.text isEqualToString:@""])
    {
        self.teacherSelected = @"0";
        self.teacherSelectedRow = 0;
        self.classSelected = @"0";
        self.childGradeLevel.text = @"Don't Know";
    }
}

- (IBAction)texfieldChanged
{
    [self checkToSeeIfAButtonShouldBeUnhidden];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.tag == 4)
    {
        
        NSString *newString = textField.text;
        
        newString = [newString stringByReplacingCharactersInRange:range withString:string];
        
        if(![newString isEqualToString:@""] && [newString intValue] >= 0 && [newString intValue] <=12)
        {
            textField.textColor = [UIColor blackColor];
            self.gradeTFready = YES;
        }
        else
        {
            self.gradeTFready = NO;
            textField.textColor = [UIColor redColor];
        }
    }
    else if(textField.tag == 1)
    {
        NSString *newString = textField.text;
        
        newString = [newString stringByReplacingCharactersInRange:range withString:string];
        
        if(![newString isEqualToString:@""] && [newString intValue] >= 1 && [newString intValue] <=10)
        {
            textField.textColor = [UIColor blackColor];
            self.numberOfChildrenTFready = YES;
        }
        else
        {
            self.numberOfChildrenTFready = NO;
            textField.textColor = [UIColor redColor];
        }

    }

    [self checkToSeeIfAButtonShouldBeUnhidden];
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case 1: if([textField.text length] > 0)
        {
            
            self.cityTextField.text = @"";
            self.schoolTextField.text = @"";
            [self.cityTextField setEnabled:false];
            [self.schoolTextField setEnabled:false];
            [self.cityIndicatorView startAnimating];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getCitiesFromDatabase) userInfo:nil repeats:NO];

           
            
            
        }
            break;
        case 2:
            if([textField.text length] > 0 )
            {
                self.schoolTextField.text = @"";
                [self.schoolTextField setEnabled:false];
                [self.schoolIndicatorView startAnimating];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getSchoolsFromDatabase) userInfo:nil repeats:NO];
            }
            break;
        case 3:
            if ([textField.text length] > 0)
            {
                [self.signUpButton setHidden:false];
                self.step4Label.hidden = NO;
            }
            break;
        case 4:
                if(self.passwordTextField.text.length > 0)
                {
                    if(![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text])
                    {
                            self.confirmPasswordTextField.text = @"";
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Password Error!" message:@"The confirm password does not match the password!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                            [alert show];
                    }
                    

                }
            break;
    }
    
    [self checkToSeeIfAButtonShouldBeUnhidden];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertEmailError)
    {
        self.emailAddressTextField.text = @"";
        //self.continueButton2.hidden = YES;
    }
    else if(alertView.tag == zAlertPurchase)
    {
        switch(buttonIndex)
        {
            case 1:
            {
                UIAlertView *inAppPurchase = [[UIAlertView alloc]initWithTitle:@"Purchase Screen" message:@"This is where the In-app purchase magic will happen, but for now it's FREE" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                inAppPurchase.tag = zAlertInAppTemp;
                [inAppPurchase show];
                break;
            }
            case 2:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.myschoolintercom.com"]];
                break;
            }
                
                
        }
    }
    else if (alertView.tag == zAlertInAppTemp)
    {
        //[self purchaseComplete];
    }
    else if(alertView.tag == zAlertAddMoreError)
    {
        if(buttonIndex == 1)
        {
            self.stateTextField.text = @"";
            self.cityTextField.text = @"";
            //self.schoolIDselected = @"";
            self.schoolTextField.text = @"";
        }
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag == zAlertEmailInUseAlert)
    {
        if(buttonIndex == 1)
        {
            if([self.delegate respondsToSelector:@selector(restoreAccount)])
            {
                self.mainUserData.isAccountCreated = NO;
                self.mainUserData.isPendingVerification = NO;
                self.mainUserData.isApproved = NO;
                self.mainUserData.isDemoInUse = NO;
                [self.delegate restoreAccount];
            }
            
            [self.navigationController popToRootViewControllerAnimated:NO];

        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

@end
