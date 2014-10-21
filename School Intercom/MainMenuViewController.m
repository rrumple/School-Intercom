//
//  MainMenuViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "MainMenuViewController.h"
#import <QuartzCore/QuartzCore.h>

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
@property (weak, nonatomic) IBOutlet UIButton *updateAppButton;
@property (weak, nonatomic) IBOutlet UILabel *switchSchoolBadge;
@end

@implementation MainMenuViewController

- (IntroModel *)introData
{
    if (!_introData) _introData = [[IntroModel alloc]init];
    return  _introData;
}

- (void)appHasGoneInBackground
{
    NSLog(@"APP WENT IN BACKGROUND");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popToRootViewControllerAnimated:NO];
    self.reloadData = true;
    self.isFirstLoad = true;
}

- (void)appWillEnterForeground
{
    [self loadData];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}



- (void)viewDidLoad
{

    [super viewDidLoad];
    
    
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
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
                        
                         
                        /* if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
                         {
                             NSLog(@"Image Still exists");
                         }
                         else
                         {*/
                             NSLog(@"New Image is Downloading");
                             [HelperMethods downloadSingleImageFromBaseURL:SCHOOL_LOGO_PATH withFilename:[NSString stringWithFormat:@"%@",[self. mainUserData.schoolData objectForKey:SCHOOL_IMAGE_NAME]] saveToDisk:YES replaceExistingImage:NO];
                             
                            
                         //}

                     }
                    
                    NSLog(@"%@", self.mainUserData.schoolData);
                    
                    //self.isLoadDataComplete = YES;
                    self.reloadData = false;
                    self.isFirstLoad = false;
                    
                    
                    
                    HomeViewController *HVC;
                    
                    for(UIViewController *vc in self.navigationController.childViewControllers)
                    {
                        if([vc isKindOfClass:[HomeViewController class]])
                        {
                            HVC = (HomeViewController *)vc;
                        }
                    }
                    
                    HVC.mainUserData = self.mainUserData;
                    
                    
                }
            });
            
        }
    });
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.switchSchoolBadge.alpha = 0;
    
    self.headerFont = self.rootFont.font;
    
    if(self.mainUserData.isDemoInUse)
    {
        [self.switchSchoolButton setTitle:@"Exit Demo" forState:UIControlStateNormal];
        [self.switchSchoolButton setHidden:false];
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
    
    if(![[self.mainUserData.schoolData objectForKey:SCHOOL_LUNCH] isEqualToString:@"None"])
        [self.lunchMenuButton setHidden:false];
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:IS_APP_UP_TO_DATE]);
    if (![[NSUserDefaults standardUserDefaults] objectForKey:IS_APP_UP_TO_DATE] || [[[NSUserDefaults standardUserDefaults] objectForKey:IS_APP_UP_TO_DATE]boolValue])
        self.updateAppButton.hidden = YES;
    else
        self.updateAppButton.hidden = NO;
    
    
    
    if(self.reloadData)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

        [self loadData];
    }
    
    if(self.isFirstLoad)
    {
        [self performSegueWithIdentifier:SEGUE_TO_HOME_VIEW sender:self];
        self.isFirstLoad = NO;
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
         NSLog(@"Animation Completed");
     }];
    
    
   
    
    NSLog(@"%@", self.navigationController.parentViewController);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)snapshotOfViewAsImage:(UIImage *)image
{
    self.screenShotView.image = image;
    
}
- (IBAction)updateSchoolButtonPressed
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=917103099&mt=8"]];
    //Make sure to change this link to the app store
}

- (void)exitOutOfSchool
{
    [self.delegate signOut];
}
- (IBAction)switchSchoolsButtonPressed:(UIButton *)sender
{
   if ([sender.titleLabel.text isEqualToString:@"Exit Demo"])
   {
    
       NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
       [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
       [[NSURLCache sharedURLCache] removeAllCachedResponses];
       [self.mainUserData clearAllData];
       [self.delegate signOut];
   }
   else
   {
        [self performSegueWithIdentifier:SEGUE_TO_SWITCH_VIEW sender:self];
   }
}

- (IBAction)calendarPressed
{
    self.lastViewSelected = mv_Calendar;
    CalendarMonthViewController *vc = [[CalendarMonthViewController alloc] initWithSunday:YES];
    vc.calendarData = [self.mainUserData.appData objectForKey:DIC_CALENDAR_DATA];
    vc.delegate = self;
    vc.backgroundColor = self.view.backgroundColor;
    vc.headerFont = self.headerFont;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_HOME_VIEW])
    {
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
        self.lastViewSelected = mv_News;
        NewsViewController *VC = segue.destinationViewController;
        VC.userID = self.mainUserData.userID;
        VC.newsData = [self.mainUserData.appData objectForKey:@"newsData"];
        VC.newsHeader = [self.mainUserData.schoolData objectForKey:SCHOOL_NEWS_HEADER];
        VC.schoolID = [self.mainUserData.schoolData objectForKey:ID];

        VC.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_CONTACT_VIEW])
    {
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
        self.lastViewSelected = mv_Settings;
        SettingsTableViewController *STVC = segue.destinationViewController;
        STVC.delegate = self;
        STVC.mainUserData = self.mainUserData;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_LUNCH_MENU_VIEW])
    {
        self.lastViewSelected = mv_LunchMenu;
        LunchMenuViewController *LMVC = segue.destinationViewController;
        LMVC.delegate = self;
        LMVC.mainUserData = self.mainUserData;
    }
}

@end
