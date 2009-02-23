//
//  OSCAddressSpace.m
//  VVOSC
//
//  Created by bagheera on 2/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OSCAddressSpace.h"




@implementation OSCAddressSpace


- (OSCNode *) nodeForPath:(NSString *)p	{
	NSLog(@"%s ... %@",__func__,p);
	return nil;
}
- (void) dispatchMessage:(OSCMessage *)m	{
	NSLog(@"%s ... %@",__func__,m);
	if (m == nil)
		return;
}
- (void) addDelegate:(id)d forPath:(NSString *)p	{
	NSLog(@"%s",__func__);
	if ((d==nil)||(p==nil))
		return;
	if (![d respondsToSelector:@selector(receivedOSCMessage:)])
		return;
	NSLog(@"\tshould be adding delegate %@ for path %@",d,p);
}
- (void) removeDelegate:(id)d forPath:(NSString *)p	{
	NSLog(@"%s",__func__);
	if ((d==nil)||(p==nil))
		return;
	
}


@end
