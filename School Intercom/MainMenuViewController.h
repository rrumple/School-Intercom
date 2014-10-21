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
#import "SettingsTableViewController.h"
#import "CalendarMonthViewController.h"
#import "IntroModel.h"
#import "LunchMenuViewController.h"







@protocol MainMenuControllerDelegate;

@interface MainMenuViewController : UIViewController <HomeViewControllerDelegate, NewsViewControllerDelegate, CalendarMonthViewControllerDelegate, ContactViewControllerDelegate, SwitchViewControllerDelegate, SettingsTableViewControllerDelegate, LunchMenuViewControllerDelegate>

@property (nonatomic, weak) id<MainMenuControllerDelegate> delegate;
@property (nonatomic, strong) UserData *mainUserData;
@property (nonatomic) BOOL isFirstLoad;



@end

@protocol MainMenuControllerDelegate <NSObject>

- (void)signOut;

@end
