//
//  OSCNode.m
//  VVOSC
//
//  Created by bagheera on 2/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OSCNode.h"
#import "MutLockArray.h"
#import "OSCStringAdditions.h"




@implementation OSCNode


- (NSString *) description	{
	return [NSString stringWithFormat:@"<OSCNode %@>",nodeName];
}
- (void) logDescriptionToString:(NSMutableString *)s tabDepth:(int)d	{
	int				i;
	
	//	add the tabs
	for (i=0;i<d;++i)
		[s appendString:@"\t"];
	//	write the description
	[s appendFormat:@"<%@>",nodeName];
	//	if there are contents
	if ((nodeContents!=nil)&&([nodeContents count]>0))	{
		[s appendString:@"\t{"];
		//	call this method on my contents
		[nodeContents rdlock];
		NSEnumerator		*it = [nodeContents objectEnumerator];
		OSCNode				*nodePtr;
		while (nodePtr = [it nextObject])	{
			[s appendString:@"\n"];
			[nodePtr logDescriptionToString:s tabDepth:d+1];
		}
		[nodeContents unlock];
		//	add the tabs, close the description
		[s appendString:@"\n"];
		for (i=0;i<d;++i)
			[s appendString:@"\t"];
		[s appendString:@"}"];
	}
}
+ (id) createWithName:(NSString *)n	{
	OSCNode		*returnMe = [[OSCNode alloc] initWithName:n];
	if (returnMe == nil)
		return nil;
	return [returnMe autorelease];
}
- (id) initWithName:(NSString *)n	{
	//NSLog(@"%s ... %@",__func__,n);
	if (n == nil)
		goto BAIL;
	if (self = [super init])	{
		deleted = NO;
		
		nodeName = [[n trimFirstAndLastSlashes] retain];
		nodeContents = nil;
		parentNode = nil;
		
		lastReceivedMessage = nil;
		delegateArray = nil;
		return self;
	}
	BAIL:
	[self release];
	return nil;
}
- (id) init	{
	if (self = [super init])	{
		deleted = NO;
		
		nodeName = nil;
		nodeContents = nil;
		parentNode = nil;
		
		lastReceivedMessage = nil;
		delegateArray = nil;
		return self;
	}
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
	NSLog(@"%s",__func__);
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


- (NSComparisonResult) nodeNameCompare:(OSCNode *)comp	{
	if (nodeName == nil)
		return NSOrderedAscending;
	if (comp == nil)
		return NSOrderedDescending;
	return [nodeName caseInsensitiveCompare:[comp nodeName]];
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
	//NSLog(@"%s ... %@",__func__,n);
	if ((n == nil)||(deleted))
		return;
	if (nodeContents == nil)
		nodeContents = [[MutLockArray alloc] initWithCapacity:0];
	[nodeContents wrlock];
		[nodeContents addObject:n];
		[nodeContents sortUsingSelector:@selector(nodeNameCompare:)];
	[nodeContents unlock];
	
	[n setParentNode:self];
}
- (void) removeNode:(OSCNode *)n	{
	if ((n == nil)||(deleted))
		return;
	[n prepareToBeDeleted];
	if (nodeContents != nil)
		[nodeContents lockRemoveObject:n];
}
- (OSCNode *) findLocalNodeNamed:(NSString *)n	{
	if (n == nil)
		return nil;
	
	NSEnumerator		*nodeIt;
	OSCNode				*nodePtr;
	
	[nodeContents rdlock];
		nodeIt = [nodeContents objectEnumerator];
		do	{
			nodePtr = [nodeIt nextObject];
		} while ((nodePtr!=nil) && (![[nodePtr nodeName] isEqualToString:n]));
	[nodeContents unlock];
	
	return nodePtr;
}


- (void) addDelegate:(id)d	{
	if (d == nil)
		return;
	//	if there's no delegate array, make one
	if (delegateArray == nil)
		delegateArray = [[MutLockArray alloc] initWithCapacity:0];
	//	first check to make sure that this delegate hasn't already been added
	int			foundIndex = [delegateArray lockIndexOfIdenticalPtr:d];
	if (foundIndex == NSNotFound)	{
		//	if the delegate hasn't already been added, add it (this retains it)
		[delegateArray lockAddObject:d];
		//	release the object (so i have zero impact on its retain count)
		[d autorelease];
	}
}
- (void) removeDelegate:(id)d	{
	if ((d == nil)||(delegateArray!=nil)||([delegateArray count]<1))
		return;
	
	//	find the delegate in my delegate array
	int			foundIndex = [delegateArray lockIndexOfIdenticalPtr:d];
	//	if i could find it...
	if (foundIndex != NSNotFound)	{
		//	first, write lock
		[delegateArray wrlock];
			//	retain the object
			[d retain];
			//	remove the object from the delegate array
			[delegateArray removeObjectAtIndex:foundIndex];
		//	unlock
		[delegateArray unlock];
	}
}


- (void) dispatchMessage:(OSCMessage *)m	{
	//NSLog(@"%s ... %@",__func__,m);
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
