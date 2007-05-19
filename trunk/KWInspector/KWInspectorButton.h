//
//  KWInspectorButton.h
//  KWInspector
//
//  Created by Kevin Wojniak on 1/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KWDisclosureButton;

@interface KWInspectorButton : NSView
{
	KWDisclosureButton *_disclosureButton;
	NSTextField *_textField, *_hotkey;
	
	id _target; SEL _action;
	NSView *_view;
}

- (void)setTarget:(id)anObject;
- (void)setAction:(SEL)aSelector;
- (BOOL)state;
- (void)setKeyEquivalent:(NSString *)charCode;
- (void)setKeyEquivalentModifierMask:(unsigned int)mask;
- (void)setStringValue:(NSString *)stringValue;

- (void)setView:(NSView *)view;
- (NSView *)view;

@end
