//
//  ContactViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactModel.h"
#import "UserData.h"
#import <Google/Analytics.h>

@protocol ContactViewControllerDelegate;

@interface ContactViewController : UIViewController <UITextViewDelegate>
@property (nonatomic) CGFloat animatedDistance;
@property (nonatomic, weak) id<ContactViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *schoolData;
@property (nonatomic, strong) UserData *mainUserData;
@end

@protocol ContactViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end

