//
//  BOMedia.h
//  BootChamp
//
//  Created by Kevin Wojniak on 9/9/08.
//  Copyright 2008 Kainjow LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BOMedia : NSObject {
	NSString *mountPoint;
	NSString *deviceName;
	NSString *name;
}

@property (readwrite, retain) NSString *mountPoint;
@property (readwrite, retain) NSString *deviceName;
@property (readwrite, retain) NSString *name;

@end
