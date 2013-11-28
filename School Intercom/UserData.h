//
//  UserData.h
//  School Intercom
//
//  Created by RandallRumple on 11/20/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface UserData : NSObject

@property (nonatomic) BOOL isRegistered;
@property (nonatomic) BOOL isAccountCreated;

- (NSUInteger)getNumberOfSchools;



@end
