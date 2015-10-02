//
//  BonjourClientTachy.h
//  Gilded
//
//  Created by Michael Zuccarino on 10/1/15.
//  Copyright © 2015 SnarfSnarf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ClientDelegate <NSObject>

-(void)receivedClientDebugMessage:(NSString *)message;
-(void)receivedWebPage:(NSString *)webPage;

@end

@class GCDAsyncSocket;


@interface BonjourClientTachy : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
{
    NSNetServiceBrowser *netServiceBrowser;
    NSNetService *serverService;
    NSMutableArray *serverAddresses;
    GCDAsyncSocket *asyncSocket;
    BOOL connected;
}

@property (weak, nonatomic) id<ClientDelegate> delegate;

@end

