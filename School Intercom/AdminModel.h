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

- (NSArray *)insertAlert:(NSString *)generalID withMessage:(NSString *)message ofType:(NSString *)alertType fromSchool:(NSString *)schoolID fromUser:(NSString *)fromUserID;

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

- (NSArray *)getCalendarEventsForUser:(NSString *)userID;

- (NSArray *)addEventForUser:(NSString *)userID withCalendarTitle:(NSString *)calTitle andLocation:(NSString *)calLoc andStartDate:(NSString *)startDate andEndDate:(NSString *)endDate andIsAllDay:(NSString *)isAllDay andMoreInfo:(NSString *)moreInfo forClassID:(NSString *)classID;

- (NSArray *)updateEvent:(NSString *)eventID withCalendarTitle:(NSString *)calTitle andLocation:(NSString *)calLoc andStartDate:(NSString *)startDate andEndDate:(NSString *)endDate andIsAllDay:(NSString *)isAllDay andMoreInfo:(NSString *)moreInfo;

- (NSArray *)deleteEvent:(NSString *)eventID;

- (NSArray *)getNewsPostsforUser:(NSString *)userID;

- (NSArray *)addNewsForUser:(NSString *)userID withNewsTitle:(NSString *)newsTitle andText:(NSString *)newsText andNewsImageName:(NSString *)newsImageName andNewsDate:(NSString *)newsDate sendAlert:(NSString *)sendAlert classID:(NSString *)classID;

- (NSArray *)updateNews:(NSString *)newsID withNewsTitle:(NSString *)newsTitle andText:(NSString *)newsText andNewsImageName:(NSString *)newsImageName andNewsDate:(NSString *)newsDate;

- (NSArray *)deleteNews:(NSString *)newsID;

- (NSArray *)getParentsOfTeacher:(NSString *)teacherID;

- (NSArray *)getParentsOfClass:(NSString *)classID;

- (NSArray *)getTeachersOfPrincipal:(NSString *)userID;

- (NSArray *)getPrincipalsOfSuperintendent:(NSString *)userID;

- (NSArray *)getSchoolStats:(NSString *)schoolID forUserID:(NSString *)userID;


- (NSArray *)getAlertsSubmittedByUser:(NSString *)userID;

- (NSArray *)deleteAlert:(NSString *)alertID;

- (NSArray *)updateAlert:(NSString *)alertID withText:(NSString *)text userMakingChange:(NSString *)userID;

- (NSArray *)addClassForUser:(NSString *)userID withClassName:(NSString *)className andPeriod:(NSString *)period andGradeLevel:(NSString *)gradeLevel;

- (NSArray *)updateClass:(NSString *)classID withClassName:(NSString *)className andPeriod:(NSString *)period andGradeLevel:(NSString *)gradeLevel;

-(NSArray *)getTeacherClasses:(NSString *)userID;

- (NSArray *)deleteClass:(NSString *)classID;

@end
