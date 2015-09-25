//
//  LandscapeNavigationController.m
//  School Intercom
//
//  Created by Randall Rumple on 12/15/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "LandscapeNavigationController.h"
#import "AdStatsViewController.h"

@interface LandscapeNavigationController ()

@end

@implementation LandscapeNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AdStatsViewController *ASVC = [[self viewControllers]objectAtIndex:0];
    ASVC.mainUserData = self.mainUserData;
   

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
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
