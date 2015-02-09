//
//  FundraiserModel.m
//  School Intercom
//
//  Created by Randall Rumple on 2/8/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import "FundraiserModel.h"

@interface FundraiserModel()
@property (nonatomic, strong) DatabaseRequest *databaseRequest;
@end

@implementation FundraiserModel

-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}

- (NSArray *)getFundraisersForSchool:(NSString *)schoolID
{
    NSArray *keys = @[SCHOOL_ID];
    NSArray *data = @[schoolID];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_FUNDRAISER_DATA withKeys:keys andData:data];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    
    return dataArray;

}


@end
