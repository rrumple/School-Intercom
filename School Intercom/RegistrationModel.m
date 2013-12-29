//
//  RegistrationModel.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "RegistrationModel.h"

@interface RegistrationModel ()

@property (nonatomic, strong) DatabaseRequest *databaseRequest;

@end

@implementation RegistrationModel

-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}

-(NSDictionary *)schoolSelected
{
    if(!_schoolSelected) _schoolSelected = [[NSDictionary alloc]init];
    return _schoolSelected;
}

-(NSArray *)processArray:(NSArray *)array withKey:(NSString *)key
{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    
    for(NSDictionary *tempDic in array)
    {
        [newArray addObject:[tempDic objectForKey:key]];
    }
    
    return newArray;

}

- (NSArray *)queryDatabaseForStates
{
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:GET_STATES withKeys:nil andData:nil];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return [self processArray:dataArray withKey:SCHOOL_STATE];

}

- (NSArray *)queryDatabaseForCitiesUsingState:(NSString *)state
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:GET_CITIES withKeys:@[SCHOOL_STATE] andData:@[state]];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return [self processArray:dataArray withKey:SCHOOL_CITY];
}

- (NSArray *)queryDatabaseForSchoolsUsingState:(NSString *)state andCity:(NSString *)city
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:GET_SCHOOLS withKeys:@[SCHOOL_STATE, SCHOOL_CITY] andData:@[state, city]];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.schoolDicsArray = dataArray;
    });
    
    return [self processArray:dataArray withKey:SCHOOL_NAME];

}

- (NSArray *)addUserToDatabase
{
    NSArray *keys = @[SCHOOL_ID, USER_FIRST_NAME, USER_LAST_NAME, USER_EMAIL, US_NUMBER_OF_KIDS, USER_PASSWORD];
    NSArray *data = @[[self.schoolSelected objectForKey:ID], self.userFirstName, self.userLastName, self.userEmailAddress, self.numberOfChildren, self.userPassword];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:ADD_USER withKeys:keys andData:data];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
}

- (NSArray *)addChildToDatabaseWithUserID:(NSString *)userID
{
    NSArray *keys = @[USER_ID, SCHOOL_ID, KID_FIRST_NAME, KID_LAST_NAME, KID_GRADE_LEVEL];
    NSArray *data = @[userID, [self.schoolSelected objectForKey:ID], self.childFirstName, self.childLastName, self.childGradeLevel];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:ADD_KID withKeys:keys andData:data];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
   
}

@end
