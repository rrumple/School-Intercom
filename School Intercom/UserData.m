//
//  UserData.m
//  School Intercom
//
//  Created by RandallRumple on 11/20/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "UserData.h"

@interface UserData ()

@property (nonatomic, strong) NSDictionary *workingSchoolDic;
@property (nonatomic, strong) NSArray *schoolIDs;

@end


@implementation UserData


@synthesize isAccountCreated = _isAccountCreated;

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        if([[NSUserDefaults standardUserDefaults]objectForKey:WORKING_SCHOOL_ID])
        {
            self.workingSchoolDic = [[NSUserDefaults standardUserDefaults]objectForKey:[[NSUserDefaults standardUserDefaults]objectForKey:WORKING_SCHOOL_ID]];
        }
        self.schoolIDs = [[NSUserDefaults standardUserDefaults]objectForKey:SCHOOL_ID_ARRAY];
        self.isRegistered = [[self.workingSchoolDic objectForKey:USER_IS_VERIFIED]boolValue];
        self.isAccountCreated = [[[NSUserDefaults standardUserDefaults]objectForKey:ACCOUNT_CREATED]boolValue];
        

        
    }
    
    return self;
}

- (NSArray *)schoolIDs
{
    if(!_schoolIDs) _schoolIDs = [[NSArray alloc]init];
    return _schoolIDs;
}

- (NSDictionary *)workingSchoolDic
{
    if(!_workingSchoolDic) _workingSchoolDic = [[NSDictionary alloc]init];
    return _workingSchoolDic;
}



- (void)setIsAccountCreated:(BOOL)isAccountCreated
{
    _isAccountCreated = isAccountCreated;
    [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%d",isAccountCreated] forKey:ACCOUNT_CREATED];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"isAccountCreated set to %d",isAccountCreated);
}


- (NSUInteger)getNumberOfSchools
{
    return [self.schoolIDs count];
}

@end
