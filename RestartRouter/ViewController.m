//
//  ViewController.m
//  RestartRouter
//
//  Created by Ian Dundas on 25/05/2012.
//  Copyright (c) 2012 Freelance iOS & Web-App Developer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (void)processLine:(NSString *)line fromSocket:(GCDAsyncSocket *)sock;
@end

@implementation ViewController

@synthesize     asyncSocket     = _asyncSocket,
                stringReceived  = _stringReceived,
                isLoggedIn      = _isLoggedIn,
                statusMessage   = _statusMessage,
                startButton     = _startButton;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.stringReceived = [[NSMutableString alloc]init];
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.asyncSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:mainQueue];
    
    [self.view setBackgroundColor:[UIColor blueColor]];
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

- (IBAction)didTouchButton:(UIButton *)sender{
    if (sender.tag==1){
        if (self.asyncSocket.isDisconnected){
            
            NSError *error = nil;
            if (![self.asyncSocket connectToHost:@"192.168.1.254" onPort:23 error:&error]){
                NSLog(@"Error connecting: %@", error);
                [self.view setBackgroundColor:[UIColor redColor]];
                [self.statusMessage setText:@"Error Connecting"];
                [self.startButton setHidden:YES];
            }            
        }
    }
}
#pragma mark - GCDAsyncSocketDelegate Delegate Methods:

- (void)processLine:(NSString *)line fromSocket:(GCDAsyncSocket *)sock{
    
    if (line.length == 0)
        return;
        
    if (self.isLoggedIn){
        
        // The last line of the welcome message, indicating the router is down to party:
        if ([line compare:@"------------------------------------------------------------------------"]==NSOrderedSame){

            NSLog(@"Going for reboot now!");
            [self.view setBackgroundColor:[UIColor greenColor]];
            
            NSString *myStr = @"system reboot\r\n";
            NSData *myData = [myStr dataUsingEncoding:NSUTF8StringEncoding];
            
            [sock writeData:myData withTimeout:5.0 tag:0];   
            
            [sock disconnectAfterWriting];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Success" 
                                  message: @"Your router is now restarting"
                                  delegate:self 
                                  cancelButtonTitle:nil 
                                  otherButtonTitles:@"OK", 
                                  nil];
            [alert show];
        }
        
    }
    else{
    
        if ([line compare:@"Username : "]==NSOrderedSame){
            
            NSString *myStr = @"SuperUser\r\n"; // 
            NSData *myData = [myStr dataUsingEncoding:NSUTF8StringEncoding];
            
            [sock writeData:myData withTimeout:5.0 tag:0];
            
        }
        else if ([line compare:@"Password : "]==NSOrderedSame){
            
            NSString *myStr = @"O2Br0ad64nd\r\n";
            NSData *myData = [myStr dataUsingEncoding:NSUTF8StringEncoding];
            
            [sock writeData:myData withTimeout:5.0 tag:0];
        }
        else if ([line rangeOfString:@"Thomson TG585 v7"].location != NSNotFound){
            
            self.isLoggedIn = YES;
            NSLog(@"Authenticated with Router. Waiting for prompt..");
        }
    }
    
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
 
    NSString *telnetLine = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];

    if (!telnetLine){
        [self.asyncSocket readDataWithTimeout:-1 tag:0];
        return;
    }
    
    [self.stringReceived appendString:telnetLine];
    
    // Break by new line or by prompt:
    if ([self.stringReceived rangeOfString:@"\r\n"].location !=NSNotFound || [self.stringReceived rangeOfString:@" : "].location !=NSNotFound ){

        // Feed each line (may have received more than one) into line processor:
        for (NSString *line in [self.stringReceived componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]){
            [self processLine:line fromSocket:sock];
        }
        
        [self.stringReceived setString:@""];
    }
    
    if (sock.isConnected){ // above code may have disconnected.
        [self.asyncSocket readDataWithTimeout:-1 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{

    NSLog(@"Connected to Host");
    [self.view setBackgroundColor:[UIColor blueColor]];
    [self.asyncSocket readDataWithTimeout:5 tag:1]; // let's get things going.
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
 
    if (err)
        NSLog(@"Did disconnect with error: %@", err.description);
    else
        NSLog(@"Disconnected.");
    
    [self.statusMessage setText:@"Disconnected"];
}

@end
