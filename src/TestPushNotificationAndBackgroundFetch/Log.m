//
//  Log.m
//  TestPushNotificationAndBackgroundFetch
//
//  Created by Sergio Cirasa on 30/09/13.
//  Copyright (c) 2013 Sergio Cirasa. All rights reserved.
//

#import "Log.h"
#define kLogs @"Logs"

@implementation Log

//-----------------------------------------------------------------------------------------------
+(void)addLog:(NSString*)log
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
	NSString *date = [dateFormatter stringFromDate:[NSDate date]];
	
    NSString *newLog = [NSString stringWithFormat:@"%@: %@ \n\n",date,log];
    
    NSString *logs = [[NSUserDefaults standardUserDefaults] objectForKey:kLogs];
    
    if(logs){
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@%@",logs,newLog] forKey:kLogs];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:newLog forKey:kLogs];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
//-----------------------------------------------------------------------------------------------
+(NSString*)logs
{
    NSString *logs = [[NSUserDefaults standardUserDefaults] objectForKey:kLogs];
    
    if(!logs)
        return @"";
    
    return logs;
}
//-----------------------------------------------------------------------------------------------
+(void)removeLogs
{
     [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLogs];
    [[NSUserDefaults standardUserDefaults] synchronize];    
}
//-----------------------------------------------------------------------------------------------
@end
