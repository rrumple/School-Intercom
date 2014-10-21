//
//  ContactModel.m
//  School Intercom
//
//  Created by Randall Rumple on 1/2/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "ContactModel.h"
@interface ContactModel()
@property (nonatomic, strong) DatabaseRequest *databaseRequest;
@end

@implementation ContactModel

-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}

- (NSArray *)sendEmailToSchoolID:(NSString *)schoolID withSubject:(NSString *)subject andMessage:(NSString *)message fromUser:(NSString *)userID
{
    NSArray *keys = @[SCHOOL_ID, EMAIL_SUBJECT, EMAIL_BODY, USER_ID];
    NSArray *data = @[schoolID, subject, message, userID];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_SEND_EMAIL withKeys:keys andData:data];
    NSArray *dataArray = [[NSArray alloc] init];
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;

}

@end
