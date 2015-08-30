//
//  ShowLoginScreenViewController.m
//  School Intercom
//
//  Created by Randall Rumple on 7/30/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "ShowLoginScreenViewController.h"
#import "SchoolIntercomIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "SwitchViewController.h"
#import <Google/Analytics.h>

@interface ShowLoginScreenViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *micImageView;
@property (weak, nonatomic) IBOutlet UILabel *schoolTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ShowLoginScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.activityView.layer setCornerRadius:30.0f];
    [self.activityView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.activityView.layer setBorderWidth:1.5f];
    [self.activityView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.activityView.layer setShadowOpacity:0.8];
    [self.activityView.layer setShadowRadius:3.0];
    [self.activityView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    [self setBackgroundImage];
}

-(UIColor *)getColorFromHex:(NSString *)str
{
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr +1, NULL, 16);
    
    return [UIColor colorWithHex:(unsigned int)x];
}

- (void)setBackgroundImage
{
    //NSLog(@"setBackGroundImage Called");
    
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, [self.schoolData objectForKey:SCHOOL_IMAGE_NAME] ];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        NSString *str1 = [NSString stringWithFormat:@"#%@",[self.schoolData objectForKey:SCHOOL_COLOR_2]];
        
        [self.schoolTitleLabel setTextColor:[self getColorFromHex:str1]];
        self.schoolTitleLabel.text = [NSString stringWithFormat:@"%@\nSchool Intercom", [self.schoolData objectForKey:SCHOOL_NAME] ];
        NSString *str = [NSString stringWithFormat:@"#%@",[self.schoolData objectForKey:SCHOOL_COLOR_1]];
        
        [self.micImageView setBackgroundColor:[self getColorFromHex:str]];
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        [self.logoImageView setImage:image];
        
        
        [self.logoImageView setHidden:NO];
        [self.micImageView setImage:[UIImage imageNamed:@"WelcomeScreen"]];
        
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(showHomeScreen) userInfo:nil repeats:NO];

    
}

- (void)showHomeScreen
{
    [self.timer invalidate];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
