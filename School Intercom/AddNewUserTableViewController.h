//
//  AddNewUserTableViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 1/4/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface AddNewUserTableViewController : UITableViewController
@property (nonatomic, strong) NSString *userTypeSelected;
@property (nonatomic, strong) NSDictionary *schoolSelected;
@property (nonatomic, strong) UserData *mainUserData;
@property (nonatomic, strong) NSDictionary *corpSelected;
@end
