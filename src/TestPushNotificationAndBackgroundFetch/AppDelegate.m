//
//  AppDelegate.m
//  TestPushNotificationAndBackgroundFetch
//
//  Created by Sergio Cirasa on 30/09/13.
//  Copyright (c) 2013 Sergio Cirasa. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+Category.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Log addLog:@"Register For Remote Notification"];
    NSNotification* notification = [NSNotification notificationWithName:KRefreshNotification object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
    
    //Me registro en push notification
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    
    if(!SYSTEM_VERSION_LESS_THAN_IOS7)
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    
    // Override point for customization after application launch.
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//------------------------------------------------------------------------------------------------------------
#pragma mark - Push Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	
    [Log addLog:@"Did Register For Remote Notification"];
    NSNotification* notification = [NSNotification notificationWithName:KRefreshNotification object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
    
#if !TARGET_IPHONE_SIMULATOR
    
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appName = [NSString URLEncode:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = (rntypes & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
	NSString *pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
	NSString *pushSound = (rntypes & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";
	
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
    
    NSString *deviceUuid = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id uuid = [defaults objectForKey:@"deviceUuid"];
    if (uuid)
        deviceUuid = (NSString *)uuid;
    else {
        deviceUuid = [[NSUUID UUID] UUIDString];
        [defaults setObject:deviceUuid forKey:@"deviceUuid"];
        [defaults synchronize];
    }
	
	NSString *deviceName = [dev.name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSString *deviceModel = [dev.model stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSString *deviceSystemVersion = dev.systemVersion;
	
	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	NSString *urlString = [NSString stringWithFormat:@"ws.php?opc=addIphone&clientid=%@&task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", kClientIs,@"register",appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
	
    urlString = [NSString stringWithFormat:@"%@/%@",kHost_PushNotification,urlString];
    NSLog(@"%@",urlString);
	// Register the Device Data
	NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSError *error=[[NSError alloc] init];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
	NSLog(@"Register URL: %@", [url path]);
	NSLog(@"Return Data: %@", returnData?[NSString stringWithUTF8String:[returnData bytes]]:@"");

    [Log addLog:@"Send token to server"];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
    
#endif
}
//------------------------------------------------------------------------------------------------------------
/**
 * Failed to Register for Remote Notifications
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"ERROR, no se pudo registrar a Push Notification");
    
    [Log addLog:@"Failed To Register For Remote Notification"];
    NSNotification* notification = [NSNotification notificationWithName:KRefreshNotification object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
    
#if !TARGET_IPHONE_SIMULATOR
	
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error in registration"
                                                    message:[error description]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
#endif
}
//------------------------------------------------------------------------------------------------------------
/**
 * Remote Notification Received while application was open.
 */
//------------------------------------------------------------------------------------------------------------
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{

    [Log addLog:@"Did  Receive Remote Notification For Fetch Content"];
    NSNotification* notification = [NSNotification notificationWithName:KRefreshNotification object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    NSString *contentAvailable = [apsInfo objectForKey:@"content-available"];
    if(contentAvailable && [contentAvailable  isEqualToString:@"true"])
        [self downloadContent:completionHandler];
    else [self processNotification:userInfo];
    
}
//------------------------------------------------------------------------------------------------------------
/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
    [Log addLog:@"Did  Receive Remote Notification"];
    NSNotification* notification = [NSNotification notificationWithName:KRefreshNotification object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
    [self processNotification:userInfo];
}
*/
//------------------------------------------------------------------------------------------------------------
-(void)processNotification:(NSDictionary *)userInfo{
#if !TARGET_IPHONE_SIMULATOR
    UIApplication *application = [UIApplication sharedApplication];
    
	NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
	
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	//AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
    
  	NSString *index = [userInfo objectForKey:@"index"];
    
    if(index!=nil)
        NSLog(@"Received Push Index: %@", index);
    
	application.applicationIconBadgeNumber = 0;//[[apsInfo objectForKey:@"badge"] integerValue];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Push Notification" message:alert delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
	
#endif
}
#pragma mark - Background Fetch
//------------------------------------------------------------------------------------------------------------
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"########### Received Background Fetch ###########");
    

    [Log addLog:@"Received Background Fetch"];
    [Log addLog:@"Start Download Content"];
    NSNotification* notification = [NSNotification notificationWithName:KRefreshNotification object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
    [self downloadContent:completionHandler];

}
//------------------------------------------------------------------------------------------------------------
-(void)downloadContent:(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.allowsCellularAccess = YES;
    NSURL* fetchURL = [NSURL URLWithString:kURL];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:fetchURL
                                                         completionHandler:
                              ^(NSData *data, NSURLResponse *response, NSError *error) {
                                  
                                  if(!error){
                                      NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      [Log addLog:@"Download Content Finished"];
                                      [Log addLog:[NSString stringWithFormat:@"Content: %@",responseString]];
                                   //   completionHandler(UIBackgroundFetchResultNewData);
                                  }else{
                                      [Log addLog:@"Download Content Failed"];
                                      completionHandler(UIBackgroundFetchResultFailed);
                                  }
                                  
                                  if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
                                      NSNotification* notification = [NSNotification notificationWithName:KRefreshNotification object:nil];
                                      [[NSNotificationCenter defaultCenter] postNotification:notification];
                                  }
                                  
                              }];
    [task resume];
    
}
//------------------------------------------------------------------------------------------------------------
@end
