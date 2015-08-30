//
//  MainMenuViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "MainMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AdminModel.h"


@interface MainMenuViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *screenShotView;
@property (nonatomic) BOOL reloadData;
@property (nonatomic, strong) IntroModel *introData;
@property (nonatomic) int lastViewSelected;
@property (weak, nonatomic) IBOutlet UILabel *rootFont;
@property (nonatomic, strong) UIFont *headerFont;
@property (weak, nonatomic) IBOutlet UIButton *switchSchoolButton;
@property (weak, nonatomic) IBOutlet UIButton *lunchMenuButton;
@property (nonatomic) BOOL signOut;

@property (weak, nonatomic) IBOutlet UILabel *switchSchoolBadge;
@property (nonatomic, strong) NSArray *calendarData;
@property (weak, nonatomic) IBOutlet UIButton *adminToolsButton;
@property (weak, nonatomic) IBOutlet UIButton *offerButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;

@property (nonatomic, strong) AdminModel *adminData;
@end

@implementation MainMenuViewController

- (AdminModel *)adminData
{
    if(!_adminData) _adminData = [[AdminModel alloc]init];
    return _adminData;
}

- (IntroModel *)introData
{
    if (!_introData) _introData = [[IntroModel alloc]init];
    return  _introData;
}

- (void)getTeacherClasses
{
    dispatch_queue_t createQueue = dispatch_queue_create("getAppData", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adminData getTeacherClasses:self.mainUserData.userID];
        if ([dataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [dataArray objectAtIndex:0];
                
                if([[tempDic objectForKey:@"error"] boolValue])
                {
                    
                    
                }
                else
                {
                    if([tempDic objectForKey:@"classData"] != (id)[NSNull null])
                    {
                        if([self.mainUserData.accountType intValue] == 1)
                        {
                            self.mainUserData.classData = [tempDic objectForKey:@"classData"];
                            //NSLog(@"%@", self.mainUserData.classData);
                        }

                    }
                    
                    
                }
            });
            
        }
        
    });

}

- (void)appHasGoneInBackground
{
    NSLog(@"APP WENT IN BACKGROUND");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutButtonPressed) name:@"LogOutNotification" object:nil];

    //[self.navigationController popToRootViewControllerAnimated:NO];
    //self.reloadData = true;
    //self.isFirstLoad = true;
}

- (void)appWillEnterForeground
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"LOAD_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTeacherClasses) name:@"GET_TEACHER_CLASSES" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:ADLoadDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self loadData];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
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

- (void)viewDidLoad
{
    
    if([self.mainUserData.teacherNames count] == 0)
    {
        [self updateTeacherNames];
    }
    

    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"LOAD_DATA" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTeacherClasses) name:@"GET_TEACHER_CLASSES" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:ADLoadDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutButtonPressed) name:@"LogOutNotification" object:nil];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(loadPreviousView)];
    
    [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    
    [self.screenShotView addGestureRecognizer:swipe];
    
    self.switchSchoolBadge.layer.cornerRadius = self.switchSchoolBadge.bounds.size.height / 2;
    self.switchSchoolBadge.layer.borderColor = [UIColor whiteColor].CGColor;
    self.switchSchoolBadge.layer.borderWidth = 1.0f;
    
    
    

}
- (IBAction)loadPreviousView
{
    switch (self.lastViewSelected)
    {
        case mv_Home:
            [self performSegueWithIdentifier:SEGUE_TO_HOME_VIEW sender:self];
            break;
        case mv_Calendar:
            [self calendarPressed];
            break;
        case mv_News:
            [self performSegueWithIdentifier:SEGUE_TO_NEWS_VIEW sender:self];
            break;
        case mv_Contact:
            [self performSegueWithIdentifier:SEGUE_TO_CONTACT_VIEW sender:self];
            break;
        case mv_Settings:
            [self performSegueWithIdentifier:SEGUE_TO_SETTINGS_VIEW sender:self];
            break;
        case mv_Switch:
            [self performSegueWithIdentifier:SEGUE_TO_SWITCH_VIEW sender:self];
            break;
        case mv_LunchMenu:
            [self performSegueWithIdentifier:SEGUE_TO_LUNCH_MENU_VIEW sender:self];
            break;
        case mv_AdminTools:
            [self performSegueWithIdentifier:SEGUE_TO_ADMIN_TOOLS sender:self];
            break;
        case mv_Offer:
            [self performSegueWithIdentifier:SEGUE_TO_OFFER sender:self];
            break;
            
    }
}

- (void)loadData
{
    
    
    
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
                       
                        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
                        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                        [[NSURLCache sharedURLCache] removeAllCachedResponses];
                        [self.mainUserData clearAllData];
                        [self.delegate signOut];
                    }

                    
                }
                else
                {
                    
                    self.mainUserData.appData = tempDic;
                    
                     if([tempDic objectForKey:SCHOOL_DATA] != (id)[NSNull null])
                     {
                         NSString *oldFileToDelete = [self.mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME];
                         [self.mainUserData updateSchoolDataInArray:[[tempDic objectForKey:SCHOOL_DATA]objectAtIndex:0]];
                         
                         NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                         
                         NSString *oldFilePath = [NSString stringWithFormat:@"%@/%@",docDir, oldFileToDelete];
                         NSError *error;
                         
                         [[NSFileManager defaultManager] removeItemAtPath:oldFilePath error:&error];
                         [[NSURLCache sharedURLCache] removeAllCachedResponses];
                        
                         [self updateTeacherNames];
                         
                        /* if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                         {
                             NSLog(@"Image Still exists");
                         }
                         else
                         {*/
                            // NSLog(@"New Image is Downloading");
                             [HelperMethods downloadSingleImageFromBaseURL:SCHOOL_LOGO_PATH withFilename:[NSString stringWithFormat:@"%@",[self. mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME]] saveToDisk:YES replaceExistingImage:NO];
                             
                            
                         //}

                     }
                    
                   // NSLog(@"%@", self.mainUserData.schoolData);
                    
                    //self.isLoadDataComplete = YES;
                    self.reloadData = false;
                    self.isFirstLoad = false;
                    
                    
                    
                    HomeViewController *HVC;
                    NewsViewController *NVC;
                    
                    for(UIViewController *vc in self.navigationController.childViewControllers)
                    {
                        if([vc isKindOfClass:[HomeViewController class]])
                        {
                            HVC = (HomeViewController *)vc;
                            HVC.mainUserData = self.mainUserData;
                        }
                        else if([vc isKindOfClass:[NewsViewController class]])
                        {
                            NVC = (NewsViewController *)vc;
                            NVC.newsData = self.mainUserData.newsData;
                        }
                    }
                    
                   
                    if([[tempDic objectForKey:@"systemMessages"]count] > 0)
                    {
                        for (NSDictionary *messageDic in [tempDic objectForKey:@"systemMessages"])
                        {
                            if([[messageDic objectForKey:@"systemMessage"] isEqualToString:@"99"])
                            {
                                NSString *email = [self.mainUserData.userInfo objectForKey:USER_EMAIL];
                                [self logOutButtonPressed];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN_USER" object:email userInfo:nil];
                                
                                dispatch_queue_t createQueue = dispatch_queue_create("deleteSystemMessage", NULL);
                                dispatch_async(createQueue, ^{
                                    NSArray *dataArray;
                                    dataArray = [self.introData systemMessageHandledDeleteFromDatabase:[messageDic objectForKey:ID]];
                                    });

                            }
                        }
                    }
                    
                    
                }
            });
            
        }
        else if([dataArray count] == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Server Unreachable" message:@"Check your internet connection, and make sure Intercom is allowed a data connection on your device.  Close the app and try again, if the problem persists please contact support@myschoolintercom.com" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                alert.tag = zAlertFailedConnection;
                [alert show];
            
            });
        }

    });
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Main_Menu_Screen"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    if([self.mainUserData.accountType intValue] == utGrandparent)
    {
        [self updateTeacherNames];
    }
    
    self.switchSchoolBadge.alpha = 0;
    
    self.headerFont = self.rootFont.font;
    
    if([self.mainUserData.accountType intValue] > 0 && [self.mainUserData.accountType intValue] < 8)
    {
        self.adminToolsButton.hidden = false;
        
    }
    
    if(![[self.mainUserData.schoolData objectForKey:SCHOOL_LUNCH] isEqualToString:@"None"])
    {
        [self.lunchMenuButton setTitle:@"Lunch Menu" forState:UIControlStateNormal];
        [self.lunchMenuButton setHidden:false];
    }
    
    if(self.mainUserData.isDemoInUse)
    {
        [self.logOutButton setTitle:@"Exit Demo" forState:UIControlStateNormal];

    }
    else if([self.mainUserData getNumberOfSchools] > 1)
    {
       [self.switchSchoolButton setHidden:false];
        
        if([[[NSUserDefaults standardUserDefaults]objectForKey:BADGE_COUNT]intValue] > 0)
        {
            if([[[NSUserDefaults standardUserDefaults]objectForKey:BADGE_COUNT]intValue] > 9)
            {
                self.switchSchoolBadge.text = @"9+";
            }
            else
                self.switchSchoolBadge.text = [[NSUserDefaults standardUserDefaults]objectForKey:BADGE_COUNT];
            
            [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
                self.switchSchoolBadge.alpha = 1.0;
            }completion:^(BOOL finished) {
                //
            }];

        }
        else
        {
            self.switchSchoolBadge.alpha = 0;
           
        }
    }
    else
    {
        [self.switchSchoolButton setHidden:true];
        CGRect rect = self.switchSchoolButton.frame;
        CGPoint center = self.switchSchoolButton.center;
        CGRect rect2 = self.lunchMenuButton.frame;
        CGPoint center2 = self.lunchMenuButton.center;
        
        self.switchSchoolButton.frame = rect2;
        self.switchSchoolButton.center = center2;
        self.lunchMenuButton.frame = rect;
        self.lunchMenuButton.center = center;
        
    }
    
    
    
    if(self.reloadData)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

        [self loadData];
    }
    

    if(!self.alertReceived)
    {
        if(self.mainUserData.alertReceived)
        {
            self.mainUserData.alertReceived = false;
            
            if(self.mainUserData.viewToLoad == mv_Home)
                [self performSegueWithIdentifier:SEGUE_TO_HOME_VIEW sender:self];
            else
                [self performSegueWithIdentifier:SEGUE_TO_NEWS_VIEW sender:self];
            self.mainUserData.viewToLoad = 999;
            self.isFirstLoad = NO;
            
            
        }
        else if(self.isFirstLoad)
        {
            [self performSegueWithIdentifier:SEGUE_TO_HOME_VIEW sender:self];
            self.isFirstLoad = NO;
        }
    }
    else
    {
        self.mainUserData.alertReceived = self.alertReceived;
        self.mainUserData.viewToLoad = self.viewToLoad;
        self.alertReceived = false;
        
        self.isFirstLoad = NO;
        
        if(self.viewToLoad == mv_Home)
            [self performSegueWithIdentifier:SEGUE_TO_HOME_VIEW sender:self];
        else
            [self performSegueWithIdentifier:SEGUE_TO_NEWS_VIEW sender:self];
        self.viewToLoad = 999;
        
        if(![self.mainUserData.schoolIDselected isEqualToString:self.schoolIDtoLoad])
        {
            if([self.mainUserData checkForASchoolIDMatch:self.schoolIDtoLoad])
            {
                [self.mainUserData setActiveSchool:self.schoolIDtoLoad];
            
                [self exitOutOfSchool];
            }
            else
            {
                self.mainUserData.alertReceived = NO;
                self.mainUserData.viewToLoad = 999;
            }
        }
    }
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         CGPoint point = self.screenShotView.center;
         point.x += 240;
         self.screenShotView.center = point;
     }completion:^(BOOL finished)
     {
         //NSLog(@"Animation Completed");
     }];
    
    
   
    
    //NSLog(@"%@", self.navigationController.parentViewController);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)snapshotOfViewAsImage:(UIImage *)image
{
    self.screenShotView.image = image;
    self.alertReceived = NO;
    self.viewToLoad = 999;
    self.screenShotView.hidden = false;
    
}

- (void)segueToOffer
{
    [self performSegueWithIdentifier:SEGUE_TO_OFFER sender:self];
}

- (IBAction)logOutButtonPressed
{
    if(!self.mainUserData.isDemoInUse)
    {
        dispatch_queue_t createQueue = dispatch_queue_create("logoutuser", NULL);
        dispatch_async(createQueue, ^{
            NSArray *dataArray;
            dataArray = [self.introData logOutUserInDatabase:self.mainUserData.userID];
            if ([dataArray count] == 1)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *tempDic = [dataArray objectAtIndex:0];
                    
                    if([[tempDic objectForKey:@"error"] boolValue])
                    {
                        [HelperMethods displayErrorUsingDictionary:tempDic withTag:zAlertExistingUserIncorrectPassword andDelegate:self];
                        
                        
                    }
                });
                
            }
        });
    }

    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self.mainUserData clearAllData];
    [self.delegate signOut];
    


}


- (void)exitOutOfSchool
{
    [self.delegate signOut];
}
- (IBAction)switchSchoolsButtonPressed:(UIButton *)sender
{
   
    [self performSegueWithIdentifier:SEGUE_TO_SWITCH_VIEW sender:self];
    
}
- (IBAction)adminButtonPressed
{
     [self performSegueWithIdentifier:SEGUE_TO_ADMIN_TOOLS sender:self];
}

- (IBAction)lunchButtonPressed:(UIButton *)sender
{
    if(self.mainUserData.hasPurchased)
        [self performSegueWithIdentifier:SEGUE_TO_LUNCH_MENU_VIEW sender:self];
    else
    {
        UIAlertView *suggestPurchase = [[UIAlertView alloc]initWithTitle:@"Premium Content" message:@"Viewing the Lunch Menu requires the one time purchase of the School Premium Pack, for more details select Premium Features." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Premium Features", nil];
        suggestPurchase.tag = zAlertSuggestPurchase;
        
        [suggestPurchase show];
        
    }

    
   

}


- (void)sortCalendar
{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    
    if([self.mainUserData.appData objectForKey:DIC_CALENDAR_DATA] != (id)[NSNull null])
    {
        [tempArray addObjectsFromArray:[self.mainUserData.appData objectForKey:DIC_CALENDAR_DATA]];
        
    }
    if([self.mainUserData.appData objectForKey:@"corpCalData"] != (id)[NSNull null])
    {
        [tempArray addObjectsFromArray:[self.mainUserData.appData objectForKey:@"corpCalData"]];
        
    }
    if([self.mainUserData.appData objectForKey:@"teacherCalData"] != (id)[NSNull null])
    {
        [tempArray addObjectsFromArray:[self.mainUserData.appData objectForKey:@"teacherCalData"]];
    }
    if([self.mainUserData.appData objectForKey:@"classCalendarData"] != (id)[NSNull null])
    {
        [tempArray addObjectsFromArray:[self.mainUserData.appData objectForKey:@"classCalendarData"]];
    }
    
    
    if(tempArray != (id)[NSNull null])
    {
        self.calendarData = tempArray;
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"calStartDate"  ascending:YES];
        self.calendarData=[self.calendarData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    }
    
    
}


- (IBAction)calendarPressed
{
    self.screenShotView.hidden = true;
     //[Flurry logEvent:@"CALENDAR_VIEWED"];
    [self sortCalendar];
    self.lastViewSelected = mv_Calendar;
    CalendarMonthViewController *vc = [[CalendarMonthViewController alloc] initWithSunday:YES];
    vc.calendarData = self.calendarData;
    vc.delegate = self;
    vc.backgroundColor = self.view.backgroundColor;
    vc.headerFont = self.headerFont;
    vc.mainUserData = self.mainUserData;
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.screenShotView.hidden = true;
    if([segue.identifier isEqualToString:SEGUE_TO_HOME_VIEW])
    {
        //[Flurry logEvent:@"ALERT_SCREEN_VIEWED"];
        self.lastViewSelected = mv_Home;
        HomeViewController *HVC = segue.destinationViewController;
        HVC.delegate = self;
        HVC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_CALENDAR_VIEW])
    {
        //CalendarViewController *CVC = segue.destinationViewController;
        //CVC.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_NEWS_VIEW])
    {
        //[Flurry logEvent:@"NEWS_SCREEN_VIEWED"];
        self.lastViewSelected = mv_News;
        NewsViewController *VC = segue.destinationViewController;
        VC.userID = self.mainUserData.userID;
        VC.newsData = self.mainUserData.newsData;
        VC.newsHeader = [self.mainUserData.schoolData objectForKey:SCHOOL_NEWS_HEADER];
        VC.schoolID = [self.mainUserData.schoolData objectForKey:ID];
        VC.mainUserData = self.mainUserData;

        VC.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_CONTACT_VIEW])
    {
         //[Flurry logEvent:@"CONTACT_SCREEN_VIEWED"];
        self.lastViewSelected = mv_Contact;
        ContactViewController *VC = segue.destinationViewController;
        VC.delegate = self;
        VC.schoolData = self.mainUserData.schoolData;
        VC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_SWITCH_VIEW])
    {
        self.lastViewSelected = mv_Switch;
        SwitchViewController *VC = segue.destinationViewController;
        VC.delegate = self;
        VC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_SETTINGS_VIEW])
    {
         //[Flurry logEvent:@"SETTINGS_SCREEN_VIEWED"];
        self.lastViewSelected = mv_Settings;
        SettingsTableViewController *STVC = segue.destinationViewController;
        STVC.delegate = self;
        STVC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_LUNCH_MENU_VIEW])
    {
         //[Flurry logEvent:@"LUNCH_MENU_VIEWED"];
        self.lastViewSelected = mv_LunchMenu;
        LunchMenuViewController *LMVC = segue.destinationViewController;
        LMVC.delegate = self;
        LMVC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_ADMIN_TOOLS])
    {
         //[Flurry logEvent:@"ADMIN_TOOLS_VIEWED"];
        self.lastViewSelected = mv_AdminTools;
        AdminToolsTableViewController *ATTVC = segue.destinationViewController;
        ATTVC.delegate = self;
        ATTVC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_OFFER])
    {
         //[Flurry logEvent:@"OFFER_SCREEN_VIEWED"];
        self.lastViewSelected = mv_Offer;
        OfferViewController *FVC = segue.destinationViewController;
        FVC.delegate = self;
        FVC.mainUserData = self.mainUserData;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == zAlertSuggestPurchase)
    {
        if(buttonIndex == 1)
        {
            //[Flurry logEvent:@"SEGUE_TO_OFFER_VIA_LUNCH_MENU"];
            [self performSegueWithIdentifier:SEGUE_TO_OFFER sender:self];
        }
    }
    
}

@end
