//
//  View.m
//  SelectionView
//
//  Created by Kevin Wojniak on 11/26/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "View.h"
#import "KWImage.h"

#define KW_INTERAL_DRAG	@"KW_INTERNAL_DRAG"


int randomNumber(int high, int low)
{
	return rand() % (high - low + 1) + low;
}


@implementation View

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self setupImages];
		
		[self registerForDraggedTypes:[NSArray arrayWithObjects:NSTIFFPboardType, KW_INTERAL_DRAG, nil]];
	}
	
	return self;
}

- (void)dealloc
{
	[_objs release];
	[_bg release];
	[super dealloc];
}

- (BOOL)rectIsFree:(NSRect)rect
{
	NSEnumerator *imgEnum = [_objs objectEnumerator]; KWImage *img = nil;
	while (img = [imgEnum nextObject])
	{
		if (NSIntersectsRect(rect, [img rect]))
			return NO;
	}
	return YES;
}

- (void)setupImages
{
	srand(time(NULL));
	
	KWImage *img = nil;
	NSPoint loc = NSZeroPoint;
	
	_objs = [[NSMutableArray alloc] init];

	NSString *path = @"/Applications";
	NSEnumerator *fileEnums = [[[NSFileManager defaultManager] directoryContentsAtPath:path] objectEnumerator]; NSString *file = nil;
	NSMutableArray *apps = [NSMutableArray array];
	int count = 0;
	while (file = [fileEnums nextObject])
	{
		if (![[file pathExtension] isEqualToString:@"app"]) continue;
		[apps addObject:[path stringByAppendingPathComponent:file]];
	}
	
	// shuffle array
	int i;
	for (i=0; i<[apps count]; i++)
	{
		int r = randomNumber([apps count]-1,0);
		id obj = [apps objectAtIndex:i];
		[apps replaceObjectAtIndex:i withObject:[apps objectAtIndex:r]];
		[apps replaceObjectAtIndex:r withObject:obj];
	}
	
	fileEnums = [apps objectEnumerator];
	while ((file = [fileEnums nextObject]) && (count<15))
	{
		NSImage *fileImage = [[NSWorkspace sharedWorkspace] iconForFile:file];
		[fileImage setSize:NSMakeSize(64, 64)];
		
		NSRect freeRect;
		freeRect.size = [fileImage size];
		float bw = [self bounds].size.width, bh = [self bounds].size.height;
		
		do
		{
			loc = NSMakePoint(randomNumber(bw-freeRect.size.width,0), randomNumber(bh-freeRect.size.height,0));
			freeRect.origin = loc;
		}
		while (![self rectIsFree:freeRect]);
		
		img = [[KWImage alloc] initWithImage:fileImage];
		[img setLocation:loc];
		[img setTitle:[file lastPathComponent]];
		[img setTag:count];
		[_objs addObject:img];
		[img release];
		
		count++;
	}
}

- (KWImage *)objectWithTag:(int)tag
{
	NSEnumerator *e = [_objs objectEnumerator]; KWImage *img = nil;
	while (img = [e nextObject])
		if ([img tag] == tag)
			return img;
	return nil;
}

- (void)drawImages
{
	NSEnumerator *e = [_objs objectEnumerator]; KWImage *img = nil;
	int options = 0;
	while (img = [e nextObject])
	{
		options = 0;
		if (_drawSelection && NSIntersectsRect(_selRect, [img rect]))
				options |= KW_SELECTED;
		
		[img drawInRect:[self bounds] options:options];
	}
}

- (void)calculateSelRect
{
	if (!_drawSelection)
	{
		_selRect = NSZeroRect;
	}
	else
	{
		float w = _selEnd.x - _selStart.x, h = _selEnd.y - _selStart.y;
		//NSPoint endPoint = NSMakePoint(NSMaxX(selRect), NSMaxY(selRect));
		
		_selRect.origin = _selStart;
		if (w < 0)
			_selRect.origin.x += w;
		if (h < 0)
			_selRect.origin.y += h;
		_selRect.size.width = abs(w);
		_selRect.size.height = abs(h);
		_selRect.origin.x = floor(_selRect.origin.x)+0.5;
		_selRect.origin.y = floor(_selRect.origin.y)+0.5;
	}
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor whiteColor] set];
	NSRectFill([self bounds]);
	
	if (_autoarrange)
		[self cleanUp:nil];
	
	if (_bg)
	{
		NSSize s = [[[_bg representations] objectAtIndex:0] size];
		NSRect r = NSMakeRect(0, 0, s.width, s.height);
		[_bg drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	[self calculateSelRect];

	[self drawImages];
	
	if (_drawSelection)
	{
		[[NSColor colorWithCalibratedWhite:0.9137254902 alpha:0.5] set];
		[NSBezierPath strokeRect:_selRect];
		[[NSColor colorWithCalibratedWhite:0.89411764706 alpha:0.5] set];
		[NSBezierPath fillRect:_selRect];
	}
}

- (void)deselectAll
{
	NSEnumerator *e = [_objs objectEnumerator]; KWImage *img = nil;
	while (img = [e nextObject])
		[img setSelected:NO];
	[self setNeedsDisplay:YES];
}

- (void)selectAllInSelectionRect
{
	NSEnumerator *e = [_objs objectEnumerator]; KWImage *img = nil;
	while (img = [e nextObject])
	{
		if (NSIntersectsRect(_selRect,[img rect]))
			[img setSelected:YES];
	}
	[self setNeedsDisplay:YES];
}

- (KWImage *)objectAtPoint:(NSPoint)point
{
	NSEnumerator *e = [_objs objectEnumerator]; KWImage *img = nil;
	while (img = [e nextObject])
		if (NSPointInRect(point,[img rect]))
			return img;
	return nil;
}

- (void)mouseDown:(NSEvent *)event
{
	BOOL go = YES;
	NSPoint mouseLoc = [self convertPoint:[event locationInWindow] fromView:nil];
	
	KWImage *obj = [self objectAtPoint:mouseLoc];
	if (obj)
	{
		if (([event modifierFlags] & NSCommandKeyMask))
		{
			[obj setSelected:![obj selected]];
		}
		else
		{
			[self deselectAll]; // only deselect if command key is not down
			[obj setSelected:YES];
		}
		
		if (!_autoarrange)
		{
			NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
			[pboard declareTypes:[NSArray arrayWithObjects:NSTIFFPboardType, KW_INTERAL_DRAG, nil] owner:self];
			[pboard setData:[[obj image] TIFFRepresentation] forType:NSTIFFPboardType];
			[pboard setData:[NSArchiver archivedDataWithRootObject:[NSNumber numberWithInt:[obj tag]]] forType:KW_INTERAL_DRAG];
			[self dragImage:[obj image] at:[obj rect].origin offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];
		}
		
		[self setNeedsDisplay:YES];
		
		return;
	}
	
	[self deselectAll];
	
	_drawSelection = YES;
	_selStart = mouseLoc;
	_selEnd = _selStart;
	[self setNeedsDisplay:YES];
	
	while (go)
	{
		mouseLoc = [self convertPoint:[event locationInWindow] fromView:nil];
		event = [[self window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];
		
		switch ([event type])
		{
			case NSLeftMouseDragged:
			{
				_selEnd = mouseLoc;
				break;
			}
			case NSLeftMouseUp:
			{
				//if ([self mouse:mouseLoc inRect:[self bounds]])
				//	;
				go = NO;
				break;
			}
			default:
				break;
		}

		[self setNeedsDisplay:YES];
	}
	
	[self selectAllInSelectionRect];
	
	_drawSelection = NO;
}

- (void)resetCursorRects
{
	static NSTrackingRectTag _tag = 0;
	[self removeTrackingRect:_tag];
	_tag = [self addTrackingRect:[self visibleRect] owner:self userData:NULL assumeInside:NO];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	return NSDragOperationMove;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];
	NSData *dat = [pboard dataForType:KW_INTERAL_DRAG];
	if (dat == nil) return NO;
	
	KWImage *img = [self objectWithTag:[(NSNumber *)[NSUnarchiver unarchiveObjectWithData:dat] intValue]];
	if (!img) return NO;
	
	NSRect rect = [img rect];
	rect.origin = [sender draggedImageLocation];
	[img setLocation:rect.origin];
	[self setNeedsDisplay:YES];

	return YES;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    [self setNeedsDisplay:YES];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	KWImage *obj = [self objectAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
	
	NSMenu *menu = [[NSMenu alloc] init];
	[menu addItemWithTitle:@"Clean Up" action:@selector(cleanUp:) keyEquivalent:@""];
	id item = [menu addItemWithTitle:@"Auto Arrange" action:@selector(autoArrange:) keyEquivalent:@""];
	[item setState:_autoarrange];
	if (obj)
	{
		[menu addItemWithTitle:@"Delete" action:@selector(deleteObj:) keyEquivalent:@""];
	}
	[menu addItemWithTitle:@"Choose Background Image..." action:@selector(chooseBG:) keyEquivalent:@""];
	
	return [menu autorelease];
}

- (void)cleanUp:(id)sender
{
	NSEnumerator *e = nil; KWImage *img = nil;
	int sz = 0;
	int xspacing = 10,  yspacing = 10;
	NSRect r;
	
	// find largest width/height
	e = [_objs objectEnumerator];
	while (img = [e nextObject])
	{
		if ([[img image] size].width > sz)
			sz = [[img image] size].width;
		else if ([[img image] size].height > sz)
			sz = [[img image] size].height;
	}
	
	r = NSMakeRect(xspacing, [self bounds].size.height - yspacing - sz, sz + xspacing, sz + yspacing);
	
	e = [_objs objectEnumerator];
	while (img = [e nextObject])
	{
		if (NSMaxX(r) > [self bounds].size.width)
		{
			r.origin.x = xspacing;
			r.origin.y -= yspacing + sz;
		}
		
		NSRect imgr;
		imgr.size = [[img image] size];
		imgr.origin = r.origin;
		[img setRect:imgr];

		r.origin.x += xspacing + sz;
	}
	
	[self setNeedsDisplay:YES];
}

- (void)deleteObj:(id)sender
{
	KWImage *obj = [self objectAtPoint:[self convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil]];
	if (obj)
	{
		[_objs removeObject:obj];
		[self setNeedsDisplay:YES];
	}
}

- (void)chooseBG:(id)sender
{
	NSOpenPanel *op = [NSOpenPanel openPanel];
	[op setCanChooseFiles:YES];
	[op setCanChooseDirectories:NO];
	if ([op runModalForTypes:[NSImage imageFileTypes]] == NSOKButton)
	{
		[_bg release];
		_bg = [[NSImage alloc] initWithContentsOfFile:[op filename]];
		[self setNeedsDisplay:YES];
	}
}

- (void)autoArrange:(id)sender
{
	[sender setState:![sender state]];
	_autoarrange = [sender state];
	[self setNeedsDisplay:YES];
}

- (void)selectAll:(id)sender
{
	NSEnumerator *e = [_objs objectEnumerator]; KWImage *img = nil;
	while (img = [e nextObject])
		[img setSelected:YES];
	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

@end
