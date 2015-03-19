//
//  SendAlertViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 12/5/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "AdminModel.h"

@interface SendAlertViewController : UIViewController
@property (nonatomic, strong) UserData* mainUserData;
@property (nonatomic) BOOL isEditing;
@property (nonatomic, strong) NSDictionary *alertToEdit;

@end
