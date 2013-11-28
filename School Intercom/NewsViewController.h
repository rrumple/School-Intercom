//
//  NewsViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewsViewControllerDelegate;

@interface NewsViewController : UIViewController

@property (nonatomic, weak) id<NewsViewControllerDelegate> delegate;

@end

@protocol NewsViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end
