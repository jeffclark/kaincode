//
//  KWImage.m
//  SelectionView
//
//  Created by Kevin Wojniak on 11/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "KWImage.h"


@implementation KWImage

- (id)initWithImage:(NSImage *)image
{
	if (self = [super init])
	{
		_img = [image copy];
	}
	
	return self;
}

- (void)dealloc
{
	[_img release];
	[_title release];
	[super dealloc];
}

- (void)setLocation:(NSPoint)location
{
	_loc = location;
	
	_rect = NSMakeRect(_loc.x, _loc.y, [_img size].width, [_img size].height);
}

- (NSImage *)image
{
	return _img;
}

- (NSRect)rect
{
	return _rect;
}

- (void)setRect:(NSRect)rect
{
	_rect = rect;
	_loc = _rect.origin;
}

- (BOOL)selected
{
	return _selected;
}

- (void)setSelected:(BOOL)selected
{
	_selected = selected;
}

- (void)setTitle:(NSString *)title
{
	if (_title != title)
	{
		[_title release];
		_title = [title copy];
	}
}
- (NSString *)title
{
	return _title;
}

- (int)tag
{
	return _tag;
}

- (void)setTag:(int)tag
{
	_tag = tag;
}

- (void)drawInRect:(NSRect)rect options:(unsigned char)options
{
	[_img drawAtPoint:_loc fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];	

	if (_selected || (options & KW_SELECTED == KW_SELECTED))
	{
		[[NSColor blueColor] set];
		NSBezierPath *bp = [NSBezierPath bezierPath];
		[bp setLineWidth:2.0];
		[bp appendBezierPathWithRect:_rect];
		[bp stroke];
	}
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_img];
	[coder encodePoint:_loc];
	[coder encodeRect:_rect];
	[coder encodeObject:[NSNumber numberWithBool:_selected]];
	[coder encodeObject:_title];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		_img = [[coder decodeObject] retain];
		_loc = [coder decodePoint];
		_rect = [coder decodeRect];
		_selected = [[coder decodeObject] boolValue];
		_title = [[coder decodeObject] retain];
	}
	
	return self;
}

- (NSString *)description
{
	return _title;
}

@end
