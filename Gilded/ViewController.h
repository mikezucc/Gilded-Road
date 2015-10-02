//
//  ViewController.h
//  Gilded
//
//  Created by Michael Zuccarino on 9/29/15.
//  Copyright © 2015 SnarfSnarf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "BonjourServerTachy.h"
#import "BonjourClientTachy.h"

@interface ViewController : NSViewController

@property (strong, nonatomic) IBOutlet NSView *sideBarView;

@property (strong, nonatomic) IBOutlet WebView *gildedWebView;
@property (strong, nonatomic) IBOutlet NSButton *gButton;

@property (strong, nonatomic) IBOutlet NSTextView *debugOutputWindow;

@property (strong, nonatomic) BonjourServerTachy *serverTachy;
@property (strong, nonatomic) BonjourClientTachy *clientTachy;


@end

