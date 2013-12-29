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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *cityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *schoolIndicatorView;

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

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *addChildActivityView;

//@property (nonatomic, strong) DatabaseRequest *databaseRequest;
@property (nonatomic, strong) RegistrationModel *registerData;
@property (nonatomic, strong) NSString *schoolIDSelected;
@property (nonatomic) int stateSelected;
@property (nonatomic) int citySelected;
@property (nonatomic) int schoolSelected;
@property (nonatomic) int kidCounter;

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
    if([self.firstNameTextField.text length] > 0 && [self.lastNameTextField.text length] > 0 && [self.emailAddressTextField.text length] > 0 && [self.passwordTextField.text length] > 0 && [self.numberOfChildrenTextField.text length] > 0)
    {
        self.createButton.hidden = NO;
    }
    
    if ([self.childFirstname.text length] > 0 && [self.childLastName.text length] > 0 && [self.childGradeLevel.text length] > 0)
    {
        self.addChildButton.hidden = NO;
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
    [self.cityIndicatorView startAnimating];
    NSString *state = self.stateTextField.text;
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

- (void)getSchoolsFromDatabase
{
    self.schoolTextField.enabled = NO;
    [self.schoolIndicatorView startAnimating];
    
    NSString *state = self.stateTextField.text;
    NSString *city = self.cityTextField.text;
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

- (void)pickerViewTapped
{
    if(self.stateTextField.isFirstResponder)
    {
        //start DB query to load cities
        [self getCitiesFromDatabase];
        
        [self.stateTextField resignFirstResponder];
        
        
    }
    else if(self.cityTextField.isFirstResponder)
    {
        [self getSchoolsFromDatabase];
        
        [self.cityTextField resignFirstResponder];
    }
    else if(self.schoolTextField.isFirstResponder)
    {
        
        [self getUserData];
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
                    [HelperMethods displayErrorUsingDictionary:tempDic];
                                        
                }
                else
                {
                    self.mainUserData.userID = [tempDic objectForKey:USER_ID];
                    self.mainUserData.schoolIDselected = self.schoolIDSelected;
                    [self.mainUserData addSchoolIDtoArray:self.schoolIDSelected];
                    [self.mainUserData addschoolDataToArray:[NSDictionary dictionaryWithObjectsAndKeys:[tempDic objectForKey:USER_IS_VERIFIED],USER_IS_VERIFIED, [tempDic objectForKey:SCHOOL_IMAGE_NAME], SCHOOL_IMAGE_NAME, self.schoolIDSelected, SCHOOL_ID, nil]];
                    
                    [self downloadImages];
                    
                    
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
                    [HelperMethods displayErrorUsingDictionary:tempDic];
                    
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
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    
                    
                }
            });
            
        }
    });

}

- (IBAction)createAccountButtonPressed
{
    self.registerData.userFirstName = self.firstNameTextField.text;
    self.registerData.userLastName = self.lastNameTextField.text;
    self.registerData.userEmailAddress = self.emailAddressTextField.text;
    self.registerData.userPassword = self.passwordTextField.text;
    self.registerData.numberOfChildren = self.numberOfChildrenTextField.text;
    
    [self addUserToDatabase];
    
    [self showKidsInputView];
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
            [self.stateIndicatorView stopAnimating];
            self.stateTextField.text = [self.registerData.stateArray objectAtIndex:row];
            self.stateSelected = row;
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
            self.registerData.schoolSelected = [self.registerData.schoolArray objectAtIndex:row];
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
        
        if([self.registerData.stateArray count] > 0)
            self.stateTextField.text = [self.registerData.stateArray objectAtIndex:self.stateSelected];
        else
        {
            [self.stateIndicatorView startAnimating];
            [textField resignFirstResponder];
        }
        
    }
    else if(self.cityTextField.isFirstResponder)
    {
        self.schoolTextField.text = @"";
        if([self.registerData.cityArray count] > 0)
            self.cityTextField.text = [self.registerData.cityArray objectAtIndex:self.citySelected];
        else
        {
            [self.cityIndicatorView startAnimating];
            [textField resignFirstResponder];
        }
        
        
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
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


@end
