//
//  NewsViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "NewsViewController.h"
#import "AdminToolsQuickAddView.h"
#import "SendAlertViewController.h"
#import "ManageCalendarTableViewController.h"
#import "ManagePostTableViewController.h"
@import GoogleMobileAds;

@interface NewsViewController ()<GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *newsTableview;
@property (weak, nonatomic) IBOutlet UILabel *newsHeaderLabel;

@property (weak, nonatomic) IBOutlet UIButton *adImageButton;
@property (nonatomic, strong) NSDictionary *adData;
@property (nonatomic, strong) AdModel *adModel;
@property (weak, nonatomic) IBOutlet UIView *tableViewHelperView;

@property (weak, nonatomic) IBOutlet UIView *overlay1;
@property (weak, nonatomic) IBOutlet UIView *helpOverlay;
@property (nonatomic, strong) NSArray *postNewsData;
@property (weak, nonatomic) IBOutlet AdminToolsQuickAddView *quickAddView;
@property (weak, nonatomic) IBOutlet UIButton *quickAddButton;

@property (strong, nonatomic)  GADBannerView *adView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL viewDisappeared;

@end

@implementation NewsViewController

- (AdModel *)adModel
{
    if(!_adModel) _adModel = [[AdModel alloc]init];
    return _adModel;
}

-(NSDictionary *)adData
{
    if(!_adData) _adData = [[NSDictionary alloc]init];
    return _adData;
}

-(void)setNewsData:(NSArray *)newsData
{
    _newsData = newsData;
    [self setupNews];
    
    [self.newsTableview reloadData];
}

-(void)setupNews
{
    if(self.newsData != (id)[NSNull null])
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
        for (NSDictionary *tempDic in self.newsData)
        {
            [tempArray addObject:@[tempDic]];
        }
    
        self.postNewsData = tempArray;
    }
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
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewDisappearing");
     self.viewDisappeared = true;
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
 
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
        else if([[self.mainUserData.schoolData objectForKey:IPHONE_UNIT_ID]isEqualToString:@""])
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
    [self setupNews];
	self.newsHeaderLabel.text = self.newsHeader;
    self.newsTableview.delegate = self;
    self.newsTableview.dataSource = self;
    
    self.adView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeBanner];
    NSMutableArray *tempArray = [self.mainUserData getAd];
    
    NSLog(@"Check to see if get new ad or last user");
    if([tempArray count] == 1)
    {
        NSLog(@"last ad used");
        self.adView = (GADBannerView *)[tempArray objectAtIndex:0];
        [self startTimer];
        self.adView.rootViewController = self;
        self.newsTableview.frame = CGRectMake(self.newsTableview.frame.origin.x, self.newsTableview.frame.origin.y, self.view.frame.size.width, self.newsTableview.frame.size.height - self.adView.frame.size.height);
        self.tableViewHelperView.frame = CGRectMake(self.tableViewHelperView.frame.origin.x, self.tableViewHelperView.frame.origin.y, self.view.frame.size.width, self.tableViewHelperView.frame.size.height - self.adView.frame.size.height);
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
    
    
       NSLog(@"%@", self.newsHeaderLabel.font);
    
    if(self.mainUserData.accountType.intValue > 0 && self.mainUserData.accountType.intValue < 8)
        self.quickAddButton.hidden = false;
    
    [self.quickAddView.layer setCornerRadius:30.0f];
    [self.quickAddView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.quickAddView.layer setBorderWidth:1.5f];
    [self.quickAddView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.quickAddView.layer setShadowOpacity:0.8];
    [self.quickAddView.layer setShadowRadius:3.0];
    [self.quickAddView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    UIButton *btnDisplay = (UIButton *)[self.quickAddView viewWithTag:128];
    [btnDisplay  addTarget:self action:@selector(pressedBtnDisplay:) forControlEvents:UIControlEventTouchUpInside];
    if(self.mainUserData.accountType.intValue > 0 & self.mainUserData.accountType.intValue < 5)
    {
    btnDisplay = (UIButton *)[self.quickAddView viewWithTag:129];
    [btnDisplay  addTarget:self action:@selector(pressedBtnDisplay:) forControlEvents:UIControlEventTouchUpInside];
    btnDisplay = (UIButton *)[self.quickAddView viewWithTag:130];
    [btnDisplay  addTarget:self action:@selector(pressedBtnDisplay:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (IBAction)quickAddButtonPressed
{
    if(self.quickAddView.hidden)
        self.quickAddView.hidden = false;
    else
        self.quickAddView.hidden = true;
}


- (void) pressedBtnDisplay:(id)sender
{
    self.quickAddView.hidden = true;
    UIButton *button = sender;
    switch (button.tag) {
        case 128:
            [self performSegueWithIdentifier:SEGUE_TO_SEND_ALERTS_VIEW sender:self];
            break;
        case 129:
            [self performSegueWithIdentifier:SEGUE_TO_MANAGE_EVENT sender:self];
            break;
        case 130:
            [self performSegueWithIdentifier:SEGUE_TO_MANAGE_POST sender:self];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"News_Screen"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

    
    
    [self.newsHeaderLabel setFont:FONT_CHARCOAL_CY(17.0f)];

    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self.mainUserData getTutorialStatusOfView:mv_News])
        [self showHelp];
}

- (void)showHelp
{
    self.helpOverlay.hidden = false;
    self.overlay1.hidden = false;
    
    [UIView animateWithDuration:1 animations:^{
        
        
        self.overlay1.alpha = 0.5;
        self.helpOverlay.alpha = 1.0;
        //self.dismissButton.alpha = 1.0;
        //self.help1.alpha = 1.0;
    }];
}

- (IBAction)hideHelpPressed
{
    [self.mainUserData turnOffTutorialForView:mv_News];
    [UIView animateWithDuration:.75 animations:^{
        self.overlay1.alpha = 0.0;
        self.helpOverlay.alpha = 0.0;
        //self.dismissButton.alpha = 1.0;
        //self.help1.alpha = 1.0;
        
    }completion:^(BOOL finished){
        self.overlay1.hidden = true;
        self.helpOverlay.hidden = true;
    }];
    
    
    
    
    
}

- (IBAction)adButtonclicked
{
    NSString *urlString;
    
    switch ([[self.adData objectForKey:AD_TYPE]intValue])
    {
        case 0:
        case 1:
        {
            urlString = [self.adData objectForKey:AD_URL_LINK];
        }
            break;
        case 2:
        {
            urlString = [NSString stringWithFormat:@"%@?id=%@&user=%@", AD_OFFER_LINK, [self.adData objectForKey:ID], self.userID];
        }
            break;
            
        default:
            break;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];

    
    dispatch_queue_t createQueue = dispatch_queue_create("updateAdClickCount", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.adModel updateAdClickCountInDatabse:[self.adData objectForKey:ID]fromSchool:self.mainUserData.schoolIDselected];
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

- (void)loadAdImage
{
    NSString *fileName = [self.adData objectForKey:AD_IMAGE_NAME];
    
    NSString *baseImageURL = [NSString stringWithFormat:@"%@%@%@", AD_IMAGE_URL, AD_DIRECTORY, fileName];
    
    //NSLog(@"%@", baseImageURL);
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("get Image", NULL);
    dispatch_async(downloadQueue, ^{
        
        
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:baseImageURL]];
        dispatch_async(dispatch_get_main_queue(),^{
            UIImage *image = [UIImage imageWithData:data];
            [self.adImageButton setImage:image forState:UIControlStateNormal];
            //[spinner stopAnimating];
            //NSLog(@"%f, %f", image.size.width, image.size.height);
        });
        
        
    });
    
}

- (void)getAdFromDatabase
{
    
   
    dispatch_queue_t createQueue = dispatch_queue_create("getLocalAd", NULL);
    dispatch_async(createQueue, ^{
        NSArray *adDataArray;
        adDataArray = [self.adModel getAdFromDatabase:self.schoolID forUser:self.mainUserData.userID];
        
        if ([adDataArray count] == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *tempDic = [[adDataArray objectAtIndex:0] objectForKey:@"adData"];
                
                self.adData = tempDic;
                
                if(self.adData != (id)[NSNull null])
                    [self loadAdImage];
                else
                    self.adImageButton.enabled = false;
                
            });
            
        }
    });
    
}

- (IBAction)menuPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];

    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}
- (void)loadNewsImageAtIndex:(NSIndexPath *)path forImage:(UIImageView *)imageView withActivityIndicator:(UIActivityIndicatorView *)spinner
{
    NSString *fileName = [[[self.postNewsData objectAtIndex:path.section ] objectAtIndex:path.row] objectForKey:NEWS_IMAGE_NAME];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir,fileName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
    
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, [UIScreen mainScreen].scale);
        
        // Add a clip before drawing anything, in the shape of an rounded rect
        [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                    cornerRadius:10.0] addClip];
        // Draw your image
        [image drawInRect:imageView.bounds];
        
        // Get the image, here setting the UIImageView image
        imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        
        // Lets forget about that we were drawing
        UIGraphicsEndImageContext();
        
        
        
        
        
        [spinner stopAnimating];
        
    }
    else
    {
    
    
        NSString *baseImageURL = [NEWS_IMAGE_URL stringByAppendingString:fileName];
        
        //NSLog(@"%@", baseImageURL);
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("get Image", NULL);
        dispatch_async(downloadQueue, ^{
            
            
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:baseImageURL]];
            dispatch_async(dispatch_get_main_queue(),^{
                UIImage *image = [UIImage imageWithData:data];
                
                // Get your image somehow
                
                
                // Begin a new image that will be the new image with the rounded corners
                // (here with the size of an UIImageView)
                UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, [UIScreen mainScreen].scale);
                
                // Add a clip before drawing anything, in the shape of an rounded rect
                [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                            cornerRadius:10.0] addClip];
                // Draw your image
                [image drawInRect:imageView.bounds];
                
                // Get the image, here setting the UIImageView image
                imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                
                // Lets forget about that we were drawing
                UIGraphicsEndImageContext();

                NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                [data1 writeToFile:pngFilePath atomically:YES];
                
                
                [spinner stopAnimating];
                //NSLog(@"%f, %f", image.size.width, image.size.height);
            });
            
            
        });
    }
    
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.postNewsData != (id)[NSNull null])
        return [self.postNewsData count];
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.postNewsData != (id)[NSNull null])
        return [[self.postNewsData objectAtIndex:section ] count];
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    NSDictionary *newsDic = [[self.postNewsData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSString *imageName = [newsDic objectForKey:NEWS_IMAGE_NAME];
    
    if(imageName != (id)[NSNull null])
        height = 105.0;
    else
        height = 68.0;
    
    return height;
    
    
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 0)
    {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        [cell setBackgroundColor:self.accentColor];
    }
    
}
 */

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *newsDic = [[self.postNewsData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    
    
    static NSString *CellIdentifier = @"newsCellWithImage";
    static NSString *CellIdentifier2 = @"newsCellNoImage";
    
    NSString *cellid = nil;
    
    
    NSString *imageName = [newsDic objectForKey:NEWS_IMAGE_NAME];
    UITableViewCell *cell;
    if(imageName != (id)[NSNull null])
    {
        cellid = CellIdentifier;
        cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
        
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell.contentView viewWithTag:4];
        
        
        [self loadNewsImageAtIndex:indexPath forImage:imageView withActivityIndicator:spinner];
    }
    else
    {
        cellid = CellIdentifier2;
        cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
        
    }
    
    
    
    
    UILabel *cellLabel = (UILabel *)[cell.contentView viewWithTag:2];
    
    cellLabel.text = [newsDic objectForKey:NEWS_TITLE];
    
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *fromLabel = (UILabel *)[cell.contentView viewWithTag:5];
    fromLabel.adjustsFontSizeToFitWidth = true;
     fromLabel.hidden = false;
    if([[newsDic objectForKey:TEACHER_ID]length] > 2)
    {
        
        fromLabel.text = [[self.mainUserData getTeacherName:[newsDic objectForKey:TEACHER_ID]] stringByAppendingString:@"'s Class"];
       
    }
    else if([[newsDic objectForKey:CLASS_ID]length] > 3)
    {
        if(self.mainUserData.accountType.intValue == 1)
        {
            fromLabel.text = [NSString stringWithFormat:@"%@ %@ - %@",[self.mainUserData.userInfo objectForKey:@"prefix"], [self.mainUserData.userInfo objectForKey:USER_LAST_NAME], [self.mainUserData getClassName:[newsDic objectForKey:CLASS_ID]]];
            
        }
        else
        {
            fromLabel.text = [self.mainUserData getClassAndTeacherName:[newsDic objectForKey:CLASS_ID]];
        }
        
       
        
    }
    else if([[newsDic objectForKey:CORP_ID] length] > 3)
    {
        fromLabel.text = [self.mainUserData.schoolData objectForKey:@"name"];
    }
    else if([[newsDic objectForKey:SCHOOL_ID]length] > 3)
    {
        fromLabel.text = [self.mainUserData.schoolData objectForKey:SCHOOL_NAME];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:[newsDic objectForKey:NEWS_DATE]];
    
    [dateFormatter setDateFormat:@"hh:mma MMM-dd"];
    
    NSString *convertedDate =[dateFormatter stringFromDate:date];
    
    dateLabel.text = convertedDate;
    
    //UIImageView *cellImage = (UIImageView *)[cell.contentView viewWithTag:1];
    
    //cellImage.image = [UIImage imageNamed:@"redAlert.png"];
    

    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    if([segue.identifier isEqualToString:SEGUE_TO_NEWS_DETAIL_VIEW])
    {
        
        NSIndexPath *index = [self.newsTableview indexPathForSelectedRow];
        
        NewsDetailViewController *NDVC = segue.destinationViewController;
        NDVC.newsDetailData = [[self.postNewsData objectAtIndex:index.section] objectAtIndex:index.row];
        NDVC.userID = self.mainUserData.userID;
        
       
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_SEND_ALERTS_VIEW])
    {
        SendAlertViewController *SAVC = segue.destinationViewController;
        SAVC.mainUserData = self.mainUserData;
        SAVC.isEditing = false;
        SAVC.autoClose = true;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_MANAGE_EVENT])
    {
        ManageCalendarTableViewController *MCTVC = segue.destinationViewController;
        MCTVC.mainUserData = self.mainUserData;
        MCTVC.backgroundColor = self.view.backgroundColor;
        MCTVC.isNewEvent = true;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_MANAGE_POST])
    {
        ManagePostTableViewController *MPTVC = segue.destinationViewController;
        MPTVC.mainUserData = self.mainUserData;
        
        MPTVC.isNewPost = true;
    }
     
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:SEGUE_TO_NEWS_DETAIL_VIEW sender:self];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}



@end
