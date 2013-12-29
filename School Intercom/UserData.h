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
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *schoolIDselected;
@property (nonatomic, strong) NSDictionary *schoolData;
@property (nonatomic, strong) NSDictionary *appData;

- (NSUInteger)getNumberOfSchools;

- (void)addSchoolIDtoArray:(NSString *)schoolID;

- (void)addschoolDataToArray:(NSDictionary *)schoolData;



@end
