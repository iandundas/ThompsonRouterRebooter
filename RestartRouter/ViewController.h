//
//  ViewController.h
//  RestartRouter
//
//  Created by Ian Dundas on 25/05/2012.
//  Copyright (c) 2012 Freelance iOS & Web-App Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface ViewController : UIViewController<GCDAsyncSocketDelegate>

@property (nonatomic, retain) NSMutableString *stringReceived;
@property (nonatomic, retain) GCDAsyncSocket *asyncSocket;
@end
