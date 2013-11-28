//
//  CalendarViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarViewControllerDelegate;

@interface CalendarViewController : UIViewController

@property (nonatomic, weak) id<CalendarViewControllerDelegate> delegate;

@end

@protocol CalendarViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end

