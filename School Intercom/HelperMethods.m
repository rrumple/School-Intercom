//
//  HelperMethods.m
//  School Intercom
//
//  Created by Randall Rumple on 12/3/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "HelperMethods.h"
#import <CommonCrypto/CommonDigest.h>

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

+ (void)downloadSingleImageFromBaseURL:(NSString *)baseURL withFilename:(NSString *)fileName saveToDisk:(BOOL)saveToDisk replaceExistingImage:(BOOL)replaceExistingImage
{
    
    NSString *baseImageURL = [NSString stringWithFormat:@"%@%@", baseURL, fileName];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, fileName];
        if(![[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
        {
            
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseImageURL]];
            NSLog(@"%@", baseImageURL);
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                if (!error)
                                                                {
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                                    
                                                                    NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                                                                    [data1 writeToFile:pngFilePath atomically:YES];
                                                                    NSLog(@"%@ download complete", fileName);
                                                                }
                                                            }];
            [task resume];
        }
        else if (replaceExistingImage)
        {
            pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, fileName];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseImageURL]];
            NSLog(@"%@", baseImageURL);
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                if (!error)
                                                                {
                                                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                                    
                                                                    NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
                                                                    [data1 writeToFile:pngFilePath atomically:YES];
                                                                    NSLog(@"%@ download complete", fileName);
                                                                }
                                                            }];
            [task resume];

        }
        else
            NSLog(@"%@ is already downloaded", fileName);
    

}

+ (void)displayErrorUsingDictionary:(NSDictionary *)tempDic withTag:(NSInteger)tag andDelegate:(id)delegate
{
    UIAlertView *userCreateError = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Error %i", [[tempDic objectForKey:@"errorCode"] intValue]] message:[tempDic objectForKey:@"msg"] delegate:delegate cancelButtonTitle:nil otherButtonTitles:@"Try Again", nil];
    
    userCreateError.tag = tag;
    
    [userCreateError show];
    
}

+ (NSString *)encryptText:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH *2];
    
    for(int i = 0;i < CC_SHA1_DIGEST_LENGTH;i++)
        [output appendFormat:@"%02x",digest[i]];
    
    return output;
}

+ (BOOL)isEmailValid:(NSString *)email
{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    if  ([emailTest evaluateWithObject:email] != YES && [email length]!=0)
        return NO;
    else
        return YES;
    
    
}

+(NSArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}



@end
