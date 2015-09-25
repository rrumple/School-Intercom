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

- (void)setUserPassword:(NSString *)userPassword
{
    _userPassword = [HelperMethods encryptText:userPassword];
    //NSLog(@"%lul", (unsigned long)[_userPassword length]);
}

- (NSArray *)queryDatabaseForStates
{
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_STATES withKeys:nil andData:nil];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return [self processArray:dataArray withKey:SCHOOL_STATE];

}

- (NSArray *)queryDatabaseForCitiesUsingState:(NSString *)state
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_CITIES withKeys:@[SCHOOL_STATE] andData:@[state]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return [self processArray:dataArray withKey:SCHOOL_CITY];
}


- (NSArray *)queryDatabaseForSchoolsUsingState:(NSString *)state andCity:(NSString *)city
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_SCHOOLS withKeys:@[SCHOOL_STATE, SCHOOL_CITY] andData:@[state, city]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.schoolDicsArray = dataArray;
    });
    
    return [self processArray:dataArray withKey:SCHOOL_NAME];

}

- (NSArray *)queryDatabaseForTeachersAtSchool:(NSString *)schoolID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_TEACHERS withKeys:@[SCHOOL_ID] andData:@[schoolID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;

}

- (NSArray *)queryDatabaseForSchoolsUsingStateWithNoArrayProcessing:(NSString *)state andCity:(NSString *)city andUserID:(NSString *)userID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_SCHOOLS withKeys:@[SCHOOL_STATE, SCHOOL_CITY, USER_ID] andData:@[state, city, userID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.schoolDicsArray = dataArray;
    });
    
    return dataArray;
    
}

- (NSArray *)addAdditionalSchoolToUser:(NSString *)userID andSchool:(NSString *)schoolID
{
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADD_SCHOOL_TO_USER withKeys:@[USER_ID, SCHOOL_ID] andData:@[userID, schoolID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;

}

- (NSArray *)addUserToDatabase
{
    
    NSArray *keys = @[SCHOOL_ID, USER_FIRST_NAME, USER_LAST_NAME, USER_EMAIL, US_NUMBER_OF_KIDS, USER_PASSWORD];
    NSArray *data = @[[self.schoolSelected objectForKey:ID], self.userFirstName, self.userLastName, self.userEmailAddress, self.numberOfChildren, self.userPassword];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADD_USER withKeys:keys andData:data];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
}

- (NSArray *)addChildToDatabaseWithUserID:(NSString *)userID
{
    NSArray *keys = @[USER_ID, SCHOOL_ID, KID_FIRST_NAME, KID_LAST_NAME, @"classID"];
    NSArray *data = @[userID, [self.schoolSelected objectForKey:ID], self.childFirstName, self.childLastName, self.childGradeLevel];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADD_KID withKeys:keys andData:data];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
   
}

- (NSDictionary *)getUserInfoAsDictionary
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    
    [userInfo setObject:self.userFirstName forKey:USER_FIRST_NAME];
    [userInfo setObject:self.userLastName forKey:USER_LAST_NAME];
    [userInfo setObject:self.userEmailAddress forKey:USER_EMAIL];
    
    return userInfo;
}

- (NSArray *)updateUserPushNotificationPinForUserID:(NSString *)userID withPin:(NSString *)deviceToken
{
    NSArray *keys = @[USER_ID, USER_PUSH_NOTIFICATION_PIN];
    NSArray *data = @[userID, deviceToken];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_USER_PUSH_PIN withKeys:keys andData:data];
    NSArray *dataArray;
    
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
    
}

- (NSArray *)updateUserVersionAndModelUserID:(NSString *)userID withVersion:(NSString *)version andModel:(NSString *)model andAppVersion:(NSString *)appleAppVersion
{
    NSArray *dataArray;
    NSArray *keys = @[USER_ID, DEVICE_VERSION, DEVICE_MODEL, @"appleAppVersion"];
    NSArray *data = @[userID, version, model, appleAppVersion];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_DEVICE_VERSION withKeys:keys andData:data];
    
        
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
    
}

- (NSArray *)getCurrentAppVersion
{
    NSArray *dataArray;
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_CURRENT_VERSION withKeys:@[] andData:@[]];
    
    
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
    
}

- (NSArray *)sendEmailToRequestSchoolAdditionBy:(NSString *)name emailAddress:(NSString *)email forSchoolNamed:(NSString *)schoolName inCity:(NSString *)city inState:(NSString *)state withSchoolContactName:(NSString *)schoolContactName
{
    NSArray *keys = @[@"name", SCHOOL_NAME, @"city", @"state", @"contactName", @"email"];
    NSArray *data = @[name, schoolName, city, state, schoolContactName, email];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_ADD_SCHOOL_EMAIL withKeys:keys andData:data];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
    
    
}

- (NSArray *)sendAPNSResponseForMessage:(NSString *)messageID
{
    {
        NSArray *dataArray;
        NSArray *keys = @[MESSAGE_ID];
        NSArray *data = @[messageID];
        
        NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_APNS_RESPONSE withKeys:keys andData:data];
        
        
        dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
        
        return dataArray;
        
    }

}



@end
