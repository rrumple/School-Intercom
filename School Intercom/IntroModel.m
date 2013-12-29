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
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:LOAD_DATA withKeys:@[USER_ID, SCHOOL_ID] andData:@[userID, schoolID]];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
}

@end
