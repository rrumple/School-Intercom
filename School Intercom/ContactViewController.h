//
//  ContactViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactViewControllerDelegate;

@interface ContactViewController : UIViewController

@property (nonatomic, weak) id<ContactViewControllerDelegate> delegate;

@end

@protocol ContactViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end

