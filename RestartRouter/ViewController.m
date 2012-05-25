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
@synthesize asyncSocket=_asyncSocket;
@synthesize stringReceived = _stringReceived;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.asyncSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:mainQueue];
    
    NSError *error = nil;
     if (![self.asyncSocket connectToHost:@"192.168.1.254" onPort:23 error:&error])
//    if (![self.asyncSocket connectToHost:@"192.168.1.69" onPort:8889 error:&error])
    {
        NSLog(@"Error connecting: %@", error);
    }
    
//    

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



- (void)processLine:(NSString *)line fromSocket:(GCDAsyncSocket *)sock{
    
    NSLog(@"LINE: %@", line);
    
    if ([line compare:@"Username : "]==NSOrderedSame){
        
        NSString *myStr = @"SuperUser\r\n"; // 
        NSData *myData = [myStr dataUsingEncoding:NSUTF8StringEncoding];
        
        [sock writeData:myData withTimeout:5.0 tag:0];
        
    }
    if ([line compare:@"Password : "]==NSOrderedSame){
        
        NSString *myStr = @"O2Br0ad64nd\r\n";
        NSData *myData = [myStr dataUsingEncoding:NSUTF8StringEncoding];
        
        [sock writeData:myData withTimeout:5.0 tag:0];
    }
    
    
    
//    if ([self.stringReceived rangeOfString:@"Username : SuperUser"].location != NSNotFound){
//        NSLog(@"Interesting... (username)");
//        //        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 tag:0];  
//    }
//    else if ([self.stringReceived rangeOfString:@"Password : **"].location != NSNotFound){
//        NSLog(@"Interesting...(password)");
//        //        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 tag:0];  
//    }
//    else if ([self.stringReceived rangeOfString:@"Invalid username/password"].location != NSNotFound){
//        NSLog(@"Failed to login :(");
//        [sock disconnect];
//    }
//    else if ([self.stringReceived compare:@"Password : "]==NSOrderedSame){
//        
//        NSLog(@"ready to send password");
//        
//        NSString *myStr = @"O2Br0ad64nd\r\n"; // \r\n
//        NSData *myData = [myStr dataUsingEncoding:NSUTF8StringEncoding];
//        
//        [sock writeData:myData withTimeout:5.0 tag:0];
//        
//        //        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 tag:0];  
//        //        
//        //        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 tag:0];  
//        //        [self.asyncSocket readDataWithTimeout:5 tag:1];
//        
//    }
//    else if (self.stringReceived==nil){
//        NSLog(@"[Blank line received]");
//    }
//    else {
//        NSLog(@"Unknown received: '%@' vs '%@'", telnetLine, telnetLine_old);
//        //        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 tag:0];
//    }   
    
    
    
    
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
 
    NSString *telnetLine = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    NSLog(@"------------");
    
    if (!telnetLine){
        [self.asyncSocket readDataWithTimeout:-1 tag:0];
        return;
    }
    
    if (!self.stringReceived){
        self.stringReceived = [[NSMutableString alloc]init];
    }

    [self.stringReceived appendString:telnetLine];
    
    if ([self.stringReceived rangeOfString:@"\r\n"].location !=NSNotFound || [self.stringReceived rangeOfString:@" : "].location !=NSNotFound ){

        // Feed each line (may have received more than one) into line processor:
        for (NSString *line in [self.stringReceived componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]){
            [self processLine:line fromSocket:sock];
        }
        
        [self.stringReceived setString:@""];
    }
    
    [self.asyncSocket readDataWithTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket{
//    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 tag:0];  
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{

    NSLog(@"Connected to Host");
    [self.asyncSocket readDataWithTimeout:5 tag:1];
    
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    NSLog(@"Should timeout read?");
//    [self.asyncSocket readDataWithTimeout:5 tag:1]; // TODO this is bad.
    return 5;    
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    NSLog(@"Should timeout write?");
    
    return 5;
}








/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
//- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
//            NSLog( @"%s" , _cmd );
//}


/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
            NSLog( @"%s" , _cmd );
}

/**
 * Called if a write operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
 * 
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been written so far for the write operation.
 * 
 * Note that this method may be called multiple times for a single write if you return positive numbers.
 **/

/**
 * Conditionally called if the read stream closes, but the write stream may still be writeable.
 * 
 * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
 * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
 **/
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{
            NSLog( @"%s" , _cmd );
}

/**
 * Called when a socket disconnects with or without error.
 * 
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * this delegate method will be called before the disconnect method returns.
 **/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
 
    if (err)
        NSLog(@"Did disconnect with error: %@", err.description);
    else
        NSLog(@"Disconnected.");
}

/**
 * Called after the socket has successfully completed SSL/TLS negotiation.
 * This method is not called unless you use the provided startTLS method.
 * 
 * If a SSL/TLS negotiation fails (invalid certificate, etc) then the socket will immediately close,
 * and the socketDidDisconnect:withError: delegate method will be called with the specific SSL error code.
 **/
- (void)socketDidSecure:(GCDAsyncSocket *)sock{
            NSLog( @"%s" , _cmd );
    
}


@end
