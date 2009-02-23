//
//  OSCNode.m
//  VVOSC
//
//  Created by bagheera on 2/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OSCNode.h"




@implementation OSCNode


+ (id) createWithName:(NSString *)n	{
	OSCNode		*returnMe = [[OSCNode alloc] initWithName:n];
	if (returnMe == nil)
		return nil;
	return [returnMe autorelease];
}
- (id) initWithName:(NSString *)n	{
	if (n == nil)
		goto BAIL;
	if (self = [super init])	{
		deleted = NO;
		
		nodeName = [n retain];
		nodeContents = nil;
		parentNode = nil;
		
		lastReceivedMessage = nil;
		delegateArray = [[MutLockArray alloc] initWithCapacity:0];
		return self;
	}
	BAIL:
	[self release];
	return nil;
}
- (void) prepareToBeDeleted	{
	[delegateArray lockRemoveAllObjects];
	[delegateArray release];
	delegateArray = nil;
	deleted = YES;
}
- (void) dealloc	{
	if (!deleted)
		[self prepareToBeDeleted];
	
	if (nodeName != nil)
		[nodeName release];
	nodeName = nil;
	if (nodeContents != nil)
		[nodeContents release];
	nodeContents = nil;
	parentNode = nil;
	
	if (lastReceivedMessage != nil)
		[lastReceivedMessage release];
	lastReceivedMessage = nil;
	
	[super dealloc];
}


- (BOOL) isEqualTo:(id)o	{
	//	if the comparator is nil or i've been deleted, it's not equal
	if ((o == nil)||(deleted))
		return NO;
	//	if the ptr is an exact match (same instance), return YES
	if (self == o)
		return YES;
	//	if it's the same class and the nodeName matches, return YES
	if (([o isKindOfClass:[OSCNode class]]) && ([nodeName isEqualToString:[o nodeName]]))
		return YES;
	
	return NO;
}


- (void) addNode:(OSCNode *)n	{
	if ((n == nil)||(deleted))
		return;
	if (nodeContents == nil)
		nodeContents = [[MutLockArray alloc] initWithCapacity:0];
	[nodeContents lockAddObject:n];
	[n setParentNode:self];
}
- (void) removeNode:(OSCNode *)n	{
	if ((n == nil)||(deleted))
		return;
	if (nodeContents != nil)	{
		[nodeContents lockRemoveObject:n];
		[n setParentNode:self];
	}
}


- (void) dispatchMessage:(OSCMessage *)m	{
	if ((m==nil)||(deleted))
		return;
	
	if (delegateArray != nil)
		[delegateArray lockMakeObjectsPerformSelector:@selector(receivedOSCMessage:) withObject:m];
	
	if (lastReceivedMessage != nil)
		[lastReceivedMessage release];
	lastReceivedMessage = [m retain];
}


- (void) setNodeName:(NSString *)n	{
	if (nodeName != nil)
		[nodeName release];
	nodeName = nil;
	if (n != nil)
		nodeName = [n retain];
}
- (NSString *) nodeName	{
	return nodeName;
}
- (void) setParentNode:(OSCNode *)n	{
	parentNode = n;
}
- (OSCNode *) parentNode	{
	return parentNode;
}


@end
