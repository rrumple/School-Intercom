//
//  NewsViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NewsDetailViewController.h"
#import "AdModel.h"
#import "UserData.h"
#import <Google/Analytics.h>



@protocol NewsViewControllerDelegate;

@interface NewsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<NewsViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *newsData;
@property (nonatomic, strong) NSString *newsHeader;
@property (nonatomic, strong) NSString *schoolID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) UserData *mainUserData;


@end

@protocol NewsViewControllerDelegate <NSObject>

- (void)snapshotOfViewAsImage:(UIImage *)image;

@end
