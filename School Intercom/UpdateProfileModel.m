//
//  UpdateProfileModel.m
//  School Intercom
//
//  Created by Randall Rumple on 1/5/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "UpdateProfileModel.h"

@interface UpdateProfileModel ()

@property (nonatomic, strong) DatabaseRequest *databaseRequest;

@end

@implementation UpdateProfileModel

-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}

- (NSArray *)updatePasswordForUserID:(NSString *)userID withOldPassword:(NSString *)oldPassword andNewPassword:(NSString *)newPassword
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_PROFILE withKeys:@[USER_ID, OLD_PASSWORD, NEW_PASSWORD] andData:@[userID, oldPassword, newPassword]];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
}

- (NSArray *)updateProfileFromUserDicData:(NSDictionary *)userData
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_PROFILE withKeys:@[USER_ID, USER_FIRST_NAME, USER_LAST_NAME, USER_EMAIL] andData:@[userData[USER_ID], userData[USER_FIRST_NAME], userData[USER_LAST_NAME], userData[USER_EMAIL]]];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
}

- (NSArray *)getKidsInfoFromDatabase:(NSString *)userID
{
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_KIDS withKeys:@[USER_ID] andData:@[userID]];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;

}

- (NSArray *)updateKidFromKidDicData:(NSDictionary *)kidData
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_KID withKeys:@[KID_ID, KID_FIRST_NAME, KID_LAST_NAME, KID_GRADE_LEVEL, SCHOOL_ID, USER_ID] andData:@[kidData[KID_ID], kidData[KID_FIRST_NAME], kidData[KID_LAST_NAME], kidData[KID_GRADE_LEVEL], kidData[SCHOOL_ID], kidData[USER_ID]]];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;

}

- (NSArray *)deleteKidFromDatabase:(NSString *)kidID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_DELETE_KID withKeys:@[KID_ID] andData:@[kidID]];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;

}

- (NSArray *)zeroOutBadgeForSchoolID:(NSString *)schoolID ofUser:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_BADGE_UPDATE withKeys:@[SCHOOL_ID, USER_ID] andData:@[schoolID, userID]];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
    
}

- (NSArray *)changeSchoolStatusForUser:(NSString *)schoolID ofUser:(NSString *)userID isActive:(NSString *)isActive
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_CHANGE_SCHOOL_STATUS withKeys:@[SCHOOL_ID, USER_ID, USER_SCHOOL_IS_ACTIVE] andData:@[schoolID, userID, isActive]];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
}

@end
