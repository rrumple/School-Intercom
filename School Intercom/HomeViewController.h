//
//  HomeViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "AdModel.h"
#import "UpdateProfileModel.h"

@protocol HomeViewControllerDelegate;

@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<HomeViewControllerDelegate> delegate;
@property (nonatomic, strong) UserData *mainUserData;


@end

@protocol HomeViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end
