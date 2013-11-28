//
//  IntroViewController.m
//  School Intercom
//
//  Created by RandallRumple on 11/20/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()

@property (nonatomic, strong) UserData *mainUserData;
@property (nonatomic, strong) NSMutableDictionary *existingUserData;

@end

@implementation IntroViewController

- (UserData *)mainUserData
{
    if (!_mainUserData)
        _mainUserData = [[UserData alloc]init];
    return _mainUserData;
}

- (NSMutableDictionary *)existingUserData
{
    if(!_existingUserData) _existingUserData = [[NSMutableDictionary alloc]init];
    return _existingUserData;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self checkForValidUser];
}

- (void)checkForValidUser
{
    if (self.mainUserData.isAccountCreated && self.mainUserData.isRegistered)
    {
        //load data here
        
        [self performSegueWithIdentifier:SEGUE_TO_MAIN_MENU sender:self];
    }
    else if (!self.mainUserData.isAccountCreated)
    {
        UIAlertView *noAccountAlert = [[UIAlertView alloc]initWithTitle:@"New or Existing User?" message:Nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"New User", @"Existing User", nil];
        noAccountAlert.tag = zAlertNoUser;
        
        [noAccountAlert show];
    }
    else if (self.mainUserData.isAccountCreated && !self.mainUserData.isRegistered)
    {
        //check the database to see if the users Registered status has changed
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    if(self.mainUserData.isAccountCreated)
    {
        //change background image to users current school
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_REGISTER_VIEW])
    {
        RegisterViewController *RVC = segue.destinationViewController;
        
        RVC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_MAIN_MENU])
    {
        MainNavigationController *MNC = segue.destinationViewController;
        
        MNC.isFirstLoad = YES;
    }
}

#pragma mark Delegate Section

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertNoUser)
    {
        if(buttonIndex == zAlertButtonNew)
        {
            [self performSegueWithIdentifier:SEGUE_TO_REGISTER_VIEW sender:self];
        }
        else if (buttonIndex == zAlertButtonExisting)
        {
            UIAlertView *existingAccountAlert = [[UIAlertView alloc]initWithTitle:@"Login" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok", @"Forgot PIN", nil];
            [existingAccountAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            existingAccountAlert.tag = zAlertEnterEmail;
            UITextField *emailField = [existingAccountAlert textFieldAtIndex:0];
            emailField.placeholder = @"Email";
            emailField.delegate = self;
            emailField.tag = zTextFieldEmail;
            emailField.keyboardType = UIKeyboardTypeEmailAddress;
            
            UITextField *passwordField = [existingAccountAlert textFieldAtIndex:1];
            passwordField.placeholder = @"6-Digit PIN";
            passwordField.delegate = self;
            passwordField.tag = zTextFieldPin;
            passwordField.keyboardType = UIKeyboardTypeNumberPad;
            
            
            [existingAccountAlert show];
        }
    }
    else if (alertView.tag == zAlertEnterEmail)
    {
        
        [self.existingUserData setValue:[[alertView textFieldAtIndex:0]text] forKey:USER_EMAIL];
        [self.existingUserData setValue:[[alertView textFieldAtIndex:1]text] forKey:USER_PIN];
        
        // check the database for the user and the correct pin
    }
}

- (BOOL)isEmailValid:(NSString *)email
{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if  ([emailTest evaluateWithObject:email] != YES && [email length]!=0)
        return NO;
    else
        return YES;
            
    
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag == zAlertEnterEmail)
    {
        if([[[alertView textFieldAtIndex:1] text] length] == 6 && [self isEmailValid:[[alertView textFieldAtIndex:0] text]])
            return YES;
        else
            return NO;
    }
    else
        return YES;
}


@end
