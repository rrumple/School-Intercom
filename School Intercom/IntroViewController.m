    //
//  IntroViewController.m
//  School Intercom
//
//  Created by RandallRumple on 11/20/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "IntroViewController.h"
#import "SchoolIntercomIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "SwitchViewController.h"
#import "Reachability.h"




@interface IntroViewController ()
{
    NSArray *_products;
}

@property (nonatomic, strong) UserData *mainUserData;
@property (nonatomic, strong) NSMutableDictionary *existingUserData;
@property (weak, nonatomic) IBOutlet UIImageView *micImageView;
@property (nonatomic, strong) IntroModel *introData;
@property (nonatomic) BOOL isLoadDataComplete;
@property (nonatomic) BOOL isUpdateTeachersComplete;
@property (nonatomic) BOOL isLoadImageComplete;
@property (nonatomic) BOOL imageDownloading;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (nonatomic, strong) UIAlertView *notApprovedAlert;
@property (nonatomic, strong) UIAlertView *inAppPurchaseWarningAlert;
@property (nonatomic, strong) UIAlertView *existingAccountAlert;
@property (nonatomic, strong) UIAlertView *noAccountAlert;
@property (nonatomic, strong) UIAlertView *purchseSuccess;
@property (nonatomic, strong) UIAlertView *noActiveSchoolsAlert;
@property (nonatomic, strong) UIAlertView *productPurchasedFailedAlert;
@property (weak, nonatomic) IBOutlet UIImageView *schoolLogoImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
@property (nonatomic) BOOL isPurchaseInProgress;
@property (weak, nonatomic) IBOutlet UIButton *switchSchoolsButton;
@property (nonatomic) BOOL isInAppPurchaseEnabled;
@property (nonatomic) BOOL warningViewed;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *loadingActivityIndicatorLabel;
@property (nonatomic,strong) UIColor *defaultBackgroundColor;
@property (nonatomic) NSUInteger numberOfSchoolsRestored;
@property (nonatomic, strong) NSMutableDictionary *restoredSchools;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic) BOOL loginViaRestore;
@property (nonatomic) BOOL bypassToCreateAccount;
@property (nonatomic) BOOL bypassNoAccountAlert;


@property (weak, nonatomic) IBOutlet UIView *loadingIndicatorView;
@end

@implementation IntroViewController

- (IntroModel *)introData
{
    if (!_introData) _introData = [[IntroModel alloc]init];
    return  _introData;
}

- (UserData *)mainUserData
{
    if (!_mainUserData)
        _mainUserData = [[UserData alloc]init];
    return _mainUserData;
}

- (NSMutableDictionary *)restoredSchools
{
    if (!_restoredSchools) _restoredSchools = [[NSMutableDictionary alloc]init];
    return _restoredSchools;
}

- (NSMutableDictionary *)existingUserData
{
    if(!_existingUserData) _existingUserData = [[NSMutableDictionary alloc]init];
    return _existingUserData;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    
    
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)logoutButtonPressed:(id)sender {
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self.mainUserData clearAllData];
    [self checkForValidUser];
    
}

- (void)showHomeScreen
{
    if(self.isLoadDataComplete && self.isLoadImageComplete && self.isUpdateTeachersComplete)
    {
        self.loadingIndicatorView.hidden = true;
        self.loadingActivityIndicatorLabel.text = @"Purchasing...";
        [self.loadingActivityIndicator stopAnimating];
        if(self.timer.isValid)
        {
            [self.timer invalidate];
            self.timer = nil;
        }
        [self performSegueWithIdentifier:SEGUE_TO_MAIN_MENU sender:self];
        
    }
    else
    {
        //self.isLoadImageComplete = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isLoadImageComplete"] boolValue];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showHomeScreen) userInfo:nil repeats:NO];
    }
    
}

-(UIColor *)getColorFromHex:(NSString *)str
{
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr +1, NULL, 16);
    
    return [UIColor colorWithHex:(unsigned int)x];
}

- (void)setBackgroundImage
{
   // NSLog(@"setBackGroundImage Called");
 

    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, [self.mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME] ];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        NSString *str1 = [NSString stringWithFormat:@"#%@",[self.mainUserData.schoolData objectForKey:SCHOOL_COLOR_2]];
        
        [self.introLabel setTextColor:[self getColorFromHex:str1]];
        self.introLabel.text = [NSString stringWithFormat:@"%@\nSchool Intercom", [self.mainUserData.schoolData objectForKey:SCHOOL_NAME] ];
        NSString *str = [NSString stringWithFormat:@"#%@",[self.mainUserData.schoolData objectForKey:SCHOOL_COLOR_1]];
        
        [self.micImageView setBackgroundColor:[self getColorFromHex:str]];
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        [self.schoolLogoImageView setImage:image];
        
        
        [self.schoolLogoImageView setHidden:NO];
        [self.micImageView setImage:[UIImage imageNamed:@"WelcomeScreen"]];
        self.isLoadImageComplete = true;
    }
    else
    {
         [self.micImageView setImage:[UIImage imageNamed:@"BlankWelcomeScreen"]];
        if(!self.imageDownloading)
        {
            [HelperMethods downloadSingleImageFromBaseURL:SCHOOL_LOGO_PATH withFilename:[NSString stringWithFormat:@"%@",[self. mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME]] saveToDisk:YES replaceExistingImage:NO];
            self.imageDownloading = YES;
            [self setBackgroundImage];
        }
        else
        {
            //NSLog(@"Timer Started");
             self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setBackgroundImage) userInfo:nil repeats:NO];
            
        }
    }
    

}

- (void)appWillResignActive
{
    
    self.warningViewed = false;
    [self.notApprovedAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self.inAppPurchaseWarningAlert dismissWithClickedButtonIndex:10 animated:NO];
    [self.noAccountAlert dismissWithClickedButtonIndex:10 animated:NO];
    [self.existingAccountAlert dismissWithClickedButtonIndex:10 animated:NO];
    [self.noActiveSchoolsAlert dismissWithClickedButtonIndex:0 animated:NO];
    [self.productPurchasedFailedAlert dismissWithClickedButtonIndex:0 animated:NO];
    [self.purchseSuccess dismissWithClickedButtonIndex:0 animated:NO];
    
   


}

-(void)viewDidLayoutSubviews
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        //----------------HERE WE SETUP FOR IPHONE 4/4s/iPod----------------------
        
        if(iOSDeviceScreenSize.height == 480){
            
            CGRect rect =  self.schoolLogoImageView.frame;
            rect.origin.y += 67;
            self.schoolLogoImageView.frame = rect;
        }
        
        //----------------HERE WE SETUP FOR IPHONE 5----------------------
        
        if(iOSDeviceScreenSize.height == 568){
            
            CGRect rect =  self.schoolLogoImageView.frame;
            rect.origin.y += 67;
            self.schoolLogoImageView.frame = rect;
        }
        
        //----------------HERE WE SETUP FOR IPHONE 6----------------------
        
        
        if(iOSDeviceScreenSize.height == 667){
            
            CGRect rect =  self.schoolLogoImageView.frame;
            rect.origin.y += 105;
            self.schoolLogoImageView.frame = rect;
        }
        
        //----------------HERE WE SETUP FOR IPHONE 6+ ----------------------
        if(iOSDeviceScreenSize.height == 736){
            
            CGRect rect =  self.schoolLogoImageView.frame;
            rect.origin.y += 102;
            self.schoolLogoImageView.frame = rect;
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Intro_Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    //[self checkToEnablePurchases];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseFailed) name:IAPHelperProductPurchaseFailedNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restorePurchaseFailed) name:IAPHelperRestorePurchaseFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productRestored:) name:IAPHelperProductRestoredPurchaseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreComplete) name:IAPHelperProductRestoreCompleted object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreComplete:) name:IAPHelperProductRestoreCompletedWithNumber object:nil];
    


    /*
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.myschoolintercom.com"];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];

    if (netStatus == NotReachable) { NSLog(@"no"); }
    else if (netStatus == ReachableViaWiFi) { NSLog(@"wifi"); }
    else if (netStatus == ReachableViaWWAN) { NSLog(@"cellular"); }
    */
     
    self.isLoadDataComplete = NO;
    self.isUpdateTeachersComplete = NO;
    self.isLoadImageComplete = NO;
    self.imageDownloading = NO;
    [self.introLabel setFont:FONT_CHARCOAL_CY(26.0f)];
    
    [self.existingUserData setObject:@"helpMeRonda" forKey:USER_PASSWORD];
    
    if(self.bypassToCreateAccount)
    {
        self.bypassToCreateAccount = false;
        [self performSegueWithIdentifier:SEGUE_TO_REGISTER_VIEW sender:self];
    }
    else
    {
        
    
        if(self.mainUserData.isAccountCreated)
        {
            [self setBackgroundImage];
        }
        else
        {
            [self.schoolLogoImageView setHidden:YES];
            [self.micImageView setBackgroundColor:self.defaultBackgroundColor];
            [self.micImageView setImage:[UIImage imageNamed:@"BlankWelcomeScreen"]];
        }
        
        
        if([self.mainUserData getNumberOfSchools] > 1)
            self.switchSchoolsButton.hidden = NO;
        
        if (self.isInAppPurchaseEnabled)
        {
            /*if(!self.warningViewed)
            {
                self.inAppPurchaseWarningAlert =  [[UIAlertView alloc] initWithTitle:@"WARNING PLEASE READ!!" message:@"The In-App purchase feature is enabled, for this to work correctly during testing you must use the sandbox account that was created for you. \n-Exit this app               \n-Goto Settings->iTunes & App Store \n-Signout of your real account\nDO NOT SIGN IN WITH THE TEST ACCOUNT!       \nCome back to this app and when you make an In-App purchase enter your sandbox details in the following format\nUSERNAME = lastname + firstname@msi.com\n ex... RumpleRandy@msi.com\n\n PASSWORD = Testapp123" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            
                self.inAppPurchaseWarningAlert.tag = zAlertInAppPurchaseEnabledAlert;
                //[self.inAppPurchaseWarningAlert show];
            }
            else*/
                [self checkForValidUser];
        }
        /*
        else
        {
            self.mainUserData.hasPurchased = true;
            //[self updateHasPurchasedInDatabase];
            [self checkForValidUser];
            
        }*/
    }
    
   

}


- (void)loadData
{
    [self updateDeviceInfo];
    
    [self.loadingActivityIndicator startAnimating];
    self.logoutButton.hidden = YES;
    
    self.loadingIndicatorView.hidden = false;
    self.loadingActivityIndicatorLabel.text = @"Loading...";
    
    dispatch_queue_t createQueue = dispatch_queue_create("getAppData", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.introData queryDatabaseForSchoolsDataForUser:self.mainUserData.userID andSchoolID:self.mainUserData.schoolIDselected];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    if ([[tempDic objectForKey:@"errorCode"]integerValue] == 551)
                    {
                        self.loadingIndicatorView.hidden = true;
                        [self.schoolLogoImageView setHidden:YES];
                        [self.micImageView setBackgroundColor:self.defaultBackgroundColor];
                        [self.micImageView setImage:[UIImage imageNamed:@"BlankWelcomeScreen"]];
                        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
                        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                        [[NSURLCache sharedURLCache] removeAllCachedResponses];
                        [self.mainUserData clearAllData];
                        [self checkForValidUser];
                    }
                    
                }
                else
                {
                                        
                    self.mainUserData.appData = tempDic;
                    
                    if([tempDic objectForKey:SCHOOL_DATA] != (id)[NSNull null])
                    {
                        [self.mainUserData updateSchoolDataInArray:[[tempDic objectForKey:SCHOOL_DATA]objectAtIndex:0]];
                        
                        // NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                        
                        //NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",docDir, [self.mainUserData.schoolData objectForKey:ID] ];
                        //  NSError *error;
                        
                        //[[NSFileManager defaultManager] removeItemAtPath:pngFilePath error:&error];
                        [[NSURLCache sharedURLCache] removeAllCachedResponses];
                        
                        
                        /* if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                         {
                         NSLog(@"Image Still exists");
                         }
                         else
                         {*/
                        NSLog(@"New Image is Downloading");
                        [HelperMethods downloadSingleImageFromBaseURL:SCHOOL_LOGO_PATH withFilename:[NSString stringWithFormat:@"%@",[self. mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME]] saveToDisk:YES replaceExistingImage:YES];
                        
                        
                        //}

                    }

                    
                    self.isLoadDataComplete = YES;
                    
                    
                    
                    
                }
            });
            
        }
        else if([dataArray count] == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Server Unreachable" message:@"Check your internet connection, and make sure Intercom is allowed a data connection on your device.  Close the app and try again, if the problem persists please contact support@myschoolintercom.com" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                alert.tag = zAlertFailedConnection;
                [alert show];
                self.loadingIndicatorView.hidden = true;
            });
        }
    });

}

- (void)checkVerifyStatus
{
    dispatch_queue_t createQueue = dispatch_queue_create("checkStatus", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.introData checkAccountStatusofUserID:self.mainUserData.userID ofSchool:self.mainUserData.schoolIDselected];
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
                    
                    self.mainUserData.isPendingVerification = [[tempDic objectForKey:IS_PENDING_APPROVAL] boolValue];
                    self.mainUserData.isApproved = [[tempDic objectForKey:USER_APPROVED]boolValue];
                    
                    if (!self.mainUserData.isPendingVerification && self.mainUserData.isApproved)
                    {
                        [self checkForValidUser];
                    }
                    else if(!self.mainUserData.isPendingVerification && !self.mainUserData.isApproved )
                    {
                        if([tempDic objectForKey:VQ_MESSAGE] != (id)[NSNull null])
                            [self showDeniedAlertWithMessage:[tempDic objectForKey:VQ_MESSAGE]];
                        else
                            [self showDeniedAlertWithMessage:@""];
                    }
                    else
                        [self showNotApprovedAlert];
                }
            });
            
        }
    });

}

- (void)showDeniedAlertWithMessage:(NSString *)message
{
    if([message length] < 2)
    {
        message = @"Your access has been denied at this time, please contact the school for more information";
    }
    
    self.notApprovedAlert = [[UIAlertView alloc] initWithTitle:@"Access Denied" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [self.notApprovedAlert show];
}

- (void)showNotApprovedAlert
{
    self.notApprovedAlert = [[UIAlertView alloc]initWithTitle:@"Approval" message:@"Your Account is still under review from the school, open the app to check your status again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [self.notApprovedAlert show];
}

- (void)showNoAccountAlert
{
    
    if(!self.bypassNoAccountAlert)
    {
        self.noAccountAlert = [[UIAlertView alloc]initWithTitle:@"Create an Intercom Account or Restore/Login to an Existing Account." message:Nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"New User", @"Restore Purchases", @"Login", @"Try Demo School", nil];
        self.noAccountAlert.tag = zAlertNoUser;
    
        [self.noAccountAlert show];
    }
    else
    {
        self.bypassNoAccountAlert = false;
    }
}

- (void)showNoActiveSchoolsAlert
{
    
    self.noActiveSchoolsAlert = [[UIAlertView alloc]initWithTitle:@"No Active Schools" message:@"To gain access to this school you need to complete the In-App Purchase, please close the app and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [self.noActiveSchoolsAlert show];
}

- (void)showRestorePurchasedFailedAlert
{
    
    self.productPurchasedFailedAlert = [[UIAlertView alloc]initWithTitle:@"Restore Failed" message:@"Unable to restore purchase, Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [self.productPurchasedFailedAlert show];
}

- (void)showProductPurchasedFailedAlert
{
    
    self.productPurchasedFailedAlert = [[UIAlertView alloc]initWithTitle:@"Purchased Failed" message:@"Unable to complete purchase, Try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [self.productPurchasedFailedAlert show];
}


- (void)buyProduct
{
    
    if(_products)
    {
        
        for (SKProduct * product in _products)
        {
            if([product.productIdentifier isEqualToString:self.mainUserData.schoolIDselected])
            {
                self.isPurchaseInProgress = true;
                [[SchoolIntercomIAPHelper sharedInstance] buyProduct:product];
                //break;
            }
        }
    }
    else
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkForValidUser) userInfo:nil repeats:NO];
       
    }
}

- (void)checkForValidUser
{
    
    if (self.mainUserData.isAccountCreated && self.mainUserData.isApproved)
    {
        //Take this line of code out once tutorials are complete
        [self.mainUserData turnOffTutorial];
        
        self.switchSchoolsButton.hidden = YES;
        [self loadData];
        [self updateTeacherNames];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showHomeScreen) userInfo:nil repeats:NO];

        /*
        if(self.mainUserData.hasPurchased)
        {
            self.switchSchoolsButton.hidden = YES;
            [self loadData];
        
          self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(showHomeScreen) userInfo:nil repeats:NO];
        }
        else
        {
            if (!self.isPurchaseInProgress && !self.mainUserData.isDemoInUse)
            {
                self.isPurchaseInProgress = true;
                UIAlertView *approvedAlert = [[UIAlertView  alloc] initWithTitle:@"Approved!" message:[NSString stringWithFormat:@"Your account has been approved you may now purchase your access to %@ for $9.99", [self.mainUserData.schoolData objectForKey:SCHOOL_NAME]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
                approvedAlert.tag = zAlertApproved;
                [approvedAlert show];
            }
        
        }
         */
    }
    else if (!self.mainUserData.isAccountCreated)
    {
        [self showNoAccountAlert];
    }
    else if (self.mainUserData.isAccountCreated && !self.mainUserData.isDemoInUse)
    {
        //check the database to see if the users Registered status has changed
        [self checkVerifyStatus];
        self.logoutButton.hidden = false;
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

- (void)appWillEnterForeground
{
    [self.productPurchasedFailedAlert dismissWithClickedButtonIndex:0 animated:NO];
    [self checkToEnablePurchases];
    if (self.isInAppPurchaseEnabled)
    {
        UIAlertView *inAppPurchaseWarningAlert = [[UIAlertView alloc] initWithTitle:@"WARNING PLEASE READ!!" message:@"The In-App purchase feature is enabled, for this to work correctly during testing you must use the sandbox account that was created for you. \n-Exit this app               \n-Goto Settings->iTunes & App Store \n-Signout of your real account       \n\nCome back to this app and when you make an In-App purchase enter your sandbox details in the following format\n\nUSERNAME = lastname + firstname@msi.com\n ex... RumpleRandy@msi.com\n\n PASSWORD = Testapp123" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        
        inAppPurchaseWarningAlert.tag = zAlertInAppPurchaseEnabledAlert;
        //[inAppPurchaseWarningAlert show];
        //if(!self.mainUserData.isAccountCreated)
            [self checkForValidUser];
    }
    else
    {
        self.mainUserData.hasPurchased = true;
        [self checkForValidUser];
        
    }

}

- (void)checkToEnablePurchases
{
    
   
    
    if ([[self.mainUserData.userInfo objectForKey:USER_LAST_NAME] isEqualToString:@"IAP"])
    {
        self.isInAppPurchaseEnabled = true;
        self.warningViewed = false;
        
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginViaRestore = false;
    self.bypassToCreateAccount = false;
    self.bypassNoAccountAlert = false;
    
    
    
    //put ADs in Test mode
    self.mainUserData.isAdTestMode = false;
    
    //hash tester
    //NSLog(@"%@", [HelperMethods encryptText:@"tester"]);
    
    self.versionLabel.text = [NSString stringWithFormat:@"V%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
       
    [HelperMethods listFileAtPath:docDir];
    
    _products = nil;
    
    [[SchoolIntercomIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
     {
         if(success)
         {
             _products = products;
             
         }
         
     }];

    self.isInAppPurchaseEnabled = true;
    self.warningViewed = false;
    self.isPurchaseInProgress = false;
    
    //[self checkToEnablePurchases];
    
    self.defaultBackgroundColor = self.micImageView.backgroundColor;
    
    [self.loadingIndicatorView.layer setCornerRadius:30.0f];
    [self.loadingIndicatorView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.loadingIndicatorView.layer setBorderWidth:1.5f];
    [self.loadingIndicatorView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.loadingIndicatorView.layer setShadowOpacity:0.8];
    [self.loadingIndicatorView.layer setShadowRadius:3.0];
    [self.loadingIndicatorView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    //NSLog(@"SCHOOL DATA--- %@", self.mainUserData.schoolData);
    
    
    
    if(self.view.frame.size.height == 736 && self.view.frame.size.width == 414)
    {
        self.bottomConstraint.constant += 48;
        
        [self.view setNeedsUpdateConstraints];
        
    }
    
   
    
   
    
}

- (void)updateHasPurchasedInDatabaseWithTransactionID:(NSString *)transactionID
{
    dispatch_queue_t createQueue = dispatch_queue_create("updateHasPurchased", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.introData updateHasPurchasedinUserSchoolTable:self.mainUserData.userID ofSchool:self.mainUserData.schoolIDselected hasPurchasedBOOL:[[NSUserDefaults standardUserDefaults]objectForKey:USER_HAS_PURCHASED]withTransactionID:transactionID];
                     
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
                    //Take this line of code out once tutorials are complete
                    [self.mainUserData turnOffTutorial];
                    
                    [self checkForValidUser];
                }
            });
            
        }
    });

}

- (void)updateDeviceInfo
{
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    //NSLog(@"%@", iosVersion);
    NSString *deviceModel = [HelperMethods getDeviceModel];
    //NSLog(@"%@", deviceModel);
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:ACCOUNT_CREATED]boolValue])
    {
        RegistrationModel *registerData = [[RegistrationModel alloc]init];
        
        dispatch_queue_t createQueue = dispatch_queue_create("updateIOSVersion", NULL);
        dispatch_async(createQueue, ^{
            NSArray *dataArray;
            dataArray = [registerData updateUserVersionAndModelUserID:[[NSUserDefaults standardUserDefaults]objectForKey:USER_ID] withVersion:iosVersion andModel:deviceModel andAppVersion:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
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
    }
}

- (void)getUserEmailFromDatabase
{
    NSArray *transactionIDs = [self.restoredSchools allValues];
    
    dispatch_queue_t createQueue = dispatch_queue_create("getUserEmail", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.introData getUserInfofromTransactionID:[transactionIDs objectAtIndex:0]];
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
                    __block int matchCount = 0;
                    
                    for (NSDictionary *tempSchoolData in [tempDic objectForKey:SCHOOL_DATA])
                    {
                        [self.restoredSchools enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                         {
                             if ([[tempSchoolData objectForKey:US_TRANSACTION_ID] isEqualToString:obj] && [[tempSchoolData objectForKey:ID]isEqualToString:key])
                             {
                                 matchCount++;
                                 [self.existingUserData setValue:[tempSchoolData objectForKey:USER_EMAIL] forKey:USER_EMAIL];
                                 NSString *schoolName = [tempSchoolData objectForKey:SCHOOL_NAME];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     UIAlertView * restoredAlert = [[UIAlertView alloc]initWithTitle:@"Access Restored" message:[NSString stringWithFormat:@"Your access to %@, has been restored", schoolName] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                     //restoredAlert.tag = zAlertProductedRestored;
                                     [restoredAlert show];
                                 });
                             
                             }
                         }];
                        
                    }
                    
                    if (matchCount == [self.restoredSchools count])
                    {
                        self.loginViaRestore = true;
                        [self loginExistingUser];
                    }
                }
            });
            
        }
    });

}

- (void)restoreComplete:(NSNotification *)notification
{
   // NSLog(@"%lu", (unsigned long)[self.restoredSchools count]);
    
    [self getUserEmailFromDatabase];
}

- (void)restoreComplete
{
    if (self.numberOfSchoolsRestored == 0)
    {
        UIAlertView *restoreFailed = [[UIAlertView alloc]initWithTitle:@"Restore Failed" message:@"The apple ID used has no purchases to restore. Try again using the apple ID you used for the original purchase" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        restoreFailed.tag = zAlertRestoreFailed;
        [restoreFailed show];
        
        
    }

}

- (void)restorePurchaseFailed
{
    self.isPurchaseInProgress = false;
    self.loadingIndicatorView.hidden = true;
    self.loadingActivityIndicatorLabel.text = @"Purchasing...";
    
    [self.loadingActivityIndicator stopAnimating];
    [self showRestorePurchasedFailedAlert];
}


- (void)productPurchaseFailed
{
    self.isPurchaseInProgress = false;
    self.loadingIndicatorView.hidden = true;
    self.loadingActivityIndicatorLabel.text = @"Purchasing...";
    
    [self.loadingActivityIndicator stopAnimating];
    [self showProductPurchasedFailedAlert];
}

- (void)productRestored:(NSNotification *)notification
{
    
    
    SKPaymentTransaction *transaction = notification.object;
    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSString *transactionIdentifier = transaction.transactionIdentifier;
    //NSLog(@"%@ restored", productIdentifier);
    
    [self.restoredSchools setObject:transactionIdentifier forKey:productIdentifier];
    
    /*NSString *schoolName = [self.mainUserData getSchoolNameFromID:notification.object];
    
    UIAlertView * restoredAlert = [[UIAlertView alloc]initWithTitle:@"Access Restored" message:[NSString stringWithFormat:@"Your access to %@, has been restored", schoolName] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    restoredAlert.tag = zAlertProductedRestored;
    [restoredAlert show];
     */
}

- (void)createAccountOnNextLoad
{
    self.bypassToCreateAccount = true;
}

- (void)productPurchased:(NSNotification *)notification
{
    
    self.isPurchaseInProgress = false;
    SKPaymentTransaction *transaction = notification.object;
    NSString *productIdentifier = transaction.payment.productIdentifier;
    [self.loadingIndicatorView setHidden:true];
    [self.loadingActivityIndicator stopAnimating];
    if([productIdentifier isEqualToString:self.mainUserData.schoolIDselected])
    {
         self.purchseSuccess = [[UIAlertView alloc]initWithTitle:@"Purchase Successful" message:@"Loading School Data..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [self.purchseSuccess show];
        self.mainUserData.hasPurchased = true;
        
        [self updateHasPurchasedInDatabaseWithTransactionID:transaction.transactionIdentifier];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.introLabel setTextColor:[UIColor whiteColor]];
    self.introLabel.text = @"School Intercom";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createAccountOnNextLoad) name:@"LogOutNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginUser:) name:@"LOGIN_USER" object:nil];
        
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
        RVC.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_MAIN_MENU])
    {
        MainNavigationController *MNC = segue.destinationViewController;
        
        MNC.isFirstLoad = YES;
        MNC.mainUserData = self.mainUserData;
        
        
        [self.purchseSuccess dismissWithClickedButtonIndex:0 animated:YES];
        
    }
    else if([segue.identifier isEqualToString:@"switchSchoolsSegue"])
    {
        SwitchViewController *SVC = segue.destinationViewController;
        
        SVC.mainUserData = self.mainUserData;
    }
}


- (void)downloadImages
{
    [HelperMethods downloadAndSaveImagesToDiskWithFilename:[self.mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME]];
}

- (void)restoreAccount
{
    self.numberOfSchoolsRestored = 0;
    [[SchoolIntercomIAPHelper sharedInstance] restoreCompletedTransactions];

}

- (void)loginUser:(NSNotification *)notification
{
    self.bypassNoAccountAlert = true;
   
    
    NSString *email = notification.object;
    self.loginViaRestore = true;
    [self.existingUserData setValue:email forKey:USER_EMAIL];
    [self.existingUserData setValue:[HelperMethods encryptText:@"demoaccount0828" ]forKey:USER_PASSWORD];
    
    [self loginExistingUser];
    
    
}

- (void)loginToDemoAccount
{
    
    [self.existingUserData setValue:@"demo@brickhouseapps.com"forKey:USER_EMAIL];
    [self.existingUserData setValue:[HelperMethods encryptText:@"demoaccount0828" ]forKey:USER_PASSWORD];
    
    [self loginExistingUser];
}

- (void)restorePurchases
{
    UIAlertView *startRestore = [[UIAlertView alloc]initWithTitle:@"Restore Purchases" message:@"Would you like to restore your In-App Purchases" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    startRestore.tag = zAlertStartRestore;
    [startRestore show];
    
    
}

- (void)finishLogin:(NSDictionary *)tempDic
{

    //turn is back on for Live version
    //if(self.mainUserData.isAdmin)
       [self.mainUserData turnOffTutorial];
    
    
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setObject:[tempDic objectForKey:USER_FIRST_NAME] forKey:USER_FIRST_NAME];
    [userInfo setObject:[tempDic objectForKey:USER_LAST_NAME] forKey:USER_LAST_NAME];
    [userInfo setObject:[tempDic objectForKey:USER_EMAIL] forKey:USER_EMAIL];
    [userInfo setObject:[tempDic objectForKey:@"prefix"] forKey:@"prefix"];
    
    self.mainUserData.accountType = [tempDic objectForKey:USER_ACCOUNT_TYPE];
    
    if(self.mainUserData.accountType.intValue > 0 && self.mainUserData.accountType.intValue < 4)
        [userInfo setObject:[tempDic objectForKey:@"worksAtSchoolID"] forKey:@"worksAtSchoolID"];
    
    
    self.mainUserData.userInfo = userInfo;
    
    self.mainUserData.userID = [tempDic objectForKey:USER_ID];
   
    
    if([self.mainUserData.accountType intValue] == 1)
    {
        self.mainUserData.classData = [tempDic objectForKey:@"classData"];
        //NSLog(@"%@", self.mainUserData.classData);
    }
    
    /*
    for(NSDictionary *userClassData in [tempDic objectForKey:@"usersClassData"])
    {
        [self.mainUserData addUserClass:userClassData];
    }*/
    
    /*
    if([self.mainUserData.accountType intValue] > 0)
        [self.mainUserData addTeacherName:@{ID:self.mainUserData.userID, TEACHER_NAME:[NSString stringWithFormat:@"%@ %@",[self.mainUserData.userInfo objectForKey:@"prefix"], [self.mainUserData.userInfo objectForKey:USER_LAST_NAME]]}];
    */
    
    if([[tempDic objectForKey:NUMBER_OF_SCHOOLS] integerValue] > 0)
    {
        
        
        for(NSDictionary *schoolData in [tempDic objectForKey:@"schoolData"])
        {
            [self.mainUserData addschoolDataToArray:schoolData];
            
        }
        
       /* for(NSDictionary *teacherData in [tempDic objectForKey:@"teacherNames"])
        {
            [self.mainUserData addTeacherName:teacherData];
        }
        */
        
        [self.mainUserData addSchoolIDsFromArray:[tempDic objectForKey:@"schoolIDs"]];
        
        [self.mainUserData setActiveSchool:[[[tempDic objectForKey:@"schoolData"]objectAtIndex:0]objectForKey:ID]];
        
        [HelperMethods downloadSingleImageFromBaseURL:SCHOOL_LOGO_PATH withFilename:[NSString stringWithFormat:@"%@",[self.mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME]] saveToDisk:YES replaceExistingImage:NO];
        
        
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:USER_PUSH_NOTIFICATION_PIN];
        
        
        if(deviceToken && !self.mainUserData.isDemoInUse)
        {
            dispatch_queue_t createQueue = dispatch_queue_create("updatePin", NULL);
            dispatch_async(createQueue, ^{
                RegistrationModel *registerModel = [[RegistrationModel alloc]init];
                NSArray *dataArray;
                dataArray = [registerModel updateUserPushNotificationPinForUserID:self.mainUserData.userID withPin:deviceToken];
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
                            if(self.isInAppPurchaseEnabled)
                            {
                                if(self.mainUserData.isDemoInUse)
                                {
                                    [self setBackgroundImage];
                                    
                                    [self checkForValidUser];
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
                                    
                                    
                                    [self setBackgroundImage];
                                    
                                    [self checkForValidUser];
                                    
                                }
                                //else if(self.mainUserData.hasPurchased)
                                //[self restorePurchases];
                                
                            }
                            /*
                             else
                             {
                             self.mainUserData.hasPurchased = true;
                             
                             [self updateHasPurchasedInDatabaseWithTransactionID:@"temp"];
                             
                             
                             }*/
                        }
                    });
                    
                }
            });
            
        }
        else
        {
            
                if(self.mainUserData.isDemoInUse)
                {
                    self.mainUserData.isApproved = YES;
                    [self setBackgroundImage];
                    
                    [self checkForValidUser];
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
                    
                    
                    [self setBackgroundImage];
                    
                    [self checkForValidUser];
                    
                }
                //else if(self.mainUserData.hasPurchased)
                //[self restorePurchases];
            
            /*
             else
             {
             self.mainUserData.hasPurchased = true;
             
             [self updateHasPurchasedInDatabaseWithTransactionID:@"temp"];
             
             }
             */
        }
        
        
        
    }

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
                    
                    self.isUpdateTeachersComplete = YES;
                    
                    
                }
            });
            
        }
    });
    
}

- (void)loginExistingUser
{
    
    
    
    dispatch_queue_t createQueue = dispatch_queue_create("loginExistingUser", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.introData loginExistingUserWithEmail:[self.existingUserData objectForKey:USER_EMAIL] andPassword:[self.existingUserData objectForKey:USER_PASSWORD] andIsRestoring:[NSString stringWithFormat:@"%i", self.loginViaRestore]];
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
                    
                    [self finishLogin:tempDic];
                }
            });
            
        }
    });

}



- (void)recoverPasswordForEmail:(NSString *)email
{
    if ([HelperMethods isEmailValid:email])
    {
        dispatch_queue_t createQueue = dispatch_queue_create("resetPassword", NULL);
        dispatch_async(createQueue, ^{
            NSArray *dataArray;
            dataArray = [self.introData resetPasswordForEmail:email];
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
                        self.mainUserData.wasPasswordReset = YES;
                        UIAlertView *passwordChangeSuccessAlert = [[UIAlertView alloc]initWithTitle:@"Password Reset" message:@"An email has been sent with further instructions on how to reset your password." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        
                        passwordChangeSuccessAlert.tag = zAlertPasswordChangeSuccess;
                        
                        [passwordChangeSuccessAlert show];
                        
                        
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

- (void)showExistingAccountAlert
{
     self.existingAccountAlert = [[UIAlertView alloc]initWithTitle:@"Login" message:@"Enter your email address and password to login." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok", @"Forgot Password", nil];
    [self.existingAccountAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    self.existingAccountAlert.tag = zAlertEnterEmail;
    UITextField *emailField = [self.existingAccountAlert textFieldAtIndex:0];
    emailField.placeholder = @"Email";
    emailField.delegate = self;
    emailField.tag = zTextFieldEmail;
    emailField.keyboardType = UIKeyboardTypeEmailAddress;
    
    UITextField *passwordField = [self.existingAccountAlert textFieldAtIndex:1];
    passwordField.placeholder = @"Password";
    passwordField.delegate = self;
    passwordField.tag = zTextFieldPin;
    passwordField.keyboardType = UIKeyboardTypeAlphabet;
    
    
    [self.existingAccountAlert show];
}

- (void)checkForAuthenticationType
{
    LAContext *context = [[LAContext alloc]init];
    
    NSError *error = nil;
    
    if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error])
    {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Authenticate using Touch ID?"
                          reply:^(BOOL success, NSError *error) {
                              
                              if (error.code == LAErrorUserFallback || error.code == LAErrorUserCancel) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self showExistingAccountAlert];
                                  });
                                  
                                  
                                    return;
                              }
                              else if (error.code == LAErrorAuthenticationFailed)
                              {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                      message:@"Authentication Failed!"
                                                                                     delegate:self
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles:nil];
                                      alert.tag = zAlertTouchIDFailed;
                                      [alert show];
                                      
                                  });
                                  return;

                              }
                              else if (error)
                              {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                      message:@"There was a problem using Touch ID!"
                                                                                     delegate:self
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles:nil];
                                      alert.tag = zAlertTouchIDFailed;
                                      [alert show];

                                  });
                                  return;

                                  
                              }
                              dispatch_async(dispatch_get_main_queue(), ^{
                              if (success) {
                                  
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                                      message:@"You are the device owner!"
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                      
                                  } else {
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                      message:@"Authentication Failed!"
                                                                                     delegate:self
                                                                            cancelButtonTitle:@"Ok"
                                                                            otherButtonTitles:nil];
                                      alert.tag = zAlertTouchIDFailed;
                                      [alert show];
                                  }

                                  });

                                  
                          }];

    }
    else
    {
        [self showExistingAccountAlert];
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
            
            self.numberOfSchoolsRestored = 0;
            [[SchoolIntercomIAPHelper sharedInstance] restoreCompletedTransactions];
            //[self showExistingAccountAlert];
        }
        else if (buttonIndex == zAlertButtonAdminLogin)
        {
            [self showExistingAccountAlert];
        }
        else if (buttonIndex == zAlertButtonTryDemo)
        {
            //[Flurry logEvent:@"Demo_School_Loaded"];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Demo School"
                                                                  action:@"Demo_School_Logged_Into"
                                                                   label:@"Demo School"
                                                                   value:@1] build]];
            self.mainUserData.isAccountCreated = YES;
            self.mainUserData.isPendingVerification = NO;
                
            self.mainUserData.isDemoInUse = YES;
            [self loginToDemoAccount];
        }
    }
    else if (alertView.tag == zAlertEnterEmail)
    {
        if(buttonIndex == 1)
        {
            [self.existingUserData setValue:[[alertView textFieldAtIndex:0]text] forKey:USER_EMAIL];
            [self.existingUserData setValue:[HelperMethods encryptText:[[alertView textFieldAtIndex:1]text]] forKey:USER_PASSWORD];
            //self.mainUserData.isAdmin = true;
            [self loginExistingUser];
           

        }else if(buttonIndex == 2)
        {
            UIAlertView *forgotPasswordAlert = [[UIAlertView alloc]initWithTitle:@"Forgot Password" message:@"A new password will be emailed to you shortly" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK",  nil];
            [forgotPasswordAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            forgotPasswordAlert.tag = zAlertForgotPassword;
            UITextField *emailField = [forgotPasswordAlert textFieldAtIndex:0];
            emailField.placeholder = @"Email";
            emailField.delegate = self;
            emailField.tag = zTextFieldEmail;
            emailField.keyboardType = UIKeyboardTypeEmailAddress;
            if([[alertView textFieldAtIndex:0]text])
                emailField.text = [[alertView textFieldAtIndex:0]text];
            
            [forgotPasswordAlert show];
        }
        else
            [self checkForValidUser];
        
    }
    else if (alertView.tag == zAlertExistingUserIncorrectPassword)
    {
        [self showNoAccountAlert];
    }
    else if (alertView.tag == zAlertForgotPassword)
    {
        if(buttonIndex == 0)
        {
            [self showExistingAccountAlert];
        }
        else if(buttonIndex == 1)
        {
            [self recoverPasswordForEmail:[[alertView textFieldAtIndex:0]text]];
        }
    }
    else if (alertView.tag == zAlertInAppPurchaseEnabledAlert)
    {
        if(buttonIndex == 0)
        {
            self.warningViewed = true;
            [self checkForValidUser];
        }
    }
    else if (alertView.tag == zAlertApproved)
    {
        if(buttonIndex == 1)
        {
            [self.loadingIndicatorView setHidden:false];
            [self.loadingActivityIndicator startAnimating];
            [self buyProduct];
        }
        else
        {
            self.isPurchaseInProgress = false;
            if([self.mainUserData getNumberOfSchools] == 1)
            {
                [self showNoActiveSchoolsAlert];
            }
        }
        
    }
    else if (alertView.tag == zAlertStartRestore)
    {
        if(buttonIndex == 1)
        {
            [[SchoolIntercomIAPHelper sharedInstance] restoreCompletedTransactions];
        }
        else
        {
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            [self.mainUserData clearAllData];
            [self checkForValidUser];
        }
    }
    else if (alertView.tag == zAlertProductedRestored)
    {
        self.numberOfSchoolsRestored++;
        if(self.numberOfSchoolsRestored == [self.mainUserData getNumberOfSchools])
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
            
            
            [self setBackgroundImage];
            
            [self checkForValidUser];
        }

    
    }
    else if (alertView.tag == zAlertRestoreFailed)
    {
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [self.mainUserData clearAllData];
        [self checkForValidUser];

    }
    else if (alertView.tag == zAlertTouchIDFailed)
    {
        [self showExistingAccountAlert];
    }
    else if (alertView.tag == zAlertPasswordChangeSuccess)
    {
        [self showExistingAccountAlert];
    }
    else if(alertView.tag == zAlertFailedConnection)
    {
        
    }
}



- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag == zAlertEnterEmail)
    {
        if([[[alertView textFieldAtIndex:0]text]length] == 0)
            return NO;
        
        else if([HelperMethods isEmailValid:[[alertView textFieldAtIndex:0] text]])
            return YES;
        else
            return NO;
    }
    else
        return YES;
}


@end
