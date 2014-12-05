//
//  IntroViewController.h
//  School Intercom
//
//  Created by RandallRumple on 11/20/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RegisterViewController.h"
#import "MainNavigationController.h"
#import "IntroModel.h"
#import "RegistrationModel.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface IntroViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, RegisterViewControllerDelegate>

@end
