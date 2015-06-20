//
//  HelperMethods.h
//  School Intercom
//
//  Created by Randall Rumple on 12/3/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
UIKIT_EXTERN NSString * const HelperMethodsImageDownloadCompleted;

@interface HelperMethods : NSObject

+ (void)downloadAndSaveImagesToDiskWithFilename:(NSString *)fileName;
+ (void)downloadSingleImageFromBaseURL:(NSString *)baseURL withFilename:(NSString *)fileName saveToDisk:(BOOL)saveToDisk replaceExistingImage:(BOOL)replaceExistingImage;
+ (void)displayErrorUsingDictionary:(NSDictionary *)tempDic withTag:(NSInteger)tag andDelegate:(id)delegate;
+ (NSString *)encryptText:(NSString *)input;
+ (NSString *)prepStringForValidation:(NSString *)input;
+ (BOOL)isEmailValid:(NSString *)email;
+ (NSArray *)listFileAtPath:(NSString *)path;
+ (NSArray *)arrayOfGradeLevels;
+ (NSArray *)arrayOfPrefixes;
+ (NSString *)convertGradeLevel:(NSString *)gradeLevel appendGrade:(BOOL)addGradeText;
+ (NSString *)getDeviceModel;
+ (void)CreateAndDisplayOverHeadAlertInView:(UIView *)view withMessage:(NSString *)message andSchoolID:(NSString *)schoolID;
+ (NSArray *)getDateArrayFromString:(NSString *)date;
+ (NSArray *)getDictonaryOfUserTypes;
+ (NSString *)getMonthWithInt:(NSInteger)num shortName:(BOOL)shortName;
+ (NSArray *)ConvertHourUsingDateArray:(NSArray *)dateArray;
+ (NSString *)dateToStringMMddyyyy:(NSDate *)date;
+ (NSString *)dateToStringEEEMMddyyyy:(NSDate *)date;
+ (NSString *)dateToStringEEEMMddyyyyhhmma:(NSDate *)date;
@end
