//
//  TFController.m
//  TimeFail
//
//  Created by Kevin Wojniak on 9/3/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import "TFController.h"
#import "TFTimeMachineLogs.h"
#import "TFLogColorTransformer.h"


@implementation TFController

@synthesize logs = m_logs;

+ (void)initialize
{
	[NSValueTransformer setValueTransformer:[[[TFLogColorTransformer alloc] init] autorelease] forName:@"TFLogColorTransformer"];
}

- (id)init
{
	if ([super init])
	{
		self.logs = [TFTimeMachineLogs logs];
	}
	
	return self;
}

- (void)dealloc
{
	self.logs = nil;
	[super dealloc];
}

- (IBAction)sendFeedback:(id)sender
{
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *urlString = [[NSString stringWithFormat:@"mailto:kainjow@kainjow.com?subject=%@ %@ Feedback", [[NSProcessInfo processInfo] processName], appVersion] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
}

@end
