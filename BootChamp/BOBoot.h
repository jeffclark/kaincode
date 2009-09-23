//
//  BOBoot.h
//  BootChamp
//
//  Created by Kevin Wojniak on 7/4/07.
//  Copyright 2007-2009 Kainjow LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
	switchSuccessError = 0,
	noWindowsVolumeError,
	authFailedOrBlessFailedError,
	authCancelled,
	bcblessError,
	restartFailedError,
};


@class BOMedia;

@interface BOBoot : NSObject
{
	BOOL nextonly;
	BOMedia *media;
}

@property (readwrite) BOOL nextonly;
@property (readwrite, retain) BOMedia *media;

- (NSInteger)bootIntoWindows;

@end
