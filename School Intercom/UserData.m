//
//  UserData.m
//  School Intercom
//
//  Created by RandallRumple on 11/20/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "UserData.h"


@interface UserData ()



@property (nonatomic, strong) NSArray *schoolDataArray;
@property (nonatomic, strong) NSArray *schoolIDs;

@end


@implementation UserData

@synthesize schoolIDs = _schoolIDs;
@synthesize userID = _userID;
@synthesize schoolIDselected = _schoolIDselected;
@synthesize schoolDataArray = _schoolDataArray;
@synthesize userInfo = _userInfo;


- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.schoolIDselected = [[NSUserDefaults standardUserDefaults]objectForKey:WORKING_SCHOOL_ID];
        
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:SCHOOL_DATA_ARRAY];
        
        self.schoolDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSLog(@"SCHOOL DATA ARRAY: %@", self.schoolDataArray);
        
        for (NSDictionary *dic in self.schoolDataArray)
        {
            if ([[dic objectForKey:ID] isEqualToString:self.schoolIDselected])
            {
                self.schoolData = dic;
            }
        }

        self.schoolIDs = [[NSUserDefaults standardUserDefaults]objectForKey:SCHOOL_ID_ARRAY];
        //self.isRegistered = [[self.schoolData objectForKey:USER_IS_VERIFIED]boolValue];
        self.isRegistered = [[[NSUserDefaults standardUserDefaults]objectForKey:USER_IS_VERIFIED]boolValue];
        self.isAccountCreated = [[[NSUserDefaults standardUserDefaults]objectForKey:ACCOUNT_CREATED]boolValue];
        self.wasPasswordReset = [[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_RESET]boolValue];
        self.hasPurchased = [[[NSUserDefaults standardUserDefaults]objectForKey:USER_HAS_PURCHASED]boolValue];
        self.userID = [[NSUserDefaults standardUserDefaults]objectForKey:USER_ID];
        self.userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        self.isDemoInUse = [[[NSUserDefaults standardUserDefaults] objectForKey:IS_DEMO_IN_USE] boolValue];
        
                
        NSLog(@"%@", self.schoolDataArray);
        NSLog(@"%@", self.schoolIDs);
        
    }
    
    return self;
}

- (NSDictionary *)userInfo
{
    if (!_userInfo) _userInfo = [[NSDictionary alloc]init];
    return _userInfo;
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

- (void)setWasPasswordReset:(BOOL)wasPasswordReset
{
    _wasPasswordReset = wasPasswordReset;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", wasPasswordReset] forKey:PASSWORD_RESET];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setSchoolIDs:(NSArray *)schoolIDs
{
    _schoolIDs = schoolIDs;
    [[NSUserDefaults standardUserDefaults] setValue:schoolIDs forKey:SCHOOL_ID_ARRAY];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setIsDemoInUse:(BOOL)isDemoInUse
{
    _isDemoInUse = isDemoInUse;
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",isDemoInUse] forKey:IS_DEMO_IN_USE];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"isDemoInUse set to %d",isDemoInUse);
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
    NSMutableDictionary *tempdic = [self.schoolData mutableCopy];
    [tempdic setObject:[NSString stringWithFormat:@"%d", isRegistered] forKey:@"usApproved"];
    [self updateSchoolDataInArray:tempdic];
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",isRegistered] forKey:USER_IS_VERIFIED];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"isRegisterd is set to %d", isRegistered);
}

- (void)setHasPurchased:(BOOL)hasPurchased
{
    _hasPurchased = hasPurchased;
    NSMutableDictionary *tempDic = [self.schoolData mutableCopy];
    [tempDic setObject:[NSString stringWithFormat:@"%d", hasPurchased] forKey:USER_HAS_PURCHASED];
    [self updateSchoolDataInArray:tempDic];
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d", hasPurchased] forKey:USER_HAS_PURCHASED];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"hasPurchased is set to %d", hasPurchased);
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
    
    NSMutableArray *arr = [schoolDataArray copy];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr];
    
    
    [[NSUserDefaults standardUserDefaults] setValue:data forKey:SCHOOL_DATA_ARRAY];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


- (void)setUserInfo:(NSDictionary *)userInfo
{
    _userInfo = userInfo;
    [[NSUserDefaults standardUserDefaults] setValue:userInfo forKey:USER_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void)addSchoolIDsFromArray:(NSArray *)schoolIDs
{
    self.schoolIDs = schoolIDs;
    self.isAccountCreated = YES;
    self.schoolIDselected = [schoolIDs objectAtIndex:0];
}

- (void)addschoolDataToArray:(NSDictionary *)schoolData
{
    NSMutableArray *schoolDataArray = [self.schoolDataArray mutableCopy];
    
    if(![self.schoolDataArray containsObject:schoolData])
    {
        [schoolDataArray addObject:schoolData];
        self.schoolDataArray = schoolDataArray;
        [HelperMethods downloadSingleImageFromBaseURL:SCHOOL_LOGO_PATH withFilename:[NSString stringWithFormat:@"%@",[schoolData objectForKey:SCHOOL_IMAGE_NAME]] saveToDisk:YES replaceExistingImage:NO];

    }
    
    
}

- (void)updateSchoolDataInArray:(NSDictionary *)schoolData
{
    self.schoolData = schoolData;
    NSMutableArray *tempArray = [self.schoolDataArray mutableCopy];
    
    
    for (int i = 0; i < [tempArray count]; i++)
    {
        NSDictionary *dic = [tempArray objectAtIndex:i];
        
        if ([[dic objectForKey:ID] isEqualToString:[schoolData objectForKey:ID]])
        {
            [tempArray replaceObjectAtIndex:i withObject:schoolData];
            
            self.schoolDataArray = tempArray;
            break;
        }

        
    }
    
    

    
}

- (BOOL)checkForASchoolIDMatch:(NSString *)schoolIDtoCheck
{
    for (NSString *schoolID in self.schoolIDs)
    {
        if ([schoolID isEqualToString:schoolIDtoCheck])
        {
            return true;
        }
    }
    
    return false;
}

- (void)setActiveSchool:(NSString *)schoolID
{
    for (NSDictionary *school in self.schoolDataArray)
    {
        if([[school objectForKey:ID] isEqualToString:schoolID])
        {
            self.schoolData = school;
            NSLog(@"%@", school);
            self.isRegistered = [[school objectForKey:@"usApproved"]boolValue];
            self.hasPurchased = [[school objectForKey:USER_HAS_PURCHASED]boolValue];
            self.schoolIDselected = schoolID;

        }
    }
}

- (void)showAllSchoolsInNSLOG
{
    NSLog(@"%@", self.schoolDataArray);
}


- (NSArray *)getAllofUsersSchools
{
    return self.schoolDataArray;
}

- (NSString *)getSchoolNameFromID:(NSString *)schoolID
{
    for (NSDictionary *dic in self.schoolDataArray)
    {
        
        if ([[dic objectForKey:ID] isEqualToString:schoolID])
        {
            return [dic objectForKey:SCHOOL_NAME];
        }
    
    }
    
    return nil;

}

- (void)updateBadgeCountsForSchools:(NSArray *)schoolBadgeData
{
    
    NSMutableArray *tempArray = [self.schoolDataArray mutableCopy];
    
    
    for (int i = 0; i < [tempArray count]; i++)
    {
        
        for (NSDictionary *badgeDic in schoolBadgeData)
        {
            if ([[[tempArray objectAtIndex:i ] objectForKey:ID] isEqualToString:[badgeDic objectForKey:SCHOOL_ID]])
            {
                NSMutableDictionary *tempDic = [[tempArray objectAtIndex:i]mutableCopy];
                
                
                [tempDic setObject:[badgeDic objectForKey:BADGE_COUNT] forKey:BADGE_COUNT];
                
                [tempArray setObject:tempDic atIndexedSubscript:i];
                break;
            }

        }
        self.schoolDataArray = tempArray;
        
    }
    

}

- (void)clearAllData
{
    self.isRegistered = NO;
    self.isAccountCreated = NO;
    self.hasPurchased = NO;
    self.wasPasswordReset = NO;
    self.isDemoInUse = NO;
    self.userID = @"";
    self.schoolIDselected = @"";
    self.schoolData = @{};
    self.appData = @{};
    self.userInfo = @{};
    self.schoolDataArray = @[];
    self.schoolIDs = @[];
}

- (BOOL)removeSchoolFromPhone:(NSString *)schoolID
{
    BOOL switchSchool = NO;
    NSMutableArray *schoolDataCopy = [self.schoolDataArray mutableCopy];
    NSMutableArray *schoolIDsCopy = [self.schoolIDs mutableCopy];
    
    if([self getNumberOfSchools] == 1)
    {
        //can't remove school
    }
    else
    {
        if([[self.schoolData objectForKey:ID] isEqualToString:schoolID])
        {
            switchSchool = YES;
            
           
            
            for (NSDictionary *schoolDic in self.schoolDataArray)
            {
                if (![[schoolDic objectForKey:ID] isEqualToString:schoolID])
                {
                    [self setActiveSchool:[schoolDic objectForKey:ID]];

                }
            }
        }
        
        for (NSDictionary *schoolDic in self.schoolDataArray)
        {
            if ([[schoolDic objectForKey:ID] isEqualToString:schoolID])
            {
                [schoolDataCopy removeObject:schoolDic];
            }
        }
        
        for (NSString *schoolIDFromArray in self.schoolIDs)
        {
            if ([schoolIDFromArray isEqualToString:schoolID])
            {
                [schoolIDsCopy removeObject:schoolIDFromArray];
            }

        }

        self.schoolDataArray = schoolDataCopy;
        self.schoolIDs = schoolIDsCopy;
        
    }
    
    
    return switchSchool;
}




@end
