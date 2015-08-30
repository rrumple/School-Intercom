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

@property (nonatomic) BOOL isPendingVerification;
@property (nonatomic) BOOL isApproved;
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
@property (nonatomic, strong) NSString *accountType;
@property (nonatomic, strong) NSArray *newsData;
@property (nonatomic, strong) NSArray *teacherNames;
@property (nonatomic, strong) NSArray *classData;
@property (nonatomic, strong) NSArray *usersClassData;
@property (nonatomic, strong) NSMutableArray *adViewArray;
@property (nonatomic) int remainingCounts;
@property (nonatomic) BOOL isTimerExpired;
@property (nonatomic) BOOL isAdTestMode;
@property (nonatomic) BOOL alertReceived;
@property (nonatomic) int viewToLoad;



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

- (void)resetTutorials;

- (BOOL)getTutorialStatusOfView:(int)viewID;

- (void)turnOffTutorialForView:(int)viewID;

- (void)turnOffTutorial;

- (void)addTeacherName:(NSDictionary *)teacher;

- (void)removeTeacher:(NSString *)teacherID;

- (NSString *)getTeacherName:(NSString *)teacherID;

- (NSString *)getClassName:(NSString *)classID;

- (void)addUserClass:(NSDictionary *)classData;

- (NSString *)getClassAndTeacherName:(NSString *)classID;

- (NSDictionary *)getSchoolDataForSchoolID:(NSString *)schoolID;

- (NSMutableArray *)getAd;

- (void)resetTeacherNamesAndUserClasses;

@end
