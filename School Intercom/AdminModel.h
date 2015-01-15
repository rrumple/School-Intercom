//
//  AdminModel.h
//  School Intercom
//
//  Created by Randall Rumple on 12/5/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseRequest.h"

@interface AdminModel : NSObject

- (NSArray *)getAlertGroupsFromDatabase;

- (NSArray *)getSecondaryAlertGroupsFromDatabase:(NSString *)generalID andQueryType:(NSString *)queryType;

- (NSArray *)insertAlert:(NSString *)generalID withMessage:(NSString *)message ofType:(NSString *)alertType fromSchool:(NSString *)schoolID;

- (NSArray *)getAdStats:(NSString *)generalID ofType:(NSString *)queryType withSchoolID:(NSString *)schoolID withTimeframe:(NSString *)timeframe;

- (NSArray *)updateApprovalStatusOfUser:(NSString *)userID withStatus:(NSString *)status withSchoolID:(NSString *)schoolID andMessage:(NSString *)message;

- (NSArray *)getPendingNewUsersFromDatabaseForUser:(NSString *)userID withSchoolID:(NSString *)schoolID;

- (NSArray *)queryDatabaseForUsers:(NSString *)generalID andQueryType:(NSString *)queryType forUserID:(NSString *)userID;

- (NSArray *)queryDatabaseForSingleUser:(NSString *)generalID andQueryType:(NSString *)queryType forUserID:(NSString *)userID;

- (NSArray *)getSchoolsForSelectedUser:(NSString *)userID;

- (NSArray *)getSchoolsFromDatabaseForAccountType:(NSString *)accountType andID:(NSString *)generalID;

- (NSArray *)getAllCorpsForAccountType:(NSString *)accountType;

- (NSArray *)addUserToDatabseWithFirstName:(NSString *)fName andLastName:(NSString *)lName andUserType:(NSString *)userType andEmail:(NSString *)email toSchoolID:(NSString *)schoolID withPrefix:(NSString *)prefix andGrade:(NSString *)grade andSubject:(NSString *)subject andCorpID:(NSString *)corpID;

- (NSArray *)deleteUserFromDatabase:(NSString *)userID;

- (NSArray *)updateUserInDatabseWithFirstName:(NSString *)fName andLastName:(NSString *)lName andUserType:(NSString *)userType andEmail:(NSString *)email withPrefix:(NSString *)prefix andGrade:(NSString *)grade andSubject:(NSString *)subject andUserID:(NSString *)userID;

- (NSArray *)addSchoolToUser:(NSString *)userID withSchoolID:(NSString *)schoolID;

- (NSArray *)deleteSchoolFromUser:(NSString *)userID withSchoolID:(NSString *)schoolID;

- (NSArray *)updateSchoolForUser:(NSString *)userSchoolID isActive:(NSString *)isActive andIsApproved:(NSString *)usApproved;

@end
