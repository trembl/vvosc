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




@protocol OSCNodeDelegateProtocol
- (void) receivedOSCMessage:(OSCMessage *)m;
- (void) oscNodeNameChangedFrom:(NSString *)oldName to:(NSString *)newName;
- (void) oscNodeDeleted;
@end




typedef enum	{
	OSCNodeTypeUnknown,
	OSCNodeTypeFloat,
	OSCNodeType2DPoint,
	OSCNodeType3DPoint,
	OSCNodeTypeRect,
	OSCNodeTypeColor,
	OSCNodeTypeString,
} OSCNodeType;




@interface OSCNode : NSObject {
	BOOL			deleted;
	
	NSString		*nodeName;	//	"local" name: name of the node at /a/b/c is "c"
	id				nodeContents;	//	type 'MutLockArray'
	OSCNode			*parentNode;	//	NOT retained!
	int				nodeType;	//	what 'type' of node i am
	
	OSCMessage		*lastReceivedMessage;	//	store the msg instead of the val because msgs can have multiple vals
	id				delegateArray;	//	type 'MutLockArray'. contents are NOT retained! could be anything!
}

//	only called by the address space to craft a formatted string for logging purposes
- (void) logDescriptionToString:(NSMutableString *)s tabDepth:(int)d;

+ (id) createWithName:(NSString *)n;
- (id) initWithName:(NSString *)n;
- (id) init;

//	convenience method so nodes may be sorted by name
- (NSComparisonResult) nodeNameCompare:(OSCNode *)comp;

//	"local" add/remove/find methods for working with my node contents
- (void) addNode:(OSCNode *)n;
- (void) removeNode:(OSCNode *)n;
- (OSCNode *) findLocalNodeNamed:(NSString *)n;

//	a node's delegate is informed of received osc messages or name changes (OSCNodeDelegateProtocol)
- (void) addDelegate:(id)d;
- (void) removeDelegate:(id)d;

//	simply sends the passed message to all my delegates
- (void) dispatchMessage:(OSCMessage *)m;

@property (assign, readwrite) NSString *nodeName;
@property (assign, readwrite) OSCNode *parentNode;
@property (assign, readwrite) int nodeType;

@end
