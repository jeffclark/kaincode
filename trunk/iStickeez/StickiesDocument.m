//
//  Document.m
//  iStickeez
//
//  Created by Kevin Wojniak on 12/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "StickiesDocument.h"


enum {
	Yellow,
	Blue,
	Green,
	Pink,
	Purple,
	Gray,
};

#define RGB(r,g,b)	[NSColor colorWithCalibratedRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

@implementation StickiesDocument

@synthesize title, attributedString, color;

- (NSColor *)convertStickiesColor:(int)colorValue
{
	switch (colorValue) {
		case Yellow:	return RGB(254, 244, 156);
		case Blue:		return RGB(173, 244, 255);
		case Green:		return RGB(178, 255, 161);
		case Pink:		return RGB(255, 199, 199);
		case Purple:	return RGB(182, 202, 255);
		case Gray:		return RGB(238, 238, 238);
	}
	return nil;
}

- (id)initWithCoder:(NSCoder *)coder
{
	if ([super init])
	{
		if (![coder allowsKeyedCoding])
		{
			// decode RTFD data, convert to NSAttributedString
			NSData *rtfdData = [coder decodeObject];
			attributedString = [[NSAttributedString alloc] initWithRTFD:rtfdData documentAttributes:nil];

			// decode window flags. 1 for collapsed, 0 for normal. most likely holds translucent/floating states as well.
			int windowFlags;
			[coder decodeValueOfObjCType:@encode(int) at:&windowFlags];
			
			// decode window's frame
			NSRect windowFrame;
			[coder decodeValueOfObjCType:@encode(NSRect) at:&windowFrame];
			
			// decode window color, convert to a usable NSColor object
			int windowColor;
			[coder decodeValueOfObjCType:@encode(int) at:&windowColor];
			color = [[self convertStickiesColor:windowColor] retain];
			
			// decode creation and modification dates
			NSDate *creationDate, *modificationDate;
			creationDate = [coder decodeObject];
			modificationDate = [coder decodeObject];
			
			// generate a title based on the first line of the note
			title = [[[[attributedString string] componentsSeparatedByString:@"\n"] objectAtIndex:0] retain];
		}
	}
	
	return self;
}

- (void)dealloc
{
	[attributedString release];
	[color release];
	[title release];
	
	[super dealloc];
}

@end
