//
//  ViewController.m
//  RestartRouter
//
//  Created by Ian Dundas on 25/05/2012.
//  Copyright (c) 2012 Freelance iOS & Web-App Developer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize asyncSocket=_asyncSocket;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.asyncSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:mainQueue];
    
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:@"192.168.1.254" onPort:23 error:&error])
    {
        NSLog(@"Error connecting: %@", error);
    }
    
    [self.asyncSocket readDataWithTimeout:5 tag:1];
    
    NSLog(@"Connected!");
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - Delegate:

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSLog(@"Length: %i", data.length);

    NSString *telnetLine = [NSString stringWithUTF8String:[data bytes]];    

    if ([telnetLine compare:@"Username : "]){
        
        NSLog(@"ready to accept username");
        
    }
    else if (telnetLine==nil){
        NSLog(@"[Blank line received]");
    }
    else{
        NSLog(@"Line received: %@", telnetLine);
    }
    [self.asyncSocket readDataWithTimeout:5 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
    NSString *requestStr = [NSString stringWithFormat:@"help"];
	NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
	
	[sock writeData:requestData withTimeout:10 tag:0];
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 tag:0];    
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{

    NSLog(@"Connected to Host");
    
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    NSLog(@"Should timeout read?");
    [self.asyncSocket readDataWithTimeout:5 tag:1]; // TODO this is bad.
    return 5;    
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSLog(@"Should timeout write?");
    
    return 5;
}

@end
