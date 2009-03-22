//
//  OSCAddressSpace.h
//  VVOSC
//
//  Created by bagheera on 2/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#if IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import "OSCNode.h"




id _mainAddressSpace;




@interface OSCAddressSpace : OSCNode {

}

+ (OSCAddressSpace *) mainSpace;

- (OSCNode *) findNodeForAddress:(NSString *)p;
- (OSCNode *) findNodeForAddress:(NSString *)p createIfMissing:(BOOL)c;

- (OSCNode *) findNodeForAddressArray:(NSArray *)a;
- (OSCNode *) findNodeForAddressArray:(NSArray *)a createIfMissing:(BOOL)c;

//	unlike a normal node: first finds the destination node, then dispatches the msg
- (void) dispatchMessage:(OSCMessage *)m;

- (void) addDelegate:(id)d forPath:(NSString *)p;
- (void) removeDelegate:(id)d forPath:(NSString *)p;

@end
