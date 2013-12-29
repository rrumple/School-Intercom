//
//  SettingsViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 12/22/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController

@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;

@end

@protocol SettingsViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end