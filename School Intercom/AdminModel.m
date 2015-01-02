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

- (NSArray *)insertAlert:(NSString *)generalID withMessage:(NSString *)message ofType:(NSString *)alertType fromSchool:(NSString *)schoolID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_INSERT_ALERT withKeys:@[ID, ALERT_TEXT, ALERT_TYPE, SCHOOL_ID] andData:@[generalID, message, alertType, schoolID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
}

- (NSArray *)getAdStats:(NSString *)generalID ofType:(NSString *)queryType withSchoolID:(NSString *)schoolID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_AD_STATS withKeys:@[ID, @"queryType", SCHOOL_ID] andData:@[generalID, queryType, schoolID]];
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






@end
