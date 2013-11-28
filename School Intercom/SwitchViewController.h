//
//  SwitchViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchViewControllerDelegate;

@interface SwitchViewController : UIViewController

@property (nonatomic, weak) id<SwitchViewControllerDelegate> delegate;

@end

@protocol SwitchViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end

