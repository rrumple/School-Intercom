//
//  UsersSchoolsTableViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 12/29/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleSchoolTableViewController.h"
#import "UserData.h"

@interface UsersSchoolsTableViewController : UITableViewController

@property (nonatomic, strong) NSString *userIDSelected;
@property (nonatomic, strong) UserData *mainUserData;
@property (nonatomic, strong) NSDictionary *schoolSelected;


- (void)getSchoolsForUserSelected;

@end
