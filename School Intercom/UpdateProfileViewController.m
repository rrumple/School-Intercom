//
//  UpdateProfileViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/29/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "UpdateProfileViewController.h"
#import "SchoolIntercomIAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface UpdateProfileViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIView *changePasswordView;
@property (weak, nonatomic) IBOutlet UIButton *showChangePasswordViewButton;
@property (weak, nonatomic) IBOutlet UIButton *updateProfileButton;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *updatedPasswordTextField;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (nonatomic) CGFloat animatedDistance;
@property (weak, nonatomic) IBOutlet UIButton *cancelPasswordChangeButton;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (nonatomic, strong) UpdateProfileModel *updateProfileData;
@property (nonatomic, strong) IntroModel *introData;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *restorePurchasesButton;

@end

#define CHANGE_PASSWORD_VIEW_START_HEIGHT 40.0
#define CHANGE_PASSWORD_VIEW_START_Y 163.0
#define CHANGE_PASSWORD_VIEW_END_HEIGHT 353.0
#define CHANGE_PASSWORD_VIEW_END_Y 163.0

@implementation UpdateProfileViewController
//static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
//static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
//static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
//static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
//static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (IntroModel *)introData
{
    if (!_introData) _introData = [[IntroModel alloc]init];
    return  _introData;
}

- (UpdateProfileModel *)updateProfileData
{
    if(!_updateProfileData) _updateProfileData = [[UpdateProfileModel alloc]init];
    return _updateProfileData;
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
    
        
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Update_Profile_Screen"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restorePurchasesFromDatabase:) name:IAPHelperProductRestoredPurchaseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreComplete) name:IAPHelperProductRestoreCompleted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreComplete:) name:IAPHelperProductRestoreCompletedWithNumber object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPushAlert:) name:@"DisplayAlert" object:nil];
    
    
}

- (void)showPushAlert:(NSNotification *)notification
{
    NSDictionary *data = [notification userInfo];
    
    [HelperMethods CreateAndDisplayOverHeadAlertInView:self.view withMessage:[data objectForKey:@"message"] andSchoolID:[data objectForKey:SCHOOL_ID]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[Flurry logEvent:@"UPDATE_PROFILE_SCREEN_VIEWED"];
    self.firstNameTextfield.text = [self.mainUserData.userInfo objectForKey:USER_FIRST_NAME];
    self.lastNameTextfield.text = [self.mainUserData.userInfo objectForKey:USER_LAST_NAME];
    self.emailTextField.text = [self.mainUserData.userInfo objectForKey:USER_EMAIL];
    self.firstNameTextfield.delegate = self;
    self.lastNameTextfield.delegate = self;
    self.currentPasswordTextField.delegate = self;
    self.updatedPasswordTextField.delegate = self;
    self.confirmPasswordTextField.delegate = self;
    [self setupTapGestures];
	// Do any additional setup after loading the view.
    
    [self.headerLabel setFont:FONT_CHARCOAL_CY(17.0f)];
    
    [self.activityIndicatorView.layer setCornerRadius:30.0f];
    [self.activityIndicatorView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.activityIndicatorView.layer setBorderWidth:1.5f];
    [self.activityIndicatorView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.activityIndicatorView.layer setShadowOpacity:0.8];
    [self.activityIndicatorView.layer setShadowRadius:3.0];
    [self.activityIndicatorView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    if([self.mainUserData.accountType intValue] > 0 && [self.mainUserData.accountType intValue] < 8)
        self.restorePurchasesButton.hidden = true;


}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}

-(void)hideKeyboard
{

    
    [self.updatedPasswordTextField resignFirstResponder];
    [self.currentPasswordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
    [self.firstNameTextfield resignFirstResponder];
    [self.lastNameTextfield resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    
}

- (void)setupTapGestures
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecgnizer.cancelsTouchesInView = NO;
    gestureRecgnizer.delegate = self;
    
    [self.view addGestureRecognizer:gestureRecgnizer];
    //[self.changePasswordView addGestureRecognizer:gestureRecgnizer];
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateProfileInDatabase
{
    NSDictionary *userdata = [NSDictionary dictionaryWithObjects:@[self.mainUserData.userID, self.firstNameTextfield.text, self.lastNameTextfield.text, self.emailTextField.text] forKeys:@[USER_ID, USER_FIRST_NAME, USER_LAST_NAME, USER_EMAIL]];
    
    dispatch_queue_t createQueue = dispatch_queue_create("updateProfile", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.updateProfileData updateProfileFromUserDicData:userdata];
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
                    self.mainUserData.userInfo = [NSDictionary dictionaryWithObjects:@[self.firstNameTextfield.text, self.lastNameTextfield.text, self.emailTextField.text] forKeys:@[USER_FIRST_NAME, USER_LAST_NAME, USER_EMAIL]];
                    
                    UIAlertView *profileUpdatedAlert = [[UIAlertView alloc]initWithTitle:@"Profile Updated" message:@"Your Profile was Updated Successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [profileUpdatedAlert show];
                    
                }
            });
            
        }
    });

}

- (void)movePasswordView
{
    self.updatedPasswordTextField.text = @"";
    self.currentPasswordTextField.text = @"";
    self.confirmPasswordTextField.text = @"";
    self.mainUserData.wasPasswordReset = NO;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect rect = self.changePasswordView.frame;
        rect.size.height = CHANGE_PASSWORD_VIEW_START_HEIGHT;
        self.changePasswordView.frame = rect;
        self.changePasswordView.alpha = 0.0;
        self.showChangePasswordViewButton.alpha = 1.0;
    }completion:^(BOOL finished) {
        //
    }];

}

- (void)resetPasswordInDatabase
{
    if ([HelperMethods isEmailValid:[self.mainUserData.userInfo objectForKey:USER_EMAIL]])
    {
        dispatch_queue_t createQueue = dispatch_queue_create("resetPassword", NULL);
        dispatch_async(createQueue, ^{
            NSArray *dataArray;
            dataArray = [self.introData resetPasswordForEmail:[self.mainUserData.userInfo objectForKey:USER_EMAIL]];
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
                        
                        UIAlertView *passwordResetAlert = [[UIAlertView alloc]initWithTitle:@"Password Reset" message:@"An email has been sent with your new password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        [passwordResetAlert show];
                        self.mainUserData.wasPasswordReset = YES;
                    }
                });
                
            }
        });
        
    }
    else
    {
        //display alert for invalid email
    }

}

- (void)updatePasswordInDatabase
{
    dispatch_queue_t createQueue = dispatch_queue_create("updatePassword", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.updateProfileData updatePasswordForUserID:self.mainUserData.userID withOldPassword:[HelperMethods encryptText:self.currentPasswordTextField.text] andNewPassword:[HelperMethods encryptText:self.updatedPasswordTextField.text]];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertNotifyOnly andDelegate:nil];
                    self.updatedPasswordTextField.text = @"";
                    self.currentPasswordTextField.text = @"";
                    self.confirmPasswordTextField.text = @"";
                }
                else
                {
                    [self movePasswordView];
                    
                    UIAlertView *passwordUpdatedAlert = [[UIAlertView alloc]initWithTitle:@"Password Changed" message:@"Password Changed Successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [passwordUpdatedAlert show];
                    
                }
            });
            
        }
    });

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
    self.activityIndicatorView.hidden = true;
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
    self.activityIndicatorView.hidden = true;
    UIAlertView *restoreFailed = [[UIAlertView alloc]initWithTitle:@"Restore Complete" message:@"All Purchases have already been restored" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    restoreFailed.tag = zAlertRestoreFailed;
    [restoreFailed show];

}

- (IBAction)restorePurchasesButtonPressed
{
    self.activityIndicatorView.hidden = false;
    
    [[SchoolIntercomIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (IBAction)showChangePasswordView
{
    //self.showChangePasswordViewButton.hidden = true;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect rect = self.changePasswordView.frame;
        rect.size.height = CHANGE_PASSWORD_VIEW_END_HEIGHT;
        self.changePasswordView.frame = rect;
        self.changePasswordView.alpha = 1.0;
        self.showChangePasswordViewButton.alpha = 0.0;
    }completion:^(BOOL finished) {
        //
    }];
    
}

- (IBAction)updateProfileButtonPressed
{
    if([HelperMethods isEmailValid:self.emailTextField.text] )
        [self updateProfileInDatabase];
    else
    {
        
        UIAlertView *invalidEmailAlert = [[UIAlertView alloc]initWithTitle:@"Invalid Email" message:@"Enter a valid Email Address"  delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        
        [invalidEmailAlert show];
    }
    
   
}

- (IBAction)privacyPolicyButtonPressed:(id)sender
{
   // [self.navigationController popToRootViewControllerAnimated:YES];
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.myschoolintercom.com/privacy.php"]];

}


- (IBAction)forgotPasswordButtonPressed
{
    [self resetPasswordInDatabase];
}
- (IBAction)cancelPasswordChangeButtonPressed
{
    [self movePasswordView];
}

- (IBAction)changePasswordButtonPressed
{
    if([self.updatedPasswordTextField.text isEqualToString:self.confirmPasswordTextField.text] && self.currentPasswordTextField.hasText)
    {
        if([self.updatedPasswordTextField.text length] >= 6)
            [self updatePasswordInDatabase ];
        else
        {
            UIAlertView *invalidNewPasswordAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"New Password must be at least 6 characters long" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            
            [invalidNewPasswordAlert show];
            self.updatedPasswordTextField.text = @"";
            self.confirmPasswordTextField.text = @"";
        }
    }
    else
    {
        UIAlertView *noMatchAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"New password does not match Confirm Password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [noMatchAlert show];
        self.currentPasswordTextField.text = @"";
        self.updatedPasswordTextField.text = @"";
        self.confirmPasswordTextField.text = @"";
    }
    
    
}

- (IBAction)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag > 2)
    {
        CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
        CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
        
        CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
        CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
        CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
        CGFloat heightFraction = numerator / denominator;
        
        if(heightFraction < 0.0){
            
            heightFraction = 0.0;
            
        }else if(heightFraction > 1.0){
            
            heightFraction = 1.0;
        }
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
            
            self.animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
            
        }else{
            
            self.animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
        }
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y -= self.animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag > 2)
    {
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += self.animatedDistance;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}


@end
