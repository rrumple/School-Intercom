//
//  UpdateKidViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 7/28/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateProfileModel.h"

@interface UpdateKidViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSDictionary *kidData;
@property (nonatomic, strong) UserData *mainUserData;
@property (nonatomic) BOOL addingNewKid;
@end
