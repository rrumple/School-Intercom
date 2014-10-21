//
//  RegisterViewController.m
//  School Intercom
//
//  Created by RandallRumple on 11/21/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "RegisterViewController.h"


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
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (weak, nonatomic) IBOutlet UIView *childInputView;
@property (weak, nonatomic) IBOutlet UITextField *childFirstname;
@property (weak, nonatomic) IBOutlet UITextField *childLastName;
@property (weak, nonatomic) IBOutlet UITextField *childGradeLevel;
@property (weak, nonatomic) IBOutlet UIButton *addChildButton;
@property (weak, nonatomic) IBOutlet UITextField *yourNameTF;
@property (weak, nonatomic) IBOutlet UITextField *schoolnameTF;
@property (weak, nonatomic) IBOutlet UITextField *cityTF;
@property (weak, nonatomic) IBOutlet UITextField *stateTF;
@property (weak, nonatomic) IBOutlet UITextField *schoolContactTF;
@property (nonatomic) BOOL gradeTFready;
@property (nonatomic) BOOL numberOfChildrenTFready;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *addChildActivityView;

//@property (nonatomic, strong) DatabaseRequest *databaseRequest;
@property (nonatomic, strong) RegistrationModel *registerData;
@property (nonatomic, strong) NSString *schoolIDSelected;
@property (nonatomic) NSInteger stateSelected;
@property (nonatomic) NSInteger citySelected;
@property (nonatomic) NSInteger schoolSelected;
@property (nonatomic) int kidCounter;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation RegisterViewController

/*-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}
*/
-(RegistrationModel *)registerData
{
    if(!_registerData) _registerData = [[RegistrationModel alloc]init];
    return _registerData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    self.gradeTFready = NO;
    self.numberOfChildrenTFready = NO;
    
    
    self.stateTextField.inputView = [self createPickerWithTag:zPickerState];
    self.cityTextField.inputView = [self createPickerWithTag:zPickerCity];
    self.schoolTextField.inputView = [self createPickerWithTag:zPickerSchool];

	self.cityTextField.enabled = NO;
    self.schoolTextField.enabled = NO;
    
    [self getStatesFromDatabase];
    [self setupTapGestures];
    
    
}

- (void)checkToSeeIfAButtonShouldBeUnhidden
{
    if([self.firstNameTextField.text length] > 0 && [self.lastNameTextField.text length] > 0 && [self.emailAddressTextField.text length] > 0 && [self.passwordTextField.text length] > 0 && self.numberOfChildrenTFready)
    {
        self.createButton.hidden = NO;
        if(!self.createButton.hidden)
           [self.createButton setEnabled:true];
    }
    else
    {
        self.createButton.hidden = YES;
        self.createButton.enabled = NO;
    }
    
    if ([self.childFirstname.text length] > 0 && [self.childLastName.text length] > 0 && self.gradeTFready)
    {
        self.addChildButton.hidden = NO;
    }
    else
        self.addChildButton.hidden = YES;
    
    if([self.yourNameTF.text length] > 0 && [self.schoolnameTF.text length] > 0 && [self.cityTF.text length] > 0 && [self.stateTF.text length] > 0 && [self.schoolContactTF.text length] > 0)
    {
        self.addSchoolSendButton.hidden = NO;
    }
    
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
    [self.yourNameTF resignFirstResponder];
    [self.schoolnameTF resignFirstResponder];
    [self.cityTF resignFirstResponder];
    [self.stateTF resignFirstResponder];
    [self.schoolnameTF resignFirstResponder];
    [self.schoolContactTF resignFirstResponder];
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    
    
    
    
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
                NSLog(@"%@", self.registerData.stateArray);
                self.stateTextField.enabled = YES;
                self.stateTextField.placeholder = @"Select State";
                [self.stateIndicatorView stopAnimating];
                UIPickerView *tempPicker = (UIPickerView *)self.stateTextField.inputView;
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
                    NSLog(@"%@", self.registerData.cityArray);
                    self.cityTextField.enabled = YES;
                    self.cityTextField.placeholder = @"Select City";
                    [self.cityIndicatorView stopAnimating];
                    UIPickerView *tempPicker = (UIPickerView *)self.cityTextField.inputView;
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
                    NSLog(@"%@", self.registerData.schoolArray);
                    self.schoolTextField.enabled = YES;
                    self.schoolTextField.placeholder = @"Select School";
                    [self.schoolIndicatorView stopAnimating];
                    UIPickerView *tempPicker = (UIPickerView *)self.schoolTextField.inputView;
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

- (void)getUserData
{
    self.schoolInputView.hidden = YES;
    self.userInputView.hidden = NO;
    self.headerLabel.text = [NSString stringWithFormat:@"%@",self.schoolTextField.text];
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
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    self.emailAddressTextField.text = @"";
                                        
                }
                else
                {
                    self.mainUserData.userID = [tempDic objectForKey:USER_ID];
                    self.mainUserData.schoolIDselected = self.schoolIDSelected;
                    [self.mainUserData addSchoolIDtoArray:self.schoolIDSelected];
                    [self.mainUserData addschoolDataToArray:[[tempDic objectForKey:SCHOOL_DATA] objectAtIndex:0]];
                    [self.mainUserData setActiveSchool:self.schoolIDSelected];
                    
                    //[self downloadImages];
                    //[self downloadLogo];
                    
                    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PUSH_NOTIFICATION_PIN];
                    
                    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
                    
                    dispatch_queue_t createQueue = dispatch_queue_create("updateIOSVersion", NULL);
                    dispatch_async(createQueue, ^{
                        NSArray *dataArray;
                        dataArray = [self.registerData updateUserVersionUserID:[[NSUserDefaults standardUserDefaults]objectForKey:USER_ID] withVersion:iosVersion];
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
    
    self.kidCounter = 1;
    self.headerLabel.text = [NSString stringWithFormat:@"Add Child # %i", self.kidCounter];
    
}


- (IBAction)addSchoolRequestButtonPressed
{
    dispatch_queue_t createQueue = dispatch_queue_create("sendEmail", NULL);
    dispatch_async(createQueue, ^{
        NSArray *emailArray;
        emailArray = [self.registerData sendEmailToRequestSchoolAdditionBy:self.yourNameTF.text forSchoolNamed:self.schoolnameTF.text inCity:self.cityTF.text inState:self.stateTF.text withSchoolContactName:self.schoolContactTF.text];
        
        if (emailArray)
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@", [emailArray objectAtIndex:0]);
                
                
                if(![[[emailArray objectAtIndex:0]objectForKey:@"error"] boolValue])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Sent" message:@"Message Sent Successfully" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    
                    [alert show];
                    self.yourNameTF.text = @"";
                    self.schoolnameTF.text = @"";
                    self.cityTF.text = @"";
                    self.stateTF.text =@"";
                    self.schoolContactTF.text = @"";
                    
                    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
                     {
                         self.requestSchoolView.hidden = true;
                     }completion:^(BOOL finished)
                     {
                        NSLog(@"Animation Completed");
                     }];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Sent" message:@"Message Sent Failed! Try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    
                    [alert show];
                    
                }
                
                
                
            });
            
        }
    });

}

- (IBAction)addChildPressed
{
    [self.addChildActivityView startAnimating];
    self.registerData.childFirstName = self.childFirstname.text;
    self.registerData.childLastName = self.childLastName.text;
    self.registerData.childGradeLevel = self.childGradeLevel.text;
    self.kidCounter++;
    self.addChildButton.hidden = YES;
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

- (IBAction)privacyPolicyButtonPressed
{
     [self.navigationController popToRootViewControllerAnimated:YES];
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.myschoolintercom.com/privacy.php"]];
    
   
}

- (IBAction)tryDemoPressed
{
    if([self.delegate respondsToSelector:@selector(loginToDemoAccount)])
    {
        self.mainUserData.isAccountCreated = YES;
        self.mainUserData.isRegistered = YES;
        self.mainUserData.isDemoInUse = YES;
        [self.delegate loginToDemoAccount];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)createAccountButtonPressed
{
    [self.createButton setEnabled:false];
    self.registerData.userFirstName = self.firstNameTextField.text;
    self.registerData.userLastName = self.lastNameTextField.text;
    self.registerData.userEmailAddress = self.emailAddressTextField.text;
    self.registerData.userPassword = self.passwordTextField.text;
    self.registerData.numberOfChildren = self.numberOfChildrenTextField.text;
    
    self.mainUserData.userInfo = [self.registerData getUserInfoAsDictionary];
    
    [self addUserToDatabase];
    
        
}

- (IBAction)signUpButttonPressed
{
    [self getUserData];
   
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
    
    if(pickerView.tag == zPickerState)
        return [self.registerData.stateArray count];
    else if(pickerView.tag == zPickerCity)
        return [self.registerData.cityArray count];
    else if(pickerView.tag == zPickerSchool)
        return [self.registerData.schoolArray count];
    
    
    return 0;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
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
    
    return nil;
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
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
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.schoolTextField.isFirstResponder)
    {
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
                [self.signUpButton setHidden:false];
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
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

@end
