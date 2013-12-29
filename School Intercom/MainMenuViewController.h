//
//  MainMenuViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "CalendarMonthViewController.h"
#import "NewsViewController.h"
#import "ContactViewController.h"
#import "SwitchViewController.h"
#import "SettingsViewController.h"
#import "CalendarMonthViewController.h"


@interface MainMenuViewController : UIViewController <HomeViewControllerDelegate, NewsViewControllerDelegate, CalendarMonthViewControllerDelegate, ContactViewControllerDelegate, SwitchViewControllerDelegate, SettingsViewControllerDelegate>

@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic, strong) UserData *mainUserData;

@end
