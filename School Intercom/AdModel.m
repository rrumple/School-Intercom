//
//  AdModel.m
//  School Intercom
//
//  Created by Randall Rumple on 2/16/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "AdModel.h"

@interface AdModel()
@property (nonatomic, strong) DatabaseRequest *databaseRequest;
@end

@implementation AdModel

-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}

- (NSArray *)getAdFromDatabase:(NSString *)schoolID
{
    NSArray *dataArray;
    NSArray *keys = @[SCHOOL_ID];
    NSArray *data = @[schoolID];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_LOAD_LOCAL_AD withKeys:keys andData:data];
    
    
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
    
}

- (NSArray *)updateAdClickCountInDatabse:(NSString *)adID fromSchool:(NSString *)schoolID
{
    NSArray *dataArray;
    NSArray *keys = @[AD_ID, SCHOOL_ID];
    NSArray *data = @[adID, schoolID];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_UPDATE_AD_CLICKED withKeys:keys andData:data];
    
    
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    return dataArray;
    
}


@end
