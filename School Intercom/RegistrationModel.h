//
//  RegistrationModel.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseRequest.h"

@interface RegistrationModel : NSObject

@property (nonatomic, strong) NSArray *schoolArray;
@property (nonatomic, strong) NSArray *cityArray;
@property (nonatomic, strong) NSArray *stateArray;
@property (nonatomic, strong) NSArray *schoolDicsArray;
@property (nonatomic, strong) NSDictionary *schoolSelected;
@property (nonatomic, strong) NSString *userFirstName;
@property (nonatomic, strong) NSString *userLastName;
@property (nonatomic, strong) NSString *userEmailAddress;
@property (nonatomic, strong) NSString *userPassword;
@property (nonatomic, strong) NSString *numberOfChildren;
@property (nonatomic, strong) NSString *childFirstName;
@property (nonatomic, strong) NSString *childLastName;
@property (nonatomic, strong) NSString *childGradeLevel;




- (NSArray *)queryDatabaseForStates;

- (NSArray *)queryDatabaseForCitiesUsingState:(NSString *)state;

- (NSArray *)queryDatabaseForSchoolsUsingState:
    (NSString *)state andCity:(NSString *)city;

- (NSArray *)addUserToDatabase;

- (NSArray *)addChildToDatabaseWithUserID:(NSString *)userID;

@end
