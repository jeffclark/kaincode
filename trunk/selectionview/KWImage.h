//
//  KWImage.h
//  SelectionView
//
//  Created by Kevin Wojniak on 11/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define KW_SELECTED	0x1

@interface KWImage : NSObject <NSCoding>
{
	NSImage *_img;
	NSPoint _loc;
	NSRect _rect;
	
	NSString *_title;
	int _tag;
	
	BOOL _selected;
}

- (id)initWithImage:(NSImage *)image;

- (void)setLocation:(NSPoint)location;
- (NSImage *)image;
- (NSRect)rect;
- (void)setRect:(NSRect)rect;
- (BOOL)selected;
- (void)setSelected:(BOOL)selected;
- (void)setTitle:(NSString *)title;
- (NSString *)title;
- (int)tag;
- (void)setTag:(int)tag;

- (void)drawInRect:(NSRect)rect options:(unsigned char)options;

@end
