//
//  TFController.h
//  TimeFail
//
//  Created by Kevin Wojniak on 9/3/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TFController : NSObject {
	NSArray *m_logs;
}

@property (readwrite, retain) NSArray *logs;

- (IBAction)sendFeedback:(id)sender;

@end
