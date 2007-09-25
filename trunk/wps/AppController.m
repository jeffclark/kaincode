//
//  AppController.m
//  WPS
//
//  Created by Kevin Wojniak on 9/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "WPS.h"
#import "WPSLocation.h"


@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)n
{
	[progressBar startAnimation:nil];
	[NSThread detachNewThreadSelector:@selector(loadLocation) toTarget:self withObject:nil];
}

- (void)loadLocation
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	WPS *wps = [[WPS alloc] initWithUsername:@"kainjow" realm:@"kainjow.com"];
	WPSLocation *loc = [wps currentLocation];
	[self performSelectorOnMainThread:@selector(gotLocation:) withObject:loc waitUntilDone:YES];
	[wps release];
	
	[pool release];
}

- (void)gotLocation:(WPSLocation *)location
{
	[latField setFloatValue:[location latitude]];
	[longField setFloatValue:[location longitude]];
	[progressBar stopAnimation:nil];
}

@end
