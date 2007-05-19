//
//  KWInspectorButton.m
//  KWInspector
//
//  Created by Kevin Wojniak on 1/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "KWInspectorButton.h"

@interface KWDisclosureButton : NSButton {}
@end
@implementation KWDisclosureButton
- (id)initWithFrame:(NSRect)frame
{
	if (![super initWithFrame:frame])
		return nil;
	
	[self setBordered:YES];
	[self setButtonType:NSOnOffButton];
	[self setBezelStyle:NSDisclosureBezelStyle];
	[self setFocusRingType:NSFocusRingTypeNone];
	[self setTitle:@""];
	
	return self;
}
@end



@implementation KWInspectorButton

- (id)initWithFrame:(NSRect)frame
{
	if (![super initWithFrame:frame])
		return nil;
	
	float disclosureXOffset = 6, textHeight = 16, textOffset = 2;
	
	_disclosureButton = [[KWDisclosureButton alloc] initWithFrame:
		NSMakeRect(disclosureXOffset, 0, 13, NSHeight(frame))];
	[_disclosureButton setTarget:self];
	[_disclosureButton setAction:@selector(disclosureAction:)];
	
	_textField = [[NSTextField alloc] initWithFrame:
		NSMakeRect(NSMaxX([_disclosureButton frame])+textOffset, (NSHeight(frame)-textHeight)/2 - 1, NSWidth(frame)-NSWidth([_disclosureButton frame])-textOffset, textHeight)];
	[_textField setEditable:NO];
	[_textField setBordered:NO];
	[_textField setDrawsBackground:NO];
	[_textField setFont:[NSFont labelFontOfSize:11]];
	[_textField setStringValue:@""];
	
	
	float hotkeyWidth = 40;
	_hotkey = [[NSTextField alloc] initWithFrame:
		NSMakeRect(NSWidth(frame)-hotkeyWidth-4, [_textField frame].origin.y, hotkeyWidth, [_textField frame].size.height)];
	[_hotkey setEditable:[_textField isEditable]];
	[_hotkey setBordered:[_textField isBordered]];
	[_hotkey setDrawsBackground:[_textField drawsBackground]];
	[_hotkey setFont:[_textField font]];
	[_hotkey setTextColor:[NSColor colorWithCalibratedRed:0.45 green:0.45 blue:0.45 alpha:1.0]];
	[[_hotkey cell] setAlignment:NSRightTextAlignment];
	[_hotkey setStringValue:@""];
	
	[self addSubview:_disclosureButton];
	[self addSubview:_textField];
	[self addSubview:_hotkey];
	
	return self;
}

- (void)dealloc
{
	[_disclosureButton release];
	[_textField release];
	[_hotkey release];
	[_view release];
	[super dealloc];
}

#pragma mark -
- (void)disclosureAction:(id)sender
{
	if (_target)
		[_target performSelector:_action withObject:self];
}

#pragma mark -

- (void)setTarget:(id)anObject
{
	_target = anObject;
}

- (void)setAction:(SEL)aSelector
{
	_action = aSelector;
}

- (BOOL)state
{
	return [_disclosureButton state];
}

- (void)updateHotKey
{
	unsigned int mask = [_disclosureButton keyEquivalentModifierMask];
	NSMutableString *s = [NSMutableString string];
	if (mask)
	{
		if (mask & NSCommandKeyMask)
			[s appendFormat:@"%C", 0x2318];
		[s appendString:[_disclosureButton keyEquivalent]];
	}
	[_hotkey setStringValue:s];
}

- (void)setKeyEquivalent:(NSString *)charCode
{
	[_disclosureButton setKeyEquivalent:charCode];
	[self updateHotKey];
}

- (void)setKeyEquivalentModifierMask:(unsigned int)mask
{
	[_disclosureButton setKeyEquivalentModifierMask:mask];
	[self updateHotKey];
}

- (void)setStringValue:(NSString *)stringValue
{
	[_textField setStringValue:stringValue];
}

- (void)setView:(NSView *)view
{
	if (_view != view)
	{
		[_view release];
		_view = [view retain];
	}
}

- (NSView *)view
{
	return _view;
}

@end
