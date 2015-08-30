//
//  DemoCalendarMonth.m
//  Created by Devin Ross on 10/31/09.
//
/*
 
 tapku || https://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "CalendarMonthViewController.h"
#import "AdminToolsQuickAddView.h"
#import "SendAlertViewController.h"
#import "ManageCalendarTableViewController.h"
#import "ManagePostTableViewController.h"
@import GoogleMobileAds;


@interface CalendarMonthViewController () <GADBannerViewDelegate>
@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *monthsUsed;
@property (nonatomic, strong) NSArray *yearsUsed;
@property (nonatomic) BOOL showDetailView;
@property (nonatomic, strong) NSDictionary *detailViewDic;
@property (nonatomic, strong) NSDictionary *selectedEventData;
@property (nonatomic, strong) NSArray *eventsArray;
@property (nonatomic, strong) UIView *overlay1;
@property (nonatomic, strong) UIView *helpOverlay;
@property (nonatomic, strong) AdModel *adModel;
@property (nonatomic, strong) NSDictionary *adData;
@property (strong, nonatomic) UIButton *adImageButton;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (strong, nonatomic)  UIView *quickAddView;
@property (strong, nonatomic)  UIButton *quickAddButton;
@property (nonatomic, strong) AdminToolsQuickAddView *tempView;
@property (nonatomic, strong) SendAlertViewController *SAVC;

@property (strong, nonatomic)  GADBannerView *adView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL viewDisappeared;
@end

#pragma mark - CalendarMonthViewController
@implementation CalendarMonthViewController

- (SendAlertViewController *)SAVC
{
    if (!_SAVC) _SAVC = [[SendAlertViewController alloc]init];
    return _SAVC;
}
- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) _dateFormatter = [[NSDateFormatter alloc]init];
    return _dateFormatter;
}
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

-(NSArray *)eventsArray
{
    if (!_eventsArray) _eventsArray = [[NSArray alloc]init];
    return _eventsArray;
}

-(NSDictionary *)selectedEventData
{
    if (!_selectedEventData) _selectedEventData = [[NSDictionary alloc]init];
    return _selectedEventData;
}

-(NSDictionary *)detailViewDic
{
    if(!_detailViewDic) _detailViewDic = [[NSDictionary alloc]init];
    return _detailViewDic;
}

-(NSArray *)monthsUsed
{
    if(!_monthsUsed) _monthsUsed = [[NSArray alloc]init];
    return _monthsUsed;
}

-(NSArray *)monthArray
{
    if(!_monthArray) _monthArray = [[NSArray alloc]initWithObjects:
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    [NSNumber numberWithInt:0],
                                    nil];
    return _monthArray;
    
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
            urlString = [NSString stringWithFormat:@"%@?id=%@&user=%@", AD_OFFER_LINK, [self.adData objectForKey:ID], self.mainUserData.userID];
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
                    //NSLog(@"%@", tempDic);
                }
            });
            
        }
    });
    
}


- (NSArray *)getDateArrayFromString:(NSString *)date
{
    NSArray *dateArray = [date componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"- :/"]];
    //NSLog(@"NEW DATE ARRAY: %@", dateArray);
    return dateArray;
    
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
        adDataArray = [self.adModel getAdFromDatabase:self.mainUserData.schoolIDselected forUser:self.mainUserData.userID];
        
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


- (void)loadUsersCalendar
{
    EKEventStore *store = [[EKEventStore alloc] init];
    
    
    // Get the appropriate calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    
    if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        /* iOS Settings > Privacy > Calendars > MY APP > ENABLE | DISABLE */
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             
             dispatch_queue_t createQueue = dispatch_queue_create("getCalendar", NULL);
             dispatch_async(createQueue, ^{
            
                 if ( granted )
                 {
                     
                     //NSLog(@"User has granted permission!");
                     // Create the start date components
                     NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
                     oneDayAgoComponents.day = -1;
                     NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
                                                                   toDate:[NSDate date]
                                                                  options:0];
                     
                     NSDateComponents *sixMonthsFromNowComponets = [[NSDateComponents alloc]init];
                     sixMonthsFromNowComponets.month = 12;
                     NSDate *sixMonthsFromNow = [calendar dateByAddingComponents:sixMonthsFromNowComponets
                                                                          toDate:[NSDate date]
                                                                         options:0];
                     /* // Create the end date components
                      NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
                      oneYearFromNowComponents.year = 1;
                      NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
                      toDate:[NSDate date]
                      options:0];
                      */
                     // Create the predicate from the event store's instance method
                     NSPredicate *predicate = [store predicateForEventsWithStartDate:oneDayAgo
                                                                             endDate:sixMonthsFromNow
                                                                           calendars:nil];
                     self.eventsArray = [store eventsMatchingPredicate:predicate];
                     //NSLog(@"The content of array is%@",self.eventsArray);
                     // Fetch all events that match the predicate
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
            
                         [self.tableView reloadData];
                         
                     });
                     
                 }
                 else
                 {
                     NSLog(@"User has not granted permission!");
                 }
             
             
             
             
             });

             
         
             
             
         }];
    }
}

- (void) datesToMarkStartDate:(NSDate *)start endDate:(NSDate *)end
{
    self.dataArray = [[NSMutableArray alloc]init];
    BOOL isMatched = NO;
    
    NSDate *d = start;
    	while(self.calendarData != (id)[NSNull null])
        {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:d];
        
        
        for(NSDictionary *calDic in self.calendarData)
        {
            NSArray *dateArray = [self getDateArrayFromString:[calDic objectForKey:CAL_START_DATE]];
            if([dateArray[1]integerValue] == [components month] && [dateArray[2]integerValue ] == [components day])
            {
                isMatched = YES;
                break;
            }
            else
            {
                isMatched = NO;
               
            }
            
        }
		
        if(isMatched)
            [self.dataArray addObject:@YES];
        else
            [self.dataArray addObject:@NO];
			
		NSDateComponents *info = [d dateComponentsWithTimeZone:self.monthView.timeZone];
		info.day++;
		d = [NSDate dateWithDateComponents:info];
		if([d compare:end]==NSOrderedDescending) break;
            
            
    }
}
- (void)getSectionCount
{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableArray *monthsUsed = [[NSMutableArray alloc]init];
    NSMutableArray *yearsUsed = [[NSMutableArray alloc]init];
    
    //NSLog(@"%@", tempArray);
    //NSLog(@"%@", self.calendarData);
    if(self.calendarData != (id)[NSNull null])
    {
        for(NSDictionary *calDic in self.calendarData)
        {
            NSArray *dateArray = [self getDateArrayFromString:[calDic objectForKey:CAL_START_DATE]];
            
            
            
            switch ([[dateArray objectAtIndex:1]integerValue])
            {
                case JANUARY:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:JANUARY]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:JANUARY]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case FEBUARY:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:FEBUARY]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:FEBUARY]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case MARCH:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:MARCH]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:MARCH]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case APRIL:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:APRIL]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:APRIL]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case MAY:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:MAY]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:MAY]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case JUNE:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:JUNE]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:JUNE]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case JULY:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:JULY]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:JULY]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case AUGUST:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:AUGUST]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:AUGUST]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case SEPTEMBER:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:SEPTEMBER]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:SEPTEMBER]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case OCTOBER:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:OCTOBER]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:OCTOBER]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case NOVEMBER:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:NOVEMBER]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:NOVEMBER]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
                case DECEMBER:
                {
                    if([[monthsUsed lastObject] isEqualToNumber:[NSNumber numberWithInt:DECEMBER]])
                    {
                        NSUInteger count = [monthsUsed count];
                        NSInteger number = [[tempArray lastObject] integerValue];
                        number++;
                        [tempArray replaceObjectAtIndex:count -1 withObject:[NSNumber numberWithLong:number]];
                    }
                    else
                    {
                        [monthsUsed addObject:[NSNumber numberWithInt:DECEMBER]];
                        [yearsUsed addObject:[dateArray objectAtIndex:0]];
                        [tempArray addObject:[NSNumber numberWithLong:1]];
                        
                    }
                    break;
                }
            }
        }
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Calendar Error" message:@"No Calendar Information to Display" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
    //NSLog(@"YEARS USED%@", yearsUsed);
    
    
    self.monthArray = tempArray;
    self.monthsUsed = monthsUsed;
    self.yearsUsed = yearsUsed;
    
    
    
    
}

- (NSUInteger) supportedInterfaceOrientations{
	return  UIInterfaceOrientationMaskPortrait;
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


#pragma mark View Lifecycle

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
    //NSLog(@"adViewDidLeaveApplication");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [self.timer invalidate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
     self.viewDisappeared = true;
     [self.timer invalidate];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
   
}


- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"There was an error!");
    if(!self.mainUserData.isAdTestMode)
        [self.adModel updateMMAdFailedCountInDatabse:self.mainUserData.userID andSchoolID:self.mainUserData.schoolIDselected];
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    //NSLog(@"adViewWillPresentScreen");
    if(!self.mainUserData.isAdTestMode)
        [self.adModel updateMMAdClickCountInDatabse:self.mainUserData.userID andSchoolID:self.mainUserData.schoolIDselected];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    //NSLog(@"adViewDidReceiveAd");
    if(self.mainUserData.isTimerExpired)
    {
        [self.view addSubview:self.adView];
        self.mainUserData.remainingCounts--;
        [UIView animateWithDuration:1 animations:^{
            bannerView.frame = CGRectMake(0.0,
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
        self.adView.frame = CGRectMake(0.0,
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


- (void)loadNewAd
{
    NSLog(@"New Ad Loaded...");
    
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @"59c997e06ef957f5f6c866b6fed1bb25" ];
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

- (void) viewDidLoad
{
	[super viewDidLoad];
    self.adView = [[GADBannerView alloc]initWithAdSize:kGADAdSizeSmartBannerPortrait];
    NSMutableArray *tempArray = [self.mainUserData getAd];
    
    NSLog(@"Check to see if get new ad or last user");
    if([tempArray count] == 1)
    {
        NSLog(@"last ad used");
        self.adView = (GADBannerView *)[tempArray objectAtIndex:0];
        [self startTimer];
        self.adView.rootViewController = self;
        [self.view addSubview:self.adView];
    }
    else
    {
        self.adView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width,60);
        [self setUnitID];
        self.adView.rootViewController = self;
        
        [self loadNewAd];
    }
    
    
    self.adView.delegate = self;
    
    NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
    [self.dateFormatter setLocale:usLocale];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    self.view.backgroundColor = self.backgroundColor;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadUsersCalendar) name:UIApplicationDidBecomeActiveNotification object:nil];

    self.showDetailView = false;
    [self getSectionCount];
    //NSLog(@"%@", self.calendarData);
	self.title = NSLocalizedString(@"Month Grid", @"");
	[self.monthView selectDate:[NSDate date]];
    CGRect rect = self.monthView.frame;
    rect.origin.y += 58;
    self.monthView.frame = rect;
    CGRect viewRect = self.view.frame;
    rect = self.tableView.frame;
    rect.size.height = viewRect.size.height - 124;
    
    rect.origin.y = viewRect.origin.y + 64;
    rect.origin.x = viewRect.origin.x;
    
    
    self.tableView.frame = rect;
    [self.monthView removeFromSuperview];
    
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    UILabel *pageTitle = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2) - 100, (58/2 - 22), 200, 44)];
    pageTitle.numberOfLines = 2;
    
    pageTitle.text = [NSString stringWithFormat:@"%@ Calendar",[self.mainUserData.schoolData objectForKey:SCHOOL_NAME]];
    [pageTitle setTextAlignment:NSTextAlignmentCenter];
    [pageTitle setTextColor:[UIColor whiteColor]];
    
        
        
    [pageTitle setFont:FONT_CHARCOAL_CY(17.0f)];
    
    [menuButton addTarget:self action:@selector(menuPressed) forControlEvents:UIControlEventTouchDown];
    
    [menuButton setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    [self.view addSubview:menuButton];
    [self.view addSubview:pageTitle];
    
    self.overlay1 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    self.helpOverlay = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    
    self.quickAddView   = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width /2 - 90, self.view.frame.size.height/2 - 90, 180, 180)];
    


  
    self.tempView =  [[AdminToolsQuickAddView alloc]init];
    self.tempView.frame = CGRectMake(0,0,180,180);
    
    [self.quickAddView addSubview:self.tempView];
    
    

    
    self.overlay1.alpha = 0;
    self.helpOverlay.alpha = 0;
    
    self.overlay1.backgroundColor = [UIColor blackColor];
    self.helpOverlay.backgroundColor = [UIColor clearColor];
    self.quickAddView.backgroundColor = [UIColor whiteColor];
    self.quickAddView.hidden = true;
    
    [self.view addSubview:self.overlay1];
    [self.view addSubview:self.helpOverlay];
    [self.view addSubview:self.quickAddView];
    
    
    UIButton *dismissButton = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2) - (118/2), self.view.frame.size.height-38, 118, 30)];
    [dismissButton setTitle:@"Dismiss Help" forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(hideHelpPressed) forControlEvents:UIControlEventTouchDown];
    [self.helpOverlay addSubview:dismissButton];
    
    //self.adImageButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    //[self.adImageButton addTarget:self action:@selector(adButtonclicked) forControlEvents:UIControlEventTouchDown];
    //[self.adImageButton setTitle:@"" forState:UIControlStateNormal];
    
    self.quickAddButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50, 13, 40, 40)];
    
    [self.quickAddButton addTarget:self action:@selector(quickAddButtonPressed) forControlEvents:UIControlEventTouchDown];
    [self.quickAddButton setTitle:@"✐" forState:UIControlStateNormal];
    self.quickAddButton.titleLabel.font = [UIFont systemFontOfSize:31.0];
    self.quickAddButton.hidden = true;
    
    //[self.view addSubview:self.adImageButton];
    [self.view addSubview:self.quickAddButton];
    if(self.mainUserData.accountType.intValue > 0 && self.mainUserData.accountType.intValue < 8)
        self.quickAddButton.hidden = false;
    
    /*
    UIView *detailViewControls = [[UIView alloc]initWithFrame:CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 40)];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 0, 40, 40)];
    UIButton *addButton = [[UIButton alloc]initWithFrame:CGRectMake(260, 0, 40, 40)];
    
    [backButton setTitle:@"⬅️" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont fontWithName:@"system" size:34.0];
    [backButton addTarget:self action:@selector(detailViewBackButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    [addButton setTitle:@"➕" forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont fontWithName:@"system" size:26.0];
    [addButton addTarget:self action:@selector(addEventToCalendar) forControlEvents:UIControlEventTouchDown];
    detailViewControls.backgroundColor = self.backgroundColor;
    [detailViewControls addSubview:backButton];
    [detailViewControls addSubview:addButton];
    
    [self.view insertSubview:detailViewControls belowSubview:self.tableView];
     */
    
    [self loadUsersCalendar];

    [self.quickAddView.layer setCornerRadius:30.0f];
    [self.quickAddView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.quickAddView.layer setBorderWidth:1.5f];
    [self.quickAddView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.quickAddView.layer setShadowOpacity:0.8];
    [self.quickAddView.layer setShadowRadius:3.0];
    [self.quickAddView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    UIButton *btnDisplay = (UIButton *)[self.tempView viewWithTag:128];
    [btnDisplay  addTarget:self action:@selector(pressedBtnDisplay:) forControlEvents:UIControlEventTouchUpInside];
    if(self.mainUserData.accountType.intValue > 0 & self.mainUserData.accountType.intValue < 5)
    {
    btnDisplay = (UIButton *)[self.tempView viewWithTag:129];
    [btnDisplay  addTarget:self action:@selector(pressedBtnDisplay:) forControlEvents:UIControlEventTouchUpInside];
    btnDisplay = (UIButton *)[self.tempView viewWithTag:130];
    [btnDisplay  addTarget:self action:@selector(pressedBtnDisplay:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)quickAddButtonPressed
{
    if(self.quickAddView.hidden)
        self.quickAddView.hidden = false;
    else
        self.quickAddView.hidden = true;
}


- (void) pressedBtnDisplay:(id)sender
{
    self.quickAddView.hidden = true;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SendAlertViewController *SAVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"SendAlertViewController"];
    ManageCalendarTableViewController *MCTVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"ManageCalendarTableViewController"];
    ManagePostTableViewController *MPTVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"ManagePostTableViewController"];
    
    UIButton *button = sender;
    switch (button.tag) {
        case 128:
            
            SAVC.mainUserData = self.mainUserData;
            SAVC.isEditing = false;
            SAVC.autoClose = true;
            
            [self.navigationController pushViewController:SAVC animated:YES];
            break;
        case 129:
            MCTVC.mainUserData = self.mainUserData;
            MCTVC.backgroundColor = self.view.backgroundColor;
            MCTVC.isNewEvent = true;
            [self.navigationController pushViewController:MCTVC animated:YES];
            break;
        case 130:
            MPTVC.mainUserData = self.mainUserData;
            
            MPTVC.isNewPost = true;
            
            [self.navigationController pushViewController:MPTVC animated:YES];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![self.timer isValid] && self.viewDisappeared)
    {
        [self startTimer];
        self.viewDisappeared = false;
    }
    

        
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"Calendar_Screen"];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appHasGoneInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
  
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self.mainUserData getTutorialStatusOfView:mv_Calendar])
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
    [self.mainUserData turnOffTutorialForView:mv_Calendar];
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


- (void)menuPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)detailViewBackButtonPressed
{
    self.showDetailView = false;
    self.detailViewDic = nil;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y -= 40;
        self.tableView.frame = rect;
    }completion:^(BOOL finished) {
        //
    }];
    [self.tableView reloadData];
}

- (void)addEventToUserCalendar
{
    //NSString *dateString = @"Mon, 02 Sep 2013 00:00:45";
   
   
    
    
    EKEventStore *store = [[EKEventStore alloc]init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)  {
        if (!granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *noCalendarAccessAlert = [[UIAlertView alloc]initWithTitle:@"Calendar Access" message:@"Unable to add event, enable Intercom for calendar access via Settings->Privacy->Calendars" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [noCalendarAccessAlert show];
                
                
            });

                       return;
        }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = [self.selectedEventData objectForKey:CAL_TITLE];
        event.allDay = [[self.selectedEventData objectForKey:CAL_IS_ALL_DAY] boolValue];
        event.startDate = [self.dateFormatter dateFromString:[self.selectedEventData objectForKey:CAL_START_DATE]];
        event.endDate = [self.dateFormatter dateFromString:[self.selectedEventData objectForKey:CAL_END_DATE]];
        event.location = [self.selectedEventData objectForKey:CAL_LOCATION];
        event.notes = [self.selectedEventData objectForKey:CAL_MORE_INFO];
        [event setCalendar:[store defaultCalendarForNewEvents]];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        
        //NSLog(@"%@", event.eventIdentifier);
        dispatch_async(dispatch_get_main_queue(), ^{
            
             //[Flurry logEvent:@"Event_Added_To_Users_Calendar"];
             id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Calendar"
                                                                  action:@"Added_Event_To_Device_Calendar"
                                                                   label:@"Calendar Add"
                                                                   value:@1] build]];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Calendar" message:@"Event added successfully" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [self loadUsersCalendar];
            
            
        });
        
        
    }];

}

- (BOOL)isEventAlreadyInUsersCalendar:(NSDictionary *)event
{
    
    for (EKEvent *usersEvent in self.eventsArray)
    {

        
        
        
       
        NSString *tempDate = [self.dateFormatter stringFromDate:usersEvent.startDate];
        
        //NSLog(@"%@", [event objectForKey:CAL_START_DATE]);
        //NSLog(@"%@", tempDate);
      
       
        if ([usersEvent.title isEqualToString:[event objectForKey:CAL_TITLE]] && [tempDate isEqualToString:[event objectForKey:CAL_START_DATE]])
        {
            return YES;
        }
    }
    
    return NO;
}


- (void)addEventToCalendar:(UIButton *)sender
{
    if(self.mainUserData.hasPurchased)
    {
        self.selectedEventData = [self.calendarData objectAtIndex:sender.tag];

        UIAlertView *confirmAddAlert = [[UIAlertView alloc]initWithTitle:@"Add Event" message:[NSString stringWithFormat:@"Add %@?", [self.selectedEventData    objectForKey:CAL_TITLE]] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        confirmAddAlert.tag = zAlertConfirmCalendarAdd;
    
        [confirmAddAlert show];
    }
    else
    {
        UIAlertView *suggestPurchase = [[UIAlertView alloc]initWithTitle:@"Premium Content" message:@"Adding Calendar Events requires the one time purchase of the School Premium Pack, for more details select Premium Features." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Premium Features", nil];
        suggestPurchase.tag = zAlertSuggestPurchase;
        
        [suggestPurchase show];
    }

}


#pragma mark MonthView Delegate & DataSource

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == zAlertConfirmCalendarAdd)
    {
        if(buttonIndex == 1)
        {
            [self addEventToUserCalendar];
        }
    }
    else if(alertView.tag == zAlertSuggestPurchase)
    {
        if(buttonIndex == 1)
        {
            if([self.delegate respondsToSelector:@selector(segueToOffer)])
            {
                //[Flurry logEvent:@"SEGUE_TO_OFFER_VIA_CALENDAR"];
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Calendar"
                                                                      action:@"User_Sent_To_Offer_Screen"
                                                                       label:@"No Premium Pack"
                                                                       value:@1] build]];
                [self.navigationController popViewControllerAnimated:NO];
                
                [self.delegate segueToOffer];
            }

        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{
	[self datesToMarkStartDate:startDate endDate:lastDate];
    //[self generateRandomDataForStartDate:startDate endDate:lastDate];
	return self.dataArray;
}
- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date{
	//NSLog(@"Date Selected: %@",date);
    
    if(self.showDetailView)
    {
        NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en-US"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setLocale:usLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        for (NSDictionary *dic in self.calendarData)
        {
            NSDate *newDate = [dateFormatter dateFromString:[dic objectForKey:CAL_START_DATE]];
            
            if([newDate compare:date] == NSOrderedSame)
            {
                self.detailViewDic = dic;
                break;
            }
        }
    }
    
	[self.tableView reloadData];
}
- (void) calendarMonthView:(TKCalendarMonthView*)mv monthDidChange:(NSDate*)d animated:(BOOL)animated{
	[super calendarMonthView:mv monthDidChange:d animated:animated];
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.showDetailView)
        return 1;
    else
        return [self.monthsUsed count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int counter = 1;
    
    if (self.showDetailView)
    {
        if([[self.detailViewDic objectForKey:CAL_LOCATION] length] > 1)
            counter++;
        if([[self.detailViewDic objectForKey:CAL_MORE_INFO] length] > 1)
            counter++;
        
        return counter;
    }
    else
    {
        //NSInteger num = [[self.monthsUsed objectAtIndex:section]integerValue];
    
        return [[self.monthArray objectAtIndex:section]integerValue];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.showDetailView && indexPath.row == 0)
    {
        return 105.0;
    }
    else if (self.showDetailView && indexPath.row == 1)
    {
        if([[self.detailViewDic objectForKey:CAL_LOCATION]length] > 1)
            return 44.0;
        else
            return 172.0;
    }
    else if (self.showDetailView && indexPath.row == 2)
        return 172.0;
    return 54.0f;
}

- (NSArray *)ConvertHourUsingDateArray:(NSArray *)dateArray
{
    NSMutableArray *newArray = [dateArray mutableCopy];
    NSInteger hour = [dateArray[3] integerValue];
    
    if(hour > 12)
    {
        hour -=12;
        if(hour == 12)
            newArray[5] = @"am";
        else
            newArray[5] = @"pm";
    }
    else
    {
        if(hour == 12)
            newArray[5] = @"pm";
        else
            newArray[5] = @"am";
    }
    
    newArray[3] = [NSString stringWithFormat:@"%li", (long)hour];
    
    return newArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(self.showDetailView)
    {
        if (indexPath.row == 0)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailViewTitleCell"];
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, 306, 30)];
            UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 49, 306, 41)];
            
            dateLabel.numberOfLines = 2;
            dateLabel.font = [UIFont systemFontOfSize:8.0];
            titleLabel.font = [UIFont systemFontOfSize:12.0];
                       titleLabel.numberOfLines = 2;
            
           
            titleLabel.text = [self.detailViewDic objectForKey:CAL_TITLE];;
            NSArray *startTimeArray = [self getDateArrayFromString:[self.detailViewDic objectForKey:CAL_START_DATE]];
            NSArray *endTimeArray = [self getDateArrayFromString:[self.detailViewDic objectForKey:CAL_END_DATE]];
            
            
            
            
            if([[self.detailViewDic objectForKey:CAL_IS_ALL_DAY] boolValue])
            {
                if([endTimeArray[0] integerValue] > 0 && ![[self.detailViewDic objectForKey:CAL_START_DATE] isEqualToString:[self.detailViewDic objectForKey:CAL_END_DATE]])
                {
                    dateLabel.text = [NSString stringWithFormat:@"All day from %@ %@, %@ to %@ %@, %@", [self getMonthWithInt:[startTimeArray[1] integerValue]], startTimeArray[2], startTimeArray[0], [self getMonthWithInt:[endTimeArray[1] integerValue]], endTimeArray[2], endTimeArray[0]];
                }
                else
                {
                    dateLabel.text = [NSString stringWithFormat:@"All day on %@ %@, %@", [self getMonthWithInt:[startTimeArray[1] integerValue]], startTimeArray[2], startTimeArray[0]];
                }
            }
            else
            {
                startTimeArray = [self ConvertHourUsingDateArray:startTimeArray];
                endTimeArray = [self ConvertHourUsingDateArray:endTimeArray];
                
                dateLabel.text = [NSString stringWithFormat:@"On %@ %@, %@ from %@:%@%@ - %@:%@%@", [self getMonthWithInt:[startTimeArray[1] integerValue]], startTimeArray[2], startTimeArray[0], startTimeArray[3], startTimeArray[4], startTimeArray[5], endTimeArray[3], endTimeArray[4], endTimeArray[5]];
            }
            
            [cell addSubview:dateLabel];
            [cell addSubview:titleLabel];
            

        }
        else if (indexPath.row == 1 || indexPath.row == 2)
        {
            if([[self.detailViewDic objectForKey:CAL_LOCATION] length] > 1 && indexPath.row  == 1)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"locationCell"];
                cell.textLabel.text = @"Location";
                cell.detailTextLabel.text = [self.detailViewDic objectForKey:CAL_LOCATION];
                
            }
            else if ([[self.detailViewDic objectForKey:CAL_MORE_INFO] length] > 1)
            {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moreInfoCell"];
                UILabel *moreInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 11, 143, 21)];
                UILabel *moreInfoTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 285, 111)];
                
                moreInfoLabel.font = [UIFont systemFontOfSize:17.0];
                moreInfoTextLabel.font = [UIFont systemFontOfSize:15.0];
                moreInfoTextLabel.numberOfLines = 5;
                
                moreInfoLabel.text = @"More Info";
                moreInfoTextLabel.text = [self.detailViewDic objectForKey:CAL_MORE_INFO];
                
                [cell addSubview:moreInfoLabel];
                [cell addSubview:moreInfoTextLabel];
            }
            
            
        }
    }
    else
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //UILabel *cellLabel = (UILabel *)[cell.contentView viewWithTag:2];
        //UILabel *calLabel = (UILabel *)[cell.contentView viewWithTag:1];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 1, 180, 40)];
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 90, 2, 80, 40)];
        UILabel *createdByLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 38, 175, 15)];
        
        dateLabel.textAlignment = NSTextAlignmentLeft;
        dateLabel.numberOfLines = 4;
        
        dateLabel.font = [UIFont systemFontOfSize:9.0];
        titleLabel.font = [UIFont systemFontOfSize:13.0];
        titleLabel.numberOfLines = 2;
        createdByLabel.font = [UIFont systemFontOfSize:10.0];
        createdByLabel.adjustsFontSizeToFitWidth = true;
        
        UIButton *addButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 7, 30, 30)];

        addButton.titleLabel.font = [UIFont fontWithName:@"system" size:26.0];
        
        
        NSInteger section = indexPath.section;
        NSInteger row = 0;
        
        if(section == 0)
            row = indexPath.row;
        else if(section > 0)
        {
            for (int i = 0; i < section; i++)
            {
                //NSInteger num = [[self.monthsUsed objectAtIndex:i]integerValue];
                row += [[self.monthArray objectAtIndex:i]integerValue];
            }
            row += indexPath.row;
        }
        
        NSDictionary *calendarDic = [self.calendarData objectAtIndex:row];
        addButton.tag = row;
        [addButton addTarget:self action:@selector(addEventToCalendar:) forControlEvents:UIControlEventTouchDown];
        
        titleLabel.text = [calendarDic objectForKey:CAL_TITLE];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *startDate = [dateFormatter dateFromString:[calendarDic objectForKey:CAL_START_DATE]];
        NSDate *endDate = [dateFormatter dateFromString:[calendarDic objectForKey:CAL_END_DATE]];
        
        NSString *stringDate = @"";
        
        
        

        if([[calendarDic objectForKey:CAL_IS_ALL_DAY]boolValue] && ![[HelperMethods dateToStringMMddyyyy:startDate] isEqualToString:[HelperMethods dateToStringMMddyyyy:endDate]])
        {
            
            dateLabel.frame = CGRectMake(self.view.frame.size.width - 90, 8, 80, 40);
            NSString *dateString2 = [HelperMethods dateToStringEEEMMddyyyy:endDate];
            stringDate = [NSString stringWithFormat:@"%@\n          thru\n%@", [HelperMethods dateToStringEEEMMddyyyy:startDate],dateString2 ];

        }else if([[calendarDic objectForKey:CAL_IS_ALL_DAY]boolValue])
        {
            NSString *dateString = [HelperMethods dateToStringEEEMMddyyyy:startDate];
            stringDate = [NSString stringWithFormat:@"\n%@", dateString];
            
            
        } else
        {
            NSString *dateString = [HelperMethods dateToStringEEEMMddyyyyhhmma:startDate];
            stringDate = [NSString stringWithFormat:@"\n%@", dateString];
        }
        NSMutableAttributedString * attDate = [[NSMutableAttributedString alloc]initWithString:stringDate];
        NSInteger strLength = [stringDate length];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineSpacing:2];
        [attDate addAttribute:NSParagraphStyleAttributeName
                          value:style
                          range:NSMakeRange(0, strLength)];
        [dateLabel setAttributedText:attDate];
        
        if([[calendarDic objectForKey:CLASS_ID]length] > 3)
        {
            if(self.mainUserData.accountType.intValue == 1)
            {
                createdByLabel.text = [NSString stringWithFormat:@"%@ %@ - %@",[self.mainUserData.userInfo objectForKey:@"prefix"], [self.mainUserData.userInfo objectForKey:USER_LAST_NAME], [self.mainUserData getClassName:[calendarDic objectForKey:CLASS_ID]]];
                
            }
            else
            {
                createdByLabel.text = [self.mainUserData getClassAndTeacherName:[calendarDic objectForKey:CLASS_ID]];
            }
            
        }
        else if([[calendarDic objectForKey:TEACHER_ID] length] > 3)
        {
            createdByLabel.text = [self.mainUserData getTeacherName:[calendarDic objectForKey:TEACHER_ID]];
        }
        else if([[calendarDic objectForKey:CORP_ID] length] > 3)
        {
            createdByLabel.text = [self.mainUserData.schoolData objectForKey:@"name"];
        }
        else if([[calendarDic objectForKey:SCHOOL_ID] length] > 3)
        {
            createdByLabel.text = [self.mainUserData.schoolData objectForKey:SCHOOL_NAME];

        }
        
       
        [cell addSubview:titleLabel];
        [cell addSubview:dateLabel];
        [cell addSubview:createdByLabel];
        
        
        if([self isEventAlreadyInUsersCalendar:calendarDic])
        {
            UILabel *addLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 7, 30, 30)];
            
            addLabel.font = [UIFont fontWithName:@"system" size:40.0];
            addLabel.textColor = [UIColor greenColor];
            addLabel.text = @"✔︎";
            addButton.hidden = TRUE;
            [cell addSubview:addLabel];
        }
        else
        {
            addButton.enabled = FALSE;
            [addButton setTitle:@"" forState:UIControlStateDisabled];
            [addButton setTitle:@"➕" forState:UIControlStateNormal];
            addButton.enabled = TRUE;
             [cell addSubview:addButton];
        }
        

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSArray *dateArray = [self getDateArrayFromString:cell.detailTextLabel.text];
    NSString *newDate = [NSString stringWithFormat:@"%@-%@-%@ 00:00:00", dateArray[2], dateArray[0], dateArray[1]];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *myDate = [df dateFromString: newDate];
    NSLog(@"%@", myDate);
    [self.monthView selectDate:myDate];
    self.showDetailView = true;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y += 40;
        self.tableView.frame = rect;
    }completion:^(BOOL finished) {
        //
    }];
    
    for (NSDictionary *dic in self.calendarData)
    {
        NSArray *startTime = [self getDateArrayFromString:[dic objectForKey:CAL_START_DATE]];
        NSLog(@"%@",cell.textLabel.text);
        if([dateArray[2] isEqualToString:startTime[0]] && [dateArray[0] isEqualToString:startTime[1]] && [dateArray[1] isEqualToString:startTime[2]] && [cell.textLabel.text isEqualToString:[dic objectForKey:CAL_TITLE]])
        {
            self.detailViewDic = dic;
            NSLog(@"Match Found");
            break;
        }
    }
    [self.tableView reloadData];
    //[self performSegueWithIdentifier:@"calendarDetailSegue" sender:self];
    // Navigation logic may go here. Create and push another view controller.
    
      *detailViewController = [[  alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (NSString *)getMonthWithInt:(NSInteger)num
{
    NSString *month;
    
    switch(num)
    {
        case 1:
        {
            month = @"January";
            break;
        }
        case 2:
        {
            month = @"Febuary";
            break;
        }
        case 3:
        {
            month = @"March";
            break;
        }
        case 4:
        {
            month = @"April";
            break;
        }
        case 5:
        {
            month = @"May";
            break;
        }
        case 6:
        {
            month = @"June";
            break;
        }
        case 7:
        {
            month = @"July";
            break;
        }
        case 8:
        {
            month = @"August";
            break;
        }
        case 9:
        {
            month = @"September";
            break;
        }
        case 10:
        {
            month = @"October";
            break;
        }
        case 11:
        {
            month = @"November";
            break;
        }
        case 12:
        {
            month = @"December";
            break;
        }
    }
    
    return month;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(self.showDetailView)
    {
    
        return nil;
    }
    else
    {
        NSString *headerText = [self getMonthWithInt:[[self.monthsUsed objectAtIndex:section] integerValue]];
    
        headerText = [headerText stringByAppendingString:@" - "];
    
        headerText = [headerText stringByAppendingString:[self.yearsUsed objectAtIndex:section]];
        
        return headerText;
    }
    
}
/*
#pragma mark UITableView Delegate & DataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {	
	NSArray *ar = self.dataDictionary[[self.monthView dateSelected]];
	if(ar == nil) return 0;
	return [ar count];
}
- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
	
    
	NSArray *ar = self.dataDictionary[[self.monthView dateSelected]];
	cell.textLabel.text = ar[indexPath.row];
	
    return cell;
	
}


- (void) generateRandomDataForStartDate:(NSDate*)start endDate:(NSDate*)end{
	// this function sets up dataArray & dataDictionary
	// dataArray: has boolean markers for each day to pass to the calendar view (via the delegate function)
	// dataDictionary: has items that are associated with date keys (for tableview)
	
	
	NSLog(@"Delegate Range: %@ %@ %@",start,end,@([start daysBetweenDate:end]));
	
	self.dataArray = [NSMutableArray array];
	self.dataDictionary = [NSMutableDictionary dictionary];
	
	NSDate *d = start;
	while(YES){
		
		NSInteger r = arc4random();
		if(r % 3==1){
			(self.dataDictionary)[d] = @[@"Item one",@"Item two"];
			[self.dataArray addObject:@YES];
			
		}else if(r%4==1){
			(self.dataDictionary)[d] = @[@"Item one"];
			[self.dataArray addObject:@YES];
			
		}else
			[self.dataArray addObject:@NO];
		
		
		NSDateComponents *info = [d dateComponentsWithTimeZone:self.monthView.timeZone];
		info.day++;
		d = [NSDate dateWithDateComponents:info];
		if([d compare:end]==NSOrderedDescending) break;
	}
	
}
*/



@end
