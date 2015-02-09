//
//  ContactModel.h
//  School Intercom
//
//  Created by Randall Rumple on 1/2/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseRequest.h"

@interface ContactModel : NSObject

- (NSArray *)sendEmailTo:(NSString *)toUserID withSchoolID:(NSString *)schoolID withSubject:(NSString *)subject andMessage:(NSString *)message fromUser:(NSString *)userID;

@end
