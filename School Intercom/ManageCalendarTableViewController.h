//
//  ManageCalendarTableViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 1/30/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdminModel.h"

@interface ManageCalendarTableViewController : UITableViewController

@property (nonatomic, strong) UserData *mainUserData;
@property (nonatomic, strong) NSDictionary *eventData;
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic) BOOL isNewEvent;


@end
