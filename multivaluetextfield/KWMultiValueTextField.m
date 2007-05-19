//
//  KWMultiValueTextField.m
//  KWMultiValueTextField
//
//  Created by Kevin Wojniak on 12/31/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "KWMultiValueTextField.h"


@implementation KWMultiValueTextField

- (void)dealloc
{
	[_stringValues release];
	[super dealloc];
}

- (void)displayNextValue
{
	if (_valueIndex == [_stringValues count])
		_valueIndex = 0;
	NSString *value = [_stringValues objectAtIndex:_valueIndex++];
	[self setStringValue:value];
}

- (void)setStringValues:(NSArray *)stringValues
{
	if (_stringValues != stringValues)
	{
		[_stringValues release];
		_stringValues = [stringValues copy];
	}
	_valueIndex = 0;
	[self displayNextValue];
}

- (void)mouseDown:(NSEvent *)event
{
	if (_stringValues)
		[self displayNextValue];
}

@end
