//
//  NSStringAddition.m
//
//  Created by sergio on 03/04/11.
//  Copyright 2011 Creative Coefficient All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

static const char *hex[] = {
	"%00", "%01", "%02", "%03", "%04", "%05", "%06", "%07",
	"%08", "%09", "%0A", "%0B", "%0C", "%0D", "%0E", "%0F",
	"%10", "%11", "%12", "%13", "%14", "%15", "%16", "%17",
	"%18", "%19", "%1A", "%1B", "%1C", "%1D", "%1E", "%1F",
	"%20", "%21", "%22", "%23", "%24", "%25", "%26", "%27",
	"%28", "%29", "%2A", "%2B", "%2C", "%2D", "%2E", "%2F",
	"%30", "%31", "%32", "%33", "%34", "%35", "%36", "%37",
	"%38", "%39", "%3A", "%3B", "%3C", "%3D", "%3E", "%3F",
	"%40", "%41", "%42", "%43", "%44", "%45", "%46", "%47",
	"%48", "%49", "%4A", "%4B", "%4C", "%4D", "%4E", "%4F",
	"%50", "%51", "%52", "%53", "%54", "%55", "%56", "%57",
	"%58", "%59", "%5A", "%5B", "%5C", "%5D", "%5E", "%5F",
	"%60", "%61", "%62", "%63", "%64", "%65", "%66", "%67",
	"%68", "%69", "%6A", "%6B", "%6C", "%6D", "%6E", "%6F",
	"%70", "%71", "%72", "%73", "%74", "%75", "%76", "%77",
	"%78", "%79", "%7A", "%7B", "%7C", "%7D", "%7E", "%7F",
	"%80", "%81", "%82", "%83", "%84", "%85", "%86", "%87",
	"%88", "%89", "%8A", "%8B", "%8C", "%8D", "%8E", "%8F",
	"%90", "%91", "%92", "%93", "%94", "%95", "%96", "%97",
	"%98", "%99", "%9A", "%9B", "%9C", "%9D", "%9E", "%9F",
	"%A0", "%A1", "%A2", "%A3", "%A4", "%A5", "%A6", "%A7",
	"%A8", "%A9", "%AA", "%AB", "%AC", "%AD", "%AE", "%AF",
	"%B0", "%B1", "%B2", "%B3", "%B4", "%B5", "%B6", "%B7",
	"%B8", "%B9", "%BA", "%BB", "%BC", "%BD", "%BE", "%BF",
	"%C0", "%C1", "%C2", "%C3", "%C4", "%C5", "%C6", "%C7",
	"%C8", "%C9", "%CA", "%CB", "%CC", "%CD", "%CE", "%CF",
	"%D0", "%D1", "%D2", "%D3", "%D4", "%D5", "%D6", "%D7",
	"%D8", "%D9", "%DA", "%DB", "%DC", "%DD", "%DE", "%DF",
	"%E0", "%E1", "%E2", "%E3", "%E4", "%E5", "%E6", "%E7",
	"%E8", "%E9", "%EA", "%EB", "%EC", "%ED", "%EE", "%EF",
	"%F0", "%F1", "%F2", "%F3", "%F4", "%F5", "%F6", "%F7",
	"%F8", "%F9", "%FA", "%FB", "%FC", "%FD", "%FE", "%FF"
};

+ (NSString*)URLEncode:(NSString*)s
{
	NSMutableString *aux = [NSMutableString stringWithCapacity:5];
	NSInteger len = [s length];
	
	for (int i = 0; i < len; i++) {
		unichar ch = [s characterAtIndex:i];
		
		if ('A' <= ch && ch <= 'Z') {		// 'A'..'Z'
			[aux appendFormat:@"%c",ch];
		} else if ('a' <= ch && ch <= 'z') {	// 'a'..'z'
			[aux appendFormat:@"%c",ch];
		} else if ('0' <= ch && ch <= '9') {	// '0'..'9'
			[aux appendFormat:@"%c",ch];
		} else if (ch == ' ') {			// space
			[aux appendString:@"%20"];
		} else if (ch == '-' || ch == '_'		// unreserved
				   || ch == '.' || ch == '!'
				   || ch == '~' || ch == '*'
				   || ch == '\'' || ch == '('
				   || ch == ')') {
			[aux appendFormat:@"%c",ch];
		} else if (ch <= 0x007f) {		// other ASCII
			[aux appendFormat:@"%s",hex[ch]];
		} else if (ch <= 0x07FF) {		// non-ASCII <= 0x7FF
			[aux appendFormat:@"%s",hex[0xc0 | (ch >> 6)]];
			[aux appendFormat:@"%s",hex[0x80 | (ch & 0x3F)]];
		} else {					// 0x7FF < ch <= 0xFFFF
			[aux appendFormat:@"%s",hex[0xe0 | (ch >> 12)]];
			[aux appendFormat:@"%s",hex[0x80 | ((ch >> 6) & 0x3F)]];
			[aux appendFormat:@"%s",hex[0x80 | (ch & 0x3F)]];
		}
	}
	
	return aux;
}


- (NSString *) escapeHTML{
	NSMutableString *s = [NSMutableString string];
	
	int start = 0;
	int len = [self length];
	NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"<>&\""];
	
	while (start < len) {
		NSRange r = [self rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len-start)];
		if (r.location == NSNotFound) {
			[s appendString:[self substringFromIndex:start]];
			break;
		}
		
		if (start < r.location) {
			[s appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
		}
		
		switch ([self characterAtIndex:r.location]) {
			case '<':
				[s appendString:@"&lt;"];
				break;
			case '>':
				[s appendString:@"&gt;"];
				break;
			case '"':
				[s appendString:@"&quot;"];
				break;
				//			case '…':
				//				[s appendString:@"&hellip;"];
				//				break;
			case '&':
				[s appendString:@"&amp;"];
				break;
		}
		
		start = r.location + 1;
	}
	
	return s;
}


- (NSString *) unescapeHTML{
	NSMutableString *s = [NSMutableString string];
	NSMutableString *target = [[self mutableCopy] autorelease];
	NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
	
	while ([target length] > 0) {
		NSRange r = [target rangeOfCharacterFromSet:chs];
		if (r.location == NSNotFound) {
			[s appendString:target];
			break;
		}
		
		if (r.location > 0) {
			[s appendString:[target substringToIndex:r.location]];
			[target deleteCharactersInRange:NSMakeRange(0, r.location)];
		}
		
		if ([target hasPrefix:@"&lt;"]) {
			[s appendString:@"<"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&gt;"]) {
			[s appendString:@">"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&quot;"]) {
			[s appendString:@"\""];
			[target deleteCharactersInRange:NSMakeRange(0, 6)];
		} else if ([target hasPrefix:@"&#39;"]) {
			[s appendString:@"'"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else if ([target hasPrefix:@"&amp;"]) {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else if ([target hasPrefix:@"&hellip;"]) {
			[s appendString:@"…"];
			[target deleteCharactersInRange:NSMakeRange(0, 8)];
		} else {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 1)];
		}
	}
	
	return s;
}


- (NSString*) stringByRemovingHTML{
	
	NSString *html = self;
    NSScanner *thescanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
	
    while ([thescanner isAtEnd] == NO) {
		[thescanner scanUpToString:@"<" intoString:NULL];
		[thescanner scanUpToString:@">" intoString:&text];
		html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@" "];
    }
	return html;
}

@end
