//
//  HelperMethods.h
//  School Intercom
//
//  Created by Randall Rumple on 12/3/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelperMethods : NSObject

+ (void)downloadAndSaveImagesToDiskWithFilename:(NSString *)fileName;
+ (void)downloadSingleImageFromBaseURL:(NSString *)baseURL withFilename:(NSString *)fileName saveToDisk:(BOOL)saveToDisk replaceExistingImage:(BOOL)replaceExistingImage;
+ (void)displayErrorUsingDictionary:(NSDictionary *)tempDic withTag:(NSInteger)tag andDelegate:(id)delegate;
+ (NSString *)encryptText:(NSString *)input;
+ (BOOL)isEmailValid:(NSString *)email;
+ (NSArray *)listFileAtPath:(NSString *)path;
@end
