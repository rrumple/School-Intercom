//
//  MainMenuViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "CalendarViewController.h"
#import "NewsViewController.h"
#import "ContactViewController.h"
#import "SwitchViewController.h"

@interface MainMenuViewController : UIViewController <HomeViewControllerDelegate, NewsViewControllerDelegate, CalendarViewControllerDelegate, ContactViewControllerDelegate, SwitchViewControllerDelegate>

@property (nonatomic) BOOL isFirstLoad;

@end
