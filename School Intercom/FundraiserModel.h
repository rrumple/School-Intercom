//
//  FundraiserModel.h
//  School Intercom
//
//  Created by Randall Rumple on 2/8/15.
//  Copyright (c) 2015 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseRequest.h"

@interface FundraiserModel : NSObject

- (NSArray *)getFundraisersForSchool:(NSString *)schoolID;

@end
