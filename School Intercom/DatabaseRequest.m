//
//  DatabaseRequest.m
//  SchoolApp
//
//  Created by RandallRumple on 11/10/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "DatabaseRequest.h"

@interface DatabaseRequest ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation DatabaseRequest



+(NSString *)buildURLUsingFilename:(NSString *)fileName withKeys:(NSArray *)keys andData:(NSArray *)data
{
    
    
    NSMutableString *URLstring = [NSMutableString stringWithString:BASE_URL];
    
    [URLstring appendString:fileName];
    
    if ([keys count] == [data count])
    {
        for (int i = 0; i < [keys count]; i++)
        {
            if (i == 0)
            {
                [URLstring appendString:[NSString stringWithFormat:@"?%@=%@", keys[i],data[i]]];
            }
            else
            {
                [URLstring appendString:[NSString stringWithFormat:@"&%@=%@", keys[i], data[i]]];
            }
        }
        
        [URLstring setString:[URLstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"%@ request started", fileName);
        NSLog(@"URL - %@", URLstring);
        
        
    }
    

    
    return URLstring;
}

-(NSArray *)performRequestToDatabaseWithURLasString:(NSString *)url
{
    
    
        NSArray *dataArray;
        //NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    urlRequest.timeoutInterval = 10.0;
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
        if(data)
        {
            
                
                NSError *error1;
            
                dataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error1];
                NSLog(@"%@", dataArray);
                
            
        }
        else
        {
            dataArray = [[NSArray alloc]init];
            NSLog(@"Database connection failed");
        }
    
    
    return dataArray;
}

@end
