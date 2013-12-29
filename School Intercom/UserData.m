//
//  UserData.m
//  School Intercom
//
//  Created by RandallRumple on 11/20/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "UserData.h"

@interface UserData ()


@property (nonatomic, strong) NSArray *schoolIDs;
@property (nonatomic, strong) NSArray *schoolDataArray;


@end


@implementation UserData

@synthesize schoolIDs = _schoolIDs;
@synthesize userID = _userID;
@synthesize schoolIDselected = _schoolIDselected;
@synthesize schoolDataArray = _schoolDataArray;


- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.schoolIDselected = [[NSUserDefaults standardUserDefaults]objectForKey:WORKING_SCHOOL_ID];
        for (NSDictionary *dic in [[NSUserDefaults standardUserDefaults] objectForKey:SCHOOL_DATA_ARRAY])
        {
            if ([[dic objectForKey:SCHOOL_ID] isEqualToString:self.schoolIDselected])
            {
                self.schoolData = dic;
            }
        }

        self.schoolIDs = [[NSUserDefaults standardUserDefaults]objectForKey:SCHOOL_ID_ARRAY];
        self.isRegistered = [[self.schoolData objectForKey:USER_IS_VERIFIED]boolValue];
        self.isAccountCreated = [[[NSUserDefaults standardUserDefaults]objectForKey:ACCOUNT_CREATED]boolValue];
        self.userID = [[NSUserDefaults standardUserDefaults]objectForKey:USER_ID];
        

        
    }
    
    return self;
}

- (NSDictionary *)appData
{
    if (!_appData) _appData = [[NSDictionary alloc]init];
    return _appData;
}

- (NSDictionary *)schoolData
{
    if (!_schoolData) _schoolData = [[NSDictionary alloc]init];
    return _schoolData;
}

- (NSArray *)schoolDataArray
{
    if (!_schoolDataArray) _schoolDataArray = [[NSArray alloc]init];
    return  _schoolDataArray;
}

- (NSString *)userID
{
    if (!_userID) _userID = [[NSString alloc]init];
    return _userID;
}

- (NSString *)schoolIDselected
{
    if (!_schoolIDselected) _schoolIDselected = [[NSString alloc]init];
    return _schoolIDselected;
}

- (NSArray *)schoolIDs
{
    if(!_schoolIDs) _schoolIDs = [[NSArray alloc]init];
    return _schoolIDs;
}

- (void)setSchoolIDs:(NSArray *)schoolIDs
{
    _schoolIDs = schoolIDs;
    [[NSUserDefaults standardUserDefaults] setValue:schoolIDs forKey:SCHOOL_ID_ARRAY];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setIsAccountCreated:(BOOL)isAccountCreated
{
    _isAccountCreated = isAccountCreated;
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",isAccountCreated] forKey:ACCOUNT_CREATED];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"isAccountCreated set to %d",isAccountCreated);
}

- (void)setIsRegistered:(BOOL)isRegistered
{
    _isRegistered = isRegistered;
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",isRegistered] forKey:USER_IS_VERIFIED];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"isRegisterd is set to %d", isRegistered);
}

- (void)setUserID:(NSString *)userID
{
    _userID = userID;
    [[NSUserDefaults standardUserDefaults] setValue:userID forKey:USER_ID];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


- (void)setSchoolIDselected:(NSString *)schoolIDselected
{
    _schoolIDselected = schoolIDselected;
    [[NSUserDefaults standardUserDefaults] setValue:schoolIDselected forKey:WORKING_SCHOOL_ID];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setSchoolDataArray:(NSArray *)schoolDataArray
{
    _schoolDataArray = schoolDataArray;
    [[NSUserDefaults standardUserDefaults] setValue:schoolDataArray forKey:SCHOOL_DATA_ARRAY];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSUInteger)getNumberOfSchools
{
    return [self.schoolIDs count];

}

- (void)addSchoolIDtoArray:(NSString *)schoolID
{
    NSMutableArray *schoolIDS = [self.schoolIDs mutableCopy];
    [schoolIDS addObject:schoolID];
    self.schoolIDs = schoolIDS;
    self.isAccountCreated = YES;
    
}

- (void)addschoolDataToArray:(NSDictionary *)schoolData
{
    NSMutableArray *schoolDataArray = [self.schoolDataArray mutableCopy];
    [schoolDataArray addObject:schoolData];
    self.schoolDataArray = schoolDataArray;
    self.schoolData = schoolData;
    self.isRegistered = [[schoolData objectForKey:USER_IS_VERIFIED] boolValue];
}

@end
