//
//  KWInspectorController.m
//  KWInspector
//
//  Created by Kevin Wojniak on 1/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "KWInspectorController.h"
#import "KWInspectorButton.h"


#define TITLE_HEIGHT		20


@implementation KWInspectorController

- (id)init
{
	if (![super init])
		return nil;
	
	_panel = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 200, TITLE_HEIGHT)
										styleMask:NSTitledWindowMask | NSClosableWindowMask | NSUtilityWindowMask
										  backing:NSBackingStoreBuffered
											defer:YES];
	[_panel setTitle:@"Inspector"];
	[_panel setFloatingPanel:YES];
	
	return self;
}

- (void)dealloc
{
	[_panel release];
	[super dealloc];
}

- (void)shiftAllViewsBy:(float)height belowView:(NSView *)view
{
	NSEnumerator *ve = [[[_panel contentView] subviews] objectEnumerator];
	NSView *aView = nil;
	
	while (aView = [ve nextObject])
	{
		NSRect viewFrame = [aView frame];
		if (NSMaxY(viewFrame) <= NSMaxY([view frame]) && aView!=view)
		{
			viewFrame.origin.y -= height;
			[aView setFrame:viewFrame];
		}
	}
	
	[[_panel contentView] setNeedsDisplay:YES];
}

- (void)disclosureAction:(KWInspectorButton *)sender
{
	NSView *view = [sender view];
	if (!view)
		return;
	
	int height = [view frame].size.height;
	NSRect frame = [_panel frame];
	BOOL hide = YES;
	if ([sender state])
	{
		// show
		frame.size.height += height;
		frame.origin.y -= height;
		hide = NO;
	}
	else
	{
		// hide
		frame.size.height -= height;
		frame.origin.y += height;
		hide = YES;
	}
	
	[view setHidden:hide];

	[_panel setFrame:frame display:YES animate:NO];
	[self shiftAllViewsBy:([sender state] ? height : -height) belowView:view];
}

- (void)awakeFromNib
{
	float y = [[_panel contentView] frame].size.height - TITLE_HEIGHT, w = NSWidth([[_panel contentView] frame]);
	int groups = 3, i;
	NSArray *labels = [NSArray arrayWithObjects:@"General", @"More Info", @"Preview", nil];
	for (i=0; i<groups; i++)
	{
		NSRect butFrame = NSMakeRect(0, y, w, TITLE_HEIGHT);
		KWInspectorButton *button = [[KWInspectorButton alloc] initWithFrame:butFrame];
		NSView *view = nil;
		
		switch (i)
		{
			case 0: view = view1; break;
			case 1: view = view2; break;
			case 2: view = view3; break;
		}
		
		[button setTarget:self];
		[button setAction:@selector(disclosureAction:)];
		[button setAutoresizingMask:NSViewMinYMargin];
		[button setStringValue:[labels objectAtIndex:i]];
		[button setKeyEquivalent:[NSString stringWithFormat:@"%d", i+1]];
		[button setKeyEquivalentModifierMask:NSCommandKeyMask];
		
		[view setFrameOrigin:NSMakePoint(0, butFrame.origin.y -= [view frame].size.height)];
		[view setHidden:YES];
		[view setAutoresizingMask:NSViewMinYMargin];
		[button setView:view];

		[[_panel contentView] addSubview:view];
		[[_panel contentView] addSubview:button];
		
		[button release];
		
		if (i < groups-1)
		{
			NSBox *line = [[NSBox alloc] initWithFrame:NSMakeRect(0, --y, w, 1)];
			[line setBorderType:NSLineBorder];
			[line setBoxType:NSBoxSeparator];
			[line setAutoresizingMask:NSViewMinYMargin];
			[[_panel contentView] addSubview:line];
			[line release];
		}
		
		y -= TITLE_HEIGHT;
		
	}
	
	[[_panel contentView] setAutoresizesSubviews:YES];

	NSSize contentSize = [_panel contentRectForFrameRect:[_panel frame]].size;
	contentSize.height = TITLE_HEIGHT*groups;
	[_panel setContentSize:contentSize];
	
	[_panel makeKeyAndOrderFront:nil];
	[_panel center];
}

@end
