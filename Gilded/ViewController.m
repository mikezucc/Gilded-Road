//
//  ViewController.m
//  Gilded
//
//  Created by Michael Zuccarino on 9/29/15.
//  Copyright © 2015 SnarfSnarf. All rights reserved.
//

#import "ViewController.h"

@interface ViewController() <ClientDelegate, ServerDelegate>

@end

@implementation ViewController

-(void)viewDidAppear
{
    [[self.gildedWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
}

-(IBAction)startSever:(id)sender
{
    self.serverTachy = [[BonjourServerTachy alloc] init];
    self.serverTachy.delegate = self;
}

-(IBAction)endServer:(id)sender
{
    self.clientTachy = [[BonjourClientTachy alloc] init];
    self.clientTachy.delegate = self;
}

-(IBAction)loadGPage:(id)sender
{
    NSError *error;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"kartingleague2" ofType:@"html"];

    //[[self.gildedWebView mainFrame] loadHTMLString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error] baseURL:[NSURL URLWithString:@""]];
    [[self.gildedWebView mainFrame] loadHTMLString:@"RESET" baseURL:[NSURL URLWithString:@""]];
}

-(void)receivedClientDebugMessage:(NSString *)message
{
    [self.debugOutputWindow setString:[NSString stringWithFormat:@"%@\n%@",self.debugOutputWindow.string,message]];
}

-(void)receivedServerDebugMessage:(NSString *)debugMessage
{
    [self.debugOutputWindow setString:[NSString stringWithFormat:@"%@\n%@",self.debugOutputWindow.string,debugMessage]];
}

-(void)receivedWebPage:(NSString *)webPage
{
    NSLog(@"received web page is this");
    [[self.gildedWebView mainFrame] loadHTMLString:webPage baseURL:[NSURL URLWithString:@""]];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
