//
//  KWScrollingTextView.m
//  ScrollingTextView
//
//  Created by Kevin Wojniak on 5/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "KWScrollingTextView.h"


#define KWScrollInitialPosition		0
#define KWScrollPeriod				0.04


@implementation KWScrollingTextView

- (void)awakeFromNib
{
	/* configure the textview - no scroll bars, non-editable and non-selectable */
	[self setEditable:NO];
	[self setSelectable:NO];
	[[self enclosingScrollView] setHasHorizontalScroller:NO];
	[[self enclosingScrollView] setHasVerticalScroller:NO];
}

- (void)startScrollingWithInitialDelay:(NSTimeInterval)delay
{
	/* start the animation 'delay' seconds from now */
	[NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(timerStartScroll:) userInfo:nil repeats:NO];
}

- (void)timerStartScroll:(NSTimer *)timer
{
	/* start the animation timer at our initial position (0) */
	_kwScrollPosition = KWScrollInitialPosition;
	[NSTimer scheduledTimerWithTimeInterval:KWScrollPeriod target:self selector:@selector(timerScroll:) userInfo:nil repeats:YES];
}

- (void)timerScroll:(NSTimer *)timer
{
	/* if command key is down, don't scroll */
	if ([[NSApp currentEvent] modifierFlags] & NSControlKeyMask)
		return;
	
	[self scrollPoint:NSMakePoint(KWScrollInitialPosition, _kwScrollPosition)];
	
	/* scroll down for option key, and up otherwise */
	if ([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask)
	{
		/* check to see if we're below min scroll position */
		if (_kwScrollPosition > KWScrollInitialPosition)
			_kwScrollPosition--;
	}
	else
	{
		/* check to see if we're over max scroll position */
		float maxPos = (int)(NSHeight([[[self enclosingScrollView] documentView] frame]) - NSHeight([[self enclosingScrollView] documentVisibleRect]));
		if (_kwScrollPosition < maxPos)
			_kwScrollPosition++;
	}
}

/* ignore mouse wheel scrolls */
- (void)scrollWheel:(NSEvent *)event { }

@end
