//
//  OfferViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 2/7/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import <Google/Analytics.h>

@protocol OfferViewControllerDelegate;

@interface OfferViewController : UIViewController

@property (nonatomic, weak) id<OfferViewControllerDelegate> delegate;
@property (nonatomic, strong) UserData *mainUserData;

@end

@protocol OfferViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end