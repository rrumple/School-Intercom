//
//  AdModel.h
//  School Intercom
//
//  Created by Randall Rumple on 2/16/14.
//  Copyright (c) 2014 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseRequest.h"

@interface AdModel : NSObject

- (NSArray *)getAdFromDatabase:(NSString *)schoolID;

- (NSArray *)updateAdClickCountInDatabse:(NSString *)adID fromSchool:(NSString *)schoolID;
@end
