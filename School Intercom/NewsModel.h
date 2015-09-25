//
//  NewsModel.h
//  School Intercom
//
//  Created by Randall Rumple on 9/23/15.
//  Copyright © 2015 Randall Rumple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseRequest.h"

@interface NewsModel : NSObject

- (NSArray *)emailPDFtoUser:(NSString *)userID withNewsID:(NSString *)newsID;

@end
