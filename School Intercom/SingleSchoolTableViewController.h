//
//  SingleSchoolTableViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 12/30/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface SingleSchoolTableViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *schoolData;
@property (nonatomic ,strong) UserData *mainUserData;

@end 