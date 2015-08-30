//
//  ManagePostTableViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 2/1/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdminModel.h"
#import <Google/Analytics.h>

@interface ManagePostTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UserData *mainUserData;
@property (nonatomic, strong) NSDictionary *postData;

@property (nonatomic) BOOL isNewPost;


@end
