//
//  TFLog.h
//  TimeFail
//
//  Created by Kevin Wojniak on 9/3/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
	TFLogTypeNormal,
	TFLogTypeError,
	TFLogTypeSuccess,
};
typedef NSUInteger TFLogType;

@interface TFLog : NSObject
{
	NSString *m_message;
	TFLogType m_logType;
}

@property (readwrite, retain) NSString *message;
@property (readwrite) TFLogType logType;

@end
