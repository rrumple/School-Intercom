//
//  SwitchViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "UpdateProfileModel.h"
#import "AdModel.h"
#import <Google/Analytics.h>


@protocol SwitchViewControllerDelegate;

@interface SwitchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<SwitchViewControllerDelegate> delegate;
@property (nonatomic, strong) UserData *mainUserData;


@end

@protocol SwitchViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

- (void)exitOutOfSchool;

@end

