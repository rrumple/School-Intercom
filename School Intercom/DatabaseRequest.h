//
//  DatabaseRequest.h
//  SchoolApp
//
//  Created by RandallRumple on 11/10/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseRequest : NSObject

+(NSString *)buildURLUsingFilename:(NSString *)fileName withKeys:(NSArray *)keys andData:(NSArray *)data;

-(NSArray *)performRequestToDatabaseWithURLasString:(NSString *)url;

@end
