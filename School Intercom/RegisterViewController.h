//
//  RegisterViewController.h
//  School Intercom
//
//  Created by RandallRumple on 11/21/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegistrationModel.h"

@interface RegisterViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UserData *mainUserData;

@end
