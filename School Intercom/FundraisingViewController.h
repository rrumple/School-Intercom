//
//  FundraisingViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 2/7/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@protocol FundraisingViewControllerDelegate;

@interface FundraisingViewController : UIViewController

@property (nonatomic, weak) id<FundraisingViewControllerDelegate> delegate;
@property (nonatomic, strong) UserData *mainUserData;

@end

@protocol FundraisingViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end