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
@property (nonatomic) BOOL hasPurchased;
@property (nonatomic) BOOL wasPasswordReset;
@property (nonatomic) BOOL isDemoInUse;
@property (nonatomic) BOOL isAdmin;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *schoolIDselected;
@property (nonatomic, strong) NSDictionary *schoolData;
@property (nonatomic, strong) NSDictionary *appData;
@property (nonatomic, strong) NSDictionary *userInfo;


- (NSUInteger)getNumberOfSchools;

- (void)addSchoolIDtoArray:(NSString *)schoolID;

- (void)addschoolDataToArray:(NSDictionary *)schoolData;

- (void)addSchoolIDsFromArray:(NSArray *)schoolIDs;

- (void)updateSchoolDataInArray:(NSDictionary *)schoolData;

- (BOOL)checkForASchoolIDMatch:(NSString *)schoolIDtoCheck;

- (void)setActiveSchool:(NSString *)schoolID;

- (void)showAllSchoolsInNSLOG;

- (NSArray *)getAllofUsersSchools;

- (NSString *)getSchoolNameFromID:(NSString *)schoolID;

- (void)updateBadgeCountsForSchools:(NSArray *)schoolBadgeData;

- (void)clearAllData;

- (BOOL)removeSchoolFromPhone:(NSString *)schoolID;



@end
