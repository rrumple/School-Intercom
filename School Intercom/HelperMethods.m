//
//  HelperMethods.m
//  School Intercom
//
//  Created by Randall Rumple on 12/3/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "HelperMethods.h"

@implementation HelperMethods

+ (void)downloadAndSaveImagesToDiskWithFilename:(NSString *)fileName;
{
    NSString *baseImageURL = [IMAGE_URL stringByAppendingString:fileName];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray *suffixes = @[LOW_RES_SUFFIX, RETINA_SUFFIX, IPHONE5_SUFFIX];
    
    for( NSString *suffix in suffixes)
    {
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@%@",docDir, fileName, suffix];
        if(![[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
        {
            NSString *url = [baseImageURL stringByAppendingString:suffix];

            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                if (!error)
                                                                {
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                                    
                                                                    NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                                                                    [data1 writeToFile:pngFilePath atomically:YES];
                                                                    NSLog(@"%@, %@ download complete", fileName, suffix);
                                                                }
                                                            }];
            [task resume];
        }
        else
            NSLog(@"%@, %@ is already downloaded", fileName, suffix);
    }

}

+ (void)displayErrorUsingDictionary:(NSDictionary *)tempDic
{
    UIAlertView *userCreateError = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Error %i", [[tempDic objectForKey:@"errorCode"] intValue]] message:[tempDic objectForKey:@"msg"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Try Again", nil];
    
    userCreateError.tag = zAlertEmailError;
    
    [userCreateError show];
    
}
@end
