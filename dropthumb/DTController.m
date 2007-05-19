//
//  DTController.m
//  DropThumb
//
//  Created by Kevin Wojniak on 7/18/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "DTController.h"
#import <QTKit/QTKit.h>
#import <PDFKit/PDFKit.h>
#import <WebKit/WebKit.h>

@interface DTController (private)

- (BOOL)setThumbForFile:(NSString *)filePath;
- (NSImage *)imageForFile:(NSString *)filePath;

@end


@implementation DTController

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	NSEnumerator *filesEnumerator = [filenames objectEnumerator];
	NSString *file;
	while (file = [filesEnumerator nextObject])
	{
		[self setThumbForFile:file];
	}
}

- (BOOL)setThumbForFile:(NSString *)filePath
{
	NSImage *imageForFile = [self imageForFile:filePath];
	if (imageForFile)
		return [[NSWorkspace sharedWorkspace] setIcon:imageForFile forFile:filePath options:0];

	return NO;
}

- (NSImage *)imageForFile:(NSString *)filePath
{
	NSString *fileExtension = [[filePath pathExtension] lowercaseString];
	
	// webpage
	if ([fileExtension isEqualToString:@"htm"] || [fileExtension isEqualToString:@"html"])
	{
		NSBitmapImageRep *bitmap = nil;
		NSImage *image = nil;
		
		WebView *webView = [[[WebView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100) frameName:nil groupName:nil] autorelease];
		[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
		
		[webView lockFocus];
		bitmap = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:[webView frame]] autorelease];
		[webView unlockFocus];
		
		image = [[[NSImage alloc] initWithData:[bitmap TIFFRepresentation]] autorelease];
		return image;
	}
	
	// PDF
	if ([fileExtension isEqualToString:@"pdf"])
	{
		PDFDocument *pdfDoc = [[[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:filePath]] autorelease];
		if (pdfDoc && ![pdfDoc isEncrypted] && ![pdfDoc isLocked] && [pdfDoc pageCount] > 0)
		{
			PDFPage *page = [pdfDoc pageAtIndex:0];
			if (page)
			{
				NSData *rep = [page dataRepresentation];
				if (rep)
				{
					NSImage *img = [[NSImage alloc] initWithData:rep];
					if (img)
						return img;
				}
			}
		}
	}
	
	// image
	NSArray *imageTypes = [NSImage imageFileTypes];
	if ([imageTypes containsObject:[filePath pathExtension]])
	{
		NSImage *fileImage = [[[NSImage alloc] initWithContentsOfFile:filePath] autorelease];
		if (fileImage)
			return fileImage;
	}
	
	// movie
	if ([QTMovie canInitWithFile:filePath])
	{
		QTMovie *qtMovie = [QTMovie movieWithFile:filePath error:nil];
		if (qtMovie)
		{
			QTTime newTime = QTMakeTime([qtMovie duration].timeValue / 4, [qtMovie currentTime].timeScale);
			NSImage *someFrame = [qtMovie frameImageAtTime:newTime];
			if (someFrame)
				return someFrame;
		}
	}
	
	return nil;
}

@end
