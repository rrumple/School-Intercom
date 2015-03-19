//
//  AdminModel.m
//  School Intercom
//
//  Created by Randall Rumple on 12/5/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "AdminModel.h"

@interface AdminModel ()

@property (nonatomic, strong) DatabaseRequest *databaseRequest;

@end

@implementation AdminModel

-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}

- (NSArray *)getAlertGroupsFromDatabase
{
        
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_ALERT_GROUPS withKeys:@[] andData:@[]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)getSecondaryAlertGroupsFromDatabase:(NSString *)generalID andQueryType:(NSString *)queryType
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_SECONDARY_ALERT_GROUP withKeys:@[ID, @"queryType"] andData:@[generalID, queryType]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;

}

- (NSArray *)insertAlert:(NSString *)generalID withMessage:(NSString *)message ofType:(NSString *)alertType fromSchool:(NSString *)schoolID fromUser:(NSString *)fromUserID;
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_INSERT_ALERT withKeys:@[ID, ALERT_TEXT, ALERT_TYPE, SCHOOL_ID, @"fromUserID"] andData:@[generalID, message, alertType, schoolID, fromUserID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
}

- (NSArray *)getAdStats:(NSString *)generalID ofType:(NSString *)queryType withSchoolID:(NSString *)schoolID withTimeframe:(NSString *)timeframe
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_AD_STATS withKeys:@[ID, @"queryType", SCHOOL_ID, @"timeframe"] andData:@[generalID, queryType, schoolID, timeframe]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;

}

- (NSArray *)updateApprovalStatusOfUser:(NSString *)userID withStatus:(NSString *)status withSchoolID:(NSString *)schoolID andMessage:(NSString *)message
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_USER_APPROVAL_STATUS withKeys:@[USER_ID, USER_APPROVED, SCHOOL_ID, VQ_MESSAGE] andData:@[userID, status, schoolID, message]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)getPendingNewUsersFromDatabaseForUser:(NSString *)userID withSchoolID:(NSString *)schoolID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_NEW_PENDING_USERS withKeys:@[USER_ID, SCHOOL_ID] andData:@[userID,schoolID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)queryDatabaseForUsers:(NSString *)generalID andQueryType:(NSString *)queryType forUserID:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_USERS withKeys:@[ID, @"queryType", USER_ID] andData:@[generalID, queryType, userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)queryDatabaseForSingleUser:(NSString *)generalID andQueryType:(NSString *)queryType forUserID:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_SINGLE_USER withKeys:@[ID, @"queryType", USER_ID] andData:@[generalID, queryType, userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)getSchoolsForSelectedUser:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_USERS_SCHOOLS withKeys:@[USER_ID] andData:@[userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)getSchoolsFromDatabaseForAccountType:(NSString *)accountType andID:(NSString *)generalID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_ALL_SCHOOLS withKeys:@[@"userType", ID] andData:@[accountType, generalID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)getAllCorpsForAccountType:(NSString *)accountType
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_ALL_CORPS withKeys:@[@"userType"] andData:@[accountType]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}



- (NSArray *)addUserToDatabseWithFirstName:(NSString *)fName andLastName:(NSString *)lName andUserType:(NSString *)userType andEmail:(NSString *)email toSchoolID:(NSString *)schoolID withPrefix:(NSString *)prefix andGrade:(NSString *)grade andSubject:(NSString *)subject andCorpID:(NSString *)corpID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADMIN_ADD_USER withKeys:@[USER_FIRST_NAME, USER_LAST_NAME, USER_EMAIL, USER_ACCOUNT_TYPE, SCHOOL_ID, TEACHER_PREFIX, GRADE_LEVEL, TEACHER_SUBJECT, CORP_ID] andData:@[fName, lName, email, userType, schoolID, prefix, grade, subject, corpID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)deleteUserFromDatabase:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADMIN_DELETE_USER withKeys:@[USER_ID] andData:@[userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)updateUserInDatabseWithFirstName:(NSString *)fName andLastName:(NSString *)lName andUserType:(NSString *)userType andEmail:(NSString *)email withPrefix:(NSString *)prefix andGrade:(NSString *)grade andSubject:(NSString *)subject andUserID:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADMIN_UPDATE_USER withKeys:@[USER_FIRST_NAME, USER_LAST_NAME, USER_EMAIL, USER_ACCOUNT_TYPE, TEACHER_PREFIX, GRADE_LEVEL, TEACHER_SUBJECT, USER_ID] andData:@[fName, lName, email, userType, prefix, grade, subject, userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)addSchoolToUser:(NSString *)userID withSchoolID:(NSString *)schoolID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADMIN_ADD_USER_SCHOOL withKeys:@[USER_ID, SCHOOL_ID] andData:@[userID, schoolID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)deleteSchoolFromUser:(NSString *)userID withSchoolID:(NSString *)schoolID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADMIN_DELETE_USER_SCHOOL withKeys:@[USER_ID, SCHOOL_ID] andData:@[userID, schoolID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)updateSchoolForUser:(NSString *)userSchoolsID isActive:(NSString *)isActive andIsApproved:(NSString *)usApproved
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADMIN_UPDATE_USER_SCHOOL withKeys:@[@"userSchoolsID", US_IS_ACTIVE, USER_APPROVED] andData:@[userSchoolsID, isActive, usApproved]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)getCalendarEventsForUser:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_USER_CALENDAR_EVENTS withKeys:@[USER_ID] andData:@[userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}


- (NSArray *)addEventForUser:(NSString *)userID withCalendarTitle:(NSString *)calTitle andLocation:(NSString *)calLoc andStartDate:(NSString *)startDate andEndDate:(NSString *)endDate andIsAllDay:(NSString *)isAllDay andMoreInfo:(NSString *)moreInfo
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADD_EVENT withKeys:@[USER_ID, CAL_TITLE, CAL_LOCATION, CAL_START_DATE, CAL_END_DATE, CAL_IS_ALL_DAY, CAL_MORE_INFO] andData:@[userID, calTitle, calLoc, startDate, endDate, isAllDay, moreInfo]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)updateEvent:(NSString *)eventID withCalendarTitle:(NSString *)calTitle andLocation:(NSString *)calLoc andStartDate:(NSString *)startDate andEndDate:(NSString *)endDate andIsAllDay:(NSString *)isAllDay andMoreInfo:(NSString *)moreInfo
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_EVENT withKeys:@[@"eventID", CAL_TITLE, CAL_LOCATION, CAL_START_DATE, CAL_END_DATE, CAL_IS_ALL_DAY, CAL_MORE_INFO] andData:@[eventID, calTitle, calLoc, startDate, endDate, isAllDay, moreInfo]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}


- (NSArray *)deleteEvent:(NSString *)eventID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_DELETE_EVENT withKeys:@[@"eventID"] andData:@[eventID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}


- (NSArray *)getNewsPostsforUser:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_USER_NEWS_POSTS withKeys:@[USER_ID] andData:@[userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}


- (NSArray *)addNewsForUser:(NSString *)userID withNewsTitle:(NSString *)newsTitle andText:(NSString *)newsText andNewsImageName:(NSString *)newsImageName andNewsDate:(NSString *)newsDate sendAlert:(NSString *)sendAlert
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADD_NEWS_POST withKeys:@[USER_ID, NEWS_TITLE, NEWS_TEXT, NEWS_IMAGE_NAME, NEWS_DATE, @"sendAlert"] andData:@[userID, newsTitle, newsText, newsImageName, newsDate, sendAlert]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)updateNews:(NSString *)newsID withNewsTitle:(NSString *)newsTitle andText:(NSString *)newsText andNewsImageName:(NSString *)newsImageName andNewsDate:(NSString *)newsDate
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_NEWS_POST withKeys:@[@"newsID", NEWS_TITLE, NEWS_TEXT, NEWS_IMAGE_NAME, NEWS_DATE] andData:@[newsID, newsTitle, newsText, newsImageName, newsDate]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}


- (NSArray *)deleteNews:(NSString *)newsID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_DELETE_NEWS_POST withKeys:@[@"newsID"] andData:@[newsID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)getParentsOfTeacher:(NSString *)teacherID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_PARENTS_OF_TEACHER withKeys:@[TEACHER_ID] andData:@[teacherID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)getSchoolStats:(NSString *)schoolID forUserID:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_SCHOOL_STATS withKeys:@[SCHOOL_ID, USER_ID] andData:@[schoolID, userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
}


- (NSArray *)getAlertsSubmittedByUser:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_ALERTS_SUBMITTED_BY_USER withKeys:@[USER_ID] andData:@[userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)deleteAlert:(NSString *)alertID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_DELETE_ALERT withKeys:@[@"alertID"] andData:@[alertID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
}

- (NSArray *)updateAlert:(NSString *)alertID withText:(NSString *)text userMakingChange:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_ALERT withKeys:@[@"alertID", USER_ID, ALERT_TEXT] andData:@[alertID, userID,text]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;

}



@end
