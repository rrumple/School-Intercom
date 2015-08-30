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
@property (nonatomic, strong) NSArray *tutorials;




@end


@implementation UserData

@synthesize schoolIDs = _schoolIDs;
@synthesize userID = _userID;
@synthesize schoolIDselected = _schoolIDselected;
@synthesize schoolDataArray = _schoolDataArray;
@synthesize userInfo = _userInfo;
@synthesize appData = _appData;
@synthesize teacherNames = _teacherNames;
@synthesize classData = _classData;
@synthesize usersClassData = _usersClassData;



- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.alertReceived = NO;
        self.viewToLoad = 999;
        self.schoolIDselected = [[NSUserDefaults standardUserDefaults]objectForKey:WORKING_SCHOOL_ID];
        
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:SCHOOL_DATA_ARRAY];
        
        self.schoolDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        //NSLog(@"SCHOOL DATA ARRAY: %@", self.schoolDataArray);
        
        for (NSDictionary *dic in self.schoolDataArray)
        {
            if ([[dic objectForKey:ID] isEqualToString:self.schoolIDselected])
            {
                self.schoolData = dic;
            }
        }

        self.schoolIDs = [[NSUserDefaults standardUserDefaults]objectForKey:SCHOOL_ID_ARRAY];
        //self.isPendingVerification = [[self.schoolData objectForKey:USER_IS_VERIFIED]boolValue];
        self.isPendingVerification = [[[NSUserDefaults standardUserDefaults]objectForKey:IS_PENDING_APPROVAL]boolValue];
        self.isApproved = [[[NSUserDefaults standardUserDefaults]objectForKey:USER_APPROVED]boolValue];
        self.isAccountCreated = [[[NSUserDefaults standardUserDefaults]objectForKey:ACCOUNT_CREATED]boolValue];
        self.wasPasswordReset = [[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_RESET]boolValue];
        self.hasPurchased = [[[NSUserDefaults standardUserDefaults]objectForKey:USER_HAS_PURCHASED]boolValue];
        self.userID = [[NSUserDefaults standardUserDefaults]objectForKey:USER_ID];
        self.userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
        self.isDemoInUse = [[[NSUserDefaults standardUserDefaults] objectForKey:IS_DEMO_IN_USE] boolValue];
        self.isAdmin = [[[NSUserDefaults standardUserDefaults]objectForKey:USER_IS_ADMIN] boolValue];
        self.accountType = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ACCOUNT_TYPE];
        self.teacherNames = [[NSUserDefaults standardUserDefaults]objectForKey:@"teacherNames"];
        self.classData = [[NSUserDefaults standardUserDefaults]objectForKey:@"classData"];
        self.usersClassData = [[NSUserDefaults standardUserDefaults]objectForKey:@"usersClassData"];
        if(![[NSUserDefaults standardUserDefaults]objectForKey:@"tutorials"])
        {
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            for (int i = 0; i < mvsvCount; i++)
            {
                [tempArray addObject:@"1"];
            }
            
            self.tutorials = tempArray;
        }
        
        else
            self.tutorials = [[NSUserDefaults standardUserDefaults]objectForKey:@"tutorials"];
                
        //NSLog(@"%@", self.schoolDataArray);
       // NSLog(@"%@", self.schoolIDs);
        
        self.isTimerExpired = true;
        self.remainingCounts = AD_REFRESH_RATE;
        self.isAdTestMode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isAdTestMode"]boolValue];
        
    }
    
    return self;
}

-(NSArray *)classData
{
    if (!_classData) _classData = [[NSArray alloc]init];
    return _classData;
}

-(NSArray *)usersClassData
{
    if (!_usersClassData) _usersClassData = [[NSArray alloc]init];
    return _usersClassData;
}

- (NSArray *)teacherNames
{
    if (!_teacherNames) _teacherNames = [[NSArray alloc]init];
    return _teacherNames;
}

- (NSArray *)newsData
{
    if (!_newsData) _newsData = [[NSArray alloc]init];
    return _newsData;
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

- (void)setAppData:(NSDictionary *)appData
{
    _appData = appData;
    [self sortNews];
}

- (void)setClassData:(NSArray *)classData
{
    _classData = classData;
    [[NSUserDefaults standardUserDefaults]setValue:classData forKey:@"classData"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setUsersClassData:(NSArray *)usersClassData
{
    _usersClassData = usersClassData;
    [[NSUserDefaults standardUserDefaults]setValue:usersClassData forKey:@"usersClassData"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setTeacherNames:(NSArray *)teacherNames
{
    _teacherNames = teacherNames;
    [[NSUserDefaults standardUserDefaults]setValue:teacherNames forKey:@"teacherNames"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
- (void)setTutorials:(NSArray *)tutorials
{
    _tutorials = tutorials;
    [[NSUserDefaults standardUserDefaults]setValue:tutorials forKeyPath:@"tutorials"];
    [[NSUserDefaults standardUserDefaults]synchronize];
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
    //NSLog(@"isDemoInUse set to %d",isDemoInUse);
}

- (void)setIsAdTestMode:(BOOL)isAdTestMode
{
    _isAdTestMode = isAdTestMode;
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",isAdTestMode] forKey:@"isAdTestMode"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


- (void)setIsAccountCreated:(BOOL)isAccountCreated
{
    _isAccountCreated = isAccountCreated;
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",isAccountCreated] forKey:ACCOUNT_CREATED];
    [[NSUserDefaults standardUserDefaults]synchronize];
    //NSLog(@"isAccountCreated set to %d",isAccountCreated);
}

- (void)setIsApproved:(BOOL)isApproved
{
    _isApproved = isApproved;
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d", isApproved] forKey:USER_APPROVED];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setisPendingVerification:(BOOL)isPendingVerification
{
    _isPendingVerification = isPendingVerification;
    //NSMutableDictionary *tempdic = [self.schoolData mutableCopy];
    //[tempdic setObject:[NSString stringWithFormat:@"%d", isPendingVerification] forKey:@"usApproved"];
    //[self updateSchoolDataInArray:tempdic];
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",isPendingVerification] forKey:IS_PENDING_APPROVAL];
    [[NSUserDefaults standardUserDefaults]synchronize];
   // NSLog(@"isRegisterd is set to %d", isPendingVerification);
}

- (void)setHasPurchased:(BOOL)hasPurchased
{
    _hasPurchased = hasPurchased;
    NSMutableDictionary *tempDic = [self.schoolData mutableCopy];
    [tempDic setObject:[NSString stringWithFormat:@"%d", hasPurchased] forKey:USER_HAS_PURCHASED];
    [self updateSchoolDataInArray:tempDic];
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d", hasPurchased] forKey:USER_HAS_PURCHASED];
    [[NSUserDefaults standardUserDefaults]synchronize];
    //NSLog(@"hasPurchased is set to %d", hasPurchased);
}

- (void)setAccountType:(NSString *)accountType
{
    _accountType = accountType;
    [[NSUserDefaults standardUserDefaults]setValue:accountType forKey:USER_ACCOUNT_TYPE];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setUserID:(NSString *)userID
{
    _userID = userID;
    [[NSUserDefaults standardUserDefaults] setValue:userID forKey:USER_ID];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)setIsAdmin:(BOOL)isAdmin
{
    _isAdmin = isAdmin;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d", isAdmin] forKey:USER_IS_ADMIN];
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
            //NSLog(@"%@", school);
            
            self.isApproved = [[school objectForKey:USER_APPROVED]boolValue];
            if(self.isApproved)
                self.isPendingVerification = NO;
            else
                self.isPendingVerification = YES;
            self.hasPurchased = [[school objectForKey:USER_HAS_PURCHASED]boolValue];
            self.schoolIDselected = schoolID;

        }
    }
}

- (NSDictionary *)getSchoolDataForSchoolID:(NSString *)schoolID
{
    NSDictionary *tempDic;
    for (NSDictionary *school in self.schoolDataArray)
    {
        if([[school objectForKey:ID] isEqualToString:schoolID])
        {
            tempDic = school;
            
        
        }
    }
    
    return tempDic;

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
    self.isPendingVerification = NO;
    self.isApproved = NO;
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
    self.isAdmin = NO;
    self.accountType = @"";
    self.teacherNames = @[];
    self.classData = @[];
    [self.adViewArray removeAllObjects];
    self.isTimerExpired = true;
    self.remainingCounts = AD_REFRESH_RATE;
    
    [self resetTutorials];
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
                    break;

                }
            }
        }
        
        for (NSDictionary *schoolDic in self.schoolDataArray)
        {
            if ([[schoolDic objectForKey:ID] isEqualToString:schoolID])
            {
                [schoolDataCopy removeObject:schoolDic];
                break;
            }
        }
        
        for (NSString *schoolIDFromArray in self.schoolIDs)
        {
            if ([schoolIDFromArray isEqualToString:schoolID])
            {
                [schoolIDsCopy removeObject:schoolIDFromArray];
                break;
            }

        }

        self.schoolDataArray = schoolDataCopy;
        self.schoolIDs = schoolIDsCopy;
        
    }
    
    
    return switchSchool;
}

- (void)resetTutorials
{
    NSMutableArray *tempArray = [self.tutorials mutableCopy];
   
    for (int i = 0; i < [tempArray count]; i++)
        tempArray[i] = @"1";
    
    self.tutorials = tempArray;
    
}

- (BOOL)getTutorialStatusOfView:(int)viewID
{
    return [self.tutorials[viewID] boolValue];
}

- (void)turnOffTutorialForView:(int)viewID
{
    NSMutableArray *tempArray = [self.tutorials mutableCopy];
    tempArray[viewID] = @"0";
    self.tutorials = tempArray;
}

- (void)turnOffTutorial
{
    NSMutableArray *tempArray = [self.tutorials mutableCopy];
    
    for (int i = 0; i < [tempArray count]; i++)
        tempArray[i] = @"0";
    
    self.tutorials = tempArray;
}

- (void)sortNews
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    
    if([self.appData objectForKey:@"newsData"] != (id)[NSNull null])
    {
        [tempArray addObjectsFromArray:[self.appData objectForKey:@"newsData"]];
        
    }
    if([self.appData objectForKey:@"corpNewsData"] != (id)[NSNull null])
    {
      [tempArray addObjectsFromArray:[self.appData objectForKey:@"corpNewsData"]];
    }
    if([self.appData objectForKey:@"teacherNewsData"] != (id)[NSNull null])
    {
        [tempArray addObjectsFromArray:[self.appData objectForKey:@"teacherNewsData"]];
    }
    if([self.appData objectForKey:@"classNewsData"] != (id)[NSNull null])
    {
        [tempArray addObjectsFromArray:[self.appData objectForKey:@"classNewsData"]];
    }
    
    
    if(tempArray != (id)[NSNull null])
    {
        self.newsData = tempArray;
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"newsDate"  ascending:NO];
        self.newsData = [self.newsData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    }
    
}

- (void)resetTeacherNamesAndUserClasses
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    NSMutableArray *tempArray2 = [[NSMutableArray alloc]init];
    self.teacherNames = tempArray;
    self.usersClassData = tempArray2;
}

- (void)addTeacherName:(NSDictionary *)teacher
{
    BOOL match = false;
    
    for(NSDictionary *name in self.teacherNames)
    {
        if([[name objectForKey:ID] isEqualToString:[teacher objectForKey:ID]])
        {
            match = true;
        }
    }
    
    if(!match)
    {
        NSMutableArray *tempArray = [self.teacherNames mutableCopy];
        [tempArray addObject:teacher];
    
        self.teacherNames = tempArray;
    }
    
}

- (void)addUserClass:(NSDictionary *)classData
{
    BOOL match = false;
    
    for(NSDictionary *class in self.usersClassData)
    {
        if([[class objectForKey:ID] isEqualToString:[classData objectForKey:ID]])
            match = true;
    }
    
    if(!match)
    {
        NSMutableArray *tempArray = [self.usersClassData mutableCopy];
        [tempArray addObject:classData];
        
        self.usersClassData = tempArray;
    }
}

- (void)removeTeacher:(NSString *)teacherID
{
    NSMutableArray *tempArray = [self.teacherNames mutableCopy];
    
    for(int i = 0; i < [self.teacherNames count]; i++)
    {
        if([[tempArray[i] objectForKey:ID] isEqualToString:teacherID])
        {
           [tempArray removeObjectAtIndex:i];
            break;
        }
    }
    
    self.teacherNames = tempArray;
}

- (NSString *)getTeacherName:(NSString *)teacherID
{
    for(NSDictionary *tempDic in self.teacherNames)
    {
        if([[tempDic objectForKey:ID]isEqualToString:teacherID])
            return [tempDic objectForKey:TEACHER_NAME];
    }
    
    return @"School Intercom";
}

- (NSString *)getClassName:(NSString *)classID
{
    for(NSDictionary *tempDic in self.classData)
    {
        if([[tempDic objectForKey:ID]isEqualToString:classID])
            return [tempDic objectForKey:@"className"];
    }
    
    return @"";
}

- (NSString *)getClassAndTeacherName:(NSString *)classID
{
    NSString *data = @"";
    
    for(NSDictionary *tempDic in self.usersClassData)
    {
        if([[tempDic objectForKey:ID]isEqualToString:classID])
            data = [NSString stringWithFormat:@"%@ - %@", [self getTeacherName:[tempDic objectForKey:TEACHER_ID]], [tempDic objectForKey:@"className"]];
    }
                    
    return data;
}

- (NSMutableArray *)getAd
{
    
    
    if(self.isTimerExpired)
    {
        [self.adViewArray removeAllObjects];
        return self.adViewArray;
        
    }
    else{
        return self.adViewArray;
    }
}


@end
