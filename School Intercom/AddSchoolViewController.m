//
//  AddSchoolViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/29/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "AddSchoolViewController.h"
#import "SchoolIntercomIAPHelper.h"
#import <StoreKit/StoreKit.h>


@interface AddSchoolViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *schoolTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *stateIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *cityIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *schoolIndicatorView;
@property (nonatomic, strong) RegistrationModel *registerData;
@property (nonatomic, strong) NSString *schoolIDSelected;
@property (nonatomic) NSInteger stateSelected;
@property (nonatomic) NSInteger citySelected;
@property (nonatomic) NSInteger schoolSelected;
@property (weak, nonatomic) IBOutlet UIButton *addSchoolButton;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *loadingActivityViewLabel;
@property (nonatomic, strong) IntroModel *introData;


@end

@implementation AddSchoolViewController

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restorePurchasesFromDatabase:) name:IAPHelperProductRestoredPurchaseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreComplete) name:IAPHelperProductRestoreCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreComplete:) name:IAPHelperProductRestoreCompletedWithNumber object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.headerLabel setFont:FONT_CHARCOAL_CY(17.0f)];
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
    
    [self.loadingIndicatorView.layer setCornerRadius:30.0f];
    [self.loadingIndicatorView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.loadingIndicatorView.layer setBorderWidth:1.5f];
    [self.loadingIndicatorView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.loadingIndicatorView.layer setShadowOpacity:0.8];
    [self.loadingIndicatorView.layer setShadowRadius:3.0];
    [self.loadingIndicatorView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];



}

- (void)checkToSeeIfAButtonShouldBeUnhidden
{
    //To make the add school function work again uncomment this section
    if([self.stateTextField.text length] > 0 && [self.cityTextField.text length] > 0 && [self.schoolTextField.text length] > 0)
    {
        [self.addSchoolButton setEnabled:true];
    }
    
       
}

- (void)addSchoolToUserInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("addSchool", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.registerData addAdditionalSchoolToUser:self.mainUserData.userID andSchool:self.schoolIDSelected];
        
        if (dataArray)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                self.loadingIndicatorView.hidden = true;
                [self.loadingActivityIndicator stopAnimating];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    
                }
                else
                {
                    [self.mainUserData addSchoolIDtoArray:self.schoolIDSelected];
                    [self.mainUserData addschoolDataToArray:[[tempDic objectForKey:SCHOOL_DATA] objectAtIndex:0]];
                    
                    
                    UIAlertView *addSchoolSuccess = [[UIAlertView alloc]initWithTitle:@"School Added" message:@"Goto the Main Menu and select Switch to login to this school" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [addSchoolSuccess show];
                    
                    self.stateTextField.text = @"";
                    self.cityTextField.text = @"";
                    self.schoolTextField.text = @"";
                    self.cityTextField.enabled = NO;
                    self.schoolTextField.enabled = NO;
                    self.addSchoolButton.enabled = NO;
                }

                NSLog(@"%@", dataArray);
                
               
            });
            
        }
    });

}

- (IBAction)addSchooButtonPressed
{
    [self addSchoolToUserInDatabase];
    self.addSchoolButton.enabled = NO;
    self.loadingIndicatorView.hidden = false;
    self.loadingActivityViewLabel.text = @"Adding School";
    [self.loadingActivityIndicator startAnimating];
}

-(void)hideKeyboard
{

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
            schoolArray = [self.registerData queryDatabaseForSchoolsUsingStateWithNoArrayProcessing:state andCity:city andUserID:self.mainUserData.userID];
            
            if (schoolArray)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //self.registerData.schoolArray = schoolArray;
                    NSMutableArray *newArray = [[NSMutableArray alloc]init];
                    NSMutableArray *newArray2 = [[NSMutableArray alloc]init];
                    
                    for (NSDictionary *dic in schoolArray)
                    {
                        if(![self.mainUserData checkForASchoolIDMatch:[dic objectForKey:ID]])
                        {
                           [newArray addObject:[dic objectForKey:SCHOOL_NAME]];
                           [newArray2 addObject:dic];
                        }
                        
                    }
                    self.registerData.schoolArray = newArray;
                    self.registerData.schoolDicsArray = newArray2;
                    NSLog(@"%@", self.registerData.schoolArray);

                    if ([self.registerData.schoolArray count] > 0)
                    {
                    
                        self.schoolTextField.enabled = YES;
                        self.schoolTextField.placeholder = @"Select School";
                        [self.schoolIndicatorView stopAnimating];
                        UIPickerView *tempPicker = (UIPickerView *)self.schoolTextField.inputView;
                        [tempPicker reloadAllComponents];
                    }
                    else
                    {
                        self.schoolTextField.placeholder = @"No Schools Found";
                        [self.schoolIndicatorView stopAnimating];
                    }
                });
                
            }
        });
    }
    else
        [self.schoolIndicatorView stopAnimating];}

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

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)restorePurchasesFromDatabase:(NSNotification *)notification

{
    SKPaymentTransaction *transaction = notification.object;
    
    if(![self.mainUserData checkForASchoolIDMatch:transaction.payment.productIdentifier])
    {
        dispatch_queue_t createQueue = dispatch_queue_create("loginExistingUser", NULL);
        dispatch_async(createQueue, ^{
            NSArray *dataArray;
            dataArray = [self.introData restorePurchaseForUser:self.mainUserData.userID andSchool:transaction.payment.productIdentifier];
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
                        if([[tempDic objectForKey:NUMBER_OF_SCHOOLS] integerValue] > 0)
                        {
                            
                            
                            for(NSDictionary *schoolData in [tempDic objectForKey:@"schoolData"])
                            {
                                [self.mainUserData addschoolDataToArray:schoolData];
                                
                            }
                            
                            [self.mainUserData addSchoolIDtoArray:transaction.payment.productIdentifier];
                            
                            NSString *schoolName = [self.mainUserData getSchoolNameFromID:transaction.payment.productIdentifier];
                            
                            UIAlertView * restoredAlert = [[UIAlertView alloc]initWithTitle:@"Access Restored" message:[NSString stringWithFormat:@"Your access to %@, has been restored", schoolName] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                            restoredAlert.tag = zAlertProductedRestored;
                            [restoredAlert show];
                            
                        }
                        
                    }
                });
                
            }
        });
        
    }
    
    
    
}

- (void)restoreComplete:(NSNotification *)notification
{
    self.loadingIndicatorView.hidden = true;
    UIAlertView *restoreFailed;
    if([notification.object integerValue] == 1)
    {
        restoreFailed = [[UIAlertView alloc]initWithTitle:@"Restore Complete" message:[NSString stringWithFormat:@"%@ purchase has been restored successfully", notification.object] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
    else
    {
        restoreFailed = [[UIAlertView alloc]initWithTitle:@"Restore Complete" message:[NSString stringWithFormat:@"%@ purchases have been restored successfully", notification.object] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
    }
    restoreFailed.tag = zAlertRestoreFailed;
    [restoreFailed show];
}

- (void)restoreComplete
{
    self.loadingIndicatorView.hidden = true;
    UIAlertView *restoreFailed = [[UIAlertView alloc]initWithTitle:@"Restore Complete" message:@"All Purchases have already been restored" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    restoreFailed.tag = zAlertRestoreFailed;
    [restoreFailed show];
    
}

- (IBAction)restorePurchasesButtonPressed
{
    self.loadingIndicatorView.hidden = false;
    self.loadingActivityViewLabel.text = @"Restoring Purchases";
     [self.loadingActivityIndicator startAnimating];
    
    [[SchoolIntercomIAPHelper sharedInstance] restoreCompletedTransactions];
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
                [self.addSchoolButton setHidden:false];
            break;
    }
    
    [self checkToSeeIfAButtonShouldBeUnhidden];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   /* if(alertView.tag == zAlertEmailError)
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
    */
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

@end
