//
//  BonjourServerTachy.m
//  Gilded
//
//  Created by Michael Zuccarino on 10/1/15.
//  Copyright © 2015 SnarfSnarf. All rights reserved.
//

#import "BonjourServerTachy.h"
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"


// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation BonjourServerTachy

-(id)init
{
    self = [super init];
    
    // Configure logging framework
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    
    // Create our socket.
    // We tell it to invoke our delegate methods on the main thread.
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Create an array to hold accepted incoming connections.
    
    connectedSockets = [[NSMutableArray alloc] init];
    
    // Now we tell the socket to accept incoming connections.
    // We don't care what port it listens on, so we pass zero for the port number.
    // This allows the operating system to automatically assign us an available port.
    
    NSError *err = nil;
    if ([asyncSocket acceptOnPort:0 error:&err])
    {
        // So what port did the OS give us?
        
        UInt16 port = [asyncSocket localPort];
        
        // Create and publish the bonjour service.
        // Obviously you will be using your own custom service type.
        
        netService = [[NSNetService alloc] initWithDomain:@"local."
                                                     type:@"_YourServiceName._tcp."
                                                     name:@""
                                                     port:port];
        
        [netService setDelegate:self];
        [netService publish];
        
        // You can optionally add TXT record stuff
        
        NSMutableDictionary *txtDict = [NSMutableDictionary dictionaryWithCapacity:2];
        
        [txtDict setObject:@"moo" forKey:@"cow"];
        [txtDict setObject:@"quack" forKey:@"duck"];
        
        NSData *txtData = [NSNetService dataFromTXTRecordDictionary:txtDict];
        [netService setTXTRecordData:txtData];
    }
    else
    {
        DDLogError(@"Error in acceptOnPort:error: -> %@", err);
        [self.delegate receivedServerDebugMessage:[NSString stringWithFormat:@"Error in acceptOnPort:error: -> %@", err]];
    }
    
    return self;
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    DDLogInfo(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    [self.delegate receivedServerDebugMessage:[NSString stringWithFormat:@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]]];
    
    // The newSocket automatically inherits its delegate & delegateQueue from its parent.
    
    [connectedSockets addObject:newSocket];
    
    [self sendTestDataToSock:newSocket];
}

-(void)sendTestDataToSock:(GCDAsyncSocket *)newSock
{
    NSError *error;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"kartingleague2" ofType:@"html"];
    NSString *unenc = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    unenc = [unenc stringByAppendingString:@"\r\n"];
    NSData *enc = [unenc dataUsingEncoding:NSUTF8StringEncoding];
    [self.delegate receivedServerDebugMessage:@"writing data to socket"];
    NSLog(@"writing data to socket");
    [newSock writeData:enc withTimeout:50.0 tag:100];
   // [[self.gildedWebView mainFrame] loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error] baseURL:[NSURL URLWithString:@""]];
}

- (float)progressOfWriteReturningTag:(long *)tagPtr bytesDone:(NSUInteger *)donePtr total:(NSUInteger *)totalPtr
{
    [self.delegate receivedServerDebugMessage:[NSString stringWithFormat:@"WRITING: %fl",(double)*donePtr/(double)*totalPtr]];
    
    return (double)*donePtr/(double)*totalPtr;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [connectedSockets removeObject:sock];
}

- (void)netServiceDidPublish:(NSNetService *)ns
{
    DDLogInfo(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)",
              [ns domain], [ns type], [ns name], (int)[ns port]);
    [self.delegate receivedServerDebugMessage:[NSString stringWithFormat:@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", [ns domain], [ns type], [ns name], (int)[ns port]]];
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{
    DDLogError(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
               [ns domain], [ns type], [ns name], errorDict);
    [self.delegate receivedServerDebugMessage:[NSString stringWithFormat:@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", [ns domain], [ns type], [ns name], errorDict]];
}

@end
