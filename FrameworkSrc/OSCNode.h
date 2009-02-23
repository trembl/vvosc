//
//  OSCNode.h
//  VVOSC
//
//  Created by bagheera on 2/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSCMessage.h"
#import "MutLockArray.h"




@interface OSCNode : NSObject {
	BOOL			deleted;
	
	NSString		*nodeName;
	MutLockArray	*nodeContents;
	OSCNode			*parentNode;	//	NOT retained!
	
	OSCMessage		*lastReceivedMessage;
	MutLockArray	*delegateArray;	//	contents are NOT retained! could be anything!
}

+ (id) createWithName:(NSString *)n;
- (id) initWithName:(NSString *)n;

- (void) addNode:(OSCNode *)n;
- (void) removeNode:(OSCNode *)n;

- (void) dispatchMessage:(OSCMessage *)m;

@property (assign, readwrite) NSString *nodeName;
@property (assign, readwrite) OSCNode *parentNode;

@end
