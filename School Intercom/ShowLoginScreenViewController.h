//
//  ShowLoginScreenViewController.h
//  School Intercom
//
//  Created by Randall Rumple on 7/30/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RegisterViewController.h"
#import "MainNavigationController.h"
#import "IntroModel.h"
#import "RegistrationModel.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ShowLoginScreenViewController : UIViewController


@property (nonatomic, strong) NSDictionary *schoolData;

@end
