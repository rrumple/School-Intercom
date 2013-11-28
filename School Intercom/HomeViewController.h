//
//  HomeViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeViewControllerDelegate;

@interface HomeViewController : UIViewController

@property (nonatomic, weak) id<HomeViewControllerDelegate> delegate;

@end

@protocol HomeViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end
