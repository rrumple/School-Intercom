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

- (NSArray *)sendEmailTo:(NSString *)toUserID withSchoolID:(NSString *)schoolID withSubject:(NSString *)subject andMessage:(NSString *)message fromUser:(NSString *)userID
{
    NSArray *keys = @[ID, EMAIL_SUBJECT, EMAIL_BODY, USER_ID];
    NSArray *data = @[toUserID, subject, message, userID];
    
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_SEND_EMAIL withKeys:keys andData:data];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
  
    
    return dataArray;

}

@end
