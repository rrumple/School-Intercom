//
//  AddUpdateClassTableViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 8/15/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdminModel.h"
#import <Google/Analytics.h>

@interface AddUpdateClassTableViewController : UITableViewController

@property (nonatomic, strong) UserData *mainUserData;
@property (nonatomic, strong) NSDictionary *classData;

@property (nonatomic) BOOL isNewClass;

@end
