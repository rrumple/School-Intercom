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
+ (void)displayErrorUsingDictionary:(NSDictionary *)tempDic;

@end
