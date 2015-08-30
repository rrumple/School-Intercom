//
//  LunchMenuViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 7/6/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "LunchMenuViewController.h"

@interface LunchMenuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIWebView *lunchMenuWebView;

@end

@implementation LunchMenuViewController

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
    [super viewWillAppear:animated];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Lunch_Menu_Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.headerLabel setFont:FONT_CHARCOAL_CY(17.0f)];
    // Do any additional setup after loading the view.
    
    NSURL *url = [[NSURL alloc]initWithString:[self.mainUserData.schoolData objectForKey:SCHOOL_LUNCH]];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    
    
    
    [self.lunchMenuWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)menuButtonPressed
{
    if([self.delegate respondsToSelector:@selector(snapshotOfViewAsImage:)])
    {
        [self.delegate snapshotOfViewAsImage:[UIView captureView:self.view]];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
