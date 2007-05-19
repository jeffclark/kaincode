//
//  TSProjectController.m
//  Timeous
//
//  Created by Kevin Wojniak on 7/18/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TSProjectController.h"
#import "TSProject.h"
#import "TSPeriodDay.h"
#import "TSPeriod.h"
#import "ImageAndTextCell.h"

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <IOKit/IOKitLib.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#import "NSStringXtras.h"


@interface NSCalendarDate (TSFormats)
- (NSString *)timeDescription;
- (NSString *)dateDescription;
@end
@implementation NSCalendarDate (TSFormats)
- (NSString *)timeDescription
{
	return [self descriptionWithCalendarFormat:@"%I:%M:%S %p"];
}

- (NSString *)dateDescription
{
	return [self descriptionWithCalendarFormat:@"%A, %B %e"];
}
@end


@implementation TSProjectController

- (id)init
{
	if (self = [super init])
	{
		[self setProject:[[[TSProject alloc] init] autorelease]];
		
		[[self project] setRate:[[NSUserDefaults standardUserDefaults] floatForKey:@"TSDefaultRate"]];
		
		_objectController = [[NSObjectController alloc] initWithContent:self];
		_icon = nil;
		
		[NSBundle loadNibNamed:@"ProjectView" owner:self];
	}
	
	return self;
}

- (void)dealloc
{
	[_project release];
	[_periodTimer release];
	
	[_objectController release];
	[_icon release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	NSTableColumn *tc = [periodsOutlineView tableColumnWithIdentifier:@"Start"];
	ImageAndTextCell *cell = [[[ImageAndTextCell alloc] init] autorelease];
	[cell setFont:[[tc dataCell] font]];
	[tc setDataCell:cell];
}	

- (TSProject *)project
{
	return _project;
}

- (void)setProject:(TSProject *)project
{
	if (_project != project)
	{
		[_project release];
		_project = [project retain];
	}

	[periodsOutlineView setAutosaveName:[NSString stringWithFormat:@"TSPeriodsColumns %d", [project uid]]];
	[periodsOutlineView setAutosaveTableColumns:YES];
}

- (NSOutlineView *)periodsOutlineView
{
	return periodsOutlineView;
}

- (void)setupGUI
{
	[periodsOutlineView reloadData];
	[self updateEarningsField];

	// expand last item..
	int c = [[_project days] count];
	if (c > 0)
		[periodsOutlineView expandItem:[[_project days] objectAtIndex:c-1]];
}

- (NSView *)contentView
{
	return contentView;
}

- (NSOutlineView *)outlineView
{
	return periodsOutlineView;
}

- (int)objectCount
{
    return 0;//[[[self project] currentPeriod] totalSeconds];
}

- (void)setIcon:(NSImage *)icon
{
	if (_icon != icon)
	{
		[_icon release];
		_icon = [icon retain];
	}
}
- (NSImage *)icon
{
	return _icon;
}

- (NSObjectController *)controller
{
	return _objectController;
}

- (void)updateEarningsField
{
	[earningsField setStringValue:[NSString stringWithFormat:@"%@: %@",
		[NSString stringByFormattingSeconds:[_project totalSeconds]],
		[NSString stringByFormattingSeconds:[_project totalSeconds] atRate:[_project rate] withTax:[_project tax]]]];
}

/* 10^9 --  number of ns in a second */
#define NS_SECONDS 1000000000

- (uint64_t)idleTime
{
	uint64_t ret = 0;
	
	mach_port_t masterPort;
	io_iterator_t iter;
	io_registry_entry_t curObj;
	
	IOMasterPort(MACH_PORT_NULL, &masterPort);
	
	/* Get IOHIDSystem */
	IOServiceGetMatchingServices(masterPort,
								 IOServiceMatching("IOHIDSystem"),
								 &iter);
	if (iter == 0) {
		printf("Error accessing IOHIDSystem\n");
		exit(1);
	}
	
	curObj = IOIteratorNext(iter);
	
	if (curObj == 0) {
		printf("Iterator's empty!\n");
		exit(1);
	}
	
	CFMutableDictionaryRef properties = 0;
	CFTypeRef obj;
	
	if (IORegistryEntryCreateCFProperties(curObj, &properties,
										  kCFAllocatorDefault, 0) ==
		KERN_SUCCESS && properties != NULL) {
		
		obj = CFDictionaryGetValue(properties, CFSTR("HIDIdleTime"));
		CFRetain(obj);
	} else {
		printf("Couldn't grab properties of system\n");
		obj = NULL;
	}
	
	if (obj) {
		uint64_t tHandle;
		
		CFTypeID type = CFGetTypeID(obj);
		
		if (type == CFDataGetTypeID()) {
			CFDataGetBytes((CFDataRef) obj,
						   CFRangeMake(0, sizeof(tHandle)),
						   (UInt8*) &tHandle);
		}  else if (type == CFNumberGetTypeID()) {
			CFNumberGetValue((CFNumberRef)obj,
							 kCFNumberSInt64Type,
							 &tHandle);
		} else {
			printf("%d: unsupported type\n", (int)type);
			exit(1);
		}
		
		CFRelease(obj);
		
		// essentially divides by 10^9
		tHandle >>= 30;
		//printf("%qi\n", tHandle);
		ret = tHandle;
		goto funEnd;
	} else {
		printf("Can't find idle time\n");
	}
	
funEnd:
		
		/* Release our resources */
		IOObjectRelease(curObj);
	IOObjectRelease(iter);
	CFRelease((CFTypeRef)properties);
	
	return ret;
}

- (void)timerAction
{
	[[_project currentPeriod] setEnd:[NSCalendarDate calendarDate]];
	if ([periodsOutlineView editedRow] == -1)
		[periodsOutlineView reloadData];
	[self updateEarningsField];
	
	//[self saveData];
	
	//NSLog(@"idleTime: %qi", [self idleTime]);
}

- (void)startTimer
{
	[_periodTimer release];
	_periodTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5
													 target:self
												   selector:@selector(timerAction)
												   userInfo:nil
													repeats:YES] retain];
	[self timerAction]; // call immediately
}

- (void)stopTimer
{
	[_periodTimer invalidate];
	
	//[self saveData];
}

- (BOOL)timerIsActive
{
	return ([_periodTimer isValid]);
}

#pragma mark -

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == nil)
		return [[_project days] count];
	return [item numberOfItems];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	if (item == nil)
		return [[_project days] objectAtIndex:index];
	return [[(TSPeriodDay *)item periods] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return ([item isKindOfClass:[TSPeriodDay class]]);
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	NSString *identifier = [tableColumn identifier];
	if ([identifier isEqualToString:@"Start"])
	{
		if ([item isKindOfClass:[TSPeriodDay class]])
			return [[item start] dateDescription];
		return [[item start] timeDescription];
	}
	else if ([identifier isEqualToString:@"End"])
	{
		if ([item isKindOfClass:[TSPeriod class]])
			return [[item end] timeDescription];
	}
	else if ([identifier isEqualToString:@"Time"])
	{
		NSString *s = [NSString stringByFormattingSeconds:[item totalSeconds]];
		if ((TSPeriod *)item == [_project currentPeriod])
		{
			NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
				[[NSFontManager sharedFontManager] fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:13.0], NSFontAttributeName,
				nil];
			return [[[NSAttributedString alloc] initWithString:s attributes:attrs] autorelease];
		}
		else
			return s;
	}
	else if ([identifier isEqualToString:@"Notes"])
	{
		if ([item isKindOfClass:[TSPeriod class]])
			return [item notes];
	}
	
	return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	NSString *identifier = [tableColumn identifier];
	if ([identifier isEqualToString:@"Notes"])
		[item setNotes:object];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	return (![item isKindOfClass:[TSPeriodDay class]]);
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	if ([[tableColumn identifier] isEqualToString:@"Start"])
	{
		if ([item isKindOfClass:[TSPeriodDay class]])
			[cell setImage:[NSImage imageNamed:@"time"]];
		else
		{
			TSPeriod *per = (TSPeriod *)item;
			if (per == [_project currentPeriod])
				[cell setImage:[NSImage imageNamed:@"clock_red"]];
			else
				[cell setImage:[NSImage imageNamed:@"clock"]];
		}
	}
	else
		[cell setImage:nil];
}

@end
