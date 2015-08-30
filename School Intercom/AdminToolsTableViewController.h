//
//  AdminToolsTableViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 12/5/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import <Google/Analytics.h>

@protocol AdminToolsTableViewControllerDelegate;

@interface AdminToolsTableViewController : UITableViewController
@property (nonatomic, weak) id<AdminToolsTableViewControllerDelegate> delegate;
@property (nonatomic, strong) UserData *mainUserData;

@end


@protocol AdminToolsTableViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end