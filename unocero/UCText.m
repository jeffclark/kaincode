//
//  UCTableView.m
//  UnoCero
//
//  Created by Kevin Wojniak on 7/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "UCText.h"


@implementation UCText

- (id)init
{
	if (self = [super initWithFrame:NSMakeRect(0, 0, 10, 10)])
	{
	}
	
	return self;
}

- (void)dealloc
{
	[_allowedCharacters release];
	[super dealloc];
}

#pragma mark -

- (NSCharacterSet *)allowedCharacters
{
	return _allowedCharacters;
}

- (void)setAllowedCharacters:(NSCharacterSet *)allowedCharacters
{
	if (_allowedCharacters != allowedCharacters)
	{
		[_allowedCharacters release];
		_allowedCharacters = [allowedCharacters copy];
	}
}

- (BOOL)characterIsAllowed:(unichar)c
{
	// allow back/forward delete, left/right arrow movement
	if (c != 127 && c != 63272 && c != 63234 && c != 63235)
		if ([[self allowedCharacters] characterIsMember:c] == NO)
			return NO;
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
	unichar c = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	if ([self characterIsAllowed:c] == NO)
		return;
		
	[super keyDown:theEvent];
}

- (void)paste:(id)sender
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	NSString *pastedText = [pasteboard stringForType:NSStringPboardType];
	
	int i;
	for (i=0; i<[pastedText length]; i++)
	{
		unichar c = [pastedText characterAtIndex:i];
		if ([self characterIsAllowed:c] == NO)
			return;
	}
	
	[super paste:sender];
}

@end
