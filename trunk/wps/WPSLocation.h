//
//  WPSLocation.h
//  WPS
//
//  Created by Kevin Wojniak on 9/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WPSLocation : NSObject
{
	double _wpsLatitude;
    double _wpsLongitude;
}

- (double)latitude;
- (double)longitude;

@end