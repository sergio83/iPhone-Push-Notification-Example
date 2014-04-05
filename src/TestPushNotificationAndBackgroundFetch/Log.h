//
//  Log.h
//  TestPushNotificationAndBackgroundFetch
//
//  Created by Sergio Cirasa on 30/09/13.
//  Copyright (c) 2013 Sergio Cirasa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Log : NSObject

+(void)addLog:(NSString*)log;
+(NSString*)logs;
+(void)removeLogs;

@end
