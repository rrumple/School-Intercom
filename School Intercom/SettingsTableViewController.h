//
//  SettingsTableViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 12/29/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateProfileViewController.h"
#import "UpdateKidsViewController.h"
#import "AddSchoolViewController.h"
#import "AddGrandparentViewController.h"
#import <Google/Analytics.h>

@protocol SettingsTableViewControllerDelegate;

@interface SettingsTableViewController : UITableViewController
@property (nonatomic, strong) UserData *mainUserData;

@property (nonatomic, weak) id<SettingsTableViewControllerDelegate> delegate;

@end

@protocol SettingsTableViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end
