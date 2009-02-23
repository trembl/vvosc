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
#import "MutLockArray.h"
#import "OSCNode.h"




@interface OSCAddressSpace : OSCNode {

}

- (OSCNode *) nodeForPath:(NSString *)p;
- (void) dispatchMessage:(OSCMessage *)m;
- (void) addDelegate:(id)d forPath:(NSString *)p;
- (void) removeDelegate:(id)d forPath:(NSString *)p;

@end
