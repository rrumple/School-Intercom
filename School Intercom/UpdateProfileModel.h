//
//  UpdateProfileModel.h
//  School Intercom
//
//  Created by Randall Rumple on 1/5/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseRequest.h"

@interface UpdateProfileModel : NSObject

- (NSArray *)updatePasswordForUserID:(NSString *)userID withOldPassword:(NSString *)oldPassword andNewPassword:(NSString *)newPassword;

- (NSArray *)updateProfileFromUserDicData:(NSDictionary *)userData;

- (NSArray *)getKidsInfoFromDatabase:(NSString *)userID;

- (NSArray *)queryDatabaseForTeachersAtSchool:(NSString *)schoolID;

- (NSArray *)getKidsTeachersFromDatabase:(NSString *)kidID;

- (NSArray *)updateKidFromKidDicData:(NSDictionary *)kidData;

- (NSArray *)deleteKidFromDatabase:(NSString *)kidID;

- (NSArray *)deleteClass:(NSString *)classID fromKidInDatabase:(NSString *)kidID;

- (NSArray *)addClass:(NSString *)classID ToKidInDatabase:(NSString *)kidID;

- (NSArray *)zeroOutBadgeForSchoolID:(NSString *)schoolID ofUser:(NSString *)userID;

- (NSArray *)changeSchoolStatusForUser:(NSString *)schoolID ofUser:(NSString *)userID isActive:(NSString *)isActive;

- (NSArray *)addGrandparent:(NSString *)firstName lastName:(NSString *)lastName withEmail:(NSString *)email parentUserId:(NSString *)userID atSchool:(NSString *)schoolID;

- (NSArray *)getGrandparentsOfUserID:(NSString *)userID;
@end
