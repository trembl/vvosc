//
//  OSCManager.h
//  OSC
//
//  Created by bagheera on 9/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#if IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import "OSCZeroConfManager.h"
#import "OSCInPort.h"
#import "OSCOutPort.h"
#import <pthread.h>








///	Main VVOSC class- manages in & out port creation, zero configuration networking (bonjour/zeroconf)
/*!
The OSCManager should be the "main" class that you're working with: it creates/deletes inputs and outputs, automatically creates outputs for any osc destinations detected via bonjour, handles distribution of all received OSC messages, and does other manager-ish things.  You should only need one instance of OSCManager in your application.

Incoming OSC data is initially received by an OSCInPort; fundamentally, in ports are running a loop which checks a socket for data received since the last loop.  By default, the OSCInPort's delegate is the OSCManager which created it.  Every time the loop runs, it passes the received data off to its delegate (the manager) in two different ways- first as the raw address/value pairs in the order they're received, then as a dictionary of coalesced values (each key is an address path, the object at the key is an array of values).  When the OSCManager receives data via either of these means it immediately passes the received data to its delegate, which should respond to one of the following methods (referred to as the 'OSCDelegateProtocol'):

\htmlonly
<div style="width: 100%; border: 1px #000 solid; background-color: #F0F0F0; padding: 5px; margin: 5px; color: black; font-family: Courier; font-size: 10pt; font-style: normal;">
@protocol OSCDelegateProtocol<BR>
- (void) receivedOSCVal:(id)v forAddress:(NSString *)a;<BR>
- (void) oscMessageReceived:(NSDictionary *)d;<BR>
@end
</div>
\endhtmlonly

...if you want to work with received OSC data, OSCManager's delegate must respond to at least one of these methods!
*/
@interface OSCManager : NSObject {
	NSMutableArray			*inPortArray;	//	Array of OSCInPorts- do not access without using the lock!
	NSMutableArray			*outPortArray;	//	Array of OSCOutPorts- do not access without using the lock!
	
	pthread_rwlock_t		inPortLock;		//	Used to protect inPortArray from being modified while iterated
	pthread_rwlock_t		outPortLock;	//	Used to protect outPortArray from being modified while iterated
	
	id						delegate;		//!<If there's a delegate, it will be notified when OSC messages are received
	
	OSCZeroConfManager		*zeroConfManager;	//!<Creates OSCOutPorts for any OSC destinations detected via bonjour/zeroconf
}

///	Deletes all input ports
- (void) deleteAllInputs;
///	Deletes all output ports
- (void) deleteAllOutputs;

///	Creates a new input from a snapshot dict (the snapshot must have been created via OSCInPort's createSnapshot method)
- (OSCInPort *) createNewInputFromSnapshot:(NSDictionary *)s;
///	Creates a new input for a given port and label
- (OSCInPort *) createNewInputForPort:(int)p withLabel:(NSString *)l;
///	Creates a new input for a given port, automatically generates a label
- (OSCInPort *) createNewInputForPort:(int)p;
///	Creates a new input at an arbitrary port (it tries to use port 1234) and label
- (OSCInPort *) createNewInput;

///	Creates a new output from a snapshot dict (the snapshot must have been created via OSCOutPort's createSnapshot method)
- (OSCOutPort *) createNewOutputFromSnapshot:(NSDictionary *)s;
///	Creates a new output to a given address and port with the given label
- (OSCOutPort *) createNewOutputToAddress:(NSString *)a atPort:(int)p withLabel:(NSString *)l;
///	Creates a new output to a given address and port, automatically generates a label
- (OSCOutPort *) createNewOutputToAddress:(NSString *)a atPort:(int)p;
///	Creates a new output to this machine at port 1234
- (OSCOutPort *) createNewOutput;

///	Called when OSCInPorts have a coalesced dict of received values (by default, the manager is an OSCInPort's delegate)
- (void) oscMessageReceived:(NSDictionary *)d;
///	Called when OSCInPorts are processing received messages serially (by default, the manager is an OSCInPort's delegate)
- (void) receivedOSCVal:(id)v forAddress:(NSString *)a;

//	Creates and returns a unique label for an input port (unique to this manager)
- (NSString *) getUniqueInputLabel;
//	Creates and returns a unique label for an output port (unique to this manager)
- (NSString *) getUniqueOutputLabel;
//	Finds and returns an input matching the passed label (returns nil if not found)
- (OSCInPort *) findInputWithLabel:(NSString *)n;
//	Finds and returns an output matching the passed label (returns nil if not found)
- (OSCOutPort *) findOutputWithLabel:(NSString *)n;
//	Finds and returns an output matching the passed address and port (returns nil if not found)
- (OSCOutPort *) findOutputWithAddress:(NSString *)a andPort:(int)p;
//	Returns the output at the provided index in outPortArray
- (OSCOutPort *) findOutputForIndex:(int)i;
//	Finds and returns the input whose zero conf name matches the passed string (returns nil if not found)
- (OSCInPort *) findInputWithZeroConfName:(NSString *)n;
///	Removes the passed input from the inPortArray
- (void) removeInput:(id)p;
///	Removes the passed output from the outPortArray
- (void) removeOutput:(id)p;
///	Generates and returns an array of strings which correspond to the labels of this manager's out ports
- (NSArray *) outPortLabelArray;

///	By default, returns [OSCInPort class]- subclass around to use different subclasses of OSCInPort
- (id) inPortClass;
//	By default, returns @"VVOSC"- subclass around this to use a different base string when generating in port labels
- (NSString *) inPortLabelBase;
///	By default, returns [OSCOutPort class]- subclass around to use different subclasses of OSCOutPort
- (id) outPortClass;

//	misc
///	Returns the delegate (by default, an OSCManager doesn't have a delegate)
- (id) delegate;
///	Sets the delegate; the delegate is NOT retained, make sure you tell the manager's nil before releasing it!
- (void) setDelegate:(id)n;
- (NSMutableArray *) inPortArray;
- (NSMutableArray *) outPortArray;

@end
