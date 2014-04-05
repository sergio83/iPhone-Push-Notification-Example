//
//  NSStringAddition.h
//
//  Created by sergio on 03/04/11.
//  Copyright 2011 Creative Coefficient All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)

+ (NSString*)URLEncode:(NSString*)s;
- (NSString *) escapeHTML;
- (NSString *) unescapeHTML;
- (NSString*) stringByRemovingHTML;

@end
