//
//  HelperMethods.m
//  School Intercom
//
//  Created by Randall Rumple on 12/3/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "HelperMethods.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import <sys/sysctl.h>
#import "UserData.h"

NSString *const HelperMethodsImageDownloadCompleted = @"HelperMethodsImageDownloadCompleted";



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
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        [[NSNotificationCenter defaultCenter]postNotificationName:HelperMethodsImageDownloadCompleted object:nil];
                                                                        
                                                                    });

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
    
    NSLog(@"%@", output);
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

+ (NSArray *)arrayOfGradeLevels
{
    return @[@"K",
             @"1",
             @"2",
             @"3",
             @"4",
             @"5",
             @"6",
             @"7",
             @"8",
             @"9",
             @"10",
             @"11",
             @"12",
             @"SE"
             ];
}

+ (NSArray *)arrayOfPrefixes
{
    return @[@"Ms.",
             @"Miss",
             @"Mrs.",
             @"Mr.",
             @"Dr."
             ];
}


+ (NSString *)convertGradeLevel:(NSString *)gradeLevel appendGrade:(BOOL)addGradeText
{
    
    if([gradeLevel isEqualToString:@"K"])
        return @"Kindergarten";
    else if([gradeLevel isEqualToString:@"SE"])
        return @"Special Ed.";
    else
    {
        int gradeInt = [gradeLevel intValue];
        
        switch (gradeInt)
        {
            case 1:
                return [NSString stringWithFormat:@"%@st", gradeLevel];
                break;
            case 2:
                return [NSString stringWithFormat:@"%@nd", gradeLevel];
                break;
            case 3:
                return [NSString stringWithFormat:@"%@rd", gradeLevel];
                break;
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:
            case 10:
            case 11:
            case 12:
                return [NSString stringWithFormat:@"%@th" , gradeLevel];
                break;
                
                
            default:
                break;
        }
  
    }
    
    if(addGradeText)
        return [NSString stringWithFormat:@"%@ grade", gradeLevel];
    else
        return gradeLevel;
}


+ (NSString *)getDeviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    
    return @"Not Found";
}

+ (void)CreateAndDisplayOverHeadAlertInView:(UIView *)view withMessage:(NSString *)message andSchoolID:(NSString *)schoolID
{
    UIView *overlay1 = [[UIView alloc]initWithFrame:CGRectMake(view.frame.origin.x, -115, view.frame.size.width, 100)];
    UIView *alertOverlay = [[UIView alloc]initWithFrame:overlay1.frame];
    
    overlay1.tag = 10;
    alertOverlay.tag = 11;
    overlay1.alpha = .7;
    
    
    overlay1.backgroundColor = [UIColor blackColor];
    alertOverlay.backgroundColor = [UIColor clearColor];
    
    [overlay1.layer setCornerRadius:15.0f];
    //[overlay1.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    //[overlay1.layer setBorderWidth:1.5f];
    [overlay1.layer setShadowColor:[UIColor blackColor].CGColor];
    [overlay1.layer setShadowOpacity:0.8];
    [overlay1.layer setShadowRadius:4.0];
    [overlay1.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    [alertOverlay.layer setCornerRadius:15.0f];
    //[alertOverlay.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    //[alertOverlay.layer setBorderWidth:1.5f];
    [alertOverlay.layer setShadowColor:[UIColor blackColor].CGColor];
    [alertOverlay.layer setShadowOpacity:0.8];
    [alertOverlay.layer setShadowRadius:4.0];
    [alertOverlay.layer setShadowOffset:CGSizeMake(2.0, 2.0)];


    
    
    [view addSubview:overlay1];
    [view addSubview:alertOverlay];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(51, 8, alertOverlay.frame.size.width - 59, alertOverlay.frame.size.height - 16)];
    
    UIImageView *schoolImage = [[UIImageView alloc]initWithFrame:CGRectMake(8, alertOverlay.frame.size.height/2 - (35 /2), 35, 35)];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:SCHOOL_DATA_ARRAY];
    
    NSArray *schoolDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *imageName;
    for (NSDictionary *tempDic in schoolDataArray)
    {
        if([[tempDic objectForKey:ID]isEqualToString:schoolID])
        {
            imageName = [tempDic objectForKey:SCHOOL_IMAGE_NAME];
        }
    }

    
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:pngFilePath])
    {
        
        UIImage *image = [UIImage imageWithContentsOfFile:pngFilePath];
        
        
        
        
        schoolImage .image = image;
        
    }

    [alertOverlay addSubview:schoolImage];
    label.text = message;
    
    label.textColor = [UIColor whiteColor];
    //label.textAlignment = NSTextAlignmentCenter;
    
    label.font = [UIFont systemFontOfSize:17.0];
    label.numberOfLines = 3;
    label.tag = 12;
    [alertOverlay addSubview:label];
    
    [UIView animateWithDuration:1.0 animations:^{
        CGRect rect = overlay1.frame;
        rect.origin.y = -20;
        overlay1.frame = rect;
        alertOverlay.frame = rect;
        
        
    }completion:^(BOOL finished){
        
        [UIView animateWithDuration:1.0 delay:3.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            CGRect rect = overlay1.frame;
            rect.origin.y = -110;
            overlay1.frame = rect;
            alertOverlay.frame = rect;
        
        } completion:^(BOOL finished){
            
            [alertOverlay removeFromSuperview];
            [overlay1 removeFromSuperview];
        }];
        
    }];
    
    
    
    //UIButton *dismissButton = [[UIButton alloc]initWithFrame:CGRectMake(8, 31, 30, 30)];
    //[dismissButton setTitle:@"✗" forState:UIControlStateNormal];
    //[dismissButton addTarget:view.superview action:@selector(hideHelpPressed) forControlEvents:UIControlEventTouchDown];
    //[alertOverlay addSubview:dismissButton];

}

+ (NSArray *)getDateArrayFromString:(NSString *)date
{
    NSArray *dateArray = [date componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"- :/"]];
    
    return dateArray;
    
}

+ (NSArray *)getDictonaryOfUserTypes
{
    return @[@"Users", @"Teacher", @"Secretary", @"Principal", @"Superintendent", @"Sales", @"Super User", @"Beta Tester"
             
             
             ];
}




@end
