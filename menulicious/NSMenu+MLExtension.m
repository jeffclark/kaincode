//
//  MLMenuSorter.m
//  Menulicious
//
//  Created by Kevin Wojniak on 5/14/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSMenu+MLExtension.h"

@implementation NSMenuItem (MLMenuSorter)

- (NSComparisonResult)compare:(id)menuItem
{
	return [[self title] caseInsensitiveCompare:[menuItem title]];
}

@end



@implementation NSMenu (MLMenuSorter)

- (void)sortItemsByTitle
{
	NSMutableArray *items = [NSMutableArray arrayWithArray:[self itemArray]];
	
	while ([self numberOfItems])
		[self removeItemAtIndex:0];
	
	[items sortUsingSelector:@selector(compare:)];
	
	while ([items count])
	{
		[self addItem:[items objectAtIndex:0]];
		[items removeObjectAtIndex:0];
	}
}

- (id)itemWithRepresentedString:(NSString *)str
{
	NSEnumerator *e = [[self itemArray] objectEnumerator];
	id i;
	NSString *newStr = [str lowercaseString];
	while (i = [e nextObject])
		if ([[[i representedObject] lowercaseString] isEqualToString:newStr])
			return i;
	return nil;
}

- (void)removeAllItems
{
	while ([self numberOfItems])
		[self removeItemAtIndex:0];
}

- (id <NSMenuItem>)addItemWithTitle:(NSString *)aString target:(id)aTarget action:(SEL)aSelector
{
	NSMenuItem *menuItem = [[[NSMenuItem alloc] initWithTitle:aString action:aSelector keyEquivalent:@""] autorelease];
	[menuItem setTarget:aTarget];
	[self addItem:menuItem];
	return menuItem;
}

@end
