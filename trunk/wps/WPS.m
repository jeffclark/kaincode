//
//  WPS.m
//  WPS
//
//  Created by Kevin Wojniak on 9/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "WPS.h"
#import "WPSLocation.h"


@interface WPSLocation (PrivateMethods)
- (void)setLatitude:(double)latitude;
- (void)setLongitude:(double)longitude;
@end


@implementation WPS

- (id)initWithUsername:(NSString *)username realm:(NSString *)realm
{
	if (self = [super init])
	{
		_wpsUsername = [username retain];
		_wpsRealm = [realm retain];
	}
	
	return self;
}

- (void)dealloc
{
	[_wpsUsername release];
	[_wpsRealm release];

	[super dealloc];
}

- (WPSLocation *)currentLocation
{
	WPSLocation *loc = nil;
	WPS_Location *wpsLocation = NULL;
	int err = 0;
	WPS_SimpleAuthentication auth;
	
	auth.username = [_wpsUsername UTF8String];
	auth.realm = [_wpsRealm UTF8String];
	
	err = WPS_location(&auth, WPS_NO_STREET_ADDRESS_LOOKUP, &wpsLocation);

	NSLog(@"err: %d", err);
	
	if (err == WPS_OK)
	{
		loc = [[[WPSLocation alloc] init] autorelease];
		[loc setLatitude:wpsLocation->latitude];
		[loc setLongitude:wpsLocation->longitude];
	}

	WPS_free_location(wpsLocation);
	
	return loc;
}

@end
