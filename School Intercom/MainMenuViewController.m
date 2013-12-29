//
//  MainMenuViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *screenShotView;

@end

@implementation MainMenuViewController


- (void)viewDidLoad
{

    [super viewDidLoad];
    
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
- (IBAction)calendarPressed
{
    CalendarMonthViewController *vc = [[CalendarMonthViewController alloc] initWithSunday:YES];
    vc.calendarData = [self.mainUserData.appData objectForKey:DIC_CALENDAR_DATA];
    vc.delegate = self;
    vc.backgroundColor = self.view.backgroundColor;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:SEGUE_TO_HOME_VIEW])
    {
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
        NewsViewController *VC = segue.destinationViewController;
        VC.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_CONTACT_VIEW])
    {
        ContactViewController *VC = segue.destinationViewController;
        VC.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_SWITCH_VIEW])
    {
        SwitchViewController *VC = segue.destinationViewController;
        VC.delegate = self;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_SETTINGS_VIEW])
    {
        SettingsViewController *SVC = segue.destinationViewController;
        SVC.delegate = self;
    }
}

@end
