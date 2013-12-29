//
//  IntroModel.h
//  School Intercom
//
//  Created by Randall Rumple on 12/22/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseRequest.h"

@interface IntroModel : NSObject

- (NSArray *)queryDatabaseForSchoolsDataForUser:
(NSString *)userID andSchoolID:(NSString *)schoolID;

@end
