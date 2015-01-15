//
//  AllSchoolsTableViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 1/4/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface AllSchoolsTableViewController : UITableViewController

@property (nonatomic, strong)UserData *mainUserData;
@property (nonatomic, strong)NSArray *existingSchools;
@property (nonatomic) BOOL isCorporationSearch;

@end
