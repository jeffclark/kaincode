//
//  KWCalendarControlCell.h
//  KWCalendarControl
//
//  Created by Kevin Wojniak on 2/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KWCalendarControlCell : NSActionCell
{
	NSDate *m_selectedDate;

	NSDateComponents *m_activeMonthComponents;
	NSDateFormatter *m_dateFormatter;
	
	NSColor *m_backgroundColor;
	NSColor *m_borderColor;
	NSColor *m_gridColor;
	NSColor *m_gridShadowColor;
	NSColor *m_textColor;
	NSColor *m_textShadowColor;
	NSGradient *m_headerGradient;
	NSColor *m_inactiveTextColor;
}

@property (retain, readwrite) NSDate *selectedDate;

@property (retain, readwrite) NSDateComponents *activeMonthComponents;
@property (retain, readwrite) NSDateFormatter *dateFormatter;

@property (retain, readwrite) NSColor *backgroundColor;
@property (retain, readwrite) NSColor *borderColor;
@property (retain, readwrite) NSColor *gridColor;
@property (retain, readwrite) NSColor *gridShadowColor;
@property (retain, readwrite) NSColor *textColor;
@property (retain, readwrite) NSColor *textShadowColor;
@property (retain, readwrite) NSGradient *headerGradient;
@property (retain, readwrite) NSColor *inactiveTextColor;

- (void)goToNextMonth;
- (void)goToPreviousMonth;

@end
