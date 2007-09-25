//
//  WPSLocation.m
//  WPS
//
//  Created by Kevin Wojniak on 9/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "WPSLocation.h"


@implementation WPSLocation

- (void)setLatitude:(double)latitude
{
	_wpsLatitude = latitude;
}

- (void)setLongitude:(double)longitude
{
	_wpsLongitude = longitude;
}

- (id)init
{
	if (self = [super init])
	{
		[self setLatitude:0.0];
		[self setLongitude:0.0];
	}
	
	return self;
}

- (double)latitude
{
	return _wpsLatitude;
}

- (double)longitude
{
	return _wpsLongitude;
}

@end
