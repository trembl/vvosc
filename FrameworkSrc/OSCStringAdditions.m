//
//  OSCStringAdditions.m
//  VVOSC
//
//  Created by bagheera on 2/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OSCStringAdditions.h"




@implementation NSString (OSCStringAdditions)


- (NSString *) trimFirstAndLastSlashes	{
	NSRange			desiredRange = NSMakeRange(0,[self length]);
	if ([self characterAtIndex:desiredRange.length-1] == '/')
		--desiredRange.length;
	if ([self characterAtIndex:0] == '/')	{
		--desiredRange.length;
		++desiredRange.location;
	}
	
	return [self substringWithRange:desiredRange];
}


@end
