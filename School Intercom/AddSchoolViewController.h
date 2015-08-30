//
//  AddSchoolViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 12/29/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegistrationModel.h"
#import "IntroModel.h"
#import <Google/Analytics.h>

@interface AddSchoolViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UserData *mainUserData;

@end
