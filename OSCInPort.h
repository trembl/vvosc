//
//  OSCInPort.h
//  OSC
//
//  Created by bagheera on 9/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//#import <sys/types.h>
//#import <sys/socket.h>
#import <netinet/in.h>

#import <pthread.h>
#import "AddressValPair.h"
#import "OSCPacket.h"
#import "OSCBundle.h"
#import "OSCMessage.h"


@protocol OSCInPortDelegateProtocol
- (void) oscMessageReceived:(NSDictionary *)d;
- (void) receivedOSCVal:(id)v forAddress:(NSString *)a;
@end

@protocol OSCDelegateProtocol
- (void) oscMessageReceived:(NSDictionary *)d;
- (void) receivedOSCVal:(id)v forAddress:(NSString *)a;
@end


@interface OSCInPort : NSObject {
	BOOL					deleted;	//	whether or not i'm deleted- ensures that socket gets closed
	BOOL					bound;		//	whether or not the socket is bound
	int						sock;		//	socket file descriptor.  remember, everything in unix is files!
	struct sockaddr_in		addr;		//	struct that describes *my* address (this is an in port)
	short					port;		//	the port number i'm receiving from
	BOOL					running;	//	whether or not i should keep running
	BOOL					busy;
	unsigned char			buf[2049];	//	the socket gets data and dumps it here immediately
	
	pthread_mutex_t			lock;
	NSTimer					*threadTimer;
	int						threadTimerCount;
	NSAutoreleasePool		*threadPool;
	
	NSString				*portLabel;	//	the "name" of the port (added to distinguish multiple osc input ports for bonjour)
	NSNetService			*zeroConfDest;	//	bonjour service for publishing this input's address...only active if there's a portLabel!
	
	NSMutableDictionary		*scratchDict;	//	key of dict is address port; object at key is a mut. array.  coalesced messaging.
	NSMutableArray			*scratchArray;	//	array of AddressValPair objects.  used for serial messaging.
	id						delegate;	//	my delegate gets notified of incoming messages
}

+ (id) createWithPort:(short)p;
+ (id) createWithPort:(short)p labelled:(NSString *)n;
- (id) initWithPort:(short)p;
- (id) initWithPort:(short)p labelled:(NSString *)n;

- (void) prepareToBeDeleted;

- (NSDictionary *) createSnapshot;

- (BOOL) createSocket;
- (void) start;
- (void) stop;
- (void) launchOSCLoop:(id)o;
- (void) OSCThreadProc:(NSTimer *)t;
- (void) parseRawBuffer:(unsigned char *)b ofMaxLength:(int)l;

//	if the delegate im
- (void) handleParsedScratchDict:(NSDictionary *)d;
- (void) handleScratchArray:(NSArray *)a;

- (void) addValue:(id)val toAddressPath:(NSString *)p;

- (short) port;
- (void) setPort:(short)n;
- (NSString *) portLabel;
- (void) setPortLabel:(NSString *)n;
- (BOOL) bound;

- (id) delegate;
- (void) setDelegate:(id)n;

@end
