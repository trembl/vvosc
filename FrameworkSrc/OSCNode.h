//
//  OSCNode.h
//  VVOSC
//
//  Created by bagheera on 2/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OSCMessage.h"
//#import "MutLockArray.h"




@interface OSCNode : NSObject {
	BOOL			deleted;
	
	NSString		*nodeName;
	id				nodeContents;	//	type 'MutLockArray'
	OSCNode			*parentNode;	//	NOT retained!
	
	OSCMessage		*lastReceivedMessage;	//	store the msg instead of the val because msgs can have multiple vals
	id				delegateArray;	//	type 'MutLockArray'. contents are NOT retained! could be anything!
}

- (void) logDescriptionToString:(NSMutableString *)s tabDepth:(int)d;

+ (id) createWithName:(NSString *)n;
- (id) initWithName:(NSString *)n;
- (id) init;

- (NSComparisonResult) nodeNameCompare:(OSCNode *)comp;

- (void) addNode:(OSCNode *)n;
- (void) removeNode:(OSCNode *)n;
- (OSCNode *) findLocalNodeNamed:(NSString *)n;

- (void) addDelegate:(id)d;
- (void) removeDelegate:(id)d;

- (void) dispatchMessage:(OSCMessage *)m;

@property (assign, readwrite) NSString *nodeName;
@property (assign, readwrite) OSCNode *parentNode;

@end
