//
//  PPMController.m
//  PPMReader
//
//  Created by Kevin Wojniak on 8/29/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "PPMController.h"

@implementation PPMController

- (NSImage *)imageWithContentsOfPPMFile:(NSString *)path
{
	NSData *data = [NSData dataWithContentsOfFile:path];
	if (data == nil)
		return nil;
	const char *bytes = [data bytes];
	
	NSString *type = nil;
	int width = -1, height = -1;
	int maxRGBValue = -1;
	int pos = 0;
	
	/* read in the header items */
	while (maxRGBValue == -1)
	{
		char c;
		NSMutableString *line = [NSMutableString string];
		
		c = bytes[pos];
		while (c != '\r' && c != '\n')
		{
			[line appendFormat:@"%c", c];
			
			pos++;
			c = bytes[pos];
		}
		
		pos++;
		
		if ([line length] && [line characterAtIndex:0] != '#')
		{
			if (type == nil)
			{
				type = line;
			}
			else if ([line rangeOfString:@" "].location != NSNotFound)
			{
				NSArray *wh = [line componentsSeparatedByString:@" "];
				width = [[wh objectAtIndex:0] intValue];
				height = [[wh objectAtIndex:1] intValue];
			}
			else
			{
				if (width != -1 && height != -1 && maxRGBValue == -1)
					maxRGBValue = [line intValue];
			}
		}
	}
	
	if (type && [type isEqualToString:@"P6"])
	{
		NSBitmapImageRep *bmp = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
																		pixelsWide:width
																		pixelsHigh:height
																	 bitsPerSample:8
																   samplesPerPixel:3
																		  hasAlpha:NO
																		  isPlanar:NO
																	 colorSpaceName:NSCalibratedRGBColorSpace
																		bytesPerRow:width * 3
																	   bitsPerPixel:24] autorelease];
		
		unsigned char *chars = [bmp bitmapData];
		int i, t, start = pos;
		t = width*height*3;
		
		for (i=0; i<t; i++)
			chars[i] = bytes[i + start];
		
		if (bmp)
		{
			NSImage *img = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
			[img addRepresentation:bmp];
			return [img autorelease];
		}
	}
	
	return nil;
}

- (IBAction)go:(id)sender
{
	NSString *path = [textField stringValue];
	NSImage *img = [self imageWithContentsOfPPMFile:path];
	if (img)
		[imageView setImage:img];
}

@end
