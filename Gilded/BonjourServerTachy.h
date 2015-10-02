//
//  BonjourServerTachy.h
//  Gilded
//
//  Created by Michael Zuccarino on 10/1/15.
//  Copyright © 2015 SnarfSnarf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ServerDelegate <NSObject>

-(void)receivedServerDebugMessage:(NSString *)debugMessage;

@end

@class GCDAsyncSocket;

@interface BonjourServerTachy : NSObject <NSNetServiceDelegate>
{
    NSNetService *netService;
    GCDAsyncSocket *asyncSocket;
    NSMutableArray *connectedSockets;
}

@property (weak, nonatomic) id<ServerDelegate> delegate;

@end

