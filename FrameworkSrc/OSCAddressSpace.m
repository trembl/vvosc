//
//  OSCAddressSpace.m
//  VVOSC
//
//  Created by bagheera on 2/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OSCAddressSpace.h"
#import "OSCStringAdditions.h"
#import "MutLockArray.h"




@implementation OSCAddressSpace


+ (OSCAddressSpace *) mainSpace	{
	return _mainSpace;
}
+ (void) initialize	{
	_mainSpace = [[OSCAddressSpace alloc] init];
}

- (NSString *) description	{
	NSMutableString		*mutString = [NSMutableString stringWithCapacity:0];
	[mutString appendString:@"\n"];
	[mutString appendString:@"********\tOSC Address Space\t********\n"];
	if ((nodeContents != nil) && ([nodeContents count] > 0))	{
		[nodeContents rdlock];
		NSEnumerator	*it = [nodeContents objectEnumerator];
		OSCNode			*nodePtr;
		while (nodePtr = [it nextObject])	{
			[nodePtr logDescriptionToString:mutString tabDepth:0];
			[mutString appendString:@"\n"];
		}
		[nodeContents unlock];
	}
	
	//[self logDescriptionToString:mutString tabDepth:0];
	return mutString;
}
- (OSCNode *) findNodeForAddress:(NSString *)p	{
	//NSLog(@"%s ... %@",__func__,p);
	return [self findNodeForAddress:p createIfMissing:NO];
}
- (OSCNode *) findNodeForAddress:(NSString *)p createIfMissing:(BOOL)c	{
	//NSLog(@"%s ... %@",__func__,p);
	if (p == nil)
		return nil;
	
	return [self findNodeForAddressArray:[[p trimFirstAndLastSlashes] pathComponents] createIfMissing:c];
}
- (OSCNode *) findNodeForAddressArray:(NSArray *)a	{
	return [self findNodeForAddressArray:a createIfMissing:NO];
}
- (OSCNode *) findNodeForAddressArray:(NSArray *)a createIfMissing:(BOOL)c	{
	//NSLog(@"%s ... %@",__func__,a);
	if ((a==nil)||([a count]<1))
		return nil;
	
	NSEnumerator		*it = [a objectEnumerator];
	NSString			*pathComponent;
	OSCNode				*nodeToSearch;
	OSCNode				*foundNode = nil;
	
	nodeToSearch = self;
	while ((pathComponent=[it nextObject])&&(nodeToSearch!=nil))	{
		foundNode = [nodeToSearch findLocalNodeNamed:pathComponent];
		if ((foundNode==nil) && (c))	{
			foundNode = [OSCNode createWithName:pathComponent];
			[nodeToSearch addNode:foundNode];
		}
		nodeToSearch = foundNode;
	}
	
	return foundNode;
}
- (void) dispatchMessage:(OSCMessage *)m	{
	//NSLog(@"%s ... %@",__func__,m);
	if (m == nil)
		return;
	OSCNode			*foundNode = [self findNodeForAddress:[m address] createIfMissing:YES];
	if ((foundNode != nil) && (foundNode != self))
		[foundNode dispatchMessage:m];
}
- (void) addDelegate:(id)d forPath:(NSString *)p	{
	NSLog(@"%s",__func__);
	if ((d==nil)||(p==nil))
		return;
	if (![d respondsToSelector:@selector(receivedOSCMessage:)])	{
		NSLog(@"\terr: tried to add a non-conforming delegate: %s",__func__);
		return;
	}
	
	//OSCNode			*foundNode = [self findNodeForAddress:p createIfMissing:YES];
	//if (foundNode != nil)
	//	[foundNode addDelegate:d];
}
- (void) removeDelegate:(id)d forPath:(NSString *)p	{
	NSLog(@"%s",__func__);
	if ((d==nil)||(p==nil))
		return;
	
}
- (void) removeDelegate:(id)d forPathArray:(NSArray *)a	{

}


@end
