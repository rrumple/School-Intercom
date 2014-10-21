//
//  UpdateProfileViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 12/29/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateProfileModel.h"
#import "IntroModel.h"

@interface UpdateProfileViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, strong) UserData *mainUserData;
@end
