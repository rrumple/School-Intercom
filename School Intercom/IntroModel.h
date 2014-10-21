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

- (NSArray *)queryDatabaseForSchoolsDataForUser:(NSString *)userID andSchoolID:(NSString *)schoolID;
- (NSArray *)loginExistingUserWithEmail:(NSString *)email andPassword:(NSString *)password;
- (NSArray *)restorePurchaseForUser:(NSString *)userID andSchool:(NSString *)schoolID;
- (NSArray *)resetPasswordForEmail:(NSString *)email;
- (NSArray *)checkAccountStatusofUserID:(NSString *)userID ofSchool:(NSString *)schoolID;
- (NSArray *)updateHasPurchasedinUserSchoolTable:(NSString *)userID ofSchool:(NSString *)schoolID hasPurchasedBOOL:(NSString *)hasPurchased;
@end
