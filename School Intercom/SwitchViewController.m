//
//  SwitchViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "SwitchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UserData.h"
@import GoogleMobileAds;

@interface SwitchViewController () <UIAlertViewDelegate, GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UITableView *schoolListTableView;
@property (nonatomic, strong) NSArray *allSchools;
@property (nonatomic) NSInteger rowSelected;
@property (nonatomic, strong) UpdateProfileModel *updateProfileData;
@property (strong, nonatomic)  GADBannerView *adView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AdModel *adModel;
@property (nonatomic) BOOL viewDisappeared;

@end

@implementation SwitchViewController

- (AdModel *)adModel
{
    if(!_adModel) _adModel = [[AdModel alloc]init];
    return _adModel;
}

- (UpdateProfileModel *)updateProfileData
{
    if(!_updateProfileData) _updateProfileData = [[UpdateProfileModel alloc]init];
    return _updateProfileData;
}

- (NSArray *)allSchools
{
    if (!_allSchools) _allSchools = [self.mainUserData getAllofUsersSchools];
    return _allSchools;
}
- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"There was an error!");
    if(!self.mainUserData.isAdTestMode)
        [self.adModel updateMMAdFailedCountInDatabse:self.mainUserData.userID andSchoolID:self.mainUserData.schoolIDselected];
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
    if(!self.mainUserData.isAdTestMode)
        [self.adModel updateMMAdClickCountInDatabse:self.mainUserData.userID andSchoolID:self.mainUserData.schoolIDselected];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"adViewDidReceiveAd");
    if(self.mainUserData.isTimerExpired)
    {
        [self.view addSubview:self.adView];
        self.mainUserData.remainingCounts--;
        [UIView animateWithDuration:1 animations:^{
            bannerView.frame = CGRectMake(self.view.frame.size.width /2 - 160,
                                          self.view.frame.size.height -
                                          bannerView.frame.size.height,
                                          bannerView.frame.size.width,
                                          bannerView.frame.size.height);
            
        } completion:^(BOOL finished) {
            if(finished)
                [self startTimer];
        }];
        if(!self.mainUserData.isAdTestMode)
            [self.adModel updateMMAdImpCountInDatabse:self.mainUserData.userID andSchoolID:self.mainUserData.schoolIDselected];
        
    }
    
}

- (void)hideAd
{
    NSLog(@"Hide ad");
    [UIView animateWithDuration:1 animations:^{
        self.adView.frame = CGRectMake(self.view.frame.size.width /2 - 160,
                                       self.view.frame.size.height,
                                       self.adView.frame.size.width,
                                       self.adView.frame.size.height);
        
    }];
    
    
    
    
}


- (void)startTimer
{
    NSLog(@"Timer started");
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    self.mainUserData.isTimerExpired = false;
    
    
}

- (void)appWillEnterForeground
{
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPushAlert:) name:@"DisplayAlert" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
    [self startTimer];
}

- (void)appHasGoneInBackground
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.timer invalidate];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewDidLeaveApplication");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.timer invalidate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

        
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Switch_Schools_Screen"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
    if(![self.timer isValid] && self.viewDisappeared)
    {
        [self startTimer];
        self.viewDisappeared = false;
    }
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPushAlert:) name:@"DisplayAlert" object:nil];
    
    
}

- (void)showPushAlert:(NSNotification *)notification
{
    NSDictionary *data = [notification userInfo];
    
    [HelperMethods CreateAndDisplayOverHeadAlertInView:self.view withMessage:[data objectForKey:@"message"] andSchoolID:[data objectForKey:SCHOOL_ID]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewDisappearing");
    self.viewDisappeared = true;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
    [self.timer invalidate];
}

- (void)loadNewAd
{
    NSLog(@"New Ad Loaded...");
    
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @"59c997e06ef957f5f6c866b6fed1bb25", kGADSimulatorID ];
    [self.adView loadRequest:request];
    
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    [tempArray addObject:self.adView];
    self.mainUserData.adViewArray = tempArray;
    
}

- (void)countDown
{
    
    if(--self.mainUserData.remainingCounts == 0)
    {
        [self.timer invalidate];
        self.mainUserData.isTimerExpired = true;
        self.mainUserData.remainingCounts = AD_REFRESH_RATE;
        
        [self loadNewAd];
    }
    
    if(self.mainUserData.remainingCounts == AD_HIDE_TIME)
        [self hideAd];
    
    NSLog(@"%i", self.mainUserData.remainingCounts);
}

- (void)setUnitID
{
    if(self.mainUserData.accountType.intValue == 0 || self.mainUserData.accountType.intValue == 8)
    {
        if(self.mainUserData.isAdTestMode)
            self.adView.adUnitID = AD_MOB_TEST_UNIT_ID;
        else
            self.adView.adUnitID = [self.mainUserData.schoolData objectForKey:IPHONE_UNIT_ID];
    }
    else if(self.mainUserData.accountType.intValue > 0 && self.mainUserData.accountType.intValue < 5)
    {
        if(self.mainUserData.isAdTestMode)
            self.adView.adUnitID = AD_MOB_TEST_UNIT_ID;
        else
            self.adView.adUnitID = AD_MOB_TEACHER_UNIT_ID;
    }
    else
        self.adView.adUnitID = AD_MOB_TEST_UNIT_ID;
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.headerLabel setFont:FONT_CHARCOAL_CY(17.0f)];
    
    self.schoolListTableView.delegate = self;
    self.schoolListTableView.dataSource = self;
    
    //[self.mainUserData showAllSchoolsInNSLOG];
    
    self.adView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
    NSMutableArray *tempArray = [self.mainUserData getAd];
    
    NSLog(@"Check to see if get new ad or last used ad");
    if([tempArray count] == 1)
    {
        NSLog(@"last ad used");
        self.adView = (GADBannerView *)[tempArray objectAtIndex:0];
        [self startTimer];
        self.adView.rootViewController = self;
        self.schoolListTableView.frame = CGRectMake(self.schoolListTableView.frame.origin.x, self.schoolListTableView.frame.origin.y, self.view.frame.size.width, self.schoolListTableView.frame.size.height - self.adView.frame.size.height);
        [self.view addSubview:self.adView];
    }
    else
    {
         self.adView.frame = CGRectMake(self.view.frame.size.width/2 - 160, self.view.frame.size.height , 320,50);
        [self setUnitID];
        self.adView.rootViewController = self;
        
        [self loadNewAd];
    }
    
    
    self.adView.delegate = self;
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mainUserData getNumberOfSchools];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"switcherCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *cellLabel = (UILabel *)[tableView viewWithTag:2];
    cellLabel.text = [[self.allSchools objectAtIndex:indexPath.row]objectForKey:SCHOOL_NAME];
    //NSLog(@"%@", [[self.allSchools objectAtIndex:indexPath.row]objectForKey:BADGE_COUNT]);
    if([[[self.allSchools objectAtIndex:indexPath.row]objectForKey:BADGE_COUNT]intValue] > 0)
    {
        UILabel *badgeLabel = (UILabel *)[tableView viewWithTag:3];
        
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2;
        badgeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        badgeLabel.layer.borderWidth = 1.0f;
        
        if([[[self.allSchools objectAtIndex:indexPath.row]objectForKey:BADGE_COUNT]intValue] > 9)
        {
            badgeLabel.text = @"9+";
        }
        else
            badgeLabel.text = [[self.allSchools objectAtIndex:indexPath.row]objectForKey:BADGE_COUNT];
        
        [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            badgeLabel.alpha = 1.0;
        }completion:^(BOOL finished) {
            //
        }];


    }
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, [[self.allSchools objectAtIndex:indexPath.row] objectForKey:SCHOOL_IMAGE_NAME]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        
        
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
        
        
        imageView.image = image;
        
    }

    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.mainUserData setActiveSchool:[[self.allSchools objectAtIndex:indexPath.row]objectForKey:ID]];
    
    if([self.delegate respondsToSelector:@selector(exitOutOfSchool)])
    {
        [self.delegate exitOutOfSchool];
    }
    
    [self menuPressed];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([self.mainUserData.accountType intValue] > 0 && [self.mainUserData.accountType intValue] < 8)
        return NO;
    else
        return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete ) {
        
        UIAlertView * confirmDeleteAlert = [[UIAlertView alloc]initWithTitle:@"Remove School" message:@"Are you sure you want to remove this school?  To add this school later click Restore Purchases in\n Settings->Update Profile"   delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        confirmDeleteAlert.tag = zAlertConfirmRemoveSchool;
        self.rowSelected = indexPath.row;
        
        [confirmDeleteAlert show];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
   // else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertConfirmRemoveSchool)
    {
        if (buttonIndex == 1)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[[self.allSchools objectAtIndex:self.rowSelected]objectForKey:ID]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if([self.mainUserData removeSchoolFromPhone:[[self.allSchools objectAtIndex:self.rowSelected]objectForKey:ID]])
            {
                if([self.delegate respondsToSelector:@selector(exitOutOfSchool)])
                {
                    [self.delegate exitOutOfSchool];
                }
                
                [self menuPressed];
                
            }
            else
                [self.schoolListTableView reloadData];
            
            dispatch_queue_t createQueue = dispatch_queue_create("changeStatus", NULL);
            dispatch_async(createQueue, ^{
                NSArray *dataArray;
                dataArray = [self.updateProfileData changeSchoolStatusForUser:[[self.allSchools objectAtIndex:self.rowSelected]objectForKey:ID] ofUser:self.mainUserData.userID isActive:@"0"];
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
    }
}

@end
