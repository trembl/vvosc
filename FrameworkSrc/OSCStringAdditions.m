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
	
	if (desiredRange.length == [self length])
		return self;
	return [self substringWithRange:desiredRange];
}
- (NSString *) stringByDeletingFirstPathComponent	{
	//NSLog(@"%s ... %@",__func__,self);
	NSArray			*pathArray = [[self trimFirstAndLastSlashes] pathComponents];
	NSString		*tmpString = nil;
	for (NSString *pathComponent in pathArray)	{
		if (tmpString == nil)
			tmpString = [NSString stringWithString:@""];
		else
			tmpString = [NSString stringWithFormat:@"%@/%@",tmpString,pathComponent];
	}
	//NSLog(@"\treturning %@",tmpString);
	return tmpString;
	
	/*
	NSMutableArray		*pathComponents = [[[[self trimFirstAndLastSlashes] pathComponents] mutableCopy] autorelease];
	//NSLog(@"\tinterim is %@",pathComponents);
	if ((pathComponents!=nil)&&([pathComponents count]>0))	{
		[pathComponents removeObjectAtIndex:0];
		//NSLog(@"\tinterim2 is %@",pathComponents);
		//NSLog(@"\treturning %@",[NSString pathWithComponents:pathComponents]);
		return [NSString stringWithFormat:@"/%@",[NSString pathWithComponents:pathComponents]];
	}
	return nil;
	*/
}


@end
