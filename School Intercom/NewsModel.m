//
//  NewsModel.m
//  School Intercom
//
//  Created by Randall Rumple on 9/23/15.
//  Copyright © 2015 Randall Rumple. All rights reserved.
//

#import "NewsModel.h"

@interface NewsModel()

@property (nonatomic, strong) DatabaseRequest *databaseRequest;

@end

@implementation NewsModel

-(DatabaseRequest *)databaseRequest
{
    if(!_databaseRequest) _databaseRequest = [[DatabaseRequest alloc]init];
    return _databaseRequest;
}


- (NSArray *)emailPDFtoUser:(NSString *)userID withNewsID:(NSString *)newsID
{
    NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_EMAIL_PDF_ATTACHMENT withKeys:@[USER_ID, @"newsID"] andData:@[userID, newsID]];
    NSArray *dataArray;
    dataArray = [self.databaseRequest performRequestToDatabaseWithURLasString:urlString];
    
    
    return dataArray;
}
@end
