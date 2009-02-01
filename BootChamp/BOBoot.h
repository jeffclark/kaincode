//
//  BOBoot.h
//  BootChamp
//
//  Created by Kevin Wojniak on 7/4/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
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

int bootIntoWindows();