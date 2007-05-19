//
//  TSEarnings.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TSInfoController.h"
#import "TSProject.h"

@implementation TSInfoController

- (id)init
{
	if (self = [super initWithWindowNibName:@"ProjectInfo" owner:self])
	{
		_project = nil;
		
	}
	
	return self;
}

- (void)dealloc
{
	_project = nil;
	[super dealloc];
}

- (void)setProject:(TSProject *)project
{
	// weak link
	_project = project;

	[nameField setStringValue:[_project name]];
	[rateField setFloatValue:[_project rate]];
	[taxField setFloatValue:[_project tax]];
}

- (IBAction)close:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:[rateField floatValue]] forKey:@"TSDefaultRate"];
	
	[_project setName:[nameField stringValue]];
	[_project setRate:[rateField floatValue]];
	[_project setTax:[taxField floatValue]];
	[NSApp endSheet:[self window]];
	[self close];
}

@end
