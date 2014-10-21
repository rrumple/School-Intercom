//
//  MainNavigationController.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenuViewController.h"

@interface MainNavigationController : UINavigationController <MainMenuControllerDelegate>

@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic, strong) UserData *mainUserData;

@end

