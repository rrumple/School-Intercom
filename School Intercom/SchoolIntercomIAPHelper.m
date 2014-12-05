//
//  SchoolIntercomIAPHelper.m
//  School Intercom
//
//  Created by Randall Rumple on 5/3/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import "SchoolIntercomIAPHelper.h"

@implementation SchoolIntercomIAPHelper

+ (SchoolIntercomIAPHelper *)sharedInstance
{
    static dispatch_once_t once;
    static SchoolIntercomIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [self getProductIdentifiersFromDatabase];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    
    return sharedInstance;
}

+ (NSSet *)getProductIdentifiersFromDatabase
{
    NSMutableSet *tempSet = [[NSMutableSet alloc] init];
    DatabaseRequest *databaseRequest = [[DatabaseRequest alloc]init];
    //dispatch_queue_t createQueue = dispatch_queue_create("getProductIDs", NULL);
    //dispatch_async(createQueue, ^{
        NSString *urlString = [DatabaseRequest buildURLUsingFilename:PHP_GET_PRODUCT_IDS withKeys:nil andData:nil];
        NSArray *dataArray;
        dataArray = [databaseRequest performRequestToDatabaseWithURLasString:urlString];
        
        if ([dataArray count] > 0)
        {
            if([dataArray isKindOfClass:[NSArray class]])
            {
                //dispatch_async(dispatch_get_main_queue(), ^{
                
                for(NSDictionary *tempDic in dataArray)
                {
                    [tempSet addObject:[tempDic objectForKey:ID]];
                }
                
                
                NSLog(@"%@", tempSet);
                // });

            }
            
        }
    //});
    
    
    return tempSet;
}

@end
