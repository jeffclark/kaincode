//
//  KWMultiValueTextField.h
//  KWMultiValueTextField
//
//  Created by Kevin Wojniak on 12/31/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KWMultiValueTextField : NSTextField
{
	NSArray *_stringValues;
	int _valueIndex;
}

- (void)setStringValues:(NSArray *)stringValues;

@end
