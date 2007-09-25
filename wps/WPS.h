//
//  WPS.h
//  WPS
//
//  Created by Kevin Wojniak on 9/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "wpsapi.h"

@class WPSLocation;


@interface WPS : NSObject
{
	NSString *_wpsUsername;
	NSString *_wpsRealm;
	
	WPS_SimpleAuthentication _wpsAuthentication;
}

- (id)initWithUsername:(NSString *)username realm:(NSString *)realm;

// blocks current thread
- (WPSLocation *)currentLocation;


@end
