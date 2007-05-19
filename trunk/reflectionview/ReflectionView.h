//
//  ReflectionView.h
//  ReflectionView
//
//  Created by Kevin Wojniak on 11/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ReflectionView : NSView
{
	NSImage *_img;
	NSColor *_bgColor;
}

- (IBAction)chooseImage:(id)sender;

- (void)setImage:(NSImage *)image;

@end
