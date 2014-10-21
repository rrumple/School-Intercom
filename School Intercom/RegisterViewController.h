//
//  RegisterViewController.h
//  School Intercom
//
//  Created by RandallRumple on 11/21/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegistrationModel.h"

@protocol RegisterViewControllerDelegate;

@interface RegisterViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<RegisterViewControllerDelegate> delegate;
@property (nonatomic, strong) UserData *mainUserData;

@end

@protocol RegisterViewControllerDelegate <NSObject>

- (void)loginToDemoAccount;

@end
