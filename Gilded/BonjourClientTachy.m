//
//  BonjourClientTachy.m
//  Gilded
//
//  Created by Michael Zuccarino on 10/1/15.
//  Copyright © 2015 SnarfSnarf. All rights reserved.
//

#import "BonjourClientTachy.h"
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface BonjourClientTachy (Private)
- (void)connectToNextAddress;
@end

#pragma mark -

@implementation BonjourClientTachy

-(id)init
{
    self = [super init];
    // Configure logging framework
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    
    // Start browsing for bonjour services
    
    netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    
    [netServiceBrowser setDelegate:self];
    [netServiceBrowser searchForServicesOfType:@"_YourServiceName._tcp." inDomain:@"local."];
    
    return self;
}

/*- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag
{
    [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"FINISHED READING DATA WITH TAG %ld",tag]];
}*/



- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didNotSearch:(NSDictionary *)errorInfo
{
    DDLogError(@"DidNotSearch: %@", errorInfo);
    [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"DidNotSearch: %@", errorInfo]];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    DDLogVerbose(@"DidFindService: %@", [netService name]);
    [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"DidFindService: %@", [netService name]]];
    
    // Connect to the first service we find
    
    if (serverService == nil)
    {
        DDLogVerbose(@"Resolving...");
        [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"Resolving..."]];
        
        serverService = netService;
        
        [serverService setDelegate:self];
        [serverService resolveWithTimeout:5.0];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    DDLogVerbose(@"DidRemoveService: %@", [netService name]);
    [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"DidRemoveService: %@", [netService name]]];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)sender
{
    DDLogInfo(@"DidStopSearch");
    [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"DidStopSearch"]];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    DDLogError(@"DidNotResolve");
    [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"DidNotResolve"]];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    DDLogInfo(@"DidResolve: %@", [sender addresses]);
    [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"DidResolve: %@", [sender addresses]]];
    
    if (serverAddresses == nil)
    {
        serverAddresses = [[sender addresses] mutableCopy];
    }
    
    if (asyncSocket == nil)
    {
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        [self connectToNextAddress];
    }
}

- (void)connectToNextAddress
{
    BOOL done = NO;
    
    while (!done && ([serverAddresses count] > 0))
    {
        NSData *addr;
        
        // Note: The serverAddresses array probably contains both IPv4 and IPv6 addresses.
        //
        // If your server is also using GCDAsyncSocket then you don't have to worry about it,
        // as the socket automatically handles both protocols for you transparently.
        
        if (YES) // Iterate forwards
        {
            addr = [serverAddresses objectAtIndex:0];
            [serverAddresses removeObjectAtIndex:0];
        }
        else // Iterate backwards
        {
            addr = [serverAddresses lastObject];
            [serverAddresses removeLastObject];
        }
        
        DDLogVerbose(@"Attempting connection to %@", addr);
        [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"Attempting connection to %@", addr]];
        
        NSError *err = nil;
        if ([asyncSocket connectToAddress:addr error:&err])
        {
            done = YES;
        }
        else
        {
            DDLogWarn(@"Unable to connect: %@", err);
            [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"Unable to connect: %@", err]];
        }
        
    }
    
    if (!done)
    {
        DDLogWarn(@"Unable to connect to any resolved address");
        [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"Unable to connect to any resolved address"]];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    DDLogInfo(@"Socket:DidConnectToHost: %@ Port: %hu", host, port);
    [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"Socket:DidConnectToHost: %@ Port: %hu", host, port]];
    connected = YES;
    [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:50.0 tag:100];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            
            NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
            NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
            if (msg)
            {
                [self.delegate receivedWebPage:msg];
            }
            else
            {
                [self.delegate receivedClientDebugMessage:@"Error converting received data into UTF-8 String"];
            }
            
        }
    });
    
    // Echo message back to client
//    [sock writeData:data withTimeout:-1 tag:ECHO_MSG];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DDLogWarn(@"SocketDidDisconnect:WithError: %@", err);
    [self.delegate receivedClientDebugMessage:[NSString stringWithFormat:@"SocketDidDisconnect:WithError: %@", err]];
    
    if (!connected)
    {
        [self connectToNextAddress];
    }
}

@end
