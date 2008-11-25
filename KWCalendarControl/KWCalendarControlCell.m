//
//  KWCalendarControlCell.m
//  KWCalendarControl
//
//  Created by Kevin Wojniak on 2/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KWCalendarControlCell.h"


const float KWCalendarControlWidth					= 178.0;	// width of the control
const float KWCalendarControlHeight					= 188.0;	// height of the control
const unsigned char KWCalendarControlRows			= 6;		// number of rows
const unsigned char KWCalendarControlColumns		= 7;		// number of columns
const float KWCalendarControlHeaderHeight			= 36.0;		// height of header area
//const unsigned char KWCalendarControlCellWidth		= 26;
//const unsigned char KWCalendarControlCellHeight		= 25;


@implementation KWCalendarControlCell

@synthesize selectedDate = m_selectedDate;
@synthesize activeMonthComponents = m_activeMonthComponents;
@synthesize backgroundColor = m_backgroundColor;
@synthesize borderColor = m_borderColor;
@synthesize gridColor = m_gridColor;
@synthesize gridShadowColor = m_gridShadowColor;
@synthesize textColor = m_textColor;
@synthesize textShadowColor = m_textShadowColor;
@synthesize headerGradient = m_headerGradient;
@synthesize dateFormatter = m_dateFormatter;
@synthesize inactiveTextColor = m_inactiveTextColor;


- (void)setupCellDefaultAppearance
{
	// setup colors based on iCal 3.0
	self.backgroundColor = [NSColor colorWithCalibratedRed:204.0/255.0
													 green:213.0/255.0
													  blue:221.0/255.0
													 alpha:1.0];
	self.borderColor = [NSColor colorWithDeviceWhite:165.0/255.0 alpha:1.0];
	[self setBordered:YES];	
	self.gridColor = [NSColor colorWithCalibratedRed:170.0/255.0
											   green:186.0/255.0
												blue:203.0/255.0
											   alpha:1.0];
	self.gridShadowColor = [NSColor colorWithCalibratedRed:232.0/255.0
												green:236.0/255.0
												 blue:241.0/255.0
												alpha:1.0];
	self.textColor = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
	self.textShadowColor = [NSColor colorWithDeviceWhite:1.0 alpha:1.0];

	NSColor *start = [NSColor colorWithCalibratedRed:233.0/255.0 green:237.0/255.0 blue:242.0/255.0 alpha:1.0];
	NSGradient *grad = [[[NSGradient alloc] initWithStartingColor:self.backgroundColor endingColor:start] autorelease];
	self.headerGradient = grad;
	
	self.inactiveTextColor = [NSColor colorWithDeviceWhite:0.65 alpha:1.0];
}

- (id)init
{
	if (self = [super init])
	{
		self.selectedDate = [NSDate date];
		self.activeMonthComponents = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit|NSYearCalendarUnit
																	 fromDate:self.selectedDate];
		
		NSDateFormatter *dm = [[[NSDateFormatter alloc] init] autorelease];
		self.dateFormatter = dm;
		
		[self setupCellDefaultAppearance];
	}
	
	return self;
}

- (void)dealloc
{
	self.selectedDate = nil;
	self.activeMonthComponents = nil;
	self.dateFormatter = nil;
	self.backgroundColor = nil;
	self.borderColor = nil;
	self.gridColor = nil;
	self.gridShadowColor = nil;
	self.textColor = nil;
	self.textShadowColor = nil;
	self.headerGradient = nil;
	self.inactiveTextColor = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (void)drawMonthYearInFrame:(NSRect)frame
{
	NSFont *font = [[NSFontManager sharedFontManager] fontWithFamily:@"Helvetica" traits:0 weight:9 size:13.0];
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowColor:self.textShadowColor];
	[shadow setShadowBlurRadius:0.0];
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   font,			NSFontAttributeName,
						   self.textColor,	NSForegroundColorAttributeName,
						   shadow,			NSShadowAttributeName,
						   nil];
	NSInteger month = [self.activeMonthComponents month];
	NSInteger year = [self.activeMonthComponents year];
	NSArray *monthsSymbols = [self.dateFormatter monthSymbols];
	NSString *monthYearString = [NSString stringWithFormat:@"%@ %d", [monthsSymbols objectAtIndex:month-1], year];
	//NSString *monthYearString = [self.selectedDate descriptionWithCalendarFormat:@"%B %Y" timeZone:nil locale:nil];
	NSAttributedString *string = [[NSAttributedString alloc] initWithString:monthYearString attributes:attrs];
	NSRect stringRect;
	stringRect.size = [string size];
	stringRect.origin = NSMakePoint(NSMinX(frame) + (NSWidth(frame) - NSWidth(stringRect))/2,
									NSMinY(frame) + (NSHeight(frame) - NSHeight(stringRect))/2);
	[string drawInRect:stringRect];
	[string release];
}

- (void)drawColumnHeadersInFrame:(NSRect)cellFrame
{
	float cellWidth = (NSWidth(cellFrame) / KWCalendarControlColumns);
	
	NSArray *daySymbols = [self.dateFormatter shortWeekdaySymbols];
	NSEnumerator *symsEnum = [daySymbols objectEnumerator];
	NSString *sym = nil;
	
	NSFont *font = [[NSFontManager sharedFontManager] fontWithFamily:@"Helvetica" traits:0 weight:9 size:9.0];
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowColor:self.textShadowColor];
	[shadow setShadowBlurRadius:0.0];
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
						   font,			NSFontAttributeName,
						   self.textColor,	NSForegroundColorAttributeName,
						   shadow,			NSShadowAttributeName,
						   nil];
	
	NSRect textRect = NSMakeRect(NSMinX(cellFrame), NSMinY(cellFrame), cellWidth, NSHeight(cellFrame));
	while (sym = [symsEnum nextObject])
	{
		NSAttributedString *string = [[NSAttributedString alloc] initWithString:sym attributes:attrs];
		NSRect stringRect;
		stringRect.size = [string size];
		stringRect.origin = NSMakePoint(NSMinX(textRect) + (NSWidth(textRect) - NSWidth(stringRect))/2 + 1.0,
										NSMinY(textRect) + (NSHeight(textRect) - NSHeight(stringRect))/2 + 1.0);
		[string drawInRect:stringRect];
		[string release];
		
		textRect.origin.x += cellWidth;
	}
}

- (void)drawHeaderInFrame:(NSRect)cellFrame
{
	NSRect bounds = cellFrame;
	
	NSRect dayMonthRect = bounds;
	float part = NSHeight(dayMonthRect) / 3.0;
	dayMonthRect.size.height -= part;
	dayMonthRect.origin.y += part;
	
	NSRect colHeadersRect = bounds;
	colHeadersRect.size.height = part;

	[self.headerGradient drawInRect:bounds angle:90.0];
	
	[self drawMonthYearInFrame:dayMonthRect];
	[self drawColumnHeadersInFrame:colHeadersRect];
}

- (void)drawRowsAndColumnsInFrame:(NSRect)cellFrame
{
	float cellWidth = (NSWidth(cellFrame) / KWCalendarControlColumns);
	float cellHeight = (NSHeight(cellFrame) / KWCalendarControlRows);
	NSRect cellRect = NSMakeRect(NSMinX(cellFrame), NSMaxY(cellFrame) - cellHeight,
								 cellWidth, cellHeight);
	int x, y;
	int day = 0;
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	int selectedDateMonth = [self.activeMonthComponents month];
	NSDateComponents *firstDayComps = [[[NSDateComponents alloc] init] autorelease];
	[firstDayComps setDay:1];
	[firstDayComps setMonth:selectedDateMonth];
	[firstDayComps setYear:[self.activeMonthComponents year]];
	NSDate *firstDateOfMonth = [cal dateFromComponents:firstDayComps];
	int weekday = [[cal components:NSWeekdayCalendarUnit fromDate:firstDateOfMonth] weekday];
	NSTimeInterval oneDay = 3600.0 * 24;
	NSDate *cellDate = [firstDateOfMonth addTimeInterval:-((weekday-1) * oneDay)];
	
	NSDateComponents *todayComponents = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
												fromDate:[NSDate date]];
	
	NSFont *font = [[NSFontManager sharedFontManager] fontWithFamily:@"Helvetica" traits:0 weight:9 size:14.0];
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
	[shadow setShadowColor:self.textShadowColor];
	[shadow setShadowBlurRadius:0.0];
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  font,			NSFontAttributeName,
								  self.textColor,	NSForegroundColorAttributeName,
								  shadow,			NSShadowAttributeName,
								  nil];
	
	for (y=0; y<KWCalendarControlRows; y++)
	{
		cellRect.origin.x = NSMinX(cellFrame);
		
		for (x=0; x<KWCalendarControlColumns; x++)
		{
			BOOL onMonthCell = NO;
			NSDateComponents *cellComponents = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
													   fromDate:cellDate];
			int cellMonth = [cellComponents month];
			int cellDay = [cellComponents day];
			onMonthCell = (cellMonth == selectedDateMonth);
			BOOL onToday = ((cellMonth == [todayComponents month]) &&
							(cellDay == [todayComponents day]) &&
							([cellComponents year] == [todayComponents year]));
			
			if (onToday && onMonthCell)
			{
				NSColor *cellBGColor = nil;
				NSColor *cellBGColor2 = nil;
				cellBGColor = [NSColor colorWithDeviceRed:43.0/255.0 green:55.0/255.0 blue:73.0/255.0 alpha:1.0];
				cellBGColor2 = [NSColor colorWithDeviceRed:109.0/255.0 green:137.0/255.0 blue:182.0/255.0 alpha:1.0];
				[attrs setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
				[[attrs objectForKey:NSShadowAttributeName] setShadowColor:cellBGColor];

				NSRect cellColorRect = cellRect;
				cellColorRect.origin.y = floor(cellColorRect.origin.y);
				NSGradient *grad = [[NSGradient alloc] initWithStartingColor:cellBGColor2 endingColor:cellBGColor];
				[grad drawInRect:cellColorRect angle:90.0];
				[grad release];
			}
			else
			{
				[[attrs objectForKey:NSShadowAttributeName] setShadowColor:self.textShadowColor];
				if (onMonthCell)
					[attrs setObject:self.textColor forKey:NSForegroundColorAttributeName];
				else
					[attrs setObject:self.inactiveTextColor forKey:NSForegroundColorAttributeName];
			}
			
			NSString *cellStr = [NSString stringWithFormat:@"%d", cellDay];
			NSAttributedString *string = [[NSAttributedString alloc] initWithString:cellStr attributes:attrs];
			NSRect stringRect;
			stringRect.size = [string size];
			stringRect.origin = NSMakePoint(NSMinX(cellRect) + (NSWidth(cellRect) - NSWidth(stringRect))/2,
											NSMinY(cellRect) + (NSHeight(cellRect) - NSHeight(stringRect))/2);
			[string drawInRect:stringRect];
			[string release];
			
			
			cellDate = [cellDate addTimeInterval:oneDay];
			cellRect.origin.x += cellWidth;
			day++;
		}
		
		cellRect.origin.y -= cellHeight;
	}
}

- (void)drawGridInFrame:(NSRect)cellFrame
{
	float cellWidth = (NSWidth(cellFrame) / KWCalendarControlColumns);
	float cellHeight = (NSHeight(cellFrame) / KWCalendarControlRows);
	float r, c;
	int i;
	
	NSBezierPath *bz = [NSBezierPath bezierPath];
	
	// vertical lines
	c = cellWidth;
	for (i=0; i<KWCalendarControlColumns; i++)
	{
		[bz moveToPoint:NSMakePoint(floor(c)+0.5, NSMaxY(cellFrame))];
		[bz lineToPoint:NSMakePoint(floor(c)+0.5, NSMinY(cellFrame))];
		c += cellWidth;
	}

	// horizontal lines
	r = NSMaxY(cellFrame);
	for (i=0; i<KWCalendarControlRows; i++)
	{
		[bz moveToPoint:NSMakePoint(NSMinX(cellFrame), floor(r)+0.5)];
		[bz lineToPoint:NSMakePoint(NSMaxX(cellFrame), floor(r)+0.5)];
		r -= cellHeight;
	}
	
	[self.gridColor set];
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:self.gridShadowColor];
	[shadow setShadowBlurRadius:0.0];
	[shadow setShadowOffset:NSMakeSize(1.0, -1.0)];
	[shadow set];

	[bz closePath];
	[bz setLineWidth:1.0];
	[bz stroke];
	
	[shadow release];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect bounds = cellFrame;

	// draw background color
	[self.backgroundColor set];
	[NSBezierPath fillRect:bounds];
	
	// calculate and draw header
	NSRect headerRect = bounds;
	headerRect.origin.y = (NSMaxY(bounds) - KWCalendarControlHeaderHeight);
	headerRect.size.height = KWCalendarControlHeaderHeight;
	[self drawHeaderInFrame:headerRect];
	
	// calculate and draw rows and columns
	NSRect daysRect = bounds;
	daysRect.size.height -= NSHeight(headerRect);
	[self drawGridInFrame:daysRect];
	[self drawRowsAndColumnsInFrame:daysRect];

	// draw border
	if ([self isBordered]) // from NSActionCell
	{
		[self.borderColor set];
		[NSBezierPath strokeRect:NSInsetRect(bounds, 0.5, 0.5)/*bounds*/];
	}
}

#pragma mark -
#pragma mark Events

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
	
	
	return NO;
}

#pragma mark -
#pragma mark Actions

- (void)goToNextMonth
{
	NSInteger month = [self.activeMonthComponents month];
	NSInteger year = [self.activeMonthComponents year];
	if (month == 12)
	{
		month = 1;
		year++;
	}
	else
	{
		month++;
	}
	
	[self.activeMonthComponents setMonth:month];
	[self.activeMonthComponents setYear:year];
}

- (void)goToPreviousMonth
{
	NSInteger month = [self.activeMonthComponents month];
	NSInteger year = [self.activeMonthComponents year];
	if (month == 1)
	{
		month = 12;
		year--;
	}
	else
	{
		month--;
	}
	
	[self.activeMonthComponents setMonth:month];
	[self.activeMonthComponents setYear:year];
}

@end
