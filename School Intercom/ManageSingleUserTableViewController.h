//
//  ManageSingleUserTableViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 12/29/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface ManageSingleUserTableViewController : UITableViewController

@property (nonatomic, strong) UserData *mainUserData;
@property (nonatomic, strong) NSString *userIDSelected;
@property (nonatomic, strong) NSString *queryType;
@property (nonatomic, strong) NSString *userTypeSelected;
@property (weak, nonatomic) IBOutlet UIButton *saveChangesButton;
@end
