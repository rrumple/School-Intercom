//
//  IntroModel.m
//  School Intercom
//
//  Created by Randall Rumple on 12/22/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "IntroModel.h"

@interface IntroModel ()

@property (nonatomic, strong) DatabaseRequest *databaseRequest;

@end

@implementation IntroModel

-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}


- (NSArray *)queryDatabaseForSchoolsDataForUser:(NSString *)userID andSchoolID:(NSString *)schoolID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_LOAD_DATA withKeys:@[USER_ID, SCHOOL_ID] andData:@[userID, schoolID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
}

- (NSArray *)getUserInfofromTransactionID:(NSString *)transactionID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_EMAIL withKeys:@[US_TRANSACTION_ID] andData:@[transactionID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
}


- (NSArray *)loginExistingUserWithEmail:(NSString *)email andPassword:(NSString *)password andIsRestoring:(NSString *)isRestoring
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_LOGIN_USER withKeys:@[USER_EMAIL, USER_PASSWORD, @"isRestoring"] andData:@[email, password, isRestoring]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
}

- (NSArray *)resetPasswordForEmail:(NSString *)email
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_RESET_PASSWORD withKeys:@[USER_EMAIL] andData:@[email]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
}

- (NSArray *)checkAccountStatusofUserID:(NSString *)userID ofSchool:(NSString *)schoolID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_CHECK_STATUS withKeys:@[USER_ID, SCHOOL_ID] andData:@[userID, schoolID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
}

- (NSArray *)updateHasPurchasedinUserSchoolTable:(NSString *)userID ofSchool:(NSString *)schoolID hasPurchasedBOOL:(NSString *)hasPurchased withTransactionID:(NSString *)transactionID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_HAS_PURCHASED withKeys:@[USER_ID, SCHOOL_ID, USER_HAS_PURCHASED, US_TRANSACTION_ID] andData:@[userID, schoolID, hasPurchased, transactionID]];
    
    NSArray *dataArray;
                           
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
                           
}

- (NSArray *)restorePurchaseForUser:(NSString *)userID andSchool:(NSString *)schoolID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_RESTORE_PURCHASE withKeys:@[USER_ID, SCHOOL_ID] andData:@[userID, schoolID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;

}

- (NSArray *)updateTeacherNamesForUser:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_TEACHER_NAMES withKeys:@[USER_ID] andData:@[userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
}


@end
