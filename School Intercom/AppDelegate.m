//
//  AppDelegate.m
//  School Intercom
//
//  Created by RandallRumple on 11/20/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "AppDelegate.h"
#import "SchoolIntercomIAPHelper.h"

@implementation AppDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    NSString *finalToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:finalToken forKey:USER_PUSH_NOTIFICATION_PIN];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:ACCOUNT_CREATED]boolValue] && ![[[NSUserDefaults standardUserDefaults]objectForKey:IS_DEMO_IN_USE]boolValue])
    {
        RegistrationModel *registerData = [[RegistrationModel alloc]init];
        
        dispatch_queue_t createQueue = dispatch_queue_create("updatePin", NULL);
        dispatch_async(createQueue, ^{
            NSArray *dataArray;
            dataArray = [registerData updateUserPushNotificationPinForUserID:[[NSUserDefaults standardUserDefaults]objectForKey:USER_ID] withPin:finalToken];
        });

    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    UINavigationController *navigationController = (UINavigationController*)_window.rootViewController;
    NSLog(@"%@", navigationController.viewControllers);
    
    int badgeNumber = [[[NSUserDefaults standardUserDefaults]objectForKey:BADGE_COUNT] intValue];
    
   
    badgeNumber++;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i", badgeNumber] forKey:BADGE_COUNT];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:badgeNumber];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
        
    //NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    [SchoolIntercomIAPHelper sharedInstance];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
       
    UINavigationController *navigationController = (UINavigationController*)_window.rootViewController;
    NSLog(@"%@", navigationController.viewControllers);
    
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"%@", iosVersion);
    
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:ACCOUNT_CREATED]boolValue])
    {
        RegistrationModel *registerData = [[RegistrationModel alloc]init];
        
        dispatch_queue_t createQueue = dispatch_queue_create("updateIOSVersion", NULL);
        dispatch_async(createQueue, ^{
            NSArray *dataArray;
            dataArray = [registerData updateUserVersionUserID:[[NSUserDefaults standardUserDefaults]objectForKey:USER_ID] withVersion:iosVersion];
            if ([dataArray count] == 1)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *tempDic = [dataArray objectAtIndex:0];
                    
                    if([[tempDic objectForKey:@"error"] boolValue])
                    {
                        NSLog(@"%@", tempDic);
                    }
                });
                
            }
        });
    }
    if([[[NSUserDefaults standardUserDefaults]objectForKey:ACCOUNT_CREATED]boolValue])
    {
        //-- Set Notification
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
        
        
    }
    return YES;
}



							
- (void)applicationWillResignActive:(UIApplication *)application
{
    
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
  

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:ACCOUNT_CREATED]boolValue])
        {
            RegistrationModel *registerData = [[RegistrationModel alloc]init];
            
            dispatch_queue_t createQueue = dispatch_queue_create("updatePin", NULL);
            dispatch_async(createQueue, ^{
                NSArray *dataArray;
                dataArray = [registerData getCurrentAppVersion];
                if ([dataArray count] == 1)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *tempDic = [dataArray objectAtIndex:0];
                        
                        if([[tempDic objectForKey:@"error"] boolValue])
                        {
                            //
                        }
                        else
                        {
                            NSString *currentAppVersion = [tempDic objectForKey:CURRENT_VERSION];
                            NSString *deviceAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                            if(![currentAppVersion isEqualToString:deviceAppVersion])
                            {
                                UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"Update Available" message:[NSString stringWithFormat:@"Version %@ is now available please update the app for a better experience", currentAppVersion] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                
                                [alertview show];
                                
                                
                                
                                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:IS_APP_UP_TO_DATE];
                                [[NSUserDefaults standardUserDefaults]synchronize];
                            }
                            else
                            {
                                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:IS_APP_UP_TO_DATE];
                                [[NSUserDefaults standardUserDefaults]synchronize];
                            }
                            
                            NSLog(@"device -%@, database - %@", deviceAppVersion, currentAppVersion);
                        }
                    });
                    
                }
            });
        }
    
    

    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
