//
//  HomeViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "HomeViewController.h"
@import AVFoundation;
#import "UIColor+TKCategory.h"


@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *schoolNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *alertTableView;
@property (nonatomic, strong) NSArray *alertData;
@property (nonatomic, strong) UpdateProfileModel *databaseData;
@property (weak, nonatomic) IBOutlet UIButton *adImageButton;
@property (nonatomic, strong) NSDictionary *adData;
@property (nonatomic, strong) AdModel *adModel;
@property (weak, nonatomic) IBOutlet UIView *overlay1;
@property (weak, nonatomic) IBOutlet UIView *helpOverlay;
@property (nonatomic, strong) UIRefreshControl *refreshControl;





@end

@implementation HomeViewController

- (UpdateProfileModel *)databaseData
{
    if(!_databaseData) _databaseData = [[UpdateProfileModel alloc]init];
    return _databaseData;
}

- (AdModel *)adModel
{
    if(!_adModel) _adModel = [[AdModel alloc]init];
    return _adModel;
}

- (void)setMainUserData:(UserData *)mainUserData
{
    _mainUserData = mainUserData;
    [self sortAlerts];
    [self.alertTableView reloadData];
    
    [self updateBadgeCount];
    
}

-(NSDictionary *)adData
{
    if(!_adData) _adData = [[NSDictionary alloc]init];
    return _adData;
}

-(NSArray *)alertData
{
    if(!_alertData) _alertData = [[NSArray alloc] init];
    return _alertData;
}

- (void)sortAlerts
{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    
    if([self.mainUserData.appData objectForKey:ALERT_DATA] != (id)[NSNull null])
    {
        [tempArray addObjectsFromArray:[self.mainUserData.appData objectForKey:ALERT_DATA]];

    }
    if([self.mainUserData.appData objectForKey:@"classAlerts"] != (id)[NSNull null])
    {
       [tempArray addObjectsFromArray:[self.mainUserData.appData objectForKey:@"classAlerts"]];
        
    }
    if([self.mainUserData.appData objectForKey:@"corpAlerts"] != (id)[NSNull null])
    {
       [tempArray addObjectsFromArray:[self.mainUserData.appData objectForKey:@"corpAlerts"]];
    }


    if(tempArray != (id)[NSNull null])
    {
        self.alertData = tempArray;
    
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:ALERT_TIME_SENT  ascending:NO];
        self.alertData=[self.alertData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    }


}

- (void)updateBadgeCount
{
    dispatch_queue_t createQueue = dispatch_queue_create("updateBadge", NULL);
    dispatch_async(createQueue, ^{
        NSArray *dataArray;
        dataArray = [self.databaseData zeroOutBadgeForSchoolID:self.mainUserData.schoolIDselected ofUser:self.mainUserData.userID];
        
        if (dataArray)
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@", [dataArray objectAtIndex:0]);
                
                
                if([[[dataArray objectAtIndex:0]objectForKey:@"error"] boolValue])
                {
                    //
                }
                else
                {
                  
                    int newBadgeNumber = [[[dataArray objectAtIndex:0]objectForKey:BADGE_COUNT]intValue];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i", newBadgeNumber] forKey:BADGE_COUNT];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:newBadgeNumber];
                    
                    [self.mainUserData updateBadgeCountsForSchools:[[dataArray objectAtIndex:0] objectForKey:@"schoolBadgeData"]];

                }
                
                
                
            });
            
        }
    });

}

- (IBAction)adImageClicked
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
                    NSLog(@"%@", tempDic);
                }
                else
                    [self loadAdImage];
            });
            
        }
    });

}


- (void)loadAdImage
{
    NSString *fileName = [self.adData objectForKey:AD_IMAGE_NAME];
    
    NSString *baseImageURL = [NSString stringWithFormat:@"%@%@%@", AD_IMAGE_URL, AD_DIRECTORY, fileName];
    
    NSLog(@"%@", baseImageURL);
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("get Image", NULL);
    dispatch_async(downloadQueue, ^{
        
        
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:baseImageURL]];
        dispatch_async(dispatch_get_main_queue(),^{
            UIImage *image = [UIImage imageWithData:data];
            [self.adImageButton setImage:image forState:UIControlStateNormal];
            //[spinner stopAnimating];
            NSLog(@"%f, %f", image.size.width, image.size.height);
        });
        
        
    });

}

- (void)getAdFromDatabase
{
    NSDictionary *schoolData = self.mainUserData.schoolData;
    NSLog(@"%@", schoolData);
    dispatch_queue_t createQueue = dispatch_queue_create("getLocalAd", NULL);
    dispatch_async(createQueue, ^{
        NSArray *adDataArray;
        adDataArray = [self.adModel getAdFromDatabase:[schoolData objectForKey:ID]];
        
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


- (void)viewWillAppear:(BOOL)animated
{
    
    
    [super viewWillAppear:animated];
    
    [self.schoolNameLabel setFont:FONT_CHARCOAL_CY(17.0f)];
    
    [self getAdFromDatabase];
    
    
}

- (void)refresh
{
    [self.refreshControl endRefreshing];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.alertTableView.dataSource = self;
    self.alertTableView.delegate = self;
    
    /*
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.backgroundColor = [UIColor greenColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    NSAttributedString *text = [[NSAttributedString alloc]initWithString:@"Refreshing Alerts"];
    self.refreshControl.attributedTitle = text;
    [self.alertTableView addSubview:self.refreshControl];
    */
    
    NSLog(@"HOME PAGE DATA RECIEVED: %@", self.mainUserData.appData);
    
    [self sortAlerts];
    
    
    
    
    
    NSDictionary *schoolData = self.mainUserData.schoolData;
    
    
    self.schoolNameLabel.text = [NSString stringWithFormat:@"My %@ Alerts!",[schoolData objectForKey:SCHOOL_NAME]];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self.mainUserData getTutorialStatusOfView:mv_Home])
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
    [self.mainUserData turnOffTutorialForView:mv_Home];
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

- (IBAction)menuPressed
{
    
   if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.alertData != (id)[NSNull null])
    {
    
        if([[[self.alertData objectAtIndex:indexPath.row ]objectForKey:ALERT_TEXT ] length] <= 70)
            return 60.0f;
        else if([[[self.alertData objectAtIndex:indexPath.row ]objectForKey:ALERT_TEXT ] length] <= 140)
            return 90.0f;
        else
            return 120.0f;
    }
    else
        return 44.0f;
}



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
    if(self.alertData != (id)[NSNull null])
        return [self.alertData count];
    else
        return 1;

}

-(UIColor *)getColorFromHex:(NSString *)str
{
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr +1, NULL, 16);
    
    return [UIColor colorWithHex:(unsigned int)x];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"alertCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    UILabel *cellLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *fromLabel = (UILabel *)[cell viewWithTag:4];
    
    UIView *backdrop = (UIView *)[cell viewWithTag:6];
    
    if(self.alertData != (id)[NSNull null])
    {
        /*
        NSArray *schoolInitials = [[self.mainUserData getSchoolNameFromID:[[self.alertData objectAtIndex:indexPath.row ]  objectForKey:SCHOOL_ID] ]componentsSeparatedByString:@" "];
        NSLog(@"%@", schoolInitials);
        NSString *newString = [[NSString alloc]init];
        
        for (NSString *tempString in schoolInitials)
        {
            newString = [newString stringByAppendingString:[tempString substringToIndex:1]];
        }
        */
        cellLabel.text = [[self.alertData objectAtIndex:indexPath.row]objectForKey:ALERT_TEXT];
        NSArray *tempDate = [HelperMethods getDateArrayFromString:[[self.alertData objectAtIndex:indexPath.row]objectForKey:ALERT_TIME_SENT]];
        
        dateLabel.text = [NSString stringWithFormat:@"%@/%@/%@", tempDate[1], tempDate[2], tempDate[0]];
        
        /*if([[[self.alertData objectAtIndex:indexPath.row]objectForKey:@"fromLabel"] length] > 1)
           fromLabel.text =[NSString stringWithFormat:@"From: %@", [[self.alertData objectAtIndex:indexPath.row]objectForKey:@"fromLabel"]];
        else
            fromLabel.text = @"";
        */
        
        if([[[self.alertData objectAtIndex:indexPath.row]objectForKey:@"fromSchoolID"] length] > 1)
        {

            switch([[[self.alertData objectAtIndex:indexPath.row]objectForKey:@"alertType"] intValue])
            {
                case 1: fromLabel.text = [NSString stringWithFormat:@"From: %@", [self.mainUserData getTeacherName:[[self.alertData objectAtIndex:indexPath.row]objectForKey:@"fromUserID"]]];
                    break;
                case 3: fromLabel.text = [NSString stringWithFormat:@"From: %@", [self.mainUserData getSchoolNameFromID:[[self.alertData objectAtIndex:indexPath.row]objectForKey:@"fromSchoolID"]]];
                    break;
                case 4: fromLabel.text = [NSString stringWithFormat:@"From: %@", [self.mainUserData getTeacherName:[[self.alertData objectAtIndex:indexPath.row]objectForKey:@"fromUserID"]]];
                    break;
                default:
                    fromLabel.text = @"";
                    break;
                    
                    
            }
        }
        else
            fromLabel.text = @"";

        
        [backdrop setBackgroundColor:[UIColor clearColor]];

        
        
        
    }
    else
        cellLabel.text = @"No Current Alerts";
    
    /*
    UIImageView *cellImage = (UIImageView *)[cell.contentView viewWithTag:1];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",docDir, [[self.alertData objectAtIndex:indexPath.row] objectForKey:SCHOOL_ID]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        cellImage.image = image;

    }
    
    */
    
    //cellImage.image = [UIImage imageNamed:@""];
    
    //[cell setBackgroundColor:self.accentColor];
    
    return cell;
}



@end
