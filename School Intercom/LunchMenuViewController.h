//
//  LunchMenuViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 7/6/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"


@protocol LunchMenuViewControllerDelegate;

@interface LunchMenuViewController : UIViewController

@property (nonatomic, weak) id<LunchMenuViewControllerDelegate> delegate;
@property (nonatomic, strong) UserData *mainUserData;


@end

@protocol LunchMenuViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end
