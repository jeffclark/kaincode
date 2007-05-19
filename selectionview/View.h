//
//  View.h
//  SelectionView
//
//  Created by Kevin Wojniak on 11/26/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface View : NSView
{
	BOOL _drawSelection;
	NSPoint _selStart, _selEnd;
	NSRect _selRect;
	
	NSMutableArray *_objs;
	NSImage *_bg;
	BOOL _autoarrange;
}

- (void)setupImages;

@end
