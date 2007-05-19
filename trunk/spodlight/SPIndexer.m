//
//  SPIndexer.m
//  Spodlight
//
//  Created by Kevin Wojniak on 5/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SPIndexer.h"


@implementation SPIndexer

- (id)init
{
	if (self = [super initWithWindowNibName:@"Indexer" owner:self])
	{
	}
	
	return self;
}

- (void)awakeFromNib
{
	[progressIndicator setUsesThreadedAnimation:YES];
}

#pragma mark -

- (void)indexiPod:(SPiPod *)iPod
{
	NSTask *task = [[NSTask alloc] init];
	NSPipe *inPipe = [NSPipe pipe], *outPipe = [NSPipe pipe];
	NSFileHandle /**inHandle = [inPipe fileHandleForWriting],*/ *outHandle = [outPipe fileHandleForReading];
	
	[titleField setStringValue:[NSString stringWithFormat:@"Indexing %@...", [iPod name]]];
	[progressIndicator startAnimation:nil];
	
	[task setLaunchPath:@"/usr/bin/mdimport"];
	[task setArguments:[NSArray arrayWithObjects:@"-f", [iPod path], nil]];
	[task setStandardError:outPipe];
	[task setStandardOutput:outPipe];
	[task setStandardInput:inPipe];
	
	[task launch];
	[task waitUntilExit];
	
	NSData *data = [outHandle readDataToEndOfFile];
	if (data)
	{
		NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if (output)
		{
			NSLog(output);
			[output release];
		}
	}
	
	[task release];
	
	[progressIndicator stopAnimation:nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:@"SDiPodIndexed" object:iPod];
	
	[NSApp endSheet:[self window]];
	[self close];
}

@end
